package main
import (
    "fmt"
)

func main() {
    x := []int{48,96,86,68,57,82,63,70,37,34,83,27,19,97,9,17,}
    fmt.Printf("Минимальный элемент: %d\n", Min(x))
}

func Min(list []int) int {
	min := list[0]
	for _, elem := range list {
		if elem < min {
			min = elem
		}
	}

	return min
}