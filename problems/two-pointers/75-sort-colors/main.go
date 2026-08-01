package main

import (
	"fmt"
	"os"
	"reflect"
	"runtime/debug"
)

func sortColors(nums []int) []int {
	n := len(nums)
	low, mid, high := 0, 0, n-1
	for mid <= high {
		if nums[mid] == 0 {
			nums[low], nums[mid] = nums[mid], nums[low]
			low++
			mid++
		} else if nums[mid] == 1 {
			mid++
		} else {
			nums[mid], nums[high] = nums[high], nums[mid]
			high--
		}

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
			call:        "sortColors([]int{2, 0, 2, 1, 1, 0})",
			expected:    []int{0, 0, 1, 1, 2, 2},
			run:         func() any { return sortColors([]int{2, 0, 2, 1, 1, 0}) },
			explanation: "",
		},
		{
			name:        "Example 2",
			call:        "sortColors([]int{2, 0, 1})",
			expected:    []int{0, 1, 2},
			run:         func() any { return sortColors([]int{2, 0, 1}) },
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
