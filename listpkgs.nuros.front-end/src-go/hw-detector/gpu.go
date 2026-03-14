// Package hwdetector provides hardware detection capabilities via WebAssembly
package hwdetector

// GPUInfo содержит информацию о графическом процессоре
type GPUInfo struct {
	Vendor   string `json:"vendor"`
	Renderer string `json:"renderer"`
	Version  string `json:"version"`
	VRAMMB   int    `json:"vramMB,omitempty"`
	Power    string `json:"power"` // low, medium, high
}

// DetectGPU определяет характеристики GPU через WebGL
// Использует WebGL API для получения информации о видеокарте
func DetectGPU() *GPUInfo {
	// Примечание: реальная реализация будет использовать JavaScript interop
	// для получения данных из WebGL контекста
	return &GPUInfo{
		Vendor:   "Unknown",
		Renderer: "Unknown",
		Version:  "WebGL 2.0",
		VRAMMB:   0,
		Power:    "medium",
	}
}

// EstimatePower оценивает мощность GPU на основе renderer
func (g *GPUInfo) EstimatePower() string {
	// Простая эвристика для оценки мощности
	if g.VRAMMB > 4096 {
		return "high"
	} else if g.VRAMMB > 2048 {
		return "medium"
	}
	return "low"
}

// ToJS конвертирует GPUInfo в JavaScript объект
func (g *GPUInfo) ToJS() map[string]interface{} {
	return map[string]interface{}{
		"vendor":   g.Vendor,
		"renderer": g.Renderer,
		"version":  g.Version,
		"vramMB":   g.VRAMMB,
		"power":    g.Power,
	}
}
