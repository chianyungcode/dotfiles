#!/usr/bin/env bash

set -euo pipefail

fail() {
	printf '%s\n' "$1" >&2
	exit 1
}

repo_root=$(cd "$(dirname "$0")/.." && pwd)
skim_source="$repo_root/chezmoi/dot_config/zsh/conf.d/third-party/99_skim.sh"
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

command -v zsh >/dev/null || fail 'missing required command: zsh'

stub_bin="$tmp_dir/bin"
mkdir -p "$stub_bin"

cat >"$stub_bin/fd" <<'STUB'
#!/usr/bin/env bash
printf 'candidate\n'
STUB
chmod +x "$stub_bin/fd"

cat >"$stub_bin/editor" <<'STUB'
#!/usr/bin/env bash
printf '%s\n' "$@" >"$ACTION_OUTPUT"
STUB
chmod +x "$stub_bin/editor"

cat >"$stub_bin/sk" <<'STUB'
#!/usr/bin/env bash
if [[ ${SKIM_TEST_MODE:-} == actions ]]; then
    case "$SKIM_ACTION" in
        edit)
            printf 'ctrl-e\n%s\n%s\n' "$SKIM_FILE_1" "$SKIM_FILE_2"
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
		zsh -f -c '
            zle() { :; }
            bindkey() { :; }
            source "$1"
            LBUFFER=""
            skim-ctrl-t-widget
            print -r -- "$LBUFFER"
        ' zsh "$skim_source"
)

[[ -z "$actual" ]] || fail "cancelled skim inserted: $(printf '%q' "$actual")"

rg -Fq -- 'ctrl-e:accept(ctrl-e)' "$tmp_dir/sk-args" ||
	fail 'zsh skim is missing ctrl-e editor action'
if rg -Fq -- 'ctrl-c:accept' "$tmp_dir/sk-args"; then
	fail 'zsh skim should leave ctrl-c as the default cancel action'
fi
rg -Fq -- 'ctrl-d:accept(ctrl-d)' "$tmp_dir/sk-args" ||
	fail 'zsh skim is missing ctrl-d directory action'
rg -Fq -- 'ctrl-q:abort' "$tmp_dir/sk-args" ||
	fail 'zsh skim is missing ctrl-q cancellation action'
if rg -Fq -- 'ctrl-b:accept' "$tmp_dir/sk-args"; then
	fail 'zsh skim should not bind ctrl-b to bat'
fi
if rg -Fq -- 'CTRL-B bat marked files' "$tmp_dir/sk-args"; then
	fail 'zsh skim should not advertise a bat action'
fi
rg -Fq -- 'CTRL-E edit marked files | CTRL-D cd directory | CTRL-/ toggle preview' "$tmp_dir/sk-args" ||
	fail 'zsh skim is missing the action hint'

action_start="$tmp_dir/action-start"
mkdir -p "$action_start"
action_file_1="$action_start/file-1.txt"
action_file_2="$action_start/file-2.txt"
touch "$action_file_1" "$action_file_2"
for action in edit; do
	action_output="$tmp_dir/$action-args"
	actual_pwd=$(
		PATH="$stub_bin:$PATH" SKIM_TEST_MODE=actions SKIM_ACTION="$action" \
			SKIM_FILE_1="$action_file_1" SKIM_FILE_2="$action_file_2" \
			ACTION_OUTPUT="$action_output" EDITOR=editor \
			zsh -f -c '
                zle() { :; }
                bindkey() { :; }
                source "$1"
                cd -- "$2"
                LBUFFER=""
                skim-ctrl-t-widget
                pwd
            ' zsh "$skim_source" "$action_start"
	)
	[[ "$actual_pwd" == "$action_start" ]] ||
		fail "zsh skim action changed directory: $actual_pwd"
	tail -n 2 "$action_output" >"$tmp_dir/$action-files"
	printf '%s\n%s\n' "$action_file_1" "$action_file_2" >"$tmp_dir/expected-files"
	cmp -s "$tmp_dir/expected-files" "$tmp_dir/$action-files" ||
		fail "zsh skim $action action did not receive all marked files"
done

start_dir="$tmp_dir/start"
target_dir="$start_dir/target"
mkdir -p "$target_dir"
call_count="$tmp_dir/call-count"
actual_pwd=$(
	PATH="$stub_bin:$PATH" SKIM_TEST_MODE=directory \
		SKIM_CALL_COUNT="$call_count" SKIM_TARGET="$target_dir" \
		zsh -f -c '
            zle() { :; }
            bindkey() { :; }
            source "$1"
            cd -- "$2"
            LBUFFER=""
            skim-ctrl-t-widget
            pwd
        ' zsh "$skim_source" "$start_dir"
)
[[ "$actual_pwd" == "$target_dir" ]] ||
	fail "zsh skim did not cd to selected directory: $actual_pwd"
[[ $(<"$call_count") == 2 ]] ||
	fail "zsh skim did not reopen after directory action: $(<"$call_count") calls"

file_target="$start_dir/file.txt"
touch "$file_target"
call_count="$tmp_dir/file-call-count"
actual_pwd=$(
	PATH="$stub_bin:$PATH" SKIM_TEST_MODE=directory \
		SKIM_CALL_COUNT="$call_count" SKIM_TARGET="$file_target" \
		zsh -f -c '
            zle() { :; }
            bindkey() { :; }
            source "$1"
            cd -- "$2"
            LBUFFER=""
            skim-ctrl-t-widget
            pwd
        ' zsh "$skim_source" "$start_dir"
)
[[ "$actual_pwd" == "$start_dir" ]] ||
	fail "zsh skim changed directory for file result: $actual_pwd"

printf 'zsh skim cancellation test passed\n'
