# Warehouse Tracker Go-Live Checklist

Use this checklist when deploying for ALL 4 LOGISTICS or any new logistics customer.

## 1) Stable hosting + fixed domain + TLS
- [ ] Deploy behind Caddy or Nginx using a real domain.
- [ ] Set `TRUST_PROXY=1` and `WT_DISABLE_LOCAL_SSL=1` in `.env`.
- [ ] Confirm HTTPS certificate is valid (no browser warning on phone).

## 2) Security hardening
- [ ] Set a strong bootstrap password in `.env` (`WT_BOOTSTRAP_PASS`).
- [ ] Confirm auth mode decision: `authDisabled` (`0` login mode, `1` shared mode).
- [ ] Keep production CORS allowlist in `WT_CORS_ORIGINS`.
- [ ] Tune rate limits as needed:
  - [ ] `WT_API_RATE_WINDOW_MS`
  - [ ] `WT_API_RATE_MAX`
  - [ ] `WT_LOGIN_RATE_WINDOW_MS`
  - [ ] `WT_LOGIN_RATE_MAX_ATTEMPTS`
  - [ ] `WT_LOGIN_BLOCK_MS`

## 3) Backups + restore confidence
- [ ] Run `npm run backup:db`.
- [ ] Run `npm run backup:nightly`.
- [ ] Verify backup files are present in `/backups`.
- [ ] Perform at least one restore test on a staging copy.

## 4) Monitoring + alerting
- [ ] Health endpoint responds: `/api/health`.
- [ ] Readiness endpoint responds: `/api/ready`.
- [ ] Run `npm run ops:smoke` after startup/deploy.
- [ ] Route logs to retained files (`logs/server.log`, `logs/tunnel.log`).

## 5) Release process + rollback
- [ ] Run `npm run preflight:release`.
- [ ] Run `npm run deploy:prod` (or PM2 equivalent).
- [ ] Keep previous working DB backup before each release.
- [ ] Keep previous app folder/tag for rollback.

## 6) Mobile QA on real devices
- [ ] Login/shared mode tested on iPhone and Android.
- [ ] Scan flow tested: check-in, check-out, move, remove units.
- [ ] Tracker search/filter and invoice views tested on phone/tablet.

## 7) Multi-company rollout readiness
- [ ] Configure branding (name/logo/accent) per company.
- [ ] Confirm Google Sheets sync and customer tab creation.
- [ ] Decide tenancy model per client:
  - [ ] Separate server+DB per customer (recommended to start)
  - [ ] Shared server multi-tenant (later phase)
