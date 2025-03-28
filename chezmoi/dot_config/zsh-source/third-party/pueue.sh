function pf() {
  set -f
  local PUEUE_TASKS="pueue status --json | jq -c '.tasks' | jq -r '.[] | \"\(.id | tostring | (\" \" * (2 - length)) + .) | \(.group) | \(.path[-15:]) | \(.status) | \(.command[-15:]) | \(.start[:19])\"'"
  local header="p:pause | s:start | r:restart | k:kill | l:log | f:reload"

  local bind="\
  ctrl-p:execute-silent(echo {} | cut -d'|' -f1 | xargs pueue pause > /dev/null)+reload^$PUEUE_TASKS^,\
  ctrl-s:execute-silent(echo {} | cut -d'|' -f1 | xargs pueue start > /dev/null)+reload^$PUEUE_TASKS^,\
  ctrl-r:execute-silent(echo {} | cut -d'|' -f1 | xargs pueue restart -ik > /dev/null)+reload^$PUEUE_TASKS^,\
  ctrl-k:execute-silent(echo {} | cut -d'|' -f1 | xargs pueue kill > /dev/null)+reload^$PUEUE_TASKS^,\
  ctrl-l:execute-silent(echo {} | cut -d'|' -f1 | xargs pueue log | less > /dev/tty),\
  ctrl-f:reload^$PUEUE_TASKS^\
  "

  echo $PUEUE_TASKS | sh | fzf --header "${header}" -m \
    --preview="echo {} | cut -d'|' -f1 | xargs pueue log | bat -l log --style=rule,numbers --color=always -r ':200'" \
    --bind="$bind"
  set +f
}