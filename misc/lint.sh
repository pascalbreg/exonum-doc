#!/bin/bash

# Script allowing to execute one or more linters.
# Runs from the project root directory.
# It is assumed that the HTML pages are already built and are located in $SRC_DIR.

set -e

# Root directory of the project
ROOT_DIR=.
# Directory for source Markdown files
SRC_DIR="$ROOT_DIR/src"
# Directory with the site files generated by mkdocs
SITE_DIR="$ROOT_DIR/site"
# Directory with mdl linter binary
BIN_DIR=~/.local/bin
# Directory with linter configurations
CFG_DIR="$ROOT_DIR/misc"

kill_server () {
  ps -e --format pid,command | grep 'mkdocs' | grep -v 'grep' | awk '{ print $1 }' | xargs -r kill -KILL;
}

lint_md () {
  $BIN_DIR/mdl --style "$CFG_DIR/markdownlintrc" "$SRC_DIR";
}

lint_html () {
  html5validator --root "$SITE_DIR" --show-warnings --ignore-re \
    'Illegal character in query: "\|" is not allowed' \
    '"(autocorrect|autocapitalize)" not allowed on element "input"';
}

lint_links () {
  kill_server
  python -m mkdocs serve &
  sleep 10
  linkchecker -f "$CFG_DIR/linkcheckerrc" http://localhost:8000/
  kill_server
}

case "$1" in
  kill )
    kill_server;;
  md )
    lint_md;;
  html )
    lint_html;;
  links )
    lint_links;;
  all )
    lint_md;
    lint_html;
    lint_links;;
  * )
    echo "Unknown option: $1";
    exit 1;;
esac
