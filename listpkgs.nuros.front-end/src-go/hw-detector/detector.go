// Package hwdetector provides hardware detection capabilities via WebAssembly
package hwdetector

import (
	"encoding/json"
)

// HardwareInfo содержит полную информацию о железе
type HardwareInfo struct {
	CPU    *CPUInfo    `json:"cpu"`
	Memory *MemoryInfo `json:"memory"`
	GPU    *GPUInfo    `json:"gpu"`
}

// DetectHardware собирает полную информацию о железе пользователя
func DetectHardware() *HardwareInfo {
	return &HardwareInfo{
		CPU:    DetectCPU(),
		Memory: DetectMemory(),
		GPU:    DetectGPU(),
	}
}

// ToJSON конвертирует HardwareInfo в JSON строку
func (h *HardwareInfo) ToJSON() (string, error) {
	data, err := json.Marshal(h)
	if err != nil {
		return "", err
	}
	return string(data), nil
}

// ToJS конвертирует HardwareInfo в JavaScript объект
func (h *HardwareInfo) ToJS() map[string]interface{} {
	return map[string]interface{}{
		"cpu":    h.CPU.ToJS(),
		"memory": h.Memory.ToJS(),
		"gpu":    h.GPU.ToJS(),
	}
}

// GetPowerScore вычисляет общий балл мощности системы
func (h *HardwareInfo) GetPowerScore() int {
	score := 0

	// CPU score (ядра * 100)
	score += h.CPU.LogicalCores * 100

	// Memory score (GB * 50)
	score += (h.Memory.TotalMB / 1024) * 50

	// GPU score
	switch h.GPU.Power {
	case "high":
		score += 300
	case "medium":
		score += 150
	case "low":
		score += 50
	}

	return score
}
