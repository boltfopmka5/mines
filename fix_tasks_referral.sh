#!/bin/bash

echo "=== Добавляю вызов update_task_progress при регистрации реферала ==="

cat > /tmp/fix_tasks.py << 'EOF'
with open('/opt/bot/handlers_user.py', 'r') as f:
    content = f.read()

# Добавляем импорт update_task_progress
old_import = 'from tasks import assign_tasks, update_streak'
new_import = 'from tasks import assign_tasks, update_streak, update_task_progress'
content = content.replace(old_import, new_import)

# Находим место где реферер регистрируется (после update_lottery_tickets)
old_ref = '''            await add_exp(ref[0], "referral_register")
            await update_lottery_tickets(ref[0])'''

new_ref = '''            await add_exp(ref[0], "referral_register")
            await update_lottery_tickets(ref[0])
            await update_task_progress(ref[0], "invite_1", 1)
            await update_task_progress(ref[0], "invite_3", 1)'''

content = content.replace(old_ref, new_ref)

# Также добавляем выполнение заданий при оплате рефералом
# Ищем process_payment, там где process_referral
old_payment_ref = '''        if ref and ref[0]:
            await process_referral(ref[0], user_id, is_trial)
            await update_lottery_tickets(ref[0])'''

new_payment_ref = '''        if ref and ref[0]:
            await process_referral(ref[0], user_id, is_trial)
            await update_lottery_tickets(ref[0])
            await update_task_progress(ref[0], "invite_active", 1)'''

content = content.replace(old_payment_ref, new_payment_ref)

with open('/opt/bot/handlers_user.py', 'w') as f:
    f.write(content)
print("Готово")
EOF

python3 /tmp/fix_tasks.py

systemctl restart tradeall-bot
echo "=== Бот перезапущен ==="
