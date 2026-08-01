# 1. Two Sum

## Problem

[View the problem on LeetCode](https://leetcode.com/problems/two-sum/description/)

## Description

You are given an array of integers nums and an integer target, return indices of the two numbers such that they add up to target.

You may assume that each input would have exactly one solution, and you may not use the same element twice.

You can return the answer in any order.

 

Example 1:

Input: nums = [2,7,11,15], target = 9
Output: [0,1]
Explanation: Because nums[0] + nums[1] == 9, we return [0, 1].
Example 2:

Input: nums = [3,2,4], target = 6
Output: [1,2]
Example 3:

Input: nums = [3,3], target = 6
Output: [0,1]
 

Constraints:

2 <= nums.length <= 104
-109 <= nums[i] <= 109
-109 <= target <= 109
Only one valid answer exists.


> This is my own learning summary. Refer to LeetCode for the original problem statement and constraints.

## Function Signature

```go
func twoSum(nums []int, target int) []int
```

## Local Examples

| Case | Function call | Expected | Explanation |
|---|---|---|---|
| Example 1 | `twoSum([]int{2, 7, 11, 15}, 9)` | `[]int{0, 1}` | Because nums[0] + nums[1] == 9, we return [0, 1]. |
| Example 2 | `twoSum([]int{3, 2, 4}, 6)` | `[]int{1, 2}` |  |
| Example 3 | `twoSum([]int{3, 3}, 6)` | `[]int{0, 1}` |  |

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
go run ./problems/1-two-sum
```
