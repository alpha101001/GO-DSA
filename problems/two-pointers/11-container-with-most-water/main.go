package main

import (
	"fmt"
	"os"
	"reflect"
)

func maxArea(height []int) int {
	var area int = 0
	var left, right int = 0, len(height) - 1
	for left < right {
		var newArea int = (right - left) * min(height[left], height[right])
		area = max(area, newArea)
		if height[left] <= height[right] {
			left++
		} else {
			right--
		}
	}
	return area

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
			call:        "maxArea([]int{1, 8, 6, 2, 5, 4, 8, 3, 7})",
			expected:    49,
			run:         func() any { return maxArea([]int{1, 8, 6, 2, 5, 4, 8, 3, 7}) },
			explanation: "The above vertical lines are represented by array [1,8,6,2,5,4,8,3,7]. In this case, the max area of water (blue section) the container can contain is 49.",
		},
		{
			name:        "Example 2",
			call:        "maxArea([]int{1, 1})",
			expected:    1,
			run:         func() any { return maxArea([]int{1, 1}) },
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
