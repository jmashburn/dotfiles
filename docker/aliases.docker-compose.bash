# shellcheck shell=bash
about-alias 'docker-compose abbreviations'

if _command_exists docker-compose; then
    alias dco="docker-compose"

    # Defined in the `docker-compose` plugin, please check there for details.
    alias dcofresh="docker-compose-fresh"
    alias dcol="docker-compose logs -f --tail 100"
    alias dcou="docker-compose up"
    alias dcouns="dcou --no-start"
fi