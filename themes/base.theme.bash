# shellcheck shell=bash
# shellcheck disable=SC2034 # Expected behavior for themes.

# Colors for listing files, using default color scheme.
# To customize color scheme by theme, check out https://geoff.greer.fm/lscolors/
export CLICOLOR LSCOLORS LS_COLORS

CLOCK_CHAR_THEME_PROMPT_PREFIX=''
CLOCK_CHAR_THEME_PROMPT_SUFFIX=''
CLOCK_THEME_PROMPT_PREFIX=''
CLOCK_THEME_PROMPT_SUFFIX=''

THEME_PROMPT_HOST='\h'

SCM=

: "${SCM_CHECK:=true}"

SCM_THEME_PROMPT_DIRTY=' ✗'
SCM_THEME_PROMPT_CLEAN=' ✓'
SCM_THEME_PROMPT_PREFIX=' |'
SCM_THEME_PROMPT_SUFFIX='|'
SCM_THEME_BRANCH_PREFIX=''
SCM_THEME_TAG_PREFIX='tag:'
SCM_THEME_DETACHED_PREFIX='detached:'
SCM_THEME_BRANCH_TRACK_PREFIX=' → '
SCM_THEME_BRANCH_GONE_PREFIX=' ⇢ '
SCM_THEME_CURRENT_USER_PREFFIX=' ☺︎ '
SCM_THEME_CURRENT_USER_SUFFIX=''
SCM_THEME_CHAR_PREFIX=''
SCM_THEME_CHAR_SUFFIX=''

# Define this here so it can be used by all of the themes
: "${THEME_CHECK_SUDO:=false}"
: "${THEME_BATTERY_PERCENTAGE_CHECK:=true}"

: "${SCM_GIT_SHOW_DETAILS:=true}"
: "${SCM_GIT_SHOW_REMOTE_INFO:=auto}"
: "${SCM_GIT_IGNORE_UNTRACKED:=false}"
: "${SCM_GIT_SHOW_CURRENT_USER:=false}"
: "${SCM_GIT_SHOW_MINIMAL_INFO:=false}"
: "${SCM_GIT_SHOW_STASH_INFO:=true}"
: "${SCM_GIT_SHOW_COMMIT_COUNT:=true}"
: "${SCM_GIT_USE_GITSTATUS:=false}"
: "${SCM_GIT_GITSTATUS_RAN:=false}"

SCM_GIT='git'
SCM_GIT_CHAR='±'
SCM_GIT_DETACHED_CHAR='⌿'
SCM_GIT_AHEAD_CHAR="↑"
SCM_GIT_BEHIND_CHAR="↓"
SCM_GIT_AHEAD_BEHIND_PREFIX_CHAR=" "
SCM_GIT_UNTRACKED_CHAR="?:"
SCM_GIT_UNSTAGED_CHAR="U:"
SCM_GIT_STAGED_CHAR="S:"
SCM_GIT_STASH_CHAR_PREFIX="{"
SCM_GIT_STASH_CHAR_SUFFIX="}"

SCM_JJ="jj"
SCM_JJ_CHAR='±'
SCM_JJ_DETACHED_CHAR='⌿'
SCM_JJ_AHEAD_CHAR="↑"
SCM_JJ_BEHIND_CHAR="↓"
SCM_JJ_AHEAD_BEHIND_PREFIX_CHAR=" "
SCM_JJ_UNTRACKED_CHAR="?:"
SCM_JJ_UNSTAGED_CHAR="U:"
SCM_JJ_STAGED_CHAR="S:"
SCM_JJ_STASH_CHAR_PREFIX="{"
SCM_JJ_STASH_CHAR_SUFFIX="}"

SCM_NONE='NONE'
SCM_NONE_CHAR='○'

NVM_THEME_PROMPT_PREFIX=' |'
NVM_THEME_PROMPT_SUFFIX='|'

RVM_THEME_PROMPT_PREFIX=' |'
RVM_THEME_PROMPT_SUFFIX='|'

: "${THEME_SHOW_RUBY_PROMPT:=true}"

: "${THEME_SHOW_USER_HOST:=false}"
USER_HOST_THEME_PROMPT_PREFIX=''
USER_HOST_THEME_PROMPT_SUFFIX=''

