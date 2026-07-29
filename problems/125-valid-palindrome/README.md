# 125. Valid Palindrome

## Problem

[View the problem on LeetCode](https://leetcode.com/problems/valid-palindrome/description/)

## Description

A phrase is a palindrome if, after converting all uppercase letters into lowercase letters and removing all non-alphanumeric characters, it reads the same forward and backward. Alphanumeric characters include letters and numbers.

Given a string s, return true if it is a palindrome, or false otherwise.

 

Example 1:

Input: s = "A man, a plan, a canal: Panama"
Output: true
Explanation: "amanaplanacanalpanama" is a palindrome.
Example 2:

Input: s = "race a car"
Output: false
Explanation: "raceacar" is not a palindrome.
Example 3:

Input: s = " "
Output: true
Explanation: s is an empty string "" after removing non-alphanumeric characters.
Since an empty string reads the same forward and backward, it is a palindrome.
 

Constraints:

1 <= s.length <= 2 * 105
s consists only of printable ASCII characters.

> This is my own learning summary. Refer to LeetCode for the original problem statement and constraints.

## Function Signature

```go
func isPalindrome(s string) bool
```

## Local Examples

| Case | Function call | Expected | Explanation |
|---|---|---|---|
| Example 1 | `isPalindrome("A man, a plan, a canal: Panama")` | `true` | "amanaplanacanalpanama" is a palindrome. |
| Example 2 | `isPalindrome("race a car")` | `false` | "raceacar" is not a palindrome. |
| Example 3 | `isPalindrome(" ")` | `true` | s is an empty string "" after removing non-alphanumeric characters. |

## Approach

Write the approach here after understanding the problem.

## Complexity

- **Time:** TODO
- **Space:** TODO

## What I Learned

Write mistakes, observations and lessons here.

## Local Validation

The generated runner uses exact `reflect.DeepEqual` equality by default. A nil slice and an empty non-nil slice may not be treated as identical.

Edit `equalResults` in `main.go` when output order is not significant, multiple outputs are valid, floating-point tolerance is required, or the problem needs a custom comparison.

Passing these local examples does not guarantee acceptance against LeetCode's complete test suite.

## Run

From the repository root:

```bash
go run ./problems/125-valid-palindrome
```
