package main

import (
	"fmt"
	"os"
	"reflect"
	"slices"
)

func threeSum(nums []int) [][]int {
	slices.Sort(nums)
	record := [][]int{}
	for i := 0; i < len(nums)-2; i++ {
		var left, right = i + 1, len(nums) - 1
		if i > 0 && nums[i] == nums[i-1] {
			continue
		}

		for left < right {
			var sum int = nums[i] + nums[left] + nums[right]
			if sum == 0 {
				record = append(record, []int{nums[i], nums[left], nums[right]})
				left++
				right--
				for left < right && nums[left] == nums[left-1] {
					left++
				}

				for left < right && nums[right] == nums[right+1] {
					right--
				}

			} else if sum < 0 {
				left++
			} else if sum > 0 {
				right--
			}
		}
	}
	return record
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
			name:        "Example 0",
			call:        "threeSum([]int{-100,-70,-60,110,120,130,160})",
			expected:    [][]int{[]int{-100, -60, 160}, []int{-70, -60, 130}},
			run:         func() any { return threeSum([]int{-100, -70, -60, 110, 120, 130, 160}) },
			explanation: "",
		},
		{
			name:        "Example 1",
			call:        "threeSum([]int{-1, 0, 1, 2, -1, -4})",
			expected:    [][]int{[]int{-1, -1, 2}, []int{-1, 0, 1}},
			run:         func() any { return threeSum([]int{-1, 0, 1, 2, -1, -4}) },
			explanation: "",
		},
		{
			name:        "Example 2",
			call:        "threeSum([]int{0, 1, 1})",
			expected:    [][]int{},
			run:         func() any { return threeSum([]int{0, 1, 1}) },
			explanation: "The only possible triplet does not sum up to 0.",
		},
		{
			name:        "Example 3",
			call:        "threeSum([]int{0, 0, 0})",
			expected:    [][]int{[]int{0, 0, 0}},
			run:         func() any { return threeSum([]int{0, 0, 0}) },
			explanation: "The only possible triplet sums up to 0.",
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
