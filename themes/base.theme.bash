## The Base Theme - Just setting up the basics

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

SCM_P4='p4'
SCM_P4_CHAR='⌛'
SCM_P4_CHANGES_CHAR='C:'
SCM_P4_DEFAULT_CHAR='D:'
SCM_P4_OPENED_CHAR='O:'

SCM_HG='hg'
SCM_HG_CHAR='☿'

SCM_SVN='svn'
SCM_SVN_CHAR='⑆'

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
: "${HG_EXE:=${SCM_HG?}}"
: "${SVN_EXE:=${SCM_SVN?}}"
: "${P4_EXE:=${SCM_P4?}}"


function scm() {
	if [[ "${SCM_CHECK:-true}" == "false" ]]; then
		SCM="${SCM_NONE-NONE}"
	elif [[ -x "${GIT_EXE-}" ]] && _find-in-ancestor '.git' > /dev/null; then
		SCM="${SCM_GIT?}"
	elif [[ -x "${HG_EXE-}" ]] && _find-in-ancestor '.hg' > /dev/null; then
		SCM="${SCM_HG?}"
	elif [[ -x "${SVN_EXE-}" ]] && _find-in-ancestor '.svn' > /dev/null; then
		SCM="${SCM_SVN?}"
	elif [[ -x "${P4_EXE-}" && -n "$(p4 set P4CLIENT 2> /dev/null)" ]]; then
		SCM="${SCM_P4?}"
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
		"${SCM_HG?}")
			SCM_CHAR="${SCM_HG_CHAR?}"
			;;
		"${SCM_SVN?}")
			SCM_CHAR="${SCM_SVN_CHAR?}"
			;;
		"${SCM_P4?}")
			SCM_CHAR="${SCM_P4_CHAR?}"
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
		*)
			# TODO: consider adding minimal status information for hg and svn
			prompt_info="${SCM}_prompt_info"
			;;
	esac
	_is_function "${prompt_info}" && "${prompt_info}"
}

function battery_char() {
	# The battery_char function depends on the presence of the battery_percentage function.
	if [[ "${THEME_BATTERY_PERCENTAGE_CHECK}" == true ]] && _command_exists battery_percentage; then
		echo -ne "${bold_red?}$(battery_percentage)%"
	else
		false
	fi
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