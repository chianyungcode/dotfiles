#!/usr/bin/env bash

set -euo pipefail

fail() {
    printf '%s\n' "$1" >&2
    exit 1
}

repo_root=$(cd "$(dirname "$0")/.." && pwd)
skim_source="$repo_root/chezmoi/dot_config/fish/conf.d/99_skim.fish"
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

for command_name in fish rg; do
    command -v "$command_name" >/dev/null ||
        fail "missing required command: $command_name"
done

stub_bin="$tmp_dir/bin"
mkdir -p "$stub_bin"

cat >"$stub_bin/fd" <<'STUB'
#!/usr/bin/env bash
printf '%s\n' candidate
STUB
chmod +x "$stub_bin/fd"

cat >"$stub_bin/editor" <<'STUB'
#!/usr/bin/env bash
printf '%s\n' "$@" >"$ACTION_OUTPUT"
STUB
chmod +x "$stub_bin/editor"

cat >"$stub_bin/bat" <<'STUB'
#!/usr/bin/env bash
printf '%s\n' "$@" >"$ACTION_OUTPUT"
STUB
chmod +x "$stub_bin/bat"

cat >"$stub_bin/sk" <<'STUB'
#!/usr/bin/env bash
if [[ ${SKIM_TEST_MODE:-} == actions ]]; then
    case "$SKIM_ACTION" in
        edit)
            printf 'ctrl-e\n%s\n%s\n' "$SKIM_FILE_1" "$SKIM_FILE_2"
            ;;
        bat)
            printf 'ctrl-c\n%s\n%s\n' "$SKIM_FILE_1" "$SKIM_FILE_2"
            ;;
    esac
    exit 0
fi
if [[ ${SKIM_TEST_MODE:-} == directory ]]; then
    count=0
    if [[ -f "$SKIM_CALL_COUNT" ]]; then
        count=$(<"$SKIM_CALL_COUNT")
    fi
    count=$((count + 1))
    printf '%s\n' "$count" >"$SKIM_CALL_COUNT"
    if (( count == 1 )); then
        printf 'ctrl-d\n%s\n' "$SKIM_TARGET"
    fi
    exit 130
fi
printf '%s\n' "$@" >"$SKIM_ARGS_OUTPUT"
exit 130
STUB
chmod +x "$stub_bin/sk"

actual=$(
    PATH="$stub_bin:$PATH" SKIM_ARGS_OUTPUT="$tmp_dir/sk-args" \
        fish --no-config -c '
            function commandline
                switch "$argv[1]"
                    case --current-token
                        echo ""
                    case "*"
                        return 0
                end
            end
            source "$argv[1]"
            skim_ctrl_t
        ' "$skim_source"
)

[[ -z "$actual" ]] || fail "cancelled skim inserted: $(printf '%q' "$actual")"

rg -Fq -- 'ctrl-e:accept(ctrl-e)' "$tmp_dir/sk-args" ||
    fail 'fish skim is missing ctrl-e editor action'
rg -Fq -- 'ctrl-c:accept(ctrl-c)' "$tmp_dir/sk-args" ||
    fail 'fish skim is missing ctrl-c bat action'
rg -Fq -- 'ctrl-d:accept(ctrl-d)' "$tmp_dir/sk-args" ||
    fail 'fish skim is missing ctrl-d directory action'
rg -Fq -- 'ctrl-q:abort' "$tmp_dir/sk-args" ||
    fail 'fish skim is missing ctrl-q cancellation action'
rg -Fq -- 'CTRL-E edit marked files | CTRL-C bat marked files | CTRL-D cd directory | CTRL-/ toggle preview' "$tmp_dir/sk-args" ||
    fail 'fish skim is missing the action hint'

action_start="$tmp_dir/action-start"
mkdir -p "$action_start"
action_file_1="$action_start/file-1.txt"
action_file_2="$action_start/file-2.txt"
touch "$action_file_1" "$action_file_2"
for action in edit bat; do
    action_output="$tmp_dir/$action-args"
    actual_pwd=$(
        PATH="$stub_bin:$PATH" SKIM_TEST_MODE=actions SKIM_ACTION="$action" \
            SKIM_FILE_1="$action_file_1" SKIM_FILE_2="$action_file_2" \
            ACTION_OUTPUT="$action_output" EDITOR=editor \
            fish --no-config -c '
                function commandline
                    switch "$argv[1]"
                        case --current-token
                            echo ""
                        case "*"
                            return 0
                    end
                end
                source "$argv[1]"
                cd -- "$argv[2]"
                skim_ctrl_t
                pwd
            ' "$skim_source" "$action_start"
    )
    [[ "$actual_pwd" == "$action_start" ]] ||
        fail "fish skim action changed directory: $actual_pwd"
    tail -n 2 "$action_output" >"$tmp_dir/$action-files"
    printf '%s\n%s\n' "$action_file_1" "$action_file_2" >"$tmp_dir/expected-files"
    cmp -s "$tmp_dir/expected-files" "$tmp_dir/$action-files" ||
        fail "fish skim $action action did not receive all marked files"
    if [[ "$action" == bat ]] && rg -Fxq -- '-n' "$action_output"; then
        fail 'fish skim ctrl-c bat action should not use -n'
    fi
done

start_dir="$tmp_dir/start"
target_dir="$start_dir/target"
mkdir -p "$target_dir"
call_count="$tmp_dir/call-count"
actual_pwd=$(
    PATH="$stub_bin:$PATH" SKIM_TEST_MODE=directory \
        SKIM_CALL_COUNT="$call_count" SKIM_TARGET="$target_dir" \
        fish --no-config -c '
            function commandline
                switch "$argv[1]"
                    case --current-token
                        echo ""
                    case "*"
                        return 0
                end
            end
            source "$argv[1]"
            cd -- "$argv[2]"
            skim_ctrl_t
            pwd
        ' "$skim_source" "$start_dir"
)
[[ "$actual_pwd" == "$target_dir" ]] ||
    fail "fish skim did not cd to selected directory: $actual_pwd"
[[ $(<"$call_count") == 2 ]] ||
    fail "fish skim did not reopen after directory action: $(<"$call_count") calls"

file_target="$start_dir/file.txt"
touch "$file_target"
call_count="$tmp_dir/file-call-count"
actual_pwd=$(
    PATH="$stub_bin:$PATH" SKIM_TEST_MODE=directory \
        SKIM_CALL_COUNT="$call_count" SKIM_TARGET="$file_target" \
        fish --no-config -c '
            function commandline
                switch "$argv[1]"
                    case --current-token
                        echo ""
                    case "*"
                        return 0
                end
            end
            source "$argv[1]"
            cd -- "$argv[2]"
            skim_ctrl_t
            pwd
        ' "$skim_source" "$start_dir"
)
[[ "$actual_pwd" == "$start_dir" ]] ||
    fail "fish skim changed directory for file result: $actual_pwd"

printf 'fish skim action tests passed\n'
