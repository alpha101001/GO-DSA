package main

import (
	"fmt"
	"os"
	"reflect"
)

func isAnagram(s string, t string) bool {
	if len(s) != len(t) {
		return false
	}
	a := make(map[rune]int)
	for _, ch := range s {
		a[ch]++
	}
	for _, ch := range t {
		a[ch]--
		if a[ch] < 0 {
			return false
		}
	}
	return true
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
			call:        "isAnagram(\"anagram\", \"nagaram\")",
			expected:    true,
			run:         func() any { return isAnagram("anagram", "nagaram") },
			explanation: "",
		},
		{
			name:        "Example 2",
			call:        "isAnagram(\"rat\", \"car\")",
			expected:    false,
			run:         func() any { return isAnagram("rat", "car") },
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