VIRTUALENV_THEME_PROMPT_PREFIX=' |'
VIRTUALENV_THEME_PROMPT_SUFFIX='|'

RBENV_THEME_PROMPT_PREFIX=' |'
RBENV_THEME_PROMPT_SUFFIX='|'

RBFU_THEME_PROMPT_PREFIX=' |'
RBFU_THEME_PROMPT_SUFFIX='|'

: "${GIT_EXE:=${SCM_GIT?}}"

function _appearance_scm_init() {
	GIT_EXE="$(type -P "${SCM_GIT:-git}" || true)"
	JJ_EXE="$(type -P "${SCM_JJ:-jj}" || true)"

	return 0
}
_library_finalize_hook+=('_appearance_scm_init')

function scm() {
	if [[ "${SCM_CHECK:-true}" == "false" ]]; then
		SCM="${SCM_NONE-NONE}"
	elif [[ -x "${JJ_EXE-}" ]] && _find-in-ancestor '.jj' > /dev/null; then
		SCM="${SCM_JJ?}"
	elif [[ -x "${GIT_EXE-}" ]] && _find-in-ancestor '.git' > /dev/null; then
		SCM="${SCM_GIT?}"
    else
		SCM="${SCM_NONE-NONE}"
	fi
}

function scm_prompt() {
	local format="${SCM_PROMPT_FORMAT-"[%s%s]"}"
	local scm_char scm_prompt_info
	scm_char="$(scm_char)"
	scm_prompt_info="$(scm_prompt_info)"

	if [[ "${scm_char}" != "${SCM_NONE_CHAR:-}" ]]; then
		# shellcheck disable=2059
		printf "${format}" "${scm_char}" "${scm_prompt_info}"
	fi
}

function scm_prompt_char() {
	if [[ -z "${SCM:-}" ]]; then
		scm
	fi

	case ${SCM?} in
		"${SCM_GIT?}")
			SCM_CHAR="${SCM_GIT_CHAR?}"
			;;
		"${SCM_JJ?}")
			SCM_CHAR="${SCM_JJ_CHAR?}"
			;;
		*)
			SCM_CHAR="${SCM_NONE_CHAR:-}"
			;;
	esac
}

function scm_prompt_vars() {
	scm
	scm_prompt_char
	SCM_DIRTY=0
	SCM_STATE=''

	local prompt_vars="${SCM}_prompt_vars"
	_is_function "${prompt_vars}" && "${prompt_vars}"
}

function scm_prompt_info() {
	scm
	scm_prompt_char
	scm_prompt_info_common
}

function scm_prompt_char_info() {
	scm_prompt_char
	echo -ne "${SCM_THEME_CHAR_PREFIX-}${SCM_CHAR?}${SCM_THEME_CHAR_SUFFIX-}"
	scm_prompt_info_common
}

function scm_prompt_info_common() {
	local prompt_info
	SCM_DIRTY=0
	SCM_STATE=''

	case ${SCM?} in
		"${SCM_GIT?}")
			if [[ ${SCM_GIT_SHOW_MINIMAL_INFO:-false} == "true" ]]; then
				# user requests minimal git status information
				prompt_info="${SCM}_prompt_minimal_info"
			else
				# more detailed git status
				prompt_info="${SCM}_prompt_info"
			fi
			;;
		"${SCM_JJ?}")
			if [[ ${SCM_JJ_SHOW_MINIMAL_INFO:-false} == "true" ]]; then
				# user requests minimal jj status information
				prompt_info="${SCM}_prompt_minimal_info"
			else
				# more detailed git status
				prompt_info="${SCM}_prompt_info"
			fi
			;;

        *)
			# TODO: consider adding minimal status information for hg and svn
			prompt_info="${SCM}_prompt_info"
			;;
	esac
	_is_function "${prompt_info}" && "${prompt_info}"
}

function terraform_workspace_prompt() {
	if _command_exists terraform; then
		if [[ -d .terraform ]]; then
			terraform workspace show 2> /dev/null
		fi
	fi
}

function active_gcloud_account_prompt() {
	if _command_exists gcloud; then
		gcloud config list account --format "value(core.account)" 2> /dev/null
	fi
}

