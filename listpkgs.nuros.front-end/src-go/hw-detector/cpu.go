// Package hwdetector provides hardware detection capabilities via WebAssembly
package hwdetector

// CPUInfo содержит информацию о процессоре
type CPUInfo struct {
	Cores      int     `json:"cores"`
	LogicalCores int   `json:"logicalCores"`
	Architecture string `json:"architecture"`
}

// DetectCPU определяет характеристики CPU
// Использует navigator.hardwareConcurrency для определения количества ядер
func DetectCPU() *CPUInfo {
	// Примечание: реальная реализация будет использовать JavaScript interop
	// для получения данных из браузера
	return &CPUInfo{
		Cores:      4,
		LogicalCores: 8,
		Architecture: "x86_64",
	}
}

// ToJS конвертирует CPUInfo в JavaScript объект
func (c *CPUInfo) ToJS() map[string]interface{} {
	return map[string]interface{}{
		"cores":        c.Cores,
		"logicalCores": c.LogicalCores,
		"architecture": c.Architecture,
	}
}
