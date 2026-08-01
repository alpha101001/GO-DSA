package main

import (
	"fmt"
	"os"
	"reflect"
)

func twoSum(nums []int, target int) []int {
	temp := make(map[int]int)
	for i := range nums {
		if mapValue, okay := temp[target-nums[i]]; okay {
			return []int{mapValue, i}
		}
		temp[nums[i]] = i
	}
	return []int{-1, -1}
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
			expected:    []int{0, 1},
			run:         func() any { return twoSum([]int{2, 7, 11, 15}, 9) },
			explanation: "Because nums[0] + nums[1] == 9, we return [0, 1].",
		},
		{
			name:        "Example 2",
			call:        "twoSum([]int{3, 2, 4}, 6)",
			expected:    []int{1, 2},
			run:         func() any { return twoSum([]int{3, 2, 4}, 6) },
			explanation: "",
		},
		{
			name:        "Example 3",
			call:        "twoSum([]int{3, 3}, 6)",
			expected:    []int{0, 1},
			run:         func() any { return twoSum([]int{3, 3}, 6) },
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
