package main

import (
	"fmt"
	"os"
	"reflect"
	"runtime/debug"
)

func moveZeroes(nums []int) []int {
	start, i := 0, 0
	for i < len(nums) {
		if nums[i] != 0 {
			nums[start], nums[i] = nums[i], nums[start]
			start++
		}
		i++
	}
	return nums
}
func init() {
	debug.SetMemoryLimit(0)
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
			call:        "moveZeroes([]int{0, 1, 0, 3, 12})",
			expected:    []int{1, 3, 12, 0, 0},
			run:         func() any { return moveZeroes([]int{0, 1, 0, 3, 12}) },
			explanation: "",
		},
		{
			name:        "Example 2",
			call:        "moveZeroes([]int{0})",
			expected:    []int{0},
			run:         func() any { return moveZeroes([]int{0}) },
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
