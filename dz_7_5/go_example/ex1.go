package main

import "fmt"

func main() {
    fmt.Println("Программа переводит метры в футы.\n")
    fmt.Print("Введите количество метров: ")
    var input float64
    fmt.Scanf("%f", &input)

    output := input / 0.3048

    fmt.Println(input, "метра(ов) соответствует ", output, " футам")
}

