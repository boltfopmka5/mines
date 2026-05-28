#!/bin/bash

echo "=== Исправляю /rules и меняю юзернейм бота ==="

cat > /tmp/fix_rules.py << 'EOF'
with open('/opt/bot/handlers_user.py', 'r') as f:
    content = f.read()

# ===== /rules =====
old_rules = '''@router.message(Command("rules"))
async def cmd_rules(message: types.Message):
    text = """
📋 *ПРАВИЛА КЛУБА TRADEALL*

🚫 Запрещены: реклама, спам, оскорбления, скам, слив, флуд.

⛔ 1-е нарушение — чёрный список. Разблокировка: 100 USDT
⛔ 2-е нарушение — чёрный список. Разблокировка: 200 USDT
⛔ 3-е нарушение — бан навсегда без возврата.

📞 Поддержка: @TradeAll_Support
"""
    await message.answer(text, parse_mode="Markdown")'''

new_rules = '''@router.message(Command("rules"))
async def cmd_rules(message: types.Message):
    text = (
        "ПРАВИЛА КЛУБА TRADEALL\\n\\n"
        "ЗАПРЕЩЕНО:\\n"
        "- Реклама и спам\\n"
        "- Оскорбления и токсичность\\n"
        "- Скам и мошенничество\\n"
        "- Слив контента клуба\\n"
        "- Флуд в сигналах\\n\\n"
        "САНКЦИИ:\\n"
        "1-е нарушение - чёрный список. Разблокировка: 100 USDT\\n"
        "2-е нарушение - чёрный список. Разблокировка: 200 USDT\\n"
        "3-е нарушение - бан навсегда без возврата.\\n\\n"
        "Поддержка: @TradeAll_Support"
    )
    await message.answer(text)'''

content = content.replace(old_rules, new_rules)

# ===== Юзернейм бота =====
content = content.replace('@TradeAll_bot', '@TradeAllPay_bot')
content = content.replace('TradeAll_bot', 'TradeAllPay_bot')

with open('/opt/bot/handlers_user.py', 'w') as f:
    f.write(content)
print("handlers_user.py - OK")

# Меняем в конфиге
with open('/opt/bot/config.py', 'r') as f:
    config = f.read()
config = config.replace('@TradeAll_bot', '@TradeAllPay_bot')
with open('/opt/bot/config.py', 'w') as f:
    f.write(config)
print("config.py - OK")

# Меняем в автоответчике
with open('/opt/bot/auto_reply_bot.py', 'r') as f:
    auto = f.read()
auto = auto.replace('@TradeAll_bot', '@TradeAllPay_bot')
auto = auto.replace('TradeAll_bot', 'TradeAllPay_bot')
with open('/opt/bot/auto_reply_bot.py', 'w') as f:
    f.write(auto)
print("auto_reply_bot.py - OK")
EOF

python3 /tmp/fix_rules.py

echo "=== Перезапуск ==="
systemctl restart tradeall-bot
systemctl restart tradeall-autoreply
echo "=== Готово ==="