function git_prompt_minimal_info() {
	SCM_STATE="${SCM_THEME_PROMPT_CLEAN?}"

	_git-hide-status && return

	SCM_BRANCH="${SCM_THEME_BRANCH_PREFIX-}\$(_git-friendly-ref)"

	if [[ -n "$(_git-status | tail -n1)" ]]; then
		SCM_DIRTY=1
		SCM_STATE="${SCM_THEME_PROMPT_DIRTY?}"
	fi

	# Output the git prompt
	SCM_PREFIX="${SCM_THEME_PROMPT_PREFIX-}"
	SCM_SUFFIX="${SCM_THEME_PROMPT_SUFFIX-}"
	echo -ne "${SCM_PREFIX}${SCM_BRANCH}${SCM_STATE}${SCM_SUFFIX}"
}

function git_prompt_vars() {
	if [[ "${SCM_GIT_USE_GITSTATUS:-false}" != "false" ]] && _command_exists gitstatus_query && gitstatus_query && [[ "${VCS_STATUS_RESULT:-}" == "ok-sync" ]]; then
		# we can use faster gitstatus
		# use this variable in githelpers and below to choose gitstatus output
		SCM_GIT_GITSTATUS_RAN=true
	else
		SCM_GIT_GITSTATUS_RAN=false
	fi

	if _git-branch &> /dev/null; then
		SCM_GIT_DETACHED="false"
		SCM_BRANCH="${SCM_THEME_BRANCH_PREFIX}\$(_git-friendly-ref)$(_git-remote-info)"
	else
		SCM_GIT_DETACHED="true"

		local detached_prefix
		if _git-tag &> /dev/null; then
			detached_prefix="${SCM_THEME_TAG_PREFIX}"
		else
			detached_prefix="${SCM_THEME_DETACHED_PREFIX}"
		fi
		SCM_BRANCH="${detached_prefix}\$(_git-friendly-ref)"
	fi

	if [[ "${SCM_GIT_GITSTATUS_RAN:-}" == "true" ]]; then
		commits_behind="${VCS_STATUS_COMMITS_BEHIND?}"
		commits_ahead="${VCS_STATUS_COMMITS_AHEAD?}"
	else
		IFS=$'\t' read -r commits_behind commits_ahead <<< "$(_git-upstream-behind-ahead)"
	fi
	if [[ "${commits_ahead}" -gt 0 ]]; then
		SCM_BRANCH+="${SCM_GIT_AHEAD_BEHIND_PREFIX_CHAR}${SCM_GIT_AHEAD_CHAR}"
		[[ "${SCM_GIT_SHOW_COMMIT_COUNT}" == "true" ]] && SCM_BRANCH+="${commits_ahead}"
	fi
	if [[ "${commits_behind}" -gt 0 ]]; then
		SCM_BRANCH+="${SCM_GIT_AHEAD_BEHIND_PREFIX_CHAR}${SCM_GIT_BEHIND_CHAR}"
		[[ "${SCM_GIT_SHOW_COMMIT_COUNT}" == "true" ]] && SCM_BRANCH+="${commits_behind}"
	fi

	if [[ "${SCM_GIT_SHOW_STASH_INFO}" == "true" ]]; then
		local stash_count
		if [[ "${SCM_GIT_GITSTATUS_RAN}" == "true" ]]; then
			stash_count="${VCS_STATUS_STASHES?}"
		else
			stash_count="$(git stash list 2> /dev/null | wc -l | tr -d ' ')"
		fi
		[[ "${stash_count}" -gt 0 ]] && SCM_BRANCH+=" ${SCM_GIT_STASH_CHAR_PREFIX}${stash_count}${SCM_GIT_STASH_CHAR_SUFFIX}"
	fi

	SCM_STATE="${GIT_THEME_PROMPT_CLEAN:-${SCM_THEME_PROMPT_CLEAN:-}}"
	if ! _git-hide-status; then
		if [[ "${SCM_GIT_GITSTATUS_RAN:-}" == "true" ]]; then
			untracked_count="${VCS_STATUS_NUM_UNTRACKED?}"
			unstaged_count="${VCS_STATUS_NUM_UNSTAGED?}"
			staged_count="${VCS_STATUS_NUM_STAGED?}"
		else
			IFS=$'\t' read -r untracked_count unstaged_count staged_count < <(_git-status-counts)
		fi
		if [[ "${untracked_count}" -gt 0 || "${unstaged_count}" -gt 0 || "${staged_count}" -gt 0 ]]; then
			SCM_DIRTY=1
			if [[ "${SCM_GIT_SHOW_DETAILS}" == "true" ]]; then
				[[ "${staged_count}" -gt 0 ]] && SCM_BRANCH+=" ${SCM_GIT_STAGED_CHAR}${staged_count}" && SCM_DIRTY=3
				[[ "${unstaged_count}" -gt 0 ]] && SCM_BRANCH+=" ${SCM_GIT_UNSTAGED_CHAR}${unstaged_count}" && SCM_DIRTY=2
				[[ "${untracked_count}" -gt 0 ]] && SCM_BRANCH+=" ${SCM_GIT_UNTRACKED_CHAR}${untracked_count}" && SCM_DIRTY=1
			fi
			SCM_STATE="${GIT_THEME_PROMPT_DIRTY:-${SCM_THEME_PROMPT_DIRTY?}}"
		fi
	fi

	# no if for gitstatus here, user extraction is not supported by it
	[[ "${SCM_GIT_SHOW_CURRENT_USER}" == "true" ]] && SCM_BRANCH+="$(git_user_info)"

	SCM_PREFIX="${GIT_THEME_PROMPT_PREFIX:-${SCM_THEME_PROMPT_PREFIX-}}"
	SCM_SUFFIX="${GIT_THEME_PROMPT_SUFFIX:-${SCM_THEME_PROMPT_SUFFIX-}}"

	SCM_CHANGE=$(_git-short-sha 2> /dev/null || true)
}

