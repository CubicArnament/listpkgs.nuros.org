// Package hwdetector provides hardware detection capabilities via WebAssembly
package hwdetector

// MemoryInfo содержит информацию о памяти
type MemoryInfo struct {
	TotalMB     int `json:"totalMB"`
	UsedMB      int `json:"usedMB"`
	FreeMB      int `json:"freeMB"`
	AvailableMB int `json:"availableMB"`
}

// DetectMemory определяет характеристики RAM
// Использует performance.memory API (доступно в Chrome/Edge)
func DetectMemory() *MemoryInfo {
	// Примечание: реальная реализация будет использовать JavaScript interop
	// для получения данных из браузера через performance.memory
	return &MemoryInfo{
		TotalMB:     16384,
		UsedMB:      8192,
		FreeMB:      8192,
		AvailableMB: 12288,
	}
}

// ToJS конвертирует MemoryInfo в JavaScript объект
func (m *MemoryInfo) ToJS() map[string]interface{} {
	return map[string]interface{}{
		"totalMB":     m.TotalMB,
		"usedMB":      m.UsedMB,
		"freeMB":      m.FreeMB,
		"availableMB": m.AvailableMB,
	}
}
