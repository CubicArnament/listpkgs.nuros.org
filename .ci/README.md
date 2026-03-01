# ListPkgs Aggregator

Агрегатор метаданных пакетов из организации NurOS-Packages на GitHub.

## Установка и использование

### Через uv (рекомендуется)

```bash
# Перейти в директорию .ci
cd .ci

# Синхронизировать зависимости (создаёт .venv в этой папке)
uv sync --frozen

# Запустить агрегатор
.venv/bin/listpkgs-aggregate  # Linux/macOS
.venv\Scripts\listpkgs-aggregate  # Windows

# С опциями
.venv/bin/listpkgs-aggregate --jobs 4
```

### Через pip

```bash
cd .ci
pip install -e .
listpkgs-aggregate --jobs 4
```

## Опции

```
-h, --help            Показать справку
-j JOBS, --jobs JOBS  Количество параллельных процессов (по умолчанию: все ядра CPU)
```

## Выходные данные

После выполнения создаётся файл `repodata.json` в корне `.ci/` директории.

## GitHub Actions

В workflow используется следующий подход:

1. `uv sync --frozen` создаёт `.venv` в папке `.ci/`
2. PATH обновляется для доступа к команде `listpkgs-aggregate`
3. Скрипт запускается и генерирует `repodata.json`

## Структура проекта

```
.ci/
├── pyproject.toml              # Конфигурация проекта и зависимости
├── uv.lock                     # Заблокированные версии зависимостей
├── listpkgs_aggregator/        # Пакет агрегатора
│   ├── __init__.py
│   ├── main.py                 # Точка входа CLI
│   ├── aggregator.py           # Основная логика агрегации
│   ├── github_client.py        # GitHub API клиент
│   └── metadata_processor.py   # Обработчик метаданных
└── .venv/                      # Виртуальное окружение (игнорируется git)
```

## Лицензия

NurOS Project