function jj_prompt_vars() {
	local jj_root bookmark
	if [[ -n $(jj status 2> /dev/null) ]]; then
		SCM_DIRTY=1
		SCM_STATE="${JJ_THEME_PROMPT_DIRTY:-${SCM_THEME_PROMPT_DIRTY?}}"
	else
		SCM_DIRTY=0
		SCM_STATE="${JJ_THEME_PROMPT_CLEAN:-${SCM_THEME_PROMPT_CLEAN?}}"
	fi
	SCM_PREFIX="${JJ_THEME_PROMPT_PREFIX:-${SCM_THEME_PROMPT_PREFIX-}}"
	SCM_SUFFIX="${JJ_THEME_PROMPT_SUFFIX:-${SCM_THEME_PROMPT_SUFFIX-}}"

	jj_root="$(_find-in-ancestor ".jj")/.jj"

	if [[ -f "$jj_root/branch" ]]; then
		# Mercurial holds it's current branch in .hg/branch file
		SCM_BRANCH=$(< "${jj_root}/branch")
		bookmark="${jj_root}/bookmarks.current"
		[[ -f "${bookmark}" ]] && SCM_BRANCH+=:$(< "${bookmark}")
	else
		SCM_BRANCH=$(jj summary 2> /dev/null | grep branch: | awk '{print $2}')
	fi

	if [[ -f "$jj_root/dirstate" ]]; then
		# Mercurial holds various information about the working directory in .jj/dirstate file. More on http://mercurial.selenic.com/wiki/DirState
		SCM_CHANGE=$(hexdump -vn 10 -e '1/1 "%02x"' "$hg_root/dirstate" | cut -c-12)
	else
		SCM_CHANGE=$(jj summary 2> /dev/null | grep parent: | awk '{print $2}')
	fi
}

function k8s_context_prompt() {
	kubectl config current-context 2> /dev/null
}

function k8s_namespace_prompt() {
	kubectl config view --minify --output 'jsonpath={..namespace}' 2> /dev/null
}

function virtualenv_prompt() {
	local virtualenv
	if [[ -n "${VIRTUAL_ENV:-}" ]]; then
		virtualenv="${VIRTUAL_ENV##*/}"
		echo -ne "${VIRTUALENV_THEME_PROMPT_PREFIX-}${virtualenv}${VIRTUALENV_THEME_PROMPT_SUFFIX-}"
	fi
}

function py_interp_prompt() {
	local py_version
	py_version="$(python --version 2>&1 | awk 'NR==1{print "py-"$2;}')" || return
	echo -ne "${PYTHON_THEME_PROMPT_PREFIX-}${py_version}${PYTHON_THEME_PROMPT_SUFFIX-}"
}

