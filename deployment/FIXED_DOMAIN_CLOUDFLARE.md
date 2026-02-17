# Fixed Domain Setup (Cloudflare Named Tunnel)

This gives you a stable URL like `https://tracker.all4logistics.com` instead of changing `trycloudflare.com` links.

## Prerequisites
- Domain is managed in Cloudflare DNS.
- `cloudflared` installed on the host machine.
- App runs locally on `http://127.0.0.1:3000`.

## One-time setup
From project root:

```bash
npm run tunnel:setup:fixed
```

You will be prompted for:
- Tunnel name (example: `wt-all4`)
- Hostname (example: `tracker.all4logistics.com`)

This script will:
1. login cloudflared
2. create the named tunnel
3. write `~/.cloudflared/config.yml`
4. create DNS route for hostname

## Daily start
Use your existing one-click launcher:

- `start-tracker.command`

It now auto-detects `~/.cloudflared/config.yml` and uses fixed-domain tunnel mode.

## Manual tunnel start

```bash
npm run tunnel:fixed
```

## Verify
- Desktop: `https://localhost:3443`
- Mobile fixed URL: `https://<your-hostname>`

## Notes for new customer rollout
For each new logistics customer:
- Use a unique subdomain (`tracker.customer-domain.com`)
- Run `npm run tunnel:setup:fixed` on their host machine
- Keep separate DB/app folder per customer for clean isolation (recommended)
