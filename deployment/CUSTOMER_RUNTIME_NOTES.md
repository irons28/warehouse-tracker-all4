# Customer Runtime Notes (ALL 4)

This repo contains customer-specific code/config only.
Runtime data stays on server and must not be committed.

Do not commit:
- `.env`
- `warehouse.db`
- `backups/`
- `logs/`
- SSL private keys/certs

## First-time setup on customer machine
1. Copy `.env.example` to `.env` and set production values.
2. Run `npm install`.
3. Run fixed tunnel setup: `npm run tunnel:setup:fixed`.
4. Set hostname to: `tracker.all4logistics.com`.
5. Start via `./start-tracker.command` (macOS) or `start-tracker.bat` (Windows).

## Data policy
- Keep one DB per customer deployment.
- Keep backups in that customer environment only.
- Share only exported reports, not DB files.
