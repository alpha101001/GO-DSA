package main

import (
	"fmt"
	"os"
	"reflect"
)

func alnum(char byte) bool {
	if (char >= 'a' && char <= 'z') || (char >= '0' && char <= '9') {
		return true
	}
	return false

}

func toLower(char byte) byte {
	if char >= 'A' && char <= 'Z' {
		return char + ('a' - 'A')
	}
	return char
}

func isPalindrome(s string) bool {
	var n int = len(s)
	var left int = 0
	var right int = n - 1
	for left < right {
		if !alnum(toLower(s[left])) {
			left++
			continue
		} else if !alnum(toLower(s[right])) {
			right--
			continue
		} else if toLower(s[left]) != toLower(s[right]) {
			return false
		}
		left++
		right--

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
			call:        "isPalindrome(\"A man, a plan, a canal: Panama\")",
			expected:    true,
			run:         func() any { return isPalindrome("A man, a plan, a canal: Panama") },
			explanation: "\"amanaplanacanalpanama\" is a palindrome.",
		},
		{
			name:        "Example 2",
			call:        "isPalindrome(\"race a car\")",
			expected:    false,
			run:         func() any { return isPalindrome("race a car") },
			explanation: "\"raceacar\" is not a palindrome.",
		},
		{
			name:        "Example 3",
			call:        "isPalindrome(\" \")",
			expected:    true,
			run:         func() any { return isPalindrome(" ") },
			explanation: "s is an empty string \"\" after removing non-alphanumeric characters.",
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
