//go:build js && wasm
// +build js,wasm

package main

import (
	"syscall/js"

	"listpkgs.nuros.org/hw-detector"
)

// detectHardware возвращает информацию о железе пользователя
func detectHardware(this js.Value, args []js.Value) interface{} {
	hardware := hwdetector.DetectHardware()
	return hardware.ToJS()
}

// getCPUInfo возвращает информацию о процессоре
func getCPUInfo(this js.Value, args []js.Value) interface{} {
	cpu := hwdetector.DetectCPU()
	return cpu.ToJS()
}

// getMemoryInfo возвращает информацию о памяти
func getMemoryInfo(this js.Value, args []js.Value) interface{} {
	memory := hwdetector.DetectMemory()
	return memory.ToJS()
}

// getGPUInfo возвращает информацию о GPU
func getGPUInfo(this js.Value, args []js.Value) interface{} {
	gpu := hwdetector.DetectGPU()
	return gpu.ToJS()
}

func main() {
	// Регистрируем функции для вызова из JavaScript
	js.Global().Set("detectHardware", js.FuncOf(detectHardware))
	js.Global().Set("getCPUInfo", js.FuncOf(getCPUInfo))
	js.Global().Set("getMemoryInfo", js.FuncOf(getMemoryInfo))
	js.Global().Set("getGPUInfo", js.FuncOf(getGPUInfo))

	// Блокируем завершение main
	select {}
}
