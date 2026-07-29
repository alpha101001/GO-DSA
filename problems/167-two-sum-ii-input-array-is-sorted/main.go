package main

import (
	"fmt"
	"os"
	"reflect"
)

func twoSum(numbers []int, target int) []int {
	var n = len(numbers)
	var left = 0
	var right = n - 1
	for left < right {
		var sum = numbers[left] + numbers[right]
		if sum < target {
			left++
		} else if sum > target {
			right--
		} else {
			return []int{left + 1, right + 1}
		}
	}
	return nil
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
			call:        "twoSum([]int{2, 7, 11, 15}, 9)",
			expected:    []int{1, 2},
			run:         func() any { return twoSum([]int{2, 7, 11, 15}, 9) },
			explanation: "The sum of 2 and 7 is 9. Therefore, index1 = 1, index2 = 2. We return [1, 2].",
		},
		{
			name:        "Example 2",
			call:        "twoSum([]int{2, 3, 4}, 6)",
			expected:    []int{1, 3},
			run:         func() any { return twoSum([]int{2, 3, 4}, 6) },
			explanation: "The sum of 2 and 4 is 6. Therefore index1 = 1, index2 = 3. We return [1, 3].",
		},
		{
			name:        "Example 3",
			call:        "twoSum([]int{-1, 0}, -1)",
			expected:    []int{1, 2},
			run:         func() any { return twoSum([]int{-1, 0}, -1) },
			explanation: "The sum of -1 and 0 is -1. Therefore index1 = 1, index2 = 2. We return [1, 2].",
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
