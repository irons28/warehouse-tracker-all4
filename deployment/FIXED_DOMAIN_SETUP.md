# Fixed Domain Setup (Cloudflare Tunnel)

This runbook configures a stable URL for Warehouse Tracker.

## Target URL
- `https://all4.collenlabs.uk`

## Prerequisites
- Domain is managed in Cloudflare DNS (`collenlabs.uk`).
- `cloudflared` installed on host machine.
- App runs locally on `http://127.0.0.1:3000`.

## 1) Authenticate Cloudflare CLI
```bash
cloudflared tunnel login
```

## 2) Create or verify tunnel
```bash
cloudflared tunnel list
cloudflared tunnel create wt-all4
```
If tunnel already exists, do not recreate.

## 3) Create config file
Create `~/.cloudflared/config.yml`:

```yaml
tunnel: 7b3014ac-4be0-4a4f-b599-c1f21765dd29
credentials-file: /Users/bencollen/.cloudflared/7b3014ac-4be0-4a4f-b599-c1f21765dd29.json
ingress:
  - hostname: all4.collenlabs.uk
    service: http://127.0.0.1:3000
  - service: http_status:404
```

## 4) Route DNS to tunnel
```bash
cloudflared tunnel route dns wt-all4 all4.collenlabs.uk
```

## 5) Start app (one-click)
```bash
cd /Users/bencollen/Documents/websites/warehouse-tracker-all4
./start-tracker.command
```

## 6) Validate
- Desktop: `https://localhost:3443` (or `http://localhost:3000`)
- Public/mobile: `https://all4.collenlabs.uk`

## Notes
- Fixed-domain config is machine-specific and is not committed to git.
- If URL fails after setup, wait 1-2 minutes for DNS propagation and retry.
- If startup fails, inspect logs:
  - `logs/server.log`
  - `logs/tunnel.log`
