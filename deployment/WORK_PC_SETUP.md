# Work PC Setup (ALL4)

This is the exact setup for the Windows work computer.

## 1) Pull latest repo
```bat
cd C:\Users\User\Documents\warehouse-tracker-all4
git pull
npm install
```

## 2) Create Cloudflare folder
```bat
mkdir C:\Users\User\.cloudflared
```

## 3) Login and create tunnel credentials (on the work PC)
```bat
cloudflared tunnel login
cloudflared tunnel list
```

If `wt-all4` already exists, use it. If not:
```bat
cloudflared tunnel create wt-all4
```

## 4) Map DNS
```bat
cloudflared tunnel route dns wt-all4 all4.collenlabs.uk
```

## 5) Create `config.yml`
Save this file as:
`C:\Users\User\.cloudflared\config.yml`

Use the tunnel ID shown by `cloudflared tunnel list`:

```yml
tunnel: <TUNNEL_ID>
credentials-file: C:/Users/User/.cloudflared/<TUNNEL_ID>.json

ingress:
  - hostname: all4.collenlabs.uk
    service: https://127.0.0.1:3443
    originRequest:
      noTLSVerify: true
  - service: http_status:404
```

Important:
- Do not hand-edit the JSON credentials file.
- Do not commit `.cloudflared` files to GitHub.

## 6) Start tracker (one click)
Double-click:
`C:\Users\User\Documents\warehouse-tracker-all4\start-tracker.bat`

## 7) Validate
- Public URL: `https://all4.collenlabs.uk`
- Local URL: `https://localhost:3443`

## 8) Make it reliable for staff
1. Set PC to never sleep while plugged in:
```bat
powercfg /change standby-timeout-ac 0
powercfg /change monitor-timeout-ac 0
```

2. Put `start-tracker.bat` in Windows Startup folder:
```bat
mkdir "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup" 2>nul
copy /Y "C:\Users\User\Documents\warehouse-tracker-all4\start-tracker.bat" "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\start-tracker.bat"
```

3. Reboot once and verify two windows open automatically:
   - `WT Server`
   - `WT Tunnel`

4. Keep the work PC online during business hours.

## 9) Common fixes
- If cloud URL shows 502: restart with `start-tracker.bat`.
- If login loops: hard refresh browser (`Ctrl+F5`).
- If app fails to start: check `C:\Users\User\Documents\warehouse-tracker-all4\logs\server.log`.
- If tunnel fails: check `C:\Users\User\Documents\warehouse-tracker-all4\logs\tunnel.log`.
