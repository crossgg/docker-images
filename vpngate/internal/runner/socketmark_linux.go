//go:build linux

package runner

import "syscall"

func setSocketMark(fd uintptr, mark int) error {
	return syscall.SetsockoptInt(int(fd), syscall.SOL_SOCKET, linuxSocketMarkOption, mark)
}
