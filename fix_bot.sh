#!/bin/bash

# =====================================================
# Файл: fix_bot.sh
# Описание: Автоматическое исправление бота для отправки сигналов
# Использование: chmod +x fix_bot.sh && ./fix_bot.sh
# =====================================================

BOT_FILE="signals_bot_4H.py"

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}🔧 Исправление бота для отправки сигналов${NC}"
echo -e "${GREEN}========================================${NC}"

# Проверяем существует ли файл
if [ ! -f "$BOT_FILE" ]; then
    echo -e "${RED}❌ Файл $BOT_FILE не найден!${NC}"
    exit 1
fi

# Создаем бэкап
echo -e "${YELLOW}📦 Создаю бэкап...${NC}"
cp "$BOT_FILE" "${BOT_FILE}.backup_$(date +%Y%m%d_%H%M%S)"
echo -e "${GREEN}✅ Бэкап создан${NC}"

# =====================================================
# 1. Удаляем фильтр дубликатов в analyze_symbol
# =====================================================
echo -e "${YELLOW}🔧 1. Удаляю фильтр дубликатов...${NC}"

python3 << 'PYTHON_FIX'
import re

file_path = "signals_bot_4H.py"

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Шаблон для поиска блока с фильтром
pattern = r'(if final_signal and final_signal\["confidence"\] >= MIN_CONFIDENCE_SCORE:)\s*\n(\s*)sig_key = f"{symbol}_{final_signal\[.direction.\]}"\s*\n.*?(\s*)return final_signal\s*\n(\s*)return None'

# Замена на простой возврат
replacement = r'\1\n\2return final_signal\n\2return None'

new_content = re.sub(pattern, replacement, content, flags=re.DOTALL)

# Если не сработало, пробуем другой шаблон
if new_content == content:
    # Ищем и заменяем проще
    lines = content.split('\n')
    new_lines = []
    skip_next = False
    
    for i, line in enumerate(lines):
        if 'sig_key = f"{symbol}_{final_signal' in line and 'direction' in line:
            skip_next = True
            continue
        if 'if sig_key not in' in line and 'signals_history' in line:
            skip_next = True
            continue
        if 'self.signals_history.append(final_signal)' in line and skip_next:
            # Добавляем чистый return
            indent = len(line) - len(line.lstrip())
            new_lines.append(' ' * indent + 'return final_signal')
            skip_next = False
            continue
        if not skip_next:
            new_lines.append(line)
        else:
            # Пропускаем строки до return
            if 'return None' in line:
                skip_next = False
    
    new_content = '\n'.join(new_lines)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(new_content)

print("   ✅ Фильтр дубликатов удален")
PYTHON_FIX

# =====================================================
# 2. Добавляем отладочные принты в send_telegram_message
# =====================================================
echo -e "${YELLOW}🔧 2. Добавляю отладку в send_telegram_message...${NC}"

python3 << 'PYTHON_FIX'
import re

file_path = "signals_bot_4H.py"

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Новый метод с отладкой
debug_method = '''    def send_telegram_message(self, message: str, photo_path: str = None):
        """Отправка сообщения в Telegram (фото и текст отдельно)"""
        print("   🐛 Отправка в Telegram...")
        try:
            bot = telebot.TeleBot(TELEGRAM_BOT_TOKEN)
            
            if photo_path and os.path.exists(photo_path):
                print(f"   📸 Отправляю фото: {photo_path}")
                with open(photo_path, 'rb') as photo:
                    if TELEGRAM_THREAD_ID:
                        bot.send_photo(
                            chat_id=TELEGRAM_CHAT_ID,
                            photo=photo,
                            message_thread_id=TELEGRAM_THREAD_ID
                        )
                    else:
                        bot.send_photo(
                            chat_id=TELEGRAM_CHAT_ID,
                            photo=photo
                        )
                print("   ✅ Фото отправлено")
            else:
                print("   📸 Фото не отправляется")
            
            print(f"   📨 Отправляю текст ({len(message)} символов)")
            if TELEGRAM_THREAD_ID:
                bot.send_message(
                    chat_id=TELEGRAM_CHAT_ID,
                    text=message,
                    message_thread_id=TELEGRAM_THREAD_ID
                )
            else:
                bot.send_message(
                    chat_id=TELEGRAM_CHAT_ID,
                    text=message
                )
            print("   ✅ Текст отправлен")
            return True
            
        except Exception as e:
            print(f"   ❌ Ошибка Telegram: {type(e).__name__}: {e}")
            import traceback
            traceback.print_exc()
            return False'''

# Находим старый метод и заменяем
pattern = r'    def send_telegram_message\(self, message: str, photo_path: str = None\):.*?(?=\n    def|\nclass|\Z)'
new_content = re.sub(pattern, debug_method, content, flags=re.DOTALL)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(new_content)

print("   ✅ Отладка добавлена")
PYTHON_FIX

# =====================================================
# 3. Добавляем принты в _send_signals_to_telegram
# =====================================================
echo -e "${YELLOW}🔧 3. Добавляю принты в цикл отправки...${NC}"

python3 << 'PYTHON_FIX'
import re

file_path = "signals_bot_4H.py"

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Добавляем принт в начало цикла
lines = content.split('\n')
new_lines = []

for i, line in enumerate(lines):
    new_lines.append(line)
    # После строки "for sig in signals:" добавляем принт
    if 'for sig in signals:' in line:
        indent = len(line) - len(line.lstrip())
        new_lines.append(' ' * indent + 'print(f"   📤 Обработка {sig[\"symbol\"]}...")')

content = '\n'.join(new_lines)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("   ✅ Принты добавлены")
PYTHON_FIX

# =====================================================
# 4. Создаем тестовый скрипт для проверки Telegram
# =====================================================
echo -e "${YELLOW}📝 4. Создаю тестовый скрипт...${NC}"

cat > test_telegram.py << 'EOF'
import telebot
import os

# ВСТАВЬ СВОИ ДАННЫЕ!
TOKEN = "YOUR_BOT_TOKEN_HERE"
CHAT_ID = "YOUR_CHAT_ID_HERE"  # Например: "-1001234567890" или личный ID

if TOKEN == "YOUR_BOT_TOKEN_HERE":
    print("❌ Сначала вставь свой токен в файл test_telegram.py")
    exit(1)

try:
    bot = telebot.TeleBot(TOKEN)
    bot.send_message(CHAT_ID, "✅ Тестовое сообщение от бота! Если ты это видишь — бот работает.")
    print("✅ Сообщение отправлено!")
except Exception as e:
    print(f"❌ Ошибка: {e}")
EOF

echo -e "${GREEN}✅ Тестовый скрипт создан: test_telegram.py${NC}"
echo -e "${YELLOW}⚠️  Не забудь вставить токен и CHAT_ID в test_telegram.py${NC}"

# =====================================================
# Завершение
# =====================================================
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✅ Исправление завершено!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}📋 Что делать дальше:${NC}"
echo -e "1. Проверь Telegram:"
echo -e "   ${GREEN}python3 test_telegram.py${NC}"
echo -e ""
echo -e "2. Запусти бота:"
echo -e "   ${GREEN}python3 signals_bot_4H.py${NC}"
echo -e ""
echo -e "3. Если бот не отправляет — посмотри вывод, там будут ошибки"
echo -e ""
echo -e "📦 Бэкап сохранен в папке с ботом"
EOF
