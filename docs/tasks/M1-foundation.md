# M1 — Foundation: sign-in + real inbox

**Goal:** the owner opens Next Wave in the iOS simulator, taps "Sign in with Microsoft", signs in with a
personal Outlook.com account, and the **existing screens** show their **real mail**: read threads,
reply, archive, delete, flag, mark read/unread. No AI yet.

Read first: `AGENTS.md`, `docs/ARCHITECTURE.md` §1–3, `docs/DESIGN.md`.

**Out of scope for M1:** AI of any kind, webhooks/real-time sync, push notifications, attachments upload,
drafts sync, search, multiple accounts, hosting/deployment. Don't start these.

Sub-tasks 1–2 (service) and 3 (iOS refactor) are **independent** and can run in parallel.
4 needs 2. 5 needs 3 and 4. 6 is last.

---

## M1.1 — Service skeleton
**Branch:** `m1/service-skeleton`

Create `service/` per the layout in `docs/ARCHITECTURE.md` §2.
- `package.json` (type: module), TypeScript strict, ESLint, Vitest, `tsx` for dev.
- `src/config.ts`: parse and validate env with zod; fail fast with a clear message listing missing vars.
- `src/server.ts`: Fastify app with `GET /health` → `{ ok: true, version }`. Port from `PORT` (default **8787**).
- `docker-compose.yml`: Postgres 16 for local dev.
- Migrations (any small tool — e.g. `node-pg-migrate`) with tables: `users`, `ms_accounts`
  (user_id, ms_user_id, email, display_name, encrypted_refresh_token, token_updated_at), `sessions`
  (id, user_id, token_hash, created_at, last_used_at), `login_codes` (code_hash, user_id, expires_at, used_at),
  `oauth_states` (state, pkce_verifier, created_at).
- `.env.example` with every variable and a comment (values are placeholders):
  ```
  PORT=8787
  PUBLIC_BASE_URL=http://localhost:8787
  DATABASE_URL=postgres://nextwave:nextwave@localhost:5432/nextwave
  MS_CLIENT_ID=00000000-0000-0000-0000-000000000000
  MS_CLIENT_SECRET=replace-me
  MS_REDIRECT_URI=http://localhost:8787/auth/callback
  MS_AUTHORITY=https://login.microsoftonline.com/consumers
  TOKEN_ENCRYPTION_KEY=base64-32-bytes   # openssl rand -base64 32
  APP_CALLBACK_URL=nextwave://auth/done
  ```
- `service/README.md`: how to run (`docker compose up -d`, `npm run migrate`, `npm run dev`, `npm test`).

**Acceptance:** `npm test` passes; `curl localhost:8787/health` returns ok; starting without required env
prints which vars are missing; no secrets committed (`git grep -n "MS_CLIENT_SECRET=" -- ':!*.example'` finds nothing).

---

## M1.2 — Microsoft sign-in, token vault, Graph token endpoint
**Branch:** `m1/service-auth` (after M1.1)

Implement the flow in `docs/ARCHITECTURE.md` §3:
- `GET /auth/start` → create `state` + PKCE (S256) verifier, store in `oauth_states`, 302 to
  `{MS_AUTHORITY}/oauth2/v2.0/authorize` with `client_id`, `response_type=code`, `redirect_uri`,
  `response_mode=query`, `scope` (see ARCHITECTURE §3), `state`, `code_challenge`, `code_challenge_method=S256`,
  `prompt=select_account`.
- `GET /auth/callback` → validate and consume `state` (≤10 min old), exchange `code` at `/oauth2/v2.0/token`
  with the client secret + PKCE verifier, read the user's id/email/name (ID token claims or `GET /me`),
  upsert `users` + `ms_accounts`, **encrypt the refresh token with AES-256-GCM** (`TOKEN_ENCRYPTION_KEY`,
  random 12-byte IV, store iv+tag+ciphertext), create a one-time `login_code` (random, hashed, 2-minute expiry),
  302 to `APP_CALLBACK_URL?code=…`. On error, 302 to `APP_CALLBACK_URL?error=…` (short, no internals).
- `POST /auth/session { code }` → consume the login code, create a session with a random 32-byte token,
  store its SHA-256 hash, return `{ sessionToken, user: { email, displayName } }`.
- Auth middleware: `Authorization: Bearer <sessionToken>`.
- `GET /v1/graph-token` → refresh with Microsoft using the stored refresh token (store the rotated refresh
  token if Microsoft returns a new one), return `{ accessToken, expiresAt }`. Cache access tokens in memory
  until ~5 min before expiry. If refresh fails with `invalid_grant`, return 401 `{ error: "reauth_required" }`.
- `GET /v1/me` → `{ email, displayName }`.
- `POST /auth/signout` → delete the session; if no sessions remain for the user, delete the stored refresh token.

**Tests (Vitest, Microsoft endpoints mocked — no real network):** state mismatch rejected; expired state rejected;
login code is single-use and expires; token is stored encrypted (ciphertext ≠ plaintext, decrypts correctly);
graph-token refreshes and persists rotated refresh tokens; `invalid_grant` → 401 reauth_required; no tokens in logs.

**Acceptance:** tests pass; with the owner's real `.env`, opening `http://localhost:8787/auth/start` in a browser
completes Microsoft sign-in and ends on a `nextwave://auth/done?code=…` redirect (browser will say it can't open it — that's fine).

---

## M1.3 — iOS: `MailRepository` refactor (no behavior change)
**Branch:** `m1/ios-repository` (independent of service work)

