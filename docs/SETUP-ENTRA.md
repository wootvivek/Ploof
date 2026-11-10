# Microsoft Entra app registration (owner task, one time)

This registers Ploof with Microsoft so people can sign in with personal Outlook.com accounts.
**Agents: you can't do this. Don't ask for the client secret; the owner puts it in `service/.env`.**

Use a **personal** Microsoft account and a **personal** directory — not a work/company tenant, so the
registration belongs to the owner.

## A. Get a directory (once)
1. Sign up at **azure.microsoft.com/free** with a personal Microsoft account (creates a "Default Directory").
   App registrations are free.
2. In **entra.microsoft.com**, confirm the directory (profile picture → Switch directory) is the personal one.

## B. Register the app
1. **Applications → App registrations → + New registration**
2. Name: `Ploof`
3. Supported account types: **Personal Microsoft accounts only**
4. Redirect URI: platform **Web**, `http://localhost:8787/auth/callback`
5. **Register**, then copy the **Application (client) ID** from Overview → `MS_CLIENT_ID`.

## C. API permissions (Microsoft Graph → Delegated)
`openid`, `profile`, `email`, `offline_access`, `User.Read`, `Mail.ReadWrite`, `Mail.Send`, `MailboxSettings.ReadWrite`.
No admin consent needed (personal accounts consent at sign-in).

## D. Client secret
**Certificates & secrets → New client secret** → description `ploof-service-dev`, 180 days → copy the **Value**
(shown once) → `MS_CLIENT_SECRET`. Store it in a password manager. Rotate before it expires.

## E. Optional
- **Branding & properties:** upload the Ploof icon (`Ploof/Assets.xcassets/AppIcon.appiconset/icon-1024.png`).
- **Publisher verification** (later, before public launch): removes "unverified" from the consent screen.

## Putting the values in place
```bash
cd service
cp .env.example .env
# edit .env: MS_CLIENT_ID, MS_CLIENT_SECRET, and TOKEN_ENCRYPTION_KEY:
openssl rand -base64 32
```
`.env` is git-ignored. Never commit it, paste it in chat, or include it in screenshots.

## Later (when the service is hosted)
Add the production redirect URI, e.g. `https://api.<your-domain>/auth/callback`, under **Authentication → Web**,
and set `MS_REDIRECT_URI` / `PUBLIC_BASE_URL` accordingly.

## Troubleshooting
- No "App registrations" or access denied → wrong directory; re-check A.2.
- "Personal Microsoft accounts only" not available → choose it at creation; otherwise delete and re-register.
- Redirect URI rejected → platform must be **Web**, scheme `http`, host `localhost`.
