# 128. Longest Consecutive Sequence

## Problem

[View the problem on LeetCode](https://leetcode.com/problems/longest-consecutive-sequence/description/)

## Description

Given an unsorted array of integers nums, return the length of the longest consecutive elements sequence.

You must write an algorithm that runs in O(n) time.

 

Example 1:

Input: nums = [100,4,200,1,3,2]
Output: 4
Explanation: The longest consecutive elements sequence is [1, 2, 3, 4]. Therefore its length is 4.
Example 2:

Input: nums = [0,3,7,2,5,8,4,6,0,1]
Output: 9
Example 3:

Input: nums = [1,0,1,2]
Output: 3
 

Constraints:

0 <= nums.length <= 105
-109 <= nums[i] <= 109

> This is my own learning summary. Refer to LeetCode for the original problem statement and constraints.

## Function Signature

```go
func longestConsecutive(nums []int) int
```

## Local Examples

| Case | Function call | Expected | Explanation |
|---|---|---|---|
| Example 1 | `longestConsecutive([]int{100, 4, 200, 1, 3, 2})` | `4` | The longest consecutive elements sequence is [1, 2, 3, 4]. Therefore its length is 4. |
| Example 2 | `longestConsecutive([]int{0, 3, 7, 2, 5, 8, 4, 6, 0, 1})` | `9` |  |
| Example 3 | `longestConsecutive([]int{1, 0, 1, 2})` | `3` |  |

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
go run ./problems/128-longest-consecutive-sequence
```
