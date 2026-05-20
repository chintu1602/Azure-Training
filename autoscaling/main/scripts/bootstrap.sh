#!/bin/bash
set -e

echo "Updating packages..."
sudo apt update -y

echo "Installing required packages..."
sudo apt install -y curl git nginx

# Install Node.js 20 LTS
echo "Installing Node.js 20 LTS..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

echo "Node Version:"
node -v
echo "NPM Version:"
npm -v

# Application directory
APP_DIR="/opt/organic-ghee"

echo "Preparing application directory..."
# Remove old app if exists (quoted to prevent catastrophic rm -rf / if var is empty)
sudo rm -rf "$APP_DIR"

cd /opt

echo "Cloning GitHub repository..."
sudo git clone https://github.com/chintu1602/organic-ghee.git

# Fix ownership so current user can run npm without sudo
sudo chown -R "$(whoami)":"$(whoami)" "$APP_DIR"

cd "$APP_DIR"

echo "Installing application dependencies..."
# Use npm ci for deterministic, lockfile-based installs (faster and safer for deployments)
if [ -f package-lock.json ]; then
  npm ci
else
  echo "Warning: No package-lock.json found, falling back to npm install"
  npm install
fi

# Kill existing application if running
echo "Stopping existing application..."
sudo fuser -k 5656/tcp || true

echo "Starting Node.js application..."
# Start application in background with explicit log path
nohup npm start > "$APP_DIR/app.log" 2>&1 &

# Wait for app to start with retry loop instead of fixed sleep
echo "Waiting for application to start..."
APP_STARTED=false
for i in {1..15}; do
  if sudo lsof -i :5656 > /dev/null 2>&1; then
    APP_STARTED=true
    break
  fi
  echo "  Attempt $i/15 — waiting 2s..."
  sleep 2
done

echo "Checking if application started successfully..."
if [ "$APP_STARTED" = true ]; then
  echo "Application is running on port 5656"
else
  echo "Application failed to start. Logs:"
  cat "$APP_DIR/app.log"
  exit 1
fi

echo "Configuring NGINX reverse proxy..."

# Write to sites-available first, then symlink (conventional nginx pattern)
sudo tee /etc/nginx/sites-available/organic-ghee > /dev/null <<EOF
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:5656;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

# Remove old default and symlink the new config
sudo rm -f /etc/nginx/sites-enabled/default
sudo ln -sf /etc/nginx/sites-available/organic-ghee /etc/nginx/sites-enabled/organic-ghee

echo "Testing NGINX configuration..."
sudo nginx -t

echo "Restarting NGINX..."
sudo systemctl restart nginx
sudo systemctl enable nginx

echo ""
echo "========================================"
echo "  Bootstrap completed successfully!"
echo "========================================"
echo "Application is running on port 5656"
echo "NGINX is proxying traffic on port 80"
echo "Logs: $APP_DIR/app.log"
echo ""
echo "Application accessible at:"
echo "  http://$(curl -s ifconfig.me 2>/dev/null || echo '<VM-PUBLIC-IP>')"
echo "========================================"