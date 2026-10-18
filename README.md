# Forge — AI app builder

A Bolt-style app builder that runs entirely in the browser (one `index.html`, no build step).

- Describe an app or a 3D game in chat and get a live preview with desktop / tablet / phone sizes
- Download the complete project as a `.zip` (files, README, `package.json`, a standalone page, build log)
- Accounts with recovery code, admin panel, on/off switch for users
- API keys tab: add a key, Forge verifies it and lists only the models that key can really use
- Engines with credits and an automatic failover chain (when one runs out, the next takes over)
- Model search with filters, synced chats and projects

## Run it

Open `index.html` in a browser, or serve the folder:

```bash
npx serve .
```

## Publish with GitHub Pages

1. Push this repository to GitHub (see `publish.sh` / `publish.ps1`).
2. Repository → **Settings → Pages → Build and deployment → Deploy from a branch**.
3. Branch `main`, folder `/ (root)` → **Save**.
4. After about a minute the app is live at `https://<your-user>.github.io/<repo>/`.

GitHub Pages does not restrict network calls, so API keys are verified and engines run directly against the providers.

## API keys and security

- There is no server. Accounts, chats, projects and API keys are stored in the browser's `localStorage` (not encrypted). Do not use shared computers, and never commit keys to the repository.
- Keys are sent only to the provider you choose (or to your own proxy, if you set one).
- The admin on/off switch and user accounts apply to the browser they were created in. Real multi-user control needs a backend.
- The "built-in Claude" engine only exists inside the claude.ai viewer; elsewhere Forge uses your own API keys.

## Optional proxy

If some provider blocks browser calls (CORS) you can route requests through your own Cloudflare Worker:

```bash
cd proxy
# edit wrangler.toml: set ALLOWED_ORIGIN to your GitHub Pages origin
npx wrangler deploy
```

Then paste the Worker URL in **Dashboard → API keys → Backend proxy**. Do not use public CORS proxies: they would see your API keys.

## Files

| Path | Purpose |
| --- | --- |
| `index.html` | the whole app |
| `proxy/worker.js`, `proxy/wrangler.toml` | optional provider proxy |
| `publish.sh`, `publish.ps1` | helper scripts that create the Git repo and push it |
