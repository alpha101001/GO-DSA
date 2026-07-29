# Repository instructions

GO-DSA is a minimal personal Go DSA practice repository.

Future Codex sessions must:

1. Keep the repository minimal.
2. Do not add tests unless I explicitly request them.
3. Do not add `solution_test.go`.
4. Do not add a separate test-case file.
5. Do not add metadata or indexes.
6. Do not add GitHub Actions.
7. Do not add another generator.
8. Do not scrape LeetCode.
9. Do not parse or retrieve examples from LeetCode automatically.
10. Use only problem information and examples entered by the user.
11. Do not copy complete LeetCode problem statements.
12. Do not solve a generated function unless I explicitly request help.
13. Keep the generated TODO function compile-safe.
14. Never execute user input through shell `eval`.
15. Preserve `equalResults` as the generated runner's customization point.
16. Do not automatically sort outputs.
17. Keep each problem limited to exactly:
    - `main.go`
    - `pseudocode.txt`
    - `README.md`
18. Do not commit or push unless explicitly requested.

The generator asks for a Go function signature, parses `Example N:` blocks from the user-entered description, and creates typed local validation cases inside `main.go`. It keeps the function implementation as a TODO panic and must not generate an algorithm or a copied solution. It parses only text entered by the user; it does not retrieve or scrape examples from LeetCode.

The supported workflow is:

```bash
./scripts/new-problem.sh
```

After completing one problem, use `./scripts/complete-problem.sh` with the problem number to resolve, validate, stage, commit, and optionally push only that problem. It must show each action and ask for confirmation only immediately before commit and push.
