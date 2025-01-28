# TimedRollingFileHandler

## О чем речь?

`TimedRotatingFileHandler` — это один из стандартных обработчиков логирования в Python, который позволяет автоматически создавать новые файлы логов через заданные интервалы времени (например, каждый день, каждый час или каждую неделю). Это полезно для управления большими объемами логов, чтобы они не занимали слишком много места на диске и были удобны для анализа.

В Python `TimedRotatingFileHandler` настраивается с помощью следующих параметров:

- `filename` — имя файла для логирования.

- `when` — интервал времени для ротации (например, 'D' для дня, 'H' для часа, 'M' для минуты и т.д.).

- `interval` — количество интервалов времени между ротациями (по умолчанию 1).

- `backupCount` — количество файлов логов, которые нужно сохранить (старые файлы удаляются).

- `encoding` — кодировка файла.

- `delay` — отложенное создание файла до первого использования.

- `utc` — использовать ли UTC вместо локального времени.

Пример кода на языке Python для работы с `TimedRotatingFileHandler`:

```python
import logging
from logging.handlers import TimedRotatingFileHandler
from pathlib import Path

BASE_DIR = Path.cwd()

LOGS_DIR = BASE_DIR / 'logs'
BASE_LOGGER = logging.getLogger('APPNAME')
LOG_FILE = 'APPNAME_log.log'
Path.mkdir(LOGS_DIR, exist_ok=True)
BASE_HANDLER = TimedRotatingFileHandler(
    filename=LOGS_DIR / LOG_FILE,
    when='midnight',
    interval=1,
    backupCount=90,
    encoding='utf-8'
)
BASE_FORMATTER = logging.Formatter(
    '[%(asctime)s][%(levelname)s][%(name)s]: %(message)s',
    '%d.%m.%Y %H:%M:%S'
)
BASE_HANDLER.setFormatter(BASE_FORMATTER)
BASE_LOGGER.addHandler(BASE_HANDLER)
```

## Что делать?

В Nim нет встроенного аналога `TimedRotatingFileHandler`, но его можно реализовать самостоятельно, используя стандартные средства языка. Для этого нужно:

- Создать обработчик, который будет записывать логи в файл. Назовём его `TimedRollingFileHandler`.

- Реализовать логику ротации файлов по времени (обработку `'D'`, `'H'`, `'M'`, `'S'`).

- Управлять удалением старых файлов, если их количество превышает заданное.

- НЕ НУЖНО реализовывать обработку записи лога ниже требуемого.

## Подсказки

В файле `main.nim` даны объемные подсказки для действия. В случае, если вы захотите реализовать свой `TimedRollingFileHandler` с 0 - мы не будем вам мешать. Только проверим код на NEP.