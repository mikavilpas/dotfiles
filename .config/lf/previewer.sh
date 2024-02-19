#!/bin/sh

case "$1" in
*.tar*) tar tf "$1" ;;
*.zip) unzip -l "$1" ;;
*.rar) unrar l "$1" ;;
*.7z) 7z l "$1" ;;
*.pdf) pdftotext "$1" - ;;
*) bat --paging=never --style=numbers,changes --line-range=:100 --terminal-width $(($2 - 5)) -f "$1" || true ;;
	#*) highlight -O ansi "$1" || true;;
esac
