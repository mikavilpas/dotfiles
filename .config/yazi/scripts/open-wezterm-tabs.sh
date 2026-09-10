#!/bin/sh
# Open one wezterm tab per directory given as an argument
set -eu

if [ -z "${WEZTERM_PANE:-}" ]; then
  echo "not running inside wezterm: WEZTERM_PANE is unset" >&2
  exit 1
fi

for path in "$@"; do
  #` cd` makes the path absolute, which is what `wezterm cli spawn --cwd`
  # needs.
  if [ -d "$path" ]; then
    directory=$(cd -- "$path" && pwd)
  else
    directory=$(cd -- "$(dirname -- "$path")" && pwd)
  fi

  pane=$(wezterm cli spawn --cwd "$directory")
done
