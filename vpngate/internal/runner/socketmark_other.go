//go:build !linux

package runner

func setSocketMark(fd uintptr, mark int) error {
	return nil
}
