# GO-DSA

GO-DSA is my personal Go data structures and algorithms practice repository. Problems are based primarily on LeetCode, but this repository stores my own notes rather than copied problem statements.

Each problem directory contains exactly:

- `main.go` — the function scaffold and local example runner.
- `pseudocode.txt` — language-neutral planning notes.
- `README.md` — the link, personal description, function signature, examples, and learning notes.

## Create a problem

From any directory, run:

```bash
./scripts/new-problem.sh
```

The script asks for:

- Problem name.
- Your own problem description.
- LeetCode link.
- Go function signature.
- Confirmation after the examples are parsed.

The description should contain examples in this format:

```text
Example 1:
Input: numbers = [2,7,11,15], target = 9
Output: [1,2]
Explanation: The sum of 2 and 7 is 9.
```

The generator parses only the description you enter. It maps input names to the function parameters, converts bracket notation using the declared Go types, and creates calls such as:

```go
twoSum([]int{2, 7, 11, 15}, 9)
```

If an example is missing, ambiguous, or cannot be converted to the signature's Go types, generation stops with an error before creating the problem directory. The generator does not open or retrieve anything from LeetCode.

When entering the signature, you may paste a full function skeleton beginning with `{`; close it with `}` and the generator will ignore the pasted body.

## Implement and run a problem

The generated function contains a compile-safe `panic("TODO: implement functionName")`. Replace the panic with your own implementation, then run the local examples:

```bash
go run ./problems/two-sum
```

The runner executes every example parsed from the description, prints the actual and expected values, reports `PASS` or `FAIL`, and exits successfully only when all local cases pass. The examples are personal checks, not LeetCode's complete hidden cases.

Results use exact `reflect.DeepEqual` comparison by default. Edit `equalResults` in `main.go` when output order is not significant, multiple outputs are valid, floating-point tolerance is required, or the problem needs a custom comparison. A nil slice and an empty non-nil slice may not be treated as identical.

The automatic scaffold initially supports ordinary top-level Go functions with exactly one returned value and examples using named `Input:` assignments. Methods with receivers, anonymous functions, multiple-return or no-return functions, generic functions requiring explicit type setup, functions using undeclared custom types, and in-place-only validation need manual editing after generation.

Do not copy complete LeetCode problem statements. Keep descriptions and learning notes in your own words.

## Commit and push one completed problem

After finishing one problem, run:

```bash
./scripts/complete-problem.sh
```

The script asks for the problem number, resolves the matching `problems/<number>-<slug>` directory, validates and runs only that problem, stages only its `main.go`, `pseudocode.txt`, and `README.md`, shows the staged diff, generates a Lore-format commit message, and asks for confirmation immediately before committing and immediately before pushing. It uses the configured `origin` remote automatically and asks for a remote name only when `origin` is unavailable.
