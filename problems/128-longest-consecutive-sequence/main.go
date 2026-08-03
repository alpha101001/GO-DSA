package main

import (
	"fmt"
	"os"
	"reflect"
)

func toSet[T comparable](values []T) map[T]struct{} {
	set := make(map[T]struct{}, len(values))

	for _, value := range values {
		set[value] = struct{}{}
	}

	return set
}
func longestConsecutive(nums []int) int {
	numSet := toSet(nums)
	best := 1
	for num := range numSet {
		if _, ok := numSet[num-1]; ok {
			continue
		}
		length := 1
		for _, ok := numSet[num+length]; ok; _, ok = numSet[num+length] {
			length++
		}
		best = max(best, length)
	}
	return best
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
			call:        "longestConsecutive([]int{100, 4, 200, 1, 3, 2})",
			expected:    4,
			run:         func() any { return longestConsecutive([]int{100, 4, 200, 1, 3, 2}) },
			explanation: "The longest consecutive elements sequence is [1, 2, 3, 4]. Therefore its length is 4.",
		},
		{
			name:        "Example 2",
			call:        "longestConsecutive([]int{0, 3, 7, 2, 5, 8, 4, 6, 0, 1})",
			expected:    9,
			run:         func() any { return longestConsecutive([]int{0, 3, 7, 2, 5, 8, 4, 6, 0, 1}) },
			explanation: "",
		},
		{
			name:        "Example 3",
			call:        "longestConsecutive([]int{1, 0, 1, 2})",
			expected:    3,
			run:         func() any { return longestConsecutive([]int{1, 0, 1, 2}) },
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
