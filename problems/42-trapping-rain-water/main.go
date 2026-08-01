package main

import (
	"fmt"
	"os"
	"reflect"
)

func trap(height []int) int {
	left, right, leftMax, rightMax, total := 0, len(height)-1, 0, 0, 0
	for left < right {
		if height[left] <= height[right] {
			if leftMax < height[left] {
				leftMax = height[left]
			} else {
				total += leftMax - height[left]
			}
			left++
		} else {
			if rightMax < height[right] {
				rightMax = height[right]
			} else {
				total += rightMax - height[right]
			}
			right--
		}
	}
	return total
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
			call:        "trap([]int{0, 1, 0, 2, 1, 0, 1, 3, 2, 1, 2, 1})",
			expected:    6,
			run:         func() any { return trap([]int{0, 1, 0, 2, 1, 0, 1, 3, 2, 1, 2, 1}) },
			explanation: "The above elevation map (black section) is represented by array [0,1,0,2,1,0,1,3,2,1,2,1]. In this case, 6 units of rain water (blue section) are being trapped.",
		},
		{
			name:        "Example 2",
			call:        "trap([]int{4, 2, 0, 3, 2, 5})",
			expected:    9,
			run:         func() any { return trap([]int{4, 2, 0, 3, 2, 5}) },
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
