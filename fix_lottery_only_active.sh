#!/bin/bash

echo "=== Розыгрыш только для активных подписчиков ==="

cat > /tmp/fix_lottery.py << 'EOF'
with open('/opt/bot/gamification.py', 'r') as f:
    content = f.read()

old = '''cursor = await db.execute('SELECT user_id, COALESCE(lottery_tickets, 0) FROM users WHERE COALESCE(lottery_tickets, 0) > 0')'''

new = '''cursor = await db.execute(
        "SELECT user_id, COALESCE(lottery_tickets, 0) FROM users WHERE COALESCE(lottery_tickets, 0) > 0 AND expire_date > ?",
        (datetime.now().isoformat(),)
    )'''

if old in content:
    content = content.replace(old, new)
    print("Заменено")
else:
    # Пробуем найти похожую строку
    import re
    match = re.search(r"cursor = await db\.execute\('SELECT user_id, COALESCE\(lottery_tickets, 0\) FROM users WHERE COALESCE\(lottery_tickets, 0\) > 0'\)", content)
    if match:
        content = content.replace(match.group(), new)
        print("Заменено (regex)")
    else:
        print("Не найдено, проверь gamification.py вручную")

with open('/opt/bot/gamification.py', 'w') as f:
    f.write(content)
print("gamification.py - OK")
EOF

python3 /tmp/fix_lottery.py

systemctl restart tradeall-bot
echo "=== Готово ==="
