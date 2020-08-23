#!/bin/sh
#
# This pre-commit hook will execute the google-java-format script on
# Java files which have been added to the git staging area. The hook
# Can be configured by setting the hooks.googleformatflag git config
# variable.
#   ex: git config hooks.googleformatflag 1
#
# Assumptions:
#    * An executable named "google-java-format" is available on the path
#    * This script is executed as a pre-commit hook
#
# The following flag options are supported:
#   1: If any formatting errors exist, the commit will be aborted and
#      the names of the offending files will be output as an error
#      message.
#
#   2: The formatter will be executed for all staged Java files, and
#      any changes made by the formatter will be added to the content
#      of the commit.
#
# See https://git-scm.com/docs/git-config#_description for more
# information on how this variable can be scoped.

# This function will evaluate the staging area for any modified Java files.
# If no Java files are located, the script will exit successfully.
function _check_for_modified_java_files() {
  changed_java_files=$(git diff --cached --name-only --diff-filter=ACMR | grep ".*\.java$")
  [ -z "$changed_java_files" ] && exit 0
}

# This function evaluates any staged Java files for formatting errors.
# If errors are discovered, the commit will be aborted.
#
# This function will be executed when hooks.googleformatflag is set to 1
function _check_formatting() {
  _check_for_modified_java_files

  google-java-format --dry-run --set-exit-if-changed ${changed_java_files}

  if [ $? -ne 0 ]; then
    echo >&2 -n -n "[PRE-COMMIT] Error: The files above are not properly formatted!"
    exit 1
  fi

  exit 0
}

# This function will execute the formatter on any staged Java files,
# replacing the contents of those files with the formatted version.
#
# This function will be executed when hooks.googleformatflag is set to 2
function _execute_formatter() {
  _check_for_modified_java_files

  echo >&2 "[PRE-COMMIT] The following Java files are being formatted:"
  for file in $changed_java_files; do
    echo >&2 "  $file"
    google-java-format --replace ${changed_java_files}
    git add "$file"
  done

  exit 0
}

# Main logic
#
# The script will evaluate the hooks.googleformatflag variable, and
# call the corresponding function.
googleformatflag=$(git config --type int hooks.googleformatflag)

case $googleformatflag in
1)
  _check_formatting
  ;;
2)
  _execute_formatter
  ;;
*)
  # Default case, no-op
  ;;
esac
