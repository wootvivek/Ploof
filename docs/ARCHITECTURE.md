# Outlook Next Wave — architecture

```
iPhone app (SwiftUI)  ──HTTPS──►  Next Wave service (TypeScript)  ──►  Microsoft Graph (personal accounts)
      │   ▲                              │      │
      │   └────── APNs push ◄────────────┘      └──►  Anthropic Claude API
      └──────── Graph (mail data, direct, with short-lived tokens from the service)
```

Status: only the **iOS app** exists (prototype on mock data). Everything about the service below is the
agreed design for M1+; build it as described unless the owner approves a change.

---

## 1. iOS app

### Today (prototype)
- `NextWaveStore` (`@Observable`, main actor) holds `threads: [MailThread]` and `commitments: [Commitment]`
  loaded from `MockThreads` / `MockCommitments`, plus UI state (selected tab, mail filter, toasts).
- Views read the store from the environment (`@Environment(NextWaveStore.self)`) and call its actions
  (`complete`, `snooze`, `dismiss`, `archive`, `delete`, `toggleFlag`, `toggleRead`, `markRead`, `send`).

### Target (M1+)
- Introduce a **`MailRepository` protocol** (list threads, load thread, send reply/new message, move,
  flag, mark read) with two implementations:
  - `MockMailRepository` — wraps today's mock data. Used when launched with `-useMockData YES`, in SwiftUI previews and UI tests.
  - `GraphMailRepository` — calls Microsoft Graph directly with an access token obtained from the service.
- Introduce a **`NextWaveAPI` client** for the service (auth session, Graph token, and later AI annotations).
- `NextWaveStore` depends on the protocols, not on mock data. Views don't change.
- Local cache: **SwiftData** for threads/messages/annotations (M1 may start with in-memory + refresh; SwiftData by end of M1).
- Sign-in: `ASWebAuthenticationSession` against the service (see §3). No MSAL, no third-party SDKs.

### Mapping Graph → app models
- `MailThread` = messages grouped by Graph `conversationId`; `MailThread.id` = conversationId.
- `Message.id` = Graph message `id`; `from` → `Person` (id = lowercased email address, hue derived from a hash of the address).
- `isUnread` = any message in the thread with `isRead == false`; `isFlagged` = `flag.flagStatus == "flagged"`;
  `hasAttachment` = `hasAttachments`; `folder` from `parentFolderId` mapped to well-known folders.
- Until the AI exists (M2), `bucket`, `oneLiner` and `stands` come from **placeholder heuristics** (see M1 spec);
  after M2 they come from the service's annotations, merged by conversationId.

---

## 2. Next Wave service (middle tier)

