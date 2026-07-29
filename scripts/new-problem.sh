#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPOSITORY_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
PROBLEMS_DIR="$REPOSITORY_ROOT/problems"

TEMP_DIR=""
CREATED_DIRECTORY=""

cleanup() {
    if [[ -n "$CREATED_DIRECTORY" && -d "$CREATED_DIRECTORY" ]]; then
        rm -rf -- "$CREATED_DIRECTORY"
    fi
    if [[ -n "$TEMP_DIR" && -d "$TEMP_DIR" ]]; then
        rm -rf -- "$TEMP_DIR"
    fi
}

trap cleanup EXIT

slugify() {
    local value="$1"

    value="${value,,}"
    value="$(printf '%s' "$value" | LC_ALL=C sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//')"
    printf '%s\n' "$value"
}

trim_whitespace() {
    printf '%s' "$1" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//'
}

is_nonempty() {
    [[ -n "${1//[[:space:]]/}" ]]
}

valid_leetcode_url() {
    local url="$1"
    local authority host port normalized_host

    [[ "$url" =~ ^https://([^/?#]+)([/?#].*)?$ ]] || return 1

    authority="${BASH_REMATCH[1]}"
    [[ "$authority" != *"@"* ]] || return 1

    if [[ "$authority" == *:* ]]; then
        host="${authority%%:*}"
        port="${authority#*:}"
        [[ "$port" =~ ^[0-9]+$ ]] || return 1
    else
        host="$authority"
    fi

    normalized_host="$(printf '%s' "$host" | LC_ALL=C tr '[:upper:]' '[:lower:]')"
    [[ "$normalized_host" == "leetcode.com" || "$normalized_host" =~ ^([a-z0-9]([a-z0-9-]*[a-z0-9])?\.)+leetcode\.com$ ]]
}

read_problem_description() {
    local line
    local complete=0
    local result=""

    printf '%s\n' "Enter your own problem description." >&2
    printf '%s\n' "Include each example as Example N:, Input: name = value, ..., Output: value." >&2
    printf '%s\n' "Enter a line containing only END when finished:" >&2

    while IFS= read -r line; do
        if [[ "$line" == "END" ]]; then
            complete=1
            break
        fi

        if [[ -n "$result" ]]; then
            result+=$'\n'
        fi
        result+="$line"
    done

    if (( complete == 0 )); then
        printf '%s\n' "Error: description must end with a line containing only END." >&2
        exit 1
    fi
    if ! is_nonempty "$result"; then
        printf '%s\n' "Error: problem description is required." >&2
        exit 1
    fi

    problem_description="$result"
}

go_string_literal() {
    local value="$1"

    value="${value//\\/\\\\}"
    value="${value//\"/\\\"}"
    value="${value//$'\t'/\\t}"
    value="${value//$'\r'/\\r}"
    value="${value//$'\n'/\\n}"
    printf '%s' "$value"
}

markdown_cell() {
    printf '%s' "$1" | sed 's/|/\\|/g; s/`/\\`/g'
}

find_matching_parenthesis() {
    local text="$1"
    local depth=0
    local character
    local index

    [[ "${text:0:1}" == "(" ]] || return 1

    for ((index = 0; index < ${#text}; index++)); do
        character="${text:index:1}"
        case "$character" in
            '(')
                depth=$((depth + 1))
                ;;
            ')')
                depth=$((depth - 1))
                if (( depth < 0 )); then
                    return 1
                fi
                if (( depth == 0 )); then
                    MATCHING_PARENTHESIS_INDEX="$index"
                    return 0
                fi
                ;;
        esac
    done

    return 1
}

has_top_level_comma() {
    local text="$1"
    local depth=0
    local character
    local index

    for ((index = 0; index < ${#text}; index++)); do
        character="${text:index:1}"
        case "$character" in
            '(')
                depth=$((depth + 1))
                ;;
            ')')
                depth=$((depth - 1))
                ;;
            ',')
                if (( depth == 0 )); then
                    return 0
                fi
                ;;
        esac
    done

    return 1
}

SPLIT_PARTS=()

split_top_level_commas() {
    local text="$1"
    local current=""
    local character quote=""
    local escaped=0
    local depth=0
    local index

    SPLIT_PARTS=()

    for ((index = 0; index < ${#text}; index++)); do
        character="${text:index:1}"

        if [[ -n "$quote" ]]; then
            current+="$character"
            if (( escaped == 1 )); then
                escaped=0
            elif [[ "$character" == "\\" && "$quote" != '`' ]]; then
                escaped=1
            elif [[ "$character" == "$quote" ]]; then
                quote=""
            fi
            continue
        fi

        case "$character" in
            '"'|"'"|'`')
                quote="$character"
                current+="$character"
                ;;
            '('|'['|'{')
                depth=$((depth + 1))
                current+="$character"
                ;;
            ')'|']'|'}')
                depth=$((depth - 1))
                if (( depth < 0 )); then
                    return 1
                fi
                current+="$character"
                ;;
            ',')
                if (( depth == 0 )); then
                    SPLIT_PARTS+=("$(trim_whitespace "$current")")
                    current=""
                else
                    current+="$character"
                fi
                ;;
            *)
                current+="$character"
                ;;
        esac
    done

    if [[ -n "$quote" || "$escaped" -eq 1 || "$depth" -ne 0 ]]; then
        return 1
    fi

    if [[ -n "$(trim_whitespace "$current")" || ${#SPLIT_PARTS[@]} -gt 0 ]]; then
        SPLIT_PARTS+=("$(trim_whitespace "$current")")
    fi
}

parameter_names=()
parameter_types=()
return_type=""

extract_signature_metadata() {
    local remainder parameter_close parameter_text declaration names_text parameter_type
    local parameter_name result_part result_contents
    local index name_index

    remainder="${function_signature#func }"
    remainder="${remainder#"$function_name"}"
    remainder="$(trim_whitespace "$remainder")"
    find_matching_parenthesis "$remainder"
    parameter_close="$MATCHING_PARENTHESIS_INDEX"
    parameter_text="${remainder:1:$((parameter_close - 1))}"
    return_type="$(trim_whitespace "${remainder:$((parameter_close + 1))}")"

    if [[ "${return_type:0:1}" == '(' ]]; then
        result_contents="${return_type:1:$(( ${#return_type} - 2 ))}"
        if [[ "$result_contents" =~ ^[A-Za-z_][A-Za-z0-9_]*[[:space:]]+(.+)$ ]]; then
            return_type="$(trim_whitespace "${BASH_REMATCH[1]}")"
        else
            return_type="$(trim_whitespace "$result_contents")"
        fi
    fi

    parameter_names=()
    parameter_types=()
    if [[ -z "$(trim_whitespace "$parameter_text")" ]]; then
        return 0
    fi
    if ! split_top_level_commas "$parameter_text"; then
        return 1
    fi

    for declaration in "${SPLIT_PARTS[@]}"; do
        if [[ ! "$declaration" =~ ^([A-Za-z_][A-Za-z0-9_]*(,[[:space:]]*[A-Za-z_][A-Za-z0-9_]*)*)[[:space:]]+(.+)$ ]]; then
            return 1
        fi

        names_text="${BASH_REMATCH[1]}"
        parameter_type="$(trim_whitespace "${BASH_REMATCH[3]}")"
        split_top_level_commas "$names_text"
        for parameter_name in "${SPLIT_PARTS[@]}"; do
            parameter_names+=("$(trim_whitespace "$parameter_name")")
            parameter_types+=("$parameter_type")
        done
    done

    for ((index = 0; index < ${#parameter_names[@]}; index++)); do
        for ((name_index = index + 1; name_index < ${#parameter_names[@]}; name_index++)); do
            if [[ "${parameter_names[$index]}" == "${parameter_names[$name_index]}" ]]; then
                return 1
            fi
        done
    done
}

convert_example_literal() {
    local raw_value="$(trim_whitespace "$1")"
    local target_type="$(trim_whitespace "$2")"
    local inner_type inner_text item converted result
    local index

    if [[ "$raw_value" == "null" ]]; then
        case "$target_type" in
            \[*|map\[*|*\&|*\*)
                printf '%s\n' 'nil'
                return 0
                ;;
            *)
                return 1
                ;;
        esac
    fi

    if [[ "${raw_value:0:1}" == '[' && "${raw_value: -1}" == ']' ]]; then
        if [[ "${target_type:0:2}" != '[]' ]]; then
            return 1
        fi

        inner_type="${target_type:2}"
        inner_text="${raw_value:1:$(( ${#raw_value} - 2 ))}"
        result="$target_type{" 
        if [[ -n "$(trim_whitespace "$inner_text")" ]]; then
            if ! split_top_level_commas "$inner_text"; then
                return 1
            fi
            for ((index = 0; index < ${#SPLIT_PARTS[@]}; index++)); do
                item="${SPLIT_PARTS[$index]}"
                if ! converted="$(convert_example_literal "$item" "$inner_type")"; then
                    return 1
                fi
                if (( index > 0 )); then
                    result+=", "
                fi
                result+="$converted"
            done
        fi
        result+='}'
        printf '%s\n' "$result"
        return 0
    fi

    printf '%s\n' "$raw_value"
}

example_parse_error=""
parsed_arguments=""
parsed_expected=""

parse_example_input() {
    local input_text="$1"
    local assignment input_name input_value converted
    local index found
    local -a values=()

    if ! split_top_level_commas "$input_text" || (( ${#SPLIT_PARTS[@]} == 0 )); then
        example_parse_error="input must contain comma-separated name = value assignments"
        return 1
    fi

    for assignment in "${SPLIT_PARTS[@]}"; do
        if [[ "$assignment" != *'='* ]]; then
            example_parse_error="input assignment is missing =: $assignment"
            return 1
        fi
        input_name="$(trim_whitespace "${assignment%%=*}")"
        input_value="$(trim_whitespace "${assignment#*=}")"
        found=0
        for ((index = 0; index < ${#parameter_names[@]}; index++)); do
            if [[ "$input_name" == "${parameter_names[$index]}" ]]; then
                if (( found == 1 )); then
                    example_parse_error="input contains duplicate parameter: $input_name"
                    return 1
                fi
                if ! converted="$(convert_example_literal "$input_value" "${parameter_types[$index]}")"; then
                    example_parse_error="could not convert $input_name = $input_value to ${parameter_types[$index]}"
                    return 1
                fi
                values[$index]="$converted"
                found=1
                break
            fi
        done
        if (( found == 0 )); then
            example_parse_error="input name does not match the function signature: $input_name"
            return 1
        fi
    done

    parsed_arguments=""
    for ((index = 0; index < ${#parameter_names[@]}; index++)); do
        if [[ -z "${values[$index]+present}" ]]; then
            example_parse_error="input is missing parameter: ${parameter_names[$index]}"
            return 1
        fi
        if (( index > 0 )); then
            parsed_arguments+=", "
        fi
        parsed_arguments+="${values[$index]}"
    done
}

append_parsed_example() {
    local case_name="$1"
    local input_text="$2"
    local output_text="$3"
    local explanation="$4"

    if [[ -z "$input_text" || -z "$output_text" ]]; then
        example_parse_error="$case_name must contain both Input: and Output: lines"
        return 1
    fi
    if ! parse_example_input "$input_text"; then
        return 1
    fi
    if ! parsed_expected="$(convert_example_literal "$output_text" "$return_type")"; then
        example_parse_error="could not convert output $output_text to $return_type"
        return 1
    fi

    test_case_names+=("$case_name")
    test_case_arguments+=("$parsed_arguments")
    test_case_expected+=("$parsed_expected")
    test_case_explanations+=("$explanation")
    test_case_calls+=("$function_name($parsed_arguments)")
}

parse_description_examples() {
    local line current_name="" current_input="" current_output="" current_explanation=""
    local found_example=0

    while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ "$line" =~ ^[[:space:]]*Example[[:space:]]+([0-9]+)[[:space:]]*:[[:space:]]*$ ]]; then
            if (( found_example == 1 )); then
                if ! append_parsed_example "$current_name" "$current_input" "$current_output" "$current_explanation"; then
                    return 1
                fi
            fi
            current_name="Example ${BASH_REMATCH[1]}"
            current_input=""
            current_output=""
            current_explanation=""
            found_example=1
        elif (( found_example == 1 )) && [[ "$line" =~ ^[[:space:]]*Input:[[:space:]]*(.*)$ ]]; then
            current_input="$(trim_whitespace "${BASH_REMATCH[1]}")"
        elif (( found_example == 1 )) && [[ "$line" =~ ^[[:space:]]*Output:[[:space:]]*(.*)$ ]]; then
            current_output="$(trim_whitespace "${BASH_REMATCH[1]}")"
        elif (( found_example == 1 )) && [[ "$line" =~ ^[[:space:]]*Explanation:[[:space:]]*(.*)$ ]]; then
            current_explanation="$(trim_whitespace "${BASH_REMATCH[1]}")"
        fi
    done <<< "$problem_description"

    if (( found_example == 0 )); then
        example_parse_error="no Example N: blocks were found in the description"
        return 1
    fi
    if ! append_parsed_example "$current_name" "$current_input" "$current_output" "$current_explanation"; then
        return 1
    fi
    test_case_count="${#test_case_names[@]}"
    if (( test_case_count < 1 || test_case_count > 20 )); then
        example_parse_error="the description must contain between 1 and 20 examples"
        return 1
    fi
}

signature_error=""
function_name=""
function_signature=""

validate_function_signature() {
    local candidate="$1"
    local remainder parameter_close return_part result_contents result_close
    local extracted_name

    signature_error=""
    : > "$TEMP_DIR/signature-gofmt-error.txt"
    : > "$TEMP_DIR/signature-build-error.txt"

    if [[ -z "$candidate" ]]; then
        signature_error="function signature is required"
        return 1
    fi
    if [[ "$candidate" == *$'\n'* || "$candidate" == *$'\r'* ]]; then
        signature_error="function signature must be on one line"
        return 1
    fi
    if [[ "$candidate" == *';'* ]]; then
        signature_error="function signature must not contain semicolons"
        return 1
    fi
    if [[ "$candidate" == *'{'* || "$candidate" == *'}'* ]]; then
        signature_error="enter only the declaration, not a function body"
        return 1
    fi
    if [[ "$candidate" == *'//'* || "$candidate" == *'/*'* || "$candidate" == *'*/'* ]]; then
        signature_error="function signature must not contain comments or extra code"
        return 1
    fi
    if [[ ! "$candidate" =~ ^func[[:space:]]+([A-Za-z_][A-Za-z0-9_]*)[[:space:]]*(.*)$ ]]; then
        signature_error="signature must start with func and contain a plain function name"
        return 1
    fi

    extracted_name="${BASH_REMATCH[1]}"
    remainder="$(trim_whitespace "${BASH_REMATCH[2]}")"

    if [[ "$remainder" == \[* ]]; then
        signature_error="generic functions are not supported automatically"
        return 1
    fi
    if [[ "${remainder:0:1}" != "(" ]]; then
        signature_error="signature must include a parameter list"
        return 1
    fi
    if ! find_matching_parenthesis "$remainder"; then
        signature_error="parameter list is not balanced"
        return 1
    fi

    parameter_close="$MATCHING_PARENTHESIS_INDEX"
    return_part="$(trim_whitespace "${remainder:$((parameter_close + 1))}")"
    if [[ -z "$return_part" ]]; then
        signature_error="signature must declare exactly one returned value"
        return 1
    fi

    if [[ "${return_part:0:1}" == "(" ]]; then
        if ! find_matching_parenthesis "$return_part"; then
            signature_error="returned value list is not balanced"
            return 1
        fi
        result_close="$MATCHING_PARENTHESIS_INDEX"
        if [[ -n "$(trim_whitespace "${return_part:$((result_close + 1))}")" ]]; then
            signature_error="returned value list contains extra code"
            return 1
        fi
        result_contents="${return_part:1:$((result_close - 1))}"
        if ! is_nonempty "$result_contents"; then
            signature_error="signature must declare exactly one returned value"
            return 1
        fi
        if has_top_level_comma "$result_contents"; then
            signature_error="multiple returned values are not supported automatically"
            return 1
        fi
    fi

    function_name="$extracted_name"
    function_signature="$candidate"
    printf 'package signaturecheck\n\n%s {\n\tpanic("TODO: signature validation")\n}\n' "$candidate" > "$TEMP_DIR/signature.go"

    if ! gofmt -w "$TEMP_DIR/signature.go" 2> "$TEMP_DIR/signature-gofmt-error.txt"; then
        signature_error="signature is not valid Go syntax"
        return 1
    fi
    if ! GOCACHE="$TEMP_DIR/go-cache" go build -o "$TEMP_DIR/signature-check.a" "$TEMP_DIR/signature.go" 2> "$TEMP_DIR/signature-build-error.txt"; then
        signature_error="signature uses an undeclared type or is not compilable as a standalone function"
        return 1
    fi

    return 0
}

generate_main() {
    local output_path="$1"
    local escaped_case_name escaped_call escaped_explanation
    local index

    {
        printf 'package main\n\nimport (\n\t"fmt"\n\t"os"\n\t"reflect"\n)\n\n'
        printf '%s {\n\tpanic("TODO: implement %s")\n}\n\n' "$function_signature" "$function_name"
        printf 'type testCase struct {\n\tname        string\n\tcall        string\n\texpected    any\n\trun         func() any\n\texplanation string\n}\n\n'
        printf '// Customize equalResults when a problem allows multiple valid output orders\n'
        printf '// or requires a problem-specific comparison.\n'
        printf 'func equalResults(actual, expected any) bool {\n\treturn reflect.DeepEqual(actual, expected)\n}\n\n'
        printf 'func execute(run func() any) (result any, panicValue any) {\n'
        printf '\tdefer func() {\n\t\tpanicValue = recover()\n\t}()\n\n'
        printf '\tresult = run()\n\treturn result, nil\n}\n\n'
        printf 'func main() {\n\ttestCases := []testCase{\n'

        for ((index = 0; index < test_case_count; index++)); do
            escaped_case_name="$(go_string_literal "${test_case_names[$index]}")"
            escaped_call="$(go_string_literal "${test_case_calls[$index]}")"
            escaped_explanation="$(go_string_literal "${test_case_explanations[$index]}")"

            printf '\t\t{\n'
            printf '\t\t\tname: "%s",\n' "$escaped_case_name"
            printf '\t\t\tcall: "%s",\n' "$escaped_call"
            printf '\t\t\texpected: %s,\n' "${test_case_expected[$index]}"
            printf '\t\t\trun: func() any { return %s },\n' "${test_case_calls[$index]}"
            printf '\t\t\texplanation: "%s",\n' "$escaped_explanation"
            printf '\t\t},\n'
        done

        printf '\t}\n\n\tpassed := 0\n\n'
        printf '\tfor _, current := range testCases {\n'
        printf '\t\tactual, panicValue := execute(current.run)\n\n'
        printf '\t\tfmt.Printf("Case: %%s\\n", current.name)\n'
        printf '\t\tfmt.Printf("Call: %%s\\n", current.call)\n'
        printf '\t\tfmt.Printf("Expected: %%#v\\n", current.expected)\n'
        printf '\t\tif current.explanation != "" {\n'
        printf '\t\t\tfmt.Printf("Explanation: %%s\\n", current.explanation)\n'
        printf '\t\t}\n\n'
        printf '\t\tif panicValue != nil {\n'
        printf '\t\t\tfmt.Println("Actual: <panic>")\n'
        printf '\t\t\tfmt.Println("Result: FAIL")\n'
        printf '\t\t\tfmt.Printf("Panic: %%#v\\n", panicValue)\n'
        printf '\t\t} else {\n'
        printf '\t\t\tfmt.Printf("Actual: %%#v\\n", actual)\n'
        printf '\t\t\tif equalResults(actual, current.expected) {\n'
        printf '\t\t\t\tfmt.Println("Result: PASS")\n'
        printf '\t\t\t\tpassed++\n'
        printf '\t\t\t} else {\n'
        printf '\t\t\t\tfmt.Println("Result: FAIL")\n'
        printf '\t\t\t}\n'
        printf '\t\t}\n\n'
        printf '\t\tfmt.Println()\n\t}\n\n'
        printf '\tfmt.Printf("%%d/%%d local cases passed\\n", passed, len(testCases))\n'
        printf '\tif passed != len(testCases) {\n\t\tos.Exit(1)\n\t}\n}\n'
    } > "$output_path"
}

generate_pseudocode() {
    local output_path="$1"
    local index

    {
        printf 'PROBLEM: %s\nLINK: %s\nFUNCTION: %s\n\n' "$problem_name" "$problem_link" "$function_signature"
        printf '%s\n' \
            '----------------------------------' \
            '--------------CODE----------------' \
            '----------------------------------' \
            '' '' '' '' '' '' '' \
            '----------------------------------' \
            '--------------CODE----------------' \
            '----------------------------------' \
            '' '' '' \
            '----------------------------------' \
            '--------------TEST CASES----------' \
            '----------------------------------' \
            ''
        for ((index = 0; index < test_case_count; index++)); do
            printf 'Example %d: %s\n' "$((index + 1))" "${test_case_names[$index]}"
            printf 'Call: %s\n' "${test_case_calls[$index]}"
            printf 'Expected: %s\n' "${test_case_expected[$index]}"
            if [[ -n "${test_case_explanations[$index]}" ]]; then
                printf 'Explanation: %s\n' "${test_case_explanations[$index]}"
            fi
            printf '\n'
        done
    } > "$output_path"
}

generate_readme() {
    local output_path="$1"
    local name_cell call_cell expected_cell explanation_cell
    local index

    {
        printf '# %s\n\n' "$problem_name"
        printf '## Problem\n\n[View the problem on LeetCode](%s)\n\n' "$problem_link"
        printf '## Description\n\n%s\n\n' "$problem_description"
        printf '> This is my own learning summary. Refer to LeetCode for the original problem statement and constraints.\n\n'
        printf '## Function Signature\n\n```go\n%s\n```\n\n' "$function_signature"
        printf '## Local Examples\n\n'
        printf '| Case | Function call | Expected | Explanation |\n'
        printf '|---|---|---|---|\n'

        for ((index = 0; index < test_case_count; index++)); do
            name_cell="$(markdown_cell "${test_case_names[$index]}")"
            call_cell="$(markdown_cell "${test_case_calls[$index]}")"
            expected_cell="$(markdown_cell "${test_case_expected[$index]}")"
            explanation_cell="$(markdown_cell "${test_case_explanations[$index]}")"
            printf '| %s | `%s` | `%s` | %s |\n' \
                "$name_cell" "$call_cell" "$expected_cell" "$explanation_cell"
        done

        printf '\n## Approach\n\nWrite the approach here after understanding the problem.\n\n'
        printf '## Complexity\n\n- **Time:** TODO\n- **Space:** TODO\n\n'
        printf '## What I Learned\n\nWrite mistakes, observations and lessons here.\n\n'
        printf '## Local Validation\n\nThe generated runner uses exact `reflect.DeepEqual` equality by default. A nil slice and an empty non-nil slice may not be treated as identical.\n\n'
        printf 'Edit `equalResults` in `main.go` when output order is not significant, multiple outputs are valid, floating-point tolerance is required, or the problem needs a custom comparison.\n\n'
        printf 'Passing these local examples does not guarantee acceptance against LeetCode\x27s complete test suite.\n\n'
        printf '## Run\n\nFrom the repository root:\n\n```bash\ngo run ./problems/%s\n```\n' "$problem_slug"
    } > "$output_path"
}

validate_generated_source() {
    local source_path="$1"

    if ! gofmt -w "$source_path" 2> "$TEMP_DIR/gofmt-error.txt"; then
        printf '%s\n' "Error: generated Go source is not valid syntax." >&2
        cat "$TEMP_DIR/gofmt-error.txt" >&2
        return 1
    fi

    if ! GOCACHE="$TEMP_DIR/go-cache" go build -o "$TEMP_DIR/validation.bin" "$source_path" 2> "$TEMP_DIR/build-error.txt"; then
        printf '%s\n' "Error: generated Go source did not compile." >&2
        printf '%s\n' "Check the function signature, argument expressions, and expected Go values." >&2
        cat "$TEMP_DIR/build-error.txt" >&2
        return 1
    fi
}

discard_pasted_function_body() {
    local line character index
    local brace_depth=1

    while (( brace_depth > 0 )); do
        if ! IFS= read -r line; then
            printf '%s\n' "Error: pasted function body must end with a closing brace." >&2
            return 1
        fi

        for ((index = 0; index < ${#line}; index++)); do
            character="${line:index:1}"
            case "$character" in
                '{') brace_depth=$((brace_depth + 1)) ;;
                '}') brace_depth=$((brace_depth - 1)) ;;
            esac
        done
    done
}

TEMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/go-dsa-generator.XXXXXX")"

read -r -p "Problem name: " problem_name
if ! is_nonempty "$problem_name"; then
    printf '%s\n' "Error: problem name is required." >&2
    exit 1
fi

problem_slug="$(slugify "$problem_name")"
if [[ -z "$problem_slug" ]]; then
    printf '%s\n' "Error: problem name could not produce a valid slug." >&2
    exit 1
fi

problem_description=""
read_problem_description

read -r -p "LeetCode problem link: " problem_link
if ! is_nonempty "$problem_link"; then
    printf '%s\n' "Error: LeetCode problem link is required." >&2
    exit 1
fi
if ! valid_leetcode_url "$problem_link"; then
    printf '%s\n' "Error: link must be an HTTPS URL on leetcode.com or one of its subdomains without embedded credentials." >&2
    exit 1
fi

while :; do
    printf '%s\n' "Example: func twoSum(numbers []int, target int) []int" >&2
    printf '%s\n' "Enter the declaration without a function body." >&2
    printf '%s\n' "If you paste a full function skeleton after {, close it with }; the body is ignored." >&2
    read -r -p "Go function signature: " raw_signature
    function_signature="$(trim_whitespace "$raw_signature")"
    pasted_function_body=0
    if [[ "$function_signature" == *"{" ]]; then
        function_signature="$(trim_whitespace "${function_signature%?}")"
        pasted_function_body=1
    fi
    if (( pasted_function_body == 1 )) && ! discard_pasted_function_body; then
        exit 1
    fi
    if validate_function_signature "$function_signature"; then
        break
    fi
    printf 'Error: %s.\n' "$signature_error" >&2
    if [[ -s "$TEMP_DIR/signature-gofmt-error.txt" ]]; then
        cat "$TEMP_DIR/signature-gofmt-error.txt" >&2
    fi
    if [[ -s "$TEMP_DIR/signature-build-error.txt" ]]; then
        cat "$TEMP_DIR/signature-build-error.txt" >&2
    fi
done

declare -a test_case_names=()
declare -a test_case_arguments=()
declare -a test_case_expected=()
declare -a test_case_explanations=()
declare -a test_case_calls=()

if ! extract_signature_metadata; then
    printf '%s\n' "Error: could not map the function signature parameters for example parsing." >&2
    exit 1
fi
if ! parse_description_examples; then
    printf 'Error: could not parse examples from the description: %s\n' "$example_parse_error" >&2
    printf '%s\n' "Expected format: Example N:, Input: name = value, ..., Output: value." >&2
    exit 1
fi

problem_directory="$PROBLEMS_DIR/$problem_slug"
display_directory="problems/$problem_slug"
if [[ -e "$problem_directory" || -L "$problem_directory" ]]; then
    printf 'Error: problem directory already exists: %s\n' "$display_directory" >&2
    exit 1
fi

generate_main "$TEMP_DIR/main.go"
generate_pseudocode "$TEMP_DIR/pseudocode.txt"
generate_readme "$TEMP_DIR/README.md"

if ! validate_generated_source "$TEMP_DIR/main.go"; then
    exit 1
fi

printf '\nProblem name: %s\n' "$problem_name"
printf 'Directory: %s\n' "$display_directory"
printf 'LeetCode: %s\n' "$problem_link"
printf 'Function: %s\n' "$function_signature"
printf 'Function name: %s\n' "$function_name"
printf 'Test cases: %d\n\n' "$test_case_count"
for ((case_index = 0; case_index < test_case_count; case_index++)); do
    printf '%d. %s\n' "$((case_index + 1))" "${test_case_names[$case_index]}"
    printf '   Call: %s\n' "${test_case_calls[$case_index]}"
    printf '   Expected: %s\n\n' "${test_case_expected[$case_index]}"
done

read -r -p "Create this problem? [Y/n]: " confirmation
case "${confirmation,,}" in
    ""|y|yes)
        ;;
    n|no)
        printf '%s\n' "Cancelled. No files were changed."
        exit 0
        ;;
    *)
        printf '%s\n' "Cancelled. No files were changed."
        exit 1
        ;;
esac

mkdir "$problem_directory"
CREATED_DIRECTORY="$problem_directory"
cp -- "$TEMP_DIR/main.go" "$problem_directory/main.go"
cp -- "$TEMP_DIR/pseudocode.txt" "$problem_directory/pseudocode.txt"
cp -- "$TEMP_DIR/README.md" "$problem_directory/README.md"
CREATED_DIRECTORY=""

printf '\nProblem scaffold created.\n\n'
printf 'Next steps:\n'
printf '1. Open %s/pseudocode.txt.\n' "$display_directory"
printf '2. Write your pseudocode.\n'
printf '3. Implement %s in %s/main.go.\n' "$function_name" "$display_directory"
printf '4. Run: go run ./%s\n' "$display_directory"
