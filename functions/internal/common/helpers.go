package common

import "time"

func PrintTime() {
	println("time:", time.Now().Format("2006-01-02 15:04:05"))
}
