# WASM Hardware Detector - Build System
# Requires: meson, ninja, tinygo

project('hw-detector', 'go',
  version: '1.0.0',
  license: 'MIT',
  default_options: [
    'buildtype=release',
    'optimization=3'
  ]
)

# ============================================================================
# Configuration
# ============================================================================

# Paths
src_dir = meson.current_source_dir()
build_dir = meson.current_build_dir()
output_dir = join_paths(build_dir, 'wasm')

# TinyGo compiler
tinygo = find_program('tinygo', required: true)

# Go tools
gofmt = find_program('gofmt', required: true)
goimports = find_program('goimports', required: false)
golangci_lint = find_program('golangci-lint', required: false)

# ============================================================================
# WASM Build Target
# ============================================================================

# Оптимизированная сборка WASM
wasm_output = join_paths(output_dir, 'hw-detector.wasm')
wasm_map = join_paths(output_dir, 'hw-detector.wasm.map')

custom_target('build_wasm',
  output: ['hw-detector.wasm', 'hw-detector.wasm.map'],
  input: [
    join_paths(src_dir, 'main.go'),
    join_paths(src_dir, 'hw-detector', 'detector.go'),
    join_paths(src_dir, 'hw-detector', 'cpu.go'),
    join_paths(src_dir, 'hw-detector', 'memory.go'),
    join_paths(src_dir, 'hw-detector', 'gpu.go'),
  ],
  command: [
    tinygo, 'build',
    '-o', '@OUTPUT@',
    '-no-debug',              # Убрать debug информацию для уменьшения размера
    '-opt=z',                 # Максимальная оптимизация размера
    '-wasm-abi=js',           # JavaScript ABI для WASM
    '-tags=noassert',         # Убрать assert проверки
    '-scheduler=none',        # Без планировщика (меньше вес)
    '-gc=none',               # Без сборщика мусора (меньше вес)
    '-panic=trap',            # Паника как trap (меньше вес)
    '-print-ir=false',        # Не печатать IR
    '-stack-size=8388608',    # 8MB стек
    '@INPUT@',
  ],
  build_by_default: true,
  install: true,
  install_dir: 'wasm'
)

# ============================================================================
# Custom Targets for Lint and Format (вызываются через make)
# ============================================================================

# Таргет для линтинга (вызывается через make lint)
find_program('bash', required: true)

custom_target('lint',
  output: 'lint-report.txt',
  input: [
    join_paths(src_dir, 'main.go'),
    join_paths(src_dir, 'hw-detector'),
  ],
  command: [
    'bash', '-c',
    'cd ' + src_dir + ' && golangci-lint run --out-format=colored-line-number > ' + build_dir + '/lint-report.txt 2>&1 || true'
  ],
  build_by_default: false,
  install: false
)

# Таргет для форматирования (вызывается через make format)
custom_target('format',
  output: 'format-stamp.txt',
  input: [
    join_paths(src_dir, 'main.go'),
    join_paths(src_dir, 'hw-detector'),
  ],
  command: [
    'bash', '-c',
    'cd ' + src_dir + ' && gofmt -w -s . && echo "Formatted" > ' + build_dir + '/format-stamp.txt'
  ],
  build_by_default: false,
  install: false
)

# ============================================================================
# Test Target
# ============================================================================

custom_target('test_wasm',
  output: 'test-results.txt',
  input: [
    join_paths(src_dir, 'main.go'),
  ],
  command: [
    tinygo, 'test',
    '-target=wasi',
    '-v',
    './...',
  ],
  build_by_default: false,
  install: false
)

# ============================================================================
# Summary
# ============================================================================

summary({
  'WASM Output': wasm_output,
  'Source Map': wasm_map,
  'Optimization': 'z (size)',
  'Debug Info': 'stripped',
  'GC': 'none',
  'Scheduler': 'none',
}, section: 'hw-detector')
