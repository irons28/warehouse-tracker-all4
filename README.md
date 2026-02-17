# Warehouse Tracker (PWA SaaS)

Warehouse inventory tracker with QR scanning, mobile/tablet operations mode, audit attribution, invoices, and Google Sheets sync.

## Current production-ready capabilities

- Mobile-first PWA with dedicated operations UI
- QR check-in / check-out / move / partial unit removal
- Operator attribution (`scanned_by`) in shared no-login mode
- Tracker + invoices + activity timeline
- Auto Google Sheets sync (server-side schedule)
- Per-customer Google Sheets tab sync via `sync_all`

## Prerequisites

- Node.js 18+
- npm
- OpenSSL (for local HTTPS cert generation)

## 1) Install

```bash
cd /Users/bencollen/Documents/websites/warehouse-tracker
npm install
```

## 2) Configure environment

```bash
cp .env.example .env
```

Update `.env` values as needed.

Key variables:

- `PORT` (default `3000`)
- `HTTPS_PORT` (default `3443`)
- `TRUST_PROXY` (`1` behind reverse proxy)
- `WT_BOOTSTRAP_USER` / `WT_BOOTSTRAP_PASS` (used only if DB has no users)
- `WT_CORS_ORIGINS` (comma-separated allowlist for production)

## 3) Run preflight checks

```bash
npm run preflight:release
```

## 4) Start app

### Standard start

```bash
npm run start:prod
```

### PM2 start (recommended)

```bash
npm install -g pm2
pm2 start ecosystem.config.js
pm2 save
pm2 startup
```

## 5) Database safety

Create backup anytime:

```bash
npm run backup:db
```

## 6) Mobile access

### Local LAN

- HTTP: `http://<LAN-IP>:3000`
- HTTPS (self-signed): `https://<LAN-IP>:3443`

### Trusted HTTPS for iPhone PWA

Use tunnel for trusted cert:

```bash
npm run tunnel:cf
```

Open the printed `https://...trycloudflare.com` URL on phone.

## 7) Google Sheets integration

1. Open `GoogleAppScript.js`
2. Paste into Apps Script project (`Code.gs`)
3. Deploy as Web App (`Execute as Me`, access `Anyone`)
4. Put Web App URL in `server-settings.json` under `googleSheetsUrl`
5. Use app `Settings -> Test connection` then `Smart sync`

### Notes

- `sync_all` now updates per-customer tabs and `Daily_Storage` upserts.
- If Google Apps Script code changes, redeploy new Web App version.

## 8) Shared no-login operations mode

`server-settings.json` supports:

```json
{
  "authDisabled": 1
}
```

- `1` = shared no-login mode (operator name prompt for audit)
- `0` = account login mode

After any settings/code change, restart server.

## 9) Deployment checklist

- [ ] `.env` configured
- [ ] `npm run preflight:release` clean
- [ ] backup created (`npm run backup:db`)
- [ ] server restarted
- [ ] `/api/health` returns ok
- [ ] phone/tablet scan flow tested
- [ ] Google Sheets test + sync verified

---

For production hardening next:

- Reverse proxy (Caddy/Nginx) with real domain + TLS
- PM2 log rotation
- Off-box DB backups (cloud storage)
- Separate customer-facing reporting portal

## 10) Final production pass (reverse proxy + automated backups)

### Reverse proxy with real TLS

Use one of:

- Caddy template: `deployment/Caddyfile`
- Nginx template: `deployment/nginx.conf`

For reverse proxy deployments, set in `.env`:

```bash
TRUST_PROXY=1
WT_DISABLE_LOCAL_SSL=1
```

Then run app on `127.0.0.1:3000` behind proxy TLS.

### One-command deploy

```bash
npm run deploy:prod
```

This will:

1. install prod dependencies
2. run release preflight
3. start/reload with PM2 (or foreground fallback)

### Nightly DB backups

Run one backup now:

```bash
npm run backup:nightly
```

Install nightly cron (default 02:00):

```bash
npm run backup:install-cron
```

Optional remote backup targets in `.env`:

- `BACKUP_RCLONE_REMOTE=remote:path`
- `BACKUP_S3_URI=s3://bucket/path/`

Retention is controlled by:

- `BACKUP_RETENTION_DAYS` (default `30`)

## 11) Professional go-live controls (final pass)

Run operational smoke checks:

```bash
npm run ops:smoke
```

One-command release gate:

```bash
npm run ops:go-live
```

Read full checklist for each new customer deployment:

- `deployment/GO_LIVE_CHECKLIST.md`

## 12) Fixed domain (stable mobile URL)

For a permanent URL (not rotating quick tunnel links), set up Cloudflare Named Tunnel:

```bash
npm run tunnel:setup:fixed
```

Then start as normal:

```bash
./start-tracker.command
```

If `~/.cloudflared/config.yml` exists, the launcher automatically uses fixed-domain mode.

Guide:

- `deployment/FIXED_DOMAIN_CLOUDFLARE.md`
