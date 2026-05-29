cat > /opt/bot/stop_all.sh << 'EOF'
#!/bin/bash
echo "=== Stopping all bots ==="
systemctl stop tradeall-bot
systemctl stop tradeall-autoreply
echo "Done. All bots stopped."
EOF

chmod +x /opt/bot/stop_all.sh
