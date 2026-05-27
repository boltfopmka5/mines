#!/bin/bash
cat > /tmp/fix_level.py << 'EOF'
with open('/opt/bot/handlers_user.py', 'r') as f:
    content = f.read()

old = '''@router.message(Command("level"))
async def cmd_level(message: types.Message):
    user_id = message.from_user.id
    db = await get_db()
    cursor = await db.execute('SELECT current_exp, total_exp, current_level FROM user_levels WHERE user_id = ?', (user_id,))
    row = await cursor.fetchone()
    cur, total, lvl = row if row else (0, 0, 1)
    ld = LEVELS.get(lvl, LEVELS[max(LEVELS.keys())])
    un = message.from_user.username or message.from_user.first_name
    await message.answer(f"{ld['emoji']} @{un} — *{ld['name']}* (Уровень {lvl})\\nОпыт: {cur} XP | Всего: {total} XP", parse_mode="Markdown")'''

new = '''@router.message(Command("level"))
async def cmd_level(message: types.Message):
    user_id = message.from_user.id
    db = await get_db()
    cursor = await db.execute('SELECT current_exp, total_exp, current_level FROM user_levels WHERE user_id = ?', (user_id,))
    row = await cursor.fetchone()
    cur, total, lvl = row if row else (0, 0, 1)
    ld = LEVELS.get(lvl, LEVELS[max(LEVELS.keys())])
    un = message.from_user.username or message.from_user.first_name
    await message.answer(f"{ld['emoji']} {un} — {ld['name']} (Уровень {lvl})\\nОпыт: {cur} XP | Всего: {total} XP")'''

content = content.replace(old, new)
with open('/opt/bot/handlers_user.py', 'w') as f:
    f.write(content)
print("Готово")
EOF

python3 /tmp/fix_level.py
systemctl restart tradeall-bot
echo "Бот перезапущен"