function python_version_prompt() {
	virtualenv_prompt
	condaenv_prompt
	py_interp_prompt
}

function git_user_info() {
	local current_user
	# support two or more initials, set by 'git pair' plugin
	current_user="$(git config user.initials | sed 's% %+%')"
	# if `user.initials` weren't set, attempt to extract initials from `user.name`
	[[ -z "${current_user}" ]] && current_user=$(printf "%s" "$(for word in $(git config user.name | PERLIO=:utf8 perl -pe '$_=lc'); do printf "%s" "${word:0:1}"; done)")
	[[ -n "${current_user}" ]] && printf "%s" "${SCM_THEME_CURRENT_USER_PREFFIX-}${current_user}${SCM_THEME_CURRENT_USER_SUFFIX-}"
}

function clock_char() {
	local clock_char clock_char_color show_clock_char
	clock_char="${THEME_CLOCK_CHAR:-⌚}"
	clock_char_color="${THEME_CLOCK_CHAR_COLOR:-${normal:-}}"
	show_clock_char="${THEME_SHOW_CLOCK_CHAR:-"true"}"

	if [[ "${show_clock_char}" == "true" ]]; then
		echo -ne "${clock_char_color}${CLOCK_CHAR_THEME_PROMPT_PREFIX-}${clock_char}${CLOCK_CHAR_THEME_PROMPT_SUFFIX-}"
	fi
}

function clock_prompt() {
	local clock_color="${THEME_CLOCK_COLOR:-${normal?}}"
	local clock_format="${THEME_CLOCK_FORMAT:-"%H:%M:%S"}"
	local show_clock="${THEME_SHOW_CLOCK:-${THEME_CLOCK_CHECK:-true}}"
	local clock_string="\D{${clock_format}}"

	if [[ "${show_clock}" == "true" ]]; then
		echo -ne "${clock_color}${CLOCK_THEME_PROMPT_PREFIX-}${clock_string}${CLOCK_THEME_PROMPT_SUFFIX-}"
	fi
}

function user_host_prompt() {
	if [[ "${THEME_SHOW_USER_HOST:-false}" == "true" ]]; then
		echo -ne "${USER_HOST_THEME_PROMPT_PREFIX-}\u@${THEME_PROMPT_HOST:-\h}${USER_HOST_THEME_PROMPT_SUFFIX-}"
	fi
}

# backwards-compatibility
function git_prompt_info() {
	_git-hide-status && return
	git_prompt_vars
	echo -ne "${SCM_PREFIX?}${SCM_BRANCH?}${SCM_STATE?}${SCM_SUFFIX?}"
}

function jj_prompt_info() {
	jj_prompt_vars
	echo -ne "${SCM_PREFIX?}${SCM_BRANCH?}:${SCM_CHANGE#*:}${SCM_STATE?}${SCM_SUFFIX?}"
}

function prompt_char() {
	scm_char
}

function battery_char() {
	# The battery_char function depends on the presence of the battery_percentage function.
	if [[ "${THEME_BATTERY_PERCENTAGE_CHECK}" == true ]] && _command_exists battery_percentage; then
		echo -ne "${bold_red?}$(battery_percentage)%"
	else
		false
	fi
}

if ! _command_exists battery_charge; then
	# if user has installed battery plugin, skip this...
	function battery_charge() {
		: # no op
	}
fi

function aws_profile() {
	if [[ -n "${AWS_PROFILE:-}" ]]; then
		echo -ne "${AWS_PROFILE}"
	elif [[ -n "${AWS_DEFAULT_PROFILE:-}" ]]; then
		echo -ne "${AWS_DEFAULT_PROFILE}"
	else
		echo -ne "default"
	fi
}

function _save-and-reload-history() {
	local autosave="${1:-${HISTORY_AUTOSAVE:-0}}"
	[[ ${autosave} -eq 1 ]] && local HISTCONTROL="${HISTCONTROL:-}${HISTCONTROL:+:}autoshare"
	_history-auto-save && _history-auto-load
}

function venv_prompt() {
	if [[ -n "${VIRTUAL_ENV:-}" ]]; then
		virtualenv_prompt
	fi
}
