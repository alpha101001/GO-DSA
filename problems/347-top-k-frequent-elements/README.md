# 347. Top K Frequent Elements

## Problem

[View the problem on LeetCode](https://leetcode.com/problems/top-k-frequent-elements/description/)

## Description

Given an integer array nums and an integer k, return the k most frequent elements. You may return the answer in any order.

 

Example 1:

Input: nums = [1,1,1,2,2,3], k = 2

Output: [1,2]

Example 2:

Input: nums = [1], k = 1

Output: [1]

Example 3:

Input: nums = [1,2,1,2,1,2,3,1,3,2], k = 2

Output: [1,2]

 

Constraints:

1 <= nums.length <= 105
-104 <= nums[i] <= 104
k is in the range [1, the number of unique elements in the array].
It is guaranteed that the answer is unique.

> This is my own learning summary. Refer to LeetCode for the original problem statement and constraints.

## Function Signature

```go
func topKFrequent(nums []int, k int) []int
```

## Local Examples

| Case | Function call | Expected | Explanation |
|---|---|---|---|
| Example 1 | `topKFrequent([]int{1, 1, 1, 2, 2, 3}, 2)` | `[]int{1, 2}` |  |
| Example 2 | `topKFrequent([]int{1}, 1)` | `[]int{1}` |  |
| Example 3 | `topKFrequent([]int{1, 2, 1, 2, 1, 2, 3, 1, 3, 2}, 2)` | `[]int{1, 2}` |  |

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
go run ./problems/347-top-k-frequent-elements
```
