#!/bin/zsh

emulate -L zsh
setopt err_return pipe_fail no_unset

config_dir='/Users/Apple/.config/zsh'
test_root=$(command mktemp -d -t terminal-tools.XXXXXX)
trap 'command rm -rf -- "$test_root"' EXIT INT TERM

fail() {
    print -u2 -- "FAIL: $*"
    return 1
}

require() {
    "$@" || fail "$*"
}

mkdir -p -- "$test_root/bin" "$test_root/sample/visible dir" "$test_root/sample/.hidden dir" "$test_root/zoxide-data" "$test_root/zsh-cache"
print -r -- 'visible' > "$test_root/sample/visible dir/file with spaces.txt"
print -r -- 'hidden' > "$test_root/sample/.hidden dir/secret.txt"

assertions='
setopt no_aliases
failures=0
require() { "$@" || { print -u2 -- "FAIL: $*"; (( failures++ )); }; }
require test "$EDITOR" = "code --wait"
require test "$VISUAL" = "code --wait"
require test "${aliases[vim]}" = nvim
require test "${aliases[ls]}" = "eza --icons"
require test "${aliases[cat]}" = bat
require test "${aliases[grep]}" = "rg --color=auto"
require test "$MANPAGER" = "bat -l man -p"
require test "$+functions[z]" -eq 1
require test "$+functions[y]" -eq 1
require test "$+functions[fzf-file-widget]" -eq 1
require test "$+functions[fzf-history-widget]" -eq 1
require test "$(bindkey "^R")" = "\"^R\" fzf-history-widget"
require test "$(bindkey "^T")" = "\"^T\" fzf-file-widget"
require test "$(bindkey "^F")" = "\"^F\" _fzf_file_no_hidden"
require test "$(bindkey -lL main)" = "bindkey -A emacs main"
require test "$+functions[_zsh_autosuggest_start]" -eq 1
require test "$+functions[_zsh_highlight]" -eq 1
if [[ $PROMPT != *starship* ]]; then
    print -u2 -- "FAIL: PROMPT contains starship initialization"
    (( failures++ ))
fi
require test "$FZF_DEFAULT_COMMAND" = "fd --type f --hidden --strip-cwd-prefix"
require test "$FZF_CTRL_T_COMMAND" = "$FZF_DEFAULT_COMMAND"
configured_hidden=$(cd -- "$TEST_SAMPLE_DIR" && eval "$FZF_CTRL_T_COMMAND" | command fzf --filter="secret.txt")
require test "$configured_hidden" = ".hidden dir/secret.txt"
configured_spaces=$(cd -- "$TEST_SAMPLE_DIR" && eval "$FZF_CTRL_T_COMMAND" | command fzf --filter="file with spaces.txt")
require test "$configured_spaces" = "visible dir/file with spaces.txt"
fzf-file-widget() { print -r -- "$FZF_CTRL_T_COMMAND|$FZF_CTRL_T_OPTS"; }
wrapper_result=$(_fzf_file_no_hidden)
require test "$wrapper_result" = "fd --type f --strip-cwd-prefix|$FZF_CTRL_T_OPTS +m"
(( failures == 0 ))
'

if ! TERM=xterm-256color XDG_CACHE_HOME="$test_root/zsh-cache" XDG_DATA_HOME="$test_root/zoxide-data" HISTFILE="$test_root/history" TEST_SAMPLE_DIR="$test_root/sample" /bin/zsh -ic "$assertions"; then
    print -u2 -- 'Initial configuration assertions failed (expected before terminal-tool integration).'
    exit 1
fi

non_tty_output=$(TERM=xterm-256color XDG_CACHE_HOME="$test_root/zsh-cache" XDG_DATA_HOME="$test_root/zoxide-data" HISTFILE="$test_root/history" /bin/zsh -ic 'print -r -- "${functions[fzf-file-widget]+loaded}"' 2>&1)
require test "$non_tty_output" = loaded

print -r -- '#!/bin/zsh' > "$test_root/bin/yazi"
print -r -- 'for argument in "$@"; do' >> "$test_root/bin/yazi"
print -r -- '    case "$argument" in --cwd-file=*) cwd_file=${argument#--cwd-file=};; esac' >> "$test_root/bin/yazi"
print -r -- 'done' >> "$test_root/bin/yazi"
print -r -- 'print -r -- "$cwd_file" > "$TEST_YAZI_CWD_FILE_LOG"' >> "$test_root/bin/yazi"
print -r -- 'case "$TEST_YAZI_MODE" in' >> "$test_root/bin/yazi"
print -r -- '    path|missing) print -rn -- "$TEST_YAZI_TARGET" > "$cwd_file";;' >> "$test_root/bin/yazi"
print -r -- '    empty|cancel) : > "$cwd_file";;' >> "$test_root/bin/yazi"
print -r -- '    failure) exit 73;;' >> "$test_root/bin/yazi"
print -r -- 'esac' >> "$test_root/bin/yazi"
command chmod +x "$test_root/bin/yazi"

run_yazi_case() {
    local mode="$1" expected_status="$2" target_dir="$3" expected_dir="$4"
    local cwd_log="$test_root/cwd-file-$mode"
    local yazi_assertions
    yazi_assertions='
setopt no_aliases
y
result=$?
test "$result" -eq "$TEST_YAZI_EXPECTED_STATUS" || { print -u2 -- "FAIL: y status $result"; return 1; }
test "$PWD" = "$TEST_YAZI_EXPECTED_DIR" || { print -u2 -- "FAIL: y directory $PWD"; return 1; }
'
    TERM=xterm-256color PATH="$test_root/bin:$PATH" XDG_CACHE_HOME="$test_root/zsh-cache" XDG_DATA_HOME="$test_root/zoxide-data" HISTFILE="$test_root/history" TEST_YAZI_MODE="$mode" TEST_YAZI_TARGET="$target_dir" TEST_YAZI_EXPECTED_STATUS="$expected_status" TEST_YAZI_EXPECTED_DIR="$expected_dir" TEST_YAZI_CWD_FILE_LOG="$cwd_log" /bin/zsh -ic "cd -- '$test_root/sample'; $yazi_assertions" || return 1
    local created_cwd_file
    IFS= read -r created_cwd_file < "$cwd_log" || return 1
    require test ! -e "$created_cwd_file"
}

mkdir -p -- "$test_root/sample/target with spaces"
run_yazi_case path 0 "$test_root/sample/target with spaces" "$test_root/sample/target with spaces"
run_yazi_case empty 0 "$test_root/sample" "$test_root/sample"
run_yazi_case cancel 0 "$test_root/sample" "$test_root/sample"
run_yazi_case missing 0 "$test_root/sample/missing target" "$test_root/sample"
run_yazi_case failure 73 "$test_root/sample" "$test_root/sample"

print -- 'PASS: terminal tools configuration and isolated wrappers verified.'
