package main

import (
	"fmt"
	"os"
	"reflect"
)

func productExceptSelf(nums []int) []int {
	n := len(nums)
	result := make([]int, n)
	prefix := 1
	for i := range n {
		result[i] = prefix
		prefix *= nums[i]
	}
	suffix := 1
	for i := n - 1; i >= 0; i-- {
		result[i] = result[i] * suffix
		suffix *= nums[i]
	}
	return result
}

type testCase struct {
	name        string
	call        string
	expected    any
	run         func() any
	explanation string
}

// Customize equalResults when a problem allows multiple valid output orders
// or requires a problem-specific comparison.
func equalResults(actual, expected any) bool {
	return reflect.DeepEqual(actual, expected)
}

func execute(run func() any) (result any, panicValue any) {
	defer func() {
		panicValue = recover()
	}()

	result = run()
	return result, nil
}

func main() {
	testCases := []testCase{
		{
			name:        "Example 1",
			call:        "productExceptSelf([]int{1, 2, 3, 4})",
			expected:    []int{24, 12, 8, 6},
			run:         func() any { return productExceptSelf([]int{1, 2, 3, 4}) },
			explanation: "",
		},
		{
			name:        "Example 2",
			call:        "productExceptSelf([]int{-1, 1, 0, -3, 3})",
			expected:    []int{0, 0, 9, 0, 0},
			run:         func() any { return productExceptSelf([]int{-1, 1, 0, -3, 3}) },
			explanation: "",
		},
	}

	passed := 0

	for _, current := range testCases {
		actual, panicValue := execute(current.run)

		fmt.Printf("Case: %s\n", current.name)
		fmt.Printf("Call: %s\n", current.call)
		fmt.Printf("Expected: %#v\n", current.expected)
		if current.explanation != "" {
			fmt.Printf("Explanation: %s\n", current.explanation)
		}

		if panicValue != nil {
			fmt.Println("Actual: <panic>")
			fmt.Println("Result: FAIL")
			fmt.Printf("Panic: %#v\n", panicValue)
		} else {
			fmt.Printf("Actual: %#v\n", actual)
			if equalResults(actual, current.expected) {
				fmt.Println("Result: PASS")
				passed++
			} else {
				fmt.Println("Result: FAIL")
			}
		}

		fmt.Println()
	}

	fmt.Printf("%d/%d local cases passed\n", passed, len(testCases))
	if passed != len(testCases) {
		os.Exit(1)
	}
}
