#!/usr/bin/env bash

# Copyright (C) 2012 - 2018 Jason A. Donenfeld <Jason@zx2c4.com>. All Rights Reserved.
# This file is licensed under the GPLv2+. Please see COPYING for more information.

clip() {
	local sleep_argv0="password store sleep on display $DISPLAY"
	pkill -f "^$sleep_argv0" 2>/dev/null && sleep 0.5
	local before="$(pbpaste | $BASE64)"
	echo -n "$1" | pbcopy
	(
		( exec -a "$sleep_argv0" bash <<<"trap 'kill %1' TERM; sleep '$CLIP_TIME' & wait" )
		local now="$(pbpaste | $BASE64)"
		[[ $now != $(echo -n "$1" | $BASE64) ]] && before="$now"
		echo "$before" | $BASE64 -d | pbcopy
	) >/dev/null 2>&1 & disown
	echo "Copied $2 to clipboard. Will clear in $CLIP_TIME seconds."
}

qrcode() {
	echo -n "$1" | qrencode -t utf8
}

# Use GNU getopt (installed via: brew install gnu-getopt)
if command -v /opt/homebrew/opt/gnu-getopt/bin/getopt &>/dev/null; then
	GETOPT="/opt/homebrew/opt/gnu-getopt/bin/getopt"
elif command -v /usr/local/opt/gnu-getopt/bin/getopt &>/dev/null; then
	GETOPT="/usr/local/opt/gnu-getopt/bin/getopt"
else
	echo "Error: GNU getopt is required but not found." >&2
	echo "Please install it using: brew install gnu-getopt" >&2
	exit 1
fi

SHRED="rm -f"
BASE64="base64"
