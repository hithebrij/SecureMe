#!/bin/bash

# Linux Server Hardening Script (SecureMe v1.1)
# Updated: Includes Server Health + Vulnerability Scan

set -e

if [[ "$EUID" -ne 0 ]]; then
  echo "❌ Please run as root."
  exit 1
fi

NEW_USER="adminuser"
SSH_PORT="2222"

echo "🔐 Starting Linux Server Hardening..."

# 1. Create new user
adduser $NEW_USER
usermod -aG sudo $NEW_USER

# 2. Setup SSH key-based login
mkdir -p /home/$NEW_USER/.ssh
cp ~/.ssh/authorized_keys /home/$NEW_USER/.ssh/
chown -R $NEW_USER:$NEW_USER /home/$NEW_USER/.ssh
chmod 700 /home/$NEW_USER/.ssh
chmod 600 /home/$NEW_USER/.ssh/authorized_keys

# 3. SSH Config Hardening
sed -i 's/^#Port .*/Port '"$SSH_PORT"'/' /etc/ssh/sshd_config
sed -i 's/^#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart sshd

# 4. UFW Firewall Setup
apt update -y
apt install ufw -y
ufw default deny incoming
ufw default allow outgoing
ufw allow "$SSH_PORT"/tcp
ufw enable

# 5. Fail2Ban Setup
apt install fail2ban -y
systemctl enable fail2ban
systemctl start fail2ban

# 6. Unattended Security Updates
apt install unattended-upgrades -y
DPKG_NONINTERACTIVE_FRONTEND=1 dpkg-reconfigure --priority=low unattended-upgrades

echo "✅ Basic Hardening Complete"

# -----------------------------
# 🧠 SERVER HEALTH CHECK
# -----------------------------
echo "\n🔎 SERVER HEALTH CHECK"
echo "-----------------------------"
echo "🖥️  Hostname: $(hostname)"
echo "📅 Uptime: $(uptime -p)"
echo "📦 OS: $(lsb_release -d | cut -f2)"

echo "🧠 Memory Usage:"
free -h

echo "💾 Disk Usage:"
df -hT / | grep -v tmpfs

echo "🔥 CPU Load:"
uptime

echo "🔌 Active Services:"
systemctl list-units --type=service --state=running | head -10

# -----------------------------
# 🔐 VULNERABILITY SCAN
# -----------------------------
echo "\n🛡️ VULNERABILITY SCAN"
echo "-----------------------------"
echo "🟠 Open TCP ports:"
ss -tuln | grep LISTEN

echo "🔍 World-writable files (top 10):"
find / \( -path /proc -o -path /sys -o -path /dev \) -prune -o -type f -perm -0002 -print 2>/dev/null | head -10

echo "📦 Outdated Packages:"
apt list --upgradable 2>/dev/null | grep -v Listing | head -10

echo "🔐 Permission Check:"
ls -l /etc/passwd
ls -l /etc/shadow

# -----------------------------
echo "✅ Hardened and Audited Successfully!"
echo "ℹ️ SSH port is now set to $SSH_PORT"
echo "🧑 Login as $NEW_USER using your SSH key"
echo "🚨 IMPORTANT: Test new SSH login before closing your session!"
