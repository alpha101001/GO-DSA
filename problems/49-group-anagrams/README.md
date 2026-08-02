# 49. Group Anagrams

## Problem

[View the problem on LeetCode](https://leetcode.com/problems/group-anagrams/description/)

## Description

Given an array of strings strs, group the anagrams together. You can return the answer in any order.

 

Example 1:

Input: strs = ["eat","tea","tan","ate","nat","bat"]

Output: [["bat"],["nat","tan"],["ate","eat","tea"]]

Explanation:

There is no string in strs that can be rearranged to form "bat".
The strings "nat" and "tan" are anagrams as they can be rearranged to form each other.
The strings "ate", "eat", and "tea" are anagrams as they can be rearranged to form each other.
Example 2:

Input: strs = [""]

Output: [[""]]

Example 3:

Input: strs = ["a"]

Output: [["a"]]

 

Constraints:

1 <= strs.length <= 104
0 <= strs[i].length <= 100
strs[i] consists of lowercase English letters.

> This is my own learning summary. Refer to LeetCode for the original problem statement and constraints.

## Function Signature

```go
func groupAnagrams(strs []string) [][]string
```

## Local Examples

| Case | Function call | Expected | Explanation |
|---|---|---|---|
| Example 1 | `groupAnagrams([]string{"eat", "tea", "tan", "ate", "nat", "bat"})` | `[][]string{[]string{"bat"}, []string{"nat", "tan"}, []string{"ate", "eat", "tea"}}` |  |
| Example 2 | `groupAnagrams([]string{""})` | `[][]string{[]string{""}}` |  |
| Example 3 | `groupAnagrams([]string{"a"})` | `[][]string{[]string{"a"}}` |  |

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
go run ./problems/49-group-anagrams
```
