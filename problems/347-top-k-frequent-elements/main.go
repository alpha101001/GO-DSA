package main

import (
	"fmt"
	"os"
	"reflect"
)

func topKFrequent(nums []int, k int) []int {
	count := make(map[int]int)
	n := len(nums)
	for _, num := range nums {
		count[num]++
	}
	buckets := make([][]int, len(nums)+1)
	for number, frequency := range count {
		buckets[frequency] = append(buckets[frequency], number)
	}
	var result []int
	for frequency := n; frequency >= 0; frequency-- {
		for _, bucket := range buckets[frequency] {
			result = append(result, bucket)
			if len(result) == k {
				return result
			}
		}
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
			call:        "topKFrequent([]int{1, 1, 1, 2, 2, 3}, 2)",
			expected:    []int{1, 2},
			run:         func() any { return topKFrequent([]int{1, 1, 1, 2, 2, 3}, 2) },
			explanation: "",
		},
		{
			name:        "Example 2",
			call:        "topKFrequent([]int{1}, 1)",
			expected:    []int{1},
			run:         func() any { return topKFrequent([]int{1}, 1) },
			explanation: "",
		},
		{
			name:        "Example 3",
			call:        "topKFrequent([]int{1, 2, 1, 2, 1, 2, 3, 1, 3, 2}, 2)",
			expected:    []int{1, 2},
			run:         func() any { return topKFrequent([]int{1, 2, 1, 2, 1, 2, 3, 1, 3, 2}, 2) },
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
