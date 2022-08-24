package main
import (
    "fmt"
)

func main() {
    fmt.Printf("Числа от 1 до 100 делящиеся на 3: %v\n", Div3())
}

func Div3() []int {
	result := []int{}
	for i := 1; i <= 100; i++ {
		if i%3 == 0 {
			result = append(result, i)
		}
	}

	return result
}