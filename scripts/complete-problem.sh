#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPOSITORY_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
TEMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/go-dsa-git.XXXXXX")"

cleanup() {
    if [[ -n "$TEMP_DIR" && -d "$TEMP_DIR" ]]; then
        rm -rf -- "$TEMP_DIR"
    fi
}

trap cleanup EXIT

trim_whitespace() {
    printf '%s' "$1" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//'
}

show_command() {
    printf '\n>>> '
    printf '%q ' "$@"
    printf '\n'
}

run_command() {
    show_command "$@"
    "$@"
}

fail() {
    printf '\nERROR: %s\n' "$1" >&2
    exit 1
}

cd -- "$REPOSITORY_ROOT"

printf 'Repository: %s\n' "$REPOSITORY_ROOT"
run_command git status --short

if ! git rev-parse --show-toplevel >/dev/null 2>&1; then
    fail 'this directory is not a Git repository'
fi

staged_before="$(git diff --cached --name-only)"
if [[ -n "$staged_before" ]]; then
    printf '\nAlready staged files:\n%s\n' "$staged_before" >&2
    fail 'unstage existing files before running this workflow'
fi

branch="$(git branch --show-current)"
if [[ -z "$branch" ]]; then
    fail 'cannot push while HEAD is detached'
fi

read -r -p "Problem number: " problem_number
problem_number="$(trim_whitespace "$problem_number")"
if [[ ! "$problem_number" =~ ^[0-9]+$ ]]; then
    fail 'problem number must contain digits only'
fi

mapfile -t matching_problem_paths < <(
    find problems -mindepth 1 -maxdepth 1 -type d -name "$problem_number-*" -print | LC_ALL=C sort
)
if (( ${#matching_problem_paths[@]} == 0 )); then
    fail "no problem directory starts with $problem_number-"
fi
if (( ${#matching_problem_paths[@]} > 1 )); then
    printf '\nMatching problem directories:\n%s\n' "${matching_problem_paths[*]}" >&2
    fail "problem number is ambiguous: $problem_number"
fi

problem_path="${matching_problem_paths[0]}"
printf 'Resolved problem directory: %s\n' "$problem_path"

expected_children=$'README.md\nmain.go\npseudocode.txt'
actual_children="$(find "$problem_path" -mindepth 1 -maxdepth 1 -printf '%f\n' | LC_ALL=C sort)"
if [[ "$actual_children" != "$expected_children" ]]; then
    printf '\nExpected exactly these files:\n%s\n' "$expected_children" >&2
    printf 'Found:\n%s\n' "$actual_children" >&2
    fail 'problem directory must contain exactly README.md, main.go, and pseudocode.txt'
fi
for required_file in README.md main.go pseudocode.txt; do
    if [[ ! -f "$problem_path/$required_file" ]]; then
        fail "required file is not a regular file: $problem_path/$required_file"
    fi
done

problem_title="$(awk '/^# / {sub(/^# /, ""); print; exit}' "$problem_path/README.md")"
if [[ -z "$problem_title" ]]; then
    problem_title="${problem_path#problems/}"
fi

remote_name="origin"
if remote_url="$(git remote get-url "$remote_name" 2>/dev/null)"; then
    printf 'Using configured push remote: %s (%s)\n' "$remote_name" "$remote_url"
else
    printf 'No origin remote is configured.\n' >&2
    read -r -p "Push remote name: " remote_name
    remote_name="$(trim_whitespace "$remote_name")"
    if [[ -z "$remote_name" ]]; then
        fail 'push remote name is required when origin is unavailable'
    fi
    if ! remote_url="$(git remote get-url "$remote_name" 2>/dev/null)"; then
        fail "Git remote does not exist: $remote_name"
    fi
fi

printf '\nProblem: %s\n' "$problem_title"
printf 'Path: %s\n' "$problem_path"
printf 'Branch: %s\n' "$branch"
printf 'Remote: %s (%s)\n' "$remote_name" "$remote_url"

printf '\nChecking Go formatting...\n'
show_command gofmt -d "$problem_path/main.go"
gofmt_diff="$(gofmt -d "$problem_path/main.go")"
if [[ -n "$gofmt_diff" ]]; then
    printf '%s\n' "$gofmt_diff"
    fail 'main.go is not gofmt-clean'
fi
printf 'gofmt: clean\n'

printf '\nRunning local examples...\n'
run_command go run "./$problem_path"

printf '\nStaging only this problem...\n'
run_command git add -- \
    "$problem_path/README.md" \
    "$problem_path/main.go" \
    "$problem_path/pseudocode.txt"

staged_after="$(git diff --cached --name-only | LC_ALL=C sort)"
expected_staged="$problem_path/README.md
$problem_path/main.go
$problem_path/pseudocode.txt"
if [[ "$staged_after" != "$expected_staged" ]]; then
    printf '\nStaged files:\n%s\n' "$staged_after" >&2
    fail 'staging contained files outside the selected problem'
fi

printf '\nChecking staged whitespace...\n'
show_command git diff --cached --check
whitespace_notices="$(git diff --cached --check || true)"
if [[ -n "$whitespace_notices" ]]; then
    printf 'Whitespace notices (non-blocking):\n%s\n' "$whitespace_notices"
else
    printf 'No whitespace notices.\n'
fi
printf '\nStaged files:\n%s\n' "$staged_after"

read -r -p "Approach summary for the commit (optional): " approach_summary
approach_summary="$(trim_whitespace "$approach_summary")"
if [[ -z "$approach_summary" ]]; then
    approach_summary="Completed the implementation and supporting notes for the local problem examples."
fi

read -r -p "Verification summary [go fmt and local examples passed]: " verification_summary
verification_summary="$(trim_whitespace "$verification_summary")"
if [[ -z "$verification_summary" ]]; then
    verification_summary="gofmt and go run ./$problem_path"
fi

read -r -p "Known verification gaps [hidden cases]: " not_tested
not_tested="$(trim_whitespace "$not_tested")"
if [[ -z "$not_tested" ]]; then
    not_tested="Complete online judge hidden cases were not run."
fi

commit_message_file="$TEMP_DIR/commit-message.txt"
{
    printf 'Complete %s practice solution\n\n' "$problem_title"
    printf '%s\n\n' "$approach_summary"
    printf 'Constraint: Keep the problem scoped to main.go, pseudocode.txt, and README.md\n'
    printf 'Confidence: high\n'
    printf 'Scope-risk: narrow\n'
    printf 'Reversibility: clean\n'
    printf 'Tested: %s\n' "$verification_summary"
    printf 'Not-tested: %s\n' "$not_tested"
    printf 'Directive: Keep future changes focused on this problem and preserve equalResults for custom comparison needs\n'
} > "$commit_message_file"

printf '\nGenerated commit message:\n'
sed -n '1,160p' "$commit_message_file"

read -r -p "Commit these staged files? [y/N]: " commit_confirmation
case "${commit_confirmation,,}" in
    y|yes)
        printf '\nCommitting...\n'
        run_command git commit --file "$commit_message_file"
        ;;
    *)
        printf '\nCommit skipped. Files remain staged for review.\n'
        exit 0
        ;;
esac

printf '\nLatest commit:\n'
run_command git show --stat --oneline --decorate HEAD

read -r -p "Push this commit to $remote_name/$branch? [y/N]: " push_confirmation
case "${push_confirmation,,}" in
    y|yes)
        printf '\nPushing...\n'
        run_command git push "$remote_name" "$branch"
        printf '\nPush completed.\n'
        ;;
    *)
        printf '\nPush skipped. The commit remains local.\n'
        exit 0
        ;;
esac

printf '\nFinal Git status:\n'
run_command git status --short
