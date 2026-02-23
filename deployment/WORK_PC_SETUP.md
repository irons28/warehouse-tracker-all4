# Work PC Setup (ALL4)

This is the exact setup for the Windows work computer.

## 1) Pull latest repo
```powershell
cd C:\warehouse-tracker-all4
git pull
npm install
```

## 2) Create Cloudflare folder
```powershell
mkdir "$env:USERPROFILE\.cloudflared" -Force
```

## 3) Place config.yml
Copy file from repo:
- `deployment/cloudflared-config.windows.all4.example.yml`

Save it as:
- `C:\Users\<WORK_PC_USER>\.cloudflared\config.yml`

Replace:
- `<WORK_PC_USER>` with the Windows username.

## 4) Ensure tunnel credentials JSON exists (required)
Required local file (not in git):
- `C:\Users\<WORK_PC_USER>\.cloudflared\7b3014ac-4be0-4a4f-b599-c1f21765dd29.json`

Notes:
- This file is created by Cloudflare auth/token flow.
- Do not commit this file to GitHub.

## 5) If JSON is missing, recreate it
```powershell
cloudflared tunnel login
cloudflared tunnel token wt-all4
```

## 6) Start tracker
```powershell
cd C:\warehouse-tracker-all4
start-tracker.bat
```

## 7) Validate
- Public URL: `https://all4.collenlabs.uk`
- Local URL: `https://localhost:3443`

## 8) Common fixes
- If tunnel errors repeatedly: close all terminals and run `start-tracker.bat` again.
- If login loops: hard refresh browser (Ctrl+F5).
- If app fails to start: check `C:\warehouse-tracker-all4\logs\server.log`.
- If tunnel fails: check `C:\warehouse-tracker-all4\logs\tunnel.log`.
