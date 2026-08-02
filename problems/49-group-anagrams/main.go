package main

import (
	"fmt"
	"os"
	"reflect"
	"slices"
)

func sortString(s string) string {
	chars := []byte(s)
	slices.Sort(chars)

	return string(chars)
}
func groupAnagrams(strs []string) [][]string {
	words := make(map[string][]string)
	for _, str := range strs {
		sortedString := sortString(str)
		words[sortedString] = append(words[sortedString], str)
	}
	result := make([][]string, 0, len(words))
	for _, words := range words {
		result = append(result, words)
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
			name:        "Example 2",
			call:        "groupAnagrams([]string{\"\"})",
			expected:    [][]string{[]string{""}},
			run:         func() any { return groupAnagrams([]string{""}) },
			explanation: "",
		},
		{
			name:        "Example 3",
			call:        "groupAnagrams([]string{\"a\"})",
			expected:    [][]string{[]string{"a"}},
			run:         func() any { return groupAnagrams([]string{"a"}) },
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
