#!/bin/bash
cat > /tmp/fix_indent.py << 'EOF'
with open('/opt/bot/handlers_user.py', 'r') as f:
    lines = f.readlines()

fixed = []
for line in lines:
    if line.startswith('db = await get_db()'):
        fixed.append('        db = await get_db()\n')
    elif line.startswith('cursor = await db.execute') and 'db = await get_db()' in ''.join(fixed[-3:]):
        fixed.append('            ' + line.lstrip())
    else:
        fixed.append(line)

with open('/opt/bot/handlers_user.py', 'w') as f:
    f.writelines(fixed)

print("handlers_user.py исправлен")
EOF

python3 /tmp/fix_indent.py
systemctl restart tradeall-bot
echo "Бот перезапущен"
