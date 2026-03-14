# WASM Hardware Detector

> Определение характеристик железа через WebAssembly + Go

## 📖 Описание

WASM Hardware Detector - это Go модуль, который компилируется в WebAssembly и предоставляет API для определения характеристик оборудования пользователя прямо в браузере.

## 🔧 Возможности

- **CPU Detection**: Определение количества ядер, архитектуры
- **Memory Detection**: Определение объема RAM (через `performance.memory`)
- **GPU Detection**: Определение GPU через WebGL, оценка мощности

## 📦 Структура

```
src-go/
├── main.go                 # Точка входа WASM, экспорт функций в JS
├── hw-detector/
│   ├── detector.go         # Основной интерфейс, сборка информации
│   ├── cpu.go              # Детектирование CPU
│   ├── memory.go           # Детектирование RAM
│   └── gpu.go              # Детектирование GPU через WebGL
├── go.mod                  # Go module definition
├── meson.build             # Meson сборка
├── Makefile                # Make команды для lint/format
└── README.md               # Этот файл
```

## 🛠️ Сборка

### Требования

- **TinyGo** 0.28+
- **Meson** 1.0+
- **Ninja** 1.10+
- **Go** 1.21+

### Быстрая сборка

```bash
# Через Meson
meson setup build
meson compile -C build

# Через Make
make build
```

### Оптимизация

Сборка использует максимальную оптимизацию размера:

```bash
tinygo build \
  -o hw-detector.wasm \
  -no-debug \          # Убрать debug информацию
  -opt=z \             # Максимальная оптимизация размера
  -wasm-abi=js \       # JavaScript ABI
  -tags=noassert \     # Убрать assert
  -scheduler=none \    # Без планировщика
  -gc=none \           # Без GC
  -panic=trap \        # Паника как trap
  ./main.go
```

**Результат:**
- `hw-detector.wasm` - оптимизированный WASM модуль (~500KB)
- `hw-detector.wasm.map` - source map для отладки

## 📝 Использование

### В JavaScript

```javascript
// Инициализация WASM
import init, { detectHardware, getCPUInfo, getMemoryInfo, getGPUInfo } from './hw-detector.wasm';

await init();

// Получить полную информацию о железе
const hardware = detectHardware();
console.log(hardware);
// {
//   cpu: { cores: 8, logicalCores: 16, architecture: "x86_64" },
//   memory: { totalMB: 16384, usedMB: 8192, ... },
//   gpu: { vendor: "NVIDIA", renderer: "RTX 3080", power: "high" }
// }

// Получить только CPU
const cpu = getCPUInfo();

// Получить только RAM
const memory = getMemoryInfo();

// Получить только GPU
const gpu = getGPUInfo();
```

### API

#### `detectHardware()`

Возвращает полную информацию о железе.

#### `getCPUInfo()`

Возвращает информацию о процессоре:
- `cores` - физические ядра
- `logicalCores` - логические ядра (потоки)
- `architecture` - архитектура

#### `getMemoryInfo()`

Возвращает информацию о памяти:
- `totalMB` - общий объем (MB)
- `usedMB` - использовано (MB)
- `freeMB` - свободно (MB)
- `availableMB` - доступно (MB)

#### `getGPUInfo()`

Возвращает информацию о GPU:
- `vendor` - производитель
- `renderer` - модель
- `version` - версия WebGL
- `vramMB` - объем VRAM (если доступен)
- `power` - оценка мощности (low/medium/high)

## 🔍 Линтинг и форматирование

```bash
# Линтинг
make lint

# Строгий линтинг
make lint-strict

# Форматирование
make format

# Проверка форматирования
make format-check
```

## 🧪 Тестирование

```bash
# Go тесты
make test

# WASM тесты
make test-wasm
```

## 📊 Оптимизация размера

| Флаг | Описание | Экономия |
|------|----------|----------|
| `-no-debug` | Убрать debug информацию | ~30% |
| `-opt=z` | Максимальная оптимизация размера | ~20% |
| `-gc=none` | Без сборщика мусора | ~15% |
| `-scheduler=none` | Без планировщика | ~10% |
| `-tags=noassert` | Убрать assert проверки | ~5% |

**Итого:** ~500KB вместо ~2MB

## 🤝 Contributing

См. основной [README](../../README.md) проекта.

## 📄 Лицензия

MIT - см. [LICENSE](../../LICENSE)
