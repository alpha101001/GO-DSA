package main

import (
	"fmt"
	"os"
	"reflect"
	"sort"
)

func triangleNumber(nums []int) int {
	sort.Ints(nums)
	var count int = 0
	var n int = len(nums)
	for k := n - 1; k >= 2; k-- {
		var left int = 0
		var right int = k - 1
		for left < right {
			if nums[left]+nums[right] > nums[k] {
				count = count + (right - left)
				right--
			} else {
				left++
			}
		}
	}
	return count
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
			call:        "triangleNumber([]int{2, 2, 3, 4})",
			expected:    3,
			run:         func() any { return triangleNumber([]int{2, 2, 3, 4}) },
			explanation: "Valid combinations are:",
		},
		{
			name:        "Example 2",
			call:        "triangleNumber([]int{4, 2, 3, 4})",
			expected:    4,
			run:         func() any { return triangleNumber([]int{4, 2, 3, 4}) },
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
