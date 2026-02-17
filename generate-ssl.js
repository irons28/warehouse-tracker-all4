const { execSync } = require('child_process');
const fs = require('fs');
const os = require('os');
const path = require('path');

const sslDir = path.join(__dirname, 'ssl');
const keyPath = path.join(sslDir, 'key.pem');
const certPath = path.join(sslDir, 'cert.pem');
const opensslCfgPath = path.join(sslDir, 'openssl-san.cnf');

function collectLanIps() {
  const ips = new Set();
  const nics = os.networkInterfaces();
  for (const entries of Object.values(nics)) {
    for (const e of entries || []) {
      if (e.family === 'IPv4' && !e.internal && e.address) ips.add(e.address);
    }
  }
  return Array.from(ips);
}

function parseArgIp() {
  const idx = process.argv.indexOf('--ip');
  if (idx >= 0 && process.argv[idx + 1]) return String(process.argv[idx + 1]).trim();
  return '';
}

const explicitIp = parseArgIp();
const lanIps = collectLanIps();
if (explicitIp) lanIps.unshift(explicitIp);
const uniqueIps = Array.from(new Set(lanIps.filter(Boolean)));

if (!fs.existsSync(sslDir)) {
  fs.mkdirSync(sslDir, { recursive: true });
  console.log('Created ssl directory');
}

const sanLines = [
  'DNS.1 = localhost',
  'IP.1 = 127.0.0.1',
  ...uniqueIps.map((ip, i) => `IP.${i + 2} = ${ip}`),
].join('\n');

const opensslCfg = `[ req ]
default_bits       = 4096
distinguished_name = req_distinguished_name
x509_extensions    = v3_req
prompt             = no

[ req_distinguished_name ]
C  = US
ST = State
L  = City
O  = Warehouse
CN = localhost

[ v3_req ]
subjectAltName = @alt_names

[ alt_names ]
${sanLines}
`;

fs.writeFileSync(opensslCfgPath, opensslCfg, 'utf8');

console.log('\nGenerating SAN SSL certificates...\n');
console.log(`IPs included: ${uniqueIps.length ? uniqueIps.join(', ') : '(none found)'}`);

try {
  execSync(
    `openssl req -x509 -newkey rsa:4096 -keyout "${keyPath}" -out "${certPath}" -days 3650 -nodes -config "${opensslCfgPath}" -extensions v3_req`,
    { stdio: 'inherit' }
  );

  console.log('\nSSL certificates generated successfully');
  console.log(`key:  ${keyPath}`);
  console.log(`cert: ${certPath}`);
  console.log(`config: ${opensslCfgPath}`);
  console.log('\nNext: restart server and open https://<your-lan-ip>:3443 on phone.');
} catch (error) {
  console.error('\nError generating certificates. Ensure OpenSSL is installed.');
  process.exit(1);
}
