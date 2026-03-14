# NurOS Package Search System

> **Speed • Security • Accessibility** - Поиск пакетов для экосистемы NurOS

[![CI/CD Pipeline](https://github.com/CubicArnament/listpkgs.nuros.org/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/CubicArnament/listpkgs.nuros.org/actions/workflows/ci-cd.yml)
[![Auto Format](https://github.com/CubicArnament/listpkgs.nuros.org/actions/workflows/autofmt.yml/badge.svg)](https://github.com/CubicArnament/listpkgs.nuros.org/actions/workflows/autofmt.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## 📖 О проекте

NurOS Package Search - это система поиска и каталогизации пакетов для экосистемы NurOS. Предоставляет удобный веб-интерфейс для поиска пакетов, фильтрации по различным критериям и просмотра детальной информации.

## ✨ Возможности

- 🔍 **Поиск пакетов** - по названию, описанию и ключевым словам
- 🏷️ **Фильтрация** - по архитектуре, типу пакета, мейнтейнеру, лицензии, источнику
- 📊 **Группировка** - просмотр пакетов по алфавиту или списком
- 📦 **Детальная информация** - версия, архитектура, зависимости, конфликты
- 🌙 **Тёмная/светлая тема** - переключение между темами
- 📱 **Адаптивный дизайн** - поддержка мобильных устройств

## 🏗️ Структура проекта

```
listpkgs.nuros.org/
├── .github/workflows/          # GitHub Actions workflow
│   ├── ci-cd.yml              # Полный CI/CD пайплайн
│   ├── autofmt.yml            # Автоформатирование кода
│   ├── lint.yml               # Линтинг кода
│   └── pr.yml                 # Тесты для Pull Request
├── listpkgs.nuros.front-end/  # Фронтенд приложение
│   ├── src/                   # TypeScript/React исходники
│   ├── tests/                 # Playwright E2E тесты
│   └── package.json           # Зависимости npm
├── .ci/                       # Python бэкенд для агрегации пакетов
├── docker/                    # Dockerfile для всех сервисов
│   ├── frontend.Dockerfile    # Сборка фронтенда
│   ├── lint_frontend.Dockerfile # Линтинг
│   ├── tests_frontend.Dockerfile # E2E тесты
│   ├── formatter.Dockerfile   # Форматирование кода
│   └── backend.Dockerfile     # Python агрегатор
├── docker-compose.yml         # Конфигурация Docker Compose
└── README.md                  # Этот файл
```

## 🚀 Как это работает

### 1. Обновление списка пакетов
Каждые 6 часов запускается `ci-cd.yml`:
- Сканирует репозитории NurOS-Packages
- Собирает метаданные из `metadata.json` файлов
- Генерирует актуальный `repodata.json`

### 2. Сборка фронтенда
После обновления списка:
- Установка зависимостей
- Сборка через Vite
- Деплой на GitHub Pages

## 🛠️ Технологии

### Фронтенд
- **SolidJS** - реактивный фреймворк
- **TypeScript** - типизация
- **Vite** - сборка
- **SCSS** - стилизация
- **Playwright** - E2E тесты

### Бэкенд
- **Python** - агрегация пакетов
- **httpx** - HTTP запросы
- **uv** - менеджер пакетов

## 📦 Установка и запуск локально

### Требования
- Node.js 22+
- pnpm 9+
- Docker/Podman (опционально)

### Быстрый старт

```bash
# Клонировать репозиторий
git clone https://github.com/CubicArnament/listpkgs.nuros.org.git
cd listpkgs.nuros.org

# Установить зависимости фронтенда
cd listpkgs.nuros.front-end
pnpm install

# Запустить dev сервер
pnpm dev

# Запустить линтинг
pnpm lint

# Запустить тесты
pnpm test
```

### Через Docker Compose

```bash
# Development сервер
docker compose --profile development up dev

# Preview production сборки
docker compose --profile preview up preview

# Запустить линтинг в контейнере
docker compose --profile ci run --rm lint

# Запустить тесты в контейнере
docker compose --profile ci run --rm test

# Сформатировать код
docker compose --profile development run --rm format
```

## 🧪 Тестирование

```bash
# Запустить все тесты
pnpm test

# Запустить тесты в UI режиме
pnpm test:ui

# Запустить тесты в headed режиме
pnpm test:headed

# Запустить тесты с дебагом
pnpm test:debug
```

## 📝 Кодстайл

```bash
# Линтинг TypeScript + SCSS
pnpm lint

# Форматирование кода
pnpm format

# Проверка форматирования
pnpm check-format
```

## 🤝 Contributing

Мы приветствуем вклад в проект!

### Как внести вклад

1. Fork репозиторий
2. Создайте feature branch (`git checkout -b feature/amazing-feature`)
3. Закоммитьте изменения (`git commit -m 'Add amazing feature'`)
4. Запушьте branch (`git push origin feature/amazing-feature`)
5. Откройте Pull Request

### Требования к коду

- ✅ Все тесты должны проходить
- ✅ Линтинг без ошибок
- ✅ Код отформатирован
- ✅ Добавлены тесты для новых функций

## 📚 Документация

Полная документация доступна в папке `blog/` и включает:

- 📘 Руководство по началу работы
- 🏗️ Архитектура системы
- 🔌 API Reference
- 🚀 Руководство по деплою
- 🤝 Guidelines для контрибьюторов

## 📄 Лицензия

Этот проект распространяется под лицензией **MIT**. См. файл [LICENSE](LICENSE) для деталей.

## 👥 Команда

- **NurOS Development Team** - основная разработка
- **Сообщество** - контрибьюторы и пользователи

## 🔗 Ссылки

- [NurOS Website](https://www.nuros.org/)
- [NurOS Documentation](https://docs.nuros.org/)
- [NurOS-Packages](https://github.com/NurOS-Packages/)
- [NurOS-Linux](https://github.com/NurOS-Linux/)

---

<div align="center">

**Made with ❤️ by NurOS Team**

[Website](https://www.nuros.org/) • [Documentation](https://docs.nuros.org/) • [GitHub](https://github.com/CubicArnament/listpkgs.nuros.org)

</div>