**Stack (proposed default — the owner may still change it; don't swap pieces on your own):** TypeScript on the
current Node.js LTS, **Fastify** HTTP server, **PostgreSQL**, **pg-boss** job queue (Postgres-backed), official
**Anthropic TypeScript SDK**, Vitest for tests, Docker Compose for local Postgres. Hosting is **not decided yet** —
keep it container-friendly and 12-factor (config only from env).

**Layout (to create in M1):**
```
service/
  src/
    server.ts            Fastify app, routes registration
    config.ts            env parsing/validation (zod)
    auth/                Microsoft OAuth (PKCE), sessions, token vault
    graph/               Graph client, subscriptions, delta sync
    pipeline/            intake, rules filter, triage, commitments (M2)
    db/                  migrations + queries
  test/
  .env.example
  docker-compose.yml
  package.json
```

### Responsibilities
1. **Auth broker + token vault** — runs the Microsoft OAuth flow, stores refresh tokens **encrypted**
   (AES-256-GCM, key from env in dev; a cloud KMS in production), issues Next Wave sessions, and vends
   short-lived Graph access tokens to the app.
2. **Mail intake** (M2) — Graph change notifications (webhook) per mailbox + periodic delta sync.
3. **AI pipeline** (M2/M3) — triage, one-liners, summaries, commitments, drafts, Ask.
4. **API for the app** — annotations, commitments, brief, Ask, feedback.
5. **Push** (M4) — APNs for Needs you mail and the morning brief.

### Data the service stores
- users, Microsoft account id, encrypted refresh token, Next Wave sessions
- Graph subscriptions, delta tokens
- per-thread annotations: bucket, one-liner, "where this stands", confidence
- commitments (+ evidence quote), user feedback/corrections
- **Not stored:** message bodies. They're fetched, processed in memory, and discarded.

---

## 3. Sign-in flow (M1)

Microsoft identity platform, **consumers** endpoint (`https://login.microsoftonline.com/consumers/oauth2/v2.0/…`),
authorization-code flow with PKCE, service as the confidential client (client secret).

```
App                         Service                                Microsoft
 │ ASWebAuthenticationSession  │                                       │
 │──── GET /auth/start ───────►│ create state + PKCE verifier          │
 │                             │──── 302 to /authorize ───────────────►│ user signs in, consents
 │                             │◄─── GET /auth/callback?code&state ────│
 │                             │ verify state, exchange code (+secret) │
 │                             │ encrypt+store refresh token           │
 │                             │ create one-time login code            │
 │◄── 302 nextwave://auth/done?code=… (closes the web sheet)             │
 │──── POST /auth/session {code} ─►│ returns Next Wave session token       │
 │ store session in Keychain   │                                       │
 │──── GET /v1/graph-token ───►│ refresh with Microsoft if needed      │
 │◄── { accessToken, expiresAt }│                                       │
 │──── Graph calls directly ───────────────────────────────────────────►│
```
- Scopes: `openid profile email offline_access User.Read Mail.ReadWrite Mail.Send MailboxSettings.ReadWrite`.
- Redirect URI registered in Entra (dev): `http://localhost:8787/auth/callback`. The iOS **simulator** reaches the
  Mac's `localhost`; a physical device needs the service on a reachable host (later).
- App callback scheme: `nextwave` (`nextwave://auth/done`), handled by `ASWebAuthenticationSession`'s `callbackURLScheme`.
- The Next Wave session token is opaque, random, stored hashed in the DB and in the iOS **Keychain** on device.
- Sign out: `POST /auth/signout` deletes the session (and, if last session, the stored refresh token).

---

## 4. AI pipeline (M2+) — how mail becomes buckets, one-liners and commitments

```
New mail ─► 1 Intake ─► 2 Rules filter ─► 3 Triage (fast model) ─► 4 Commitments (strong model, human threads only) ─► 5 Store + notify
```
1. **Intake.** Graph change notification → fetch message → attach to thread (conversationId) → enqueue.
   Delta sync catches anything missed. Strip quoted replies, signatures and disclaimers before any AI call.
2. **Rules filter (no AI).** `List-Unsubscribe` / list headers, `noreply@`-style senders, known receipt and
   shipping senders → **Notifications** with a template one-liner. Expect ~half of all mail to stop here.
3. **Triage (Claude, fast/cheap model, every remaining email).** Input: thread state (who wrote last, whether the
   user is To or Cc, unanswered questions to the user, deadlines, the user's replies). Output (structured JSON):
   `{ bucket, important, one_liner, stands, reason, confidence }`. Re-triage the whole thread on every new message.
   - Needs you = someone is asking *the user* for a reply/decision/action and the ball is in their court.
   - Waiting = the user wrote last, or someone owes the user something.
   - Updates = human-written, no action. Notifications = automated mail that passed the filter.
   - `important` (true/false) for Updates and Notifications: worth seeing today even though it needs no action
     (a date change, a decision, news about an open commitment, a missed call from a customer).
4. **Commitments (Claude, stronger model, human threads only).** Input: new message + thread + open commitments for the
   thread. Output: `{ new: [...], done: [ids], updated: [...] }`, each commitment with direction, person (email),
   title, **verbatim evidence**, due (ISO 8601 in the user's time zone), `due_basis`, confidence.
   - **Evidence must be an exact substring** of the message text, or the commitment is rejected (anti-hallucination).
   - Resolve relative dates against the **message's sent time** and the user's mailbox time zone; vague timing → no date.
   - Low-confidence commitments are hidden until the eval set says otherwise.
5. **Store + notify.** Save annotations/commitments; push to the app if bucket = Needs you (M4).

**Today's three lists are queries** (`NextWaveStore.todayItems(_:)`), one per tile:
- *Needs you* = your open commitments plus inbox threads in Needs you that have no commitment of yours.
- *Waiting* = other people's open commitments to you plus inbox threads in Waiting that have none.
- *Updates* = inbox threads in Updates or Notifications that triage marked **important**, unread first.

A thread drops off the first two once its commitment is done or snoozed. "Overdue" = past its due date;
"due today" = due date is today. A scheduled job refreshes overdue state.

**Feedback loop:** bucket changes, "not a commitment", snoozes are stored and used as per-user examples and sender
rules, and to grow the eval sets.

**Cost and speed:** rules filter first; fast model for triage; strong model only on human threads (~10–20% of
mail); prompt caching for the fixed instructions; the batch API for the first full-mailbox backfill.
Targets: triage within ~2 s of arrival; commitments within ~10 s.

**Evals (must exist before shipping AI to the UI):** `evals/` holds labeled emails/threads with expected
bucket and commitments, plus a script that reports triage accuracy and commitment precision/recall. Run it on every
prompt or model change.

---

## 5. Security and privacy checklist
- Refresh tokens encrypted at rest; encryption key never in git.
- Fewest Graph scopes needed (list in §3); no app-only/daemon permissions.
- No email content or tokens in logs; structured logs with IDs only.
- "Delete everything Next Wave has learned" endpoint (M3+).
- Privacy policy must disclose that short evidence quotes from emails are stored.
