# 15. 3Sum

## Problem

[View the problem on LeetCode](https://leetcode.com/problems/3sum/description/)

## Description

Given an integer array nums, return all the triplets [nums[i], nums[j], nums[k]] such that i != j, i != k, and j != k, and nums[i] + nums[j] + nums[k] == 0.

Notice that the solution set must not contain duplicate triplets.

 

Example 1:

Input: nums = [-1,0,1,2,-1,-4]
Output: [[-1,-1,2],[-1,0,1]]
Explanation: 
nums[0] + nums[1] + nums[2] = (-1) + 0 + 1 = 0.
nums[1] + nums[2] + nums[4] = 0 + 1 + (-1) = 0.
nums[0] + nums[3] + nums[4] = (-1) + 2 + (-1) = 0.
The distinct triplets are [-1,0,1] and [-1,-1,2].
Notice that the order of the output and the order of the triplets does not matter.
Example 2:

Input: nums = [0,1,1]
Output: []
Explanation: The only possible triplet does not sum up to 0.
Example 3:

Input: nums = [0,0,0]
Output: [[0,0,0]]
Explanation: The only possible triplet sums up to 0.
 

Constraints:

3 <= nums.length <= 3000
-105 <= nums[i] <= 105

> This is my own learning summary. Refer to LeetCode for the original problem statement and constraints.

## Function Signature

```go
func threeSum(nums []int) [][]int
```

## Local Examples

| Case | Function call | Expected | Explanation |
|---|---|---|---|
| Example 1 | `threeSum([]int{-1, 0, 1, 2, -1, -4})` | `[][]int{[]int{-1, -1, 2}, []int{-1, 0, 1}}` |  |
| Example 2 | `threeSum([]int{0, 1, 1})` | `[][]int{}` | The only possible triplet does not sum up to 0. |
| Example 3 | `threeSum([]int{0, 0, 0})` | `[][]int{[]int{0, 0, 0}}` | The only possible triplet sums up to 0. |

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
go run ./problems/15-3sum
```