- Add `NextWave/Data/MailRepository.swift`:
  ```swift
  protocol MailRepository: Sendable {
      func loadInbox() async throws -> [MailThread]          // all folders the UI needs; M1 may load inbox + archive + sent
      func loadThread(id: String) async throws -> MailThread
      func reply(threadID: String, body: String) async throws
      func send(to: String, subject: String, body: String) async throws
      func move(threadID: String, to folder: Folder) async throws
      func setFlag(threadID: String, flagged: Bool) async throws
      func setRead(threadID: String, read: Bool) async throws
  }
  ```
  (Adjust signatures if needed; keep it small.)
- `MockMailRepository` returns `MockThreads.all` and makes actions no-ops (the store already updates state optimistically).
- `NextWaveStore` takes a repository in its initializer; actions update local state **optimistically**, then call the
  repository; on failure, roll back and show a toast ("Couldn't archive. Try again.").
- Add `isLoading` / `loadError` state and pull-to-refresh on the Mail list (`.refreshable`).
- Commitments stay mock-only in M1 (keep `MockCommitments` when in mock mode; empty array in real mode — the existing
  empty states handle it).

**Acceptance:** app behaves exactly as `v0.1-ux` with mock data; build has zero new warnings; previews still work.

---

## M1.4 — iOS: sign-in and session
**Branch:** `m1/ios-signin` (after M1.2 merged or its API stable)

- `NextWave/Data/NextWaveAPI.swift`: base URL from a build setting / `Info.plist` key `NEXTWAVE_API_BASE_URL`
  (Debug default `http://localhost:8787`). Methods: `exchangeLoginCode`, `me`, `graphToken`, `signOut`.
  Add an App Transport Security exception for `localhost` in Debug only.
- Register URL scheme `nextwave` (Info.plist `CFBundleURLTypes` via build settings / generated Info.plist keys).
- Onboarding's "Sign in with Microsoft" button: `ASWebAuthenticationSession(url: {base}/auth/start,
  callbackURLScheme: "nextwave")` → parse `code` → `exchangeLoginCode` → store session token in the **Keychain**
  (small wrapper, no third-party libs) → enter the app.
- On launch: if a session exists, skip onboarding; if any call returns `reauth_required`, return to onboarding.
- Settings → Accounts shows the real email/name; add **Sign out**.
- Keep mock mode: launch argument `-useMockData YES` bypasses sign-in entirely (used for UI work and screenshots).

**Acceptance:** in the simulator with the service running locally, sign-in completes and lands on Today;
relaunching stays signed in; Sign out returns to onboarding; `-useMockData YES` still shows the prototype.

---

## M1.5 — iOS: `GraphMailRepository`
**Branch:** `m1/ios-graph` (after M1.3 and M1.4)

Call Graph v1.0 (`https://graph.microsoft.com/v1.0`) with the token from `GET /v1/graph-token`
(refresh it when it's within 5 min of expiry or on 401).
- **List:** `GET /me/mailFolders/{inbox|archive|sentitems}/messages?$top=50&$orderby=receivedDateTime desc&$select=id,conversationId,subject,from,toRecipients,ccRecipients,receivedDateTime,sentDateTime,isRead,flag,hasAttachments,bodyPreview,parentFolderId`.
  Group by `conversationId` into `MailThread`s (mapping rules in ARCHITECTURE §1).
- **Thread:** `GET /me/messages?$filter=conversationId eq '{id}'&$select=…,body` — sort by date **client-side**
  (Graph may reject `$orderby` combined with this filter). Convert HTML bodies to plain text for `Message.body` in M1.
- **Reply:** `POST /me/messages/{latestMessageId}/reply` with `{ "comment": "<text>" }`.
  **New:** `POST /me/sendMail`.
- **Move:** `POST /me/messages/{id}/move` `{ "destinationId": "archive" | "deleteditems" | "inbox" }` for every message in the thread.
- **Flag:** `PATCH /me/messages/{id}` `{ "flag": { "flagStatus": "flagged" | "notFlagged" } }` (latest message).
- **Read:** `PATCH /me/messages/{id}` `{ "isRead": true|false }` for every unread message in the thread.
- Handle 429/503 with `Retry-After` back-off; never log message content.
- **Placeholder triage (until M2 AI):**
  - Notifications — sender contains `noreply`, `no-reply`, `donotreply`, `notifications`, `newsletter`, or the user isn't in To/Cc.
  - Waiting — the latest message is from the user.
  - Needs you — latest message is from someone else and the user is in **To**.
  - Updates — everything else. `isImportant` = false for everything until M2.
  - `oneLiner` = latest `bodyPreview` (trimmed to ~140 chars); `stands` = "Outlook will summarize this once AI is on."
  - `suggestedReplies` = `[]`.

**Acceptance:** signed in with a real personal account, the Mail tab shows real threads across all four chips;
opening a thread shows real messages; reply, archive, delete, flag and read/unread all show up correctly in
Outlook.com on the web within a few seconds; pull-to-refresh works; airplane mode shows a friendly error, not a crash.

---

## M1.6 — End-to-end check and docs
**Branch:** `m1/verify`
- Run through the full checklist below in the simulator, light and dark mode; fix anything broken.
- Update `AGENTS.md` "Current status", `docs/ROADMAP.md` (M1 → Done), and the decisions log for any choices made.
- Tag the merge commit `v0.2-foundation`.

**Checklist:** fresh install → onboarding → sign in → Today renders (Needs you and Waiting show real mail as email cards; Updates is empty; no commitments yet) →
Mail chips each show threads → open thread → reply → appears in Outlook.com Sent → archive from list → gone from
inbox, present in Archive folder → flag/unflag → read/unread → relaunch stays signed in → sign out → onboarding →
`-useMockData YES` still shows the full prototype.
