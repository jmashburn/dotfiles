# shellcheck shell=bash

_pathmunge "${NGINX_PATH:=/opt/nginx}/sbin" after

export NGINX_PATH

function nginx_reload() {
	local FILE="${NGINX_PATH?}/logs/nginx.pid"
	if [[ -s $FILE ]]; then
		echo "Reloading NGINX..."
		read -r PID < "${FILE}"
		sudo kill -HUP "${PID?}"
	else
		echo "Nginx pid file not found"
		return 0
	fi
}

function nginx_stop() {
	local FILE="${NGINX_PATH?}/logs/nginx.pid"
	if [[ -s $FILE ]]; then
		echo "Stopping NGINX..."
		read -r PID < "${FILE}"
		sudo kill -INT "${PID?}"
	else
		echo "Nginx pid file not found"
		return 0
	fi
}

function nginx_start() {
	local FILE="${NGINX_PATH?}/sbin/nginx"
	if [[ -x $FILE ]]; then
		echo "Starting NGINX..."
		sudo "${FILE}"
	else
		echo "Couldn't start nginx"
	fi
}

function nginx_restart() {
	nginx_stop && nginx_start
}