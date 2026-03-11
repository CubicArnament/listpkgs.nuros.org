# Docker Preview - Quick Start

## Запуск preview версии сайта

### Одна команда (через docker compose)
```bash
docker compose --profile preview run --rm preview-init
```

### Скрипты (альтернатива)

**Windows (PowerShell):**
```powershell
./docker/scripts/preview.ps1
```

**Linux/WSL:**
```bash
./docker/scripts/preview.sh
```

### Вручную (2 команды)

```bash
# 1. Генерация repodata.json
docker compose --profile preview run --rm generate-repodata

# 2. Билд и запуск
docker compose --profile preview up --build preview
```

---

## Доступ к сайту

**URL:** http://localhost:8080

**Health Check:** http://localhost:8080/health

---

## Остановка

```bash
docker compose --profile preview down
```

---

## Полная пересборка

```bash
# Очистить всё
docker compose --profile preview down --volumes --rmi all

# Запустить заново
docker compose --profile preview run --rm preview-init
```

---

## Все команды

См. **[COMMANDS.md](COMMANDS.md)** — полный справочник команд Docker.
