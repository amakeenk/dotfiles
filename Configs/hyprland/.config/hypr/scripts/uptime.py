#!/usr/bin/python3


def get_uptime_seconds():
    with open('/proc/uptime', 'r') as f:
        uptime_seconds = float(f.readline().split()[0])
    return int(uptime_seconds)

def plural_ru(value, forms):
    # forms: ('секунда', 'секунды', 'секунд')
    if 11 <= (value % 100) <= 14:
        return forms[2]
    elif value % 10 == 1:
        return forms[0]
    elif 2 <= value % 10 <= 4:
        return forms[1]
    else:
        return forms[2]

def format_uptime(seconds):
    days = seconds // 86400
    hours = (seconds // 3600) % 24
    minutes = (seconds // 60) % 60
    secs = seconds % 60

    parts = []
    if days:
        parts.append(f"{days} {plural_ru(days, ('день', 'дня', 'дней'))}")
    if hours:
        parts.append(f"{hours} {plural_ru(hours, ('час', 'часа', 'часов'))}")
    if minutes:
        parts.append(f"{minutes} {plural_ru(minutes, ('минута', 'минуты', 'минут'))}")
    # Добавляем даже если это 0, чтобы всегда были секунды
    parts.append(f"{secs} {plural_ru(secs, ('секунда', 'секунды', 'секунд'))}")
    return ', '.join(parts)


if __name__ == "__main__":
    uptime_sec = get_uptime_seconds()
    print("В работе:", format_uptime(uptime_sec))
