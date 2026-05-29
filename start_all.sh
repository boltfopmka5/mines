cat > /opt/bot/start_all.sh << 'EOF'
#!/bin/bash
echo "=== TradeAll Bot Manager ==="

declare -A bots
bots=(
    ["tradeall-bot"]="Main Bot"
    ["tradeall-autoreply"]="Auto Reply"
)

for service in "${!bots[@]}"; do
    name="${bots[$service]}"
    echo "[*] Starting $name..."
    systemctl start "$service"
    sleep 2
    if systemctl is-active --quiet "$service"; then
        echo "  ✅ $name: RUNNING"
    else
        echo "  ❌ $name: FAILED"
    fi
done

echo ""
echo "=== Status ==="
for service in "${!bots[@]}"; do
    name="${bots[$service]}"
    status=$(systemctl is-active "$service")
    echo "$name: $status"
done

echo ""
echo "Logs:"
echo "  journalctl -u tradeall-bot -f"
echo "  journalctl -u tradeall-autoreply -f"
EOF

chmod +x /opt/bot/start_all.sh
