# 167. Two Sum II - Input Array Is Sorted

## Problem

[View the problem on LeetCode](https://leetcode.com/problems/two-sum-ii-input-array-is-sorted/description/)

## Description

Given a 1-indexed array of integers numbers that is already sorted in non-decreasing order, find two numbers such that they add up to a specific target number. Let these two numbers be numbers[index1] and numbers[index2] where 1 <= index1 < index2 <= numbers.length.

Return the indices of the two numbers index1 and index2, each incremented by one, as an integer array [index1, index2] of length 2.

The tests are generated such that there is exactly one solution. You may not use the same element twice.

Your solution must use only constant extra space.

 

Example 1:

Input: numbers = [2,7,11,15], target = 9
Output: [1,2]
Explanation: The sum of 2 and 7 is 9. Therefore, index1 = 1, index2 = 2. We return [1, 2].
Example 2:

Input: numbers = [2,3,4], target = 6
Output: [1,3]
Explanation: The sum of 2 and 4 is 6. Therefore index1 = 1, index2 = 3. We return [1, 3].
Example 3:

Input: numbers = [-1,0], target = -1
Output: [1,2]
Explanation: The sum of -1 and 0 is -1. Therefore index1 = 1, index2 = 2. We return [1, 2].
 

Constraints:

2 <= numbers.length <= 3 * 104
-1000 <= numbers[i] <= 1000
numbers is sorted in non-decreasing order.
-1000 <= target <= 1000
The tests are generated such that there is exactly one solution.

> This is my own learning summary. Refer to LeetCode for the original problem statement and constraints.

## Function Signature

```go
func twoSum(numbers []int, target int) []int
```

## Local Examples

| Case | Function call | Expected | Explanation |
|---|---|---|---|
| Example 1 | `twoSum([]int{2, 7, 11, 15}, 9)` | `[]int{1, 2}` | The sum of 2 and 7 is 9. Therefore, index1 = 1, index2 = 2. We return [1, 2]. |
| Example 2 | `twoSum([]int{2, 3, 4}, 6)` | `[]int{1, 3}` | The sum of 2 and 4 is 6. Therefore index1 = 1, index2 = 3. We return [1, 3]. |
| Example 3 | `twoSum([]int{-1, 0}, -1)` | `[]int{1, 2}` | The sum of -1 and 0 is -1. Therefore index1 = 1, index2 = 2. We return [1, 2]. |

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
go run ./problems/167-two-sum-ii-input-array-is-sorted
```
