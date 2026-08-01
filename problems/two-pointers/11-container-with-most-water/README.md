# 11. Container With Most Water

## Problem

[View the problem on LeetCode](https://leetcode.com/problems/container-with-most-water/description/)

## Description

You are given an integer array height of length n. There are n vertical lines drawn such that the two endpoints of the ith line are (i, 0) and (i, height[i]).

Find two lines that together with the x-axis form a container, such that the container contains the most water.

Return the maximum amount of water a container can store.

Notice that you may not slant the container.

 

Example 1:


Input: height = [1,8,6,2,5,4,8,3,7]
Output: 49
Explanation: The above vertical lines are represented by array [1,8,6,2,5,4,8,3,7]. In this case, the max area of water (blue section) the container can contain is 49.
Example 2:

Input: height = [1,1]
Output: 1
 

Constraints:

n == height.length
2 <= n <= 105
0 <= height[i] <= 104

> This is my own learning summary. Refer to LeetCode for the original problem statement and constraints.

## Function Signature

```go
func maxArea(height []int) int
```

## Local Examples

| Case | Function call | Expected | Explanation |
|---|---|---|---|
| Example 1 | `maxArea([]int{1, 8, 6, 2, 5, 4, 8, 3, 7})` | `49` | The above vertical lines are represented by array [1,8,6,2,5,4,8,3,7]. In this case, the max area of water (blue section) the container can contain is 49. |
| Example 2 | `maxArea([]int{1, 1})` | `1` |  |

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
go run ./problems/11-container-with-most-water
```
