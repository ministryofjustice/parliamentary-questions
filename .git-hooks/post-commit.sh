#!/bin/sh

# Unix - Symlink this file to your repo .git/hooks/ directory with:
#
#   $ ln -s .git-hooks/post-commit .git/hooks/post-commit
#

# MacOS (Catalina 10.15.5) - Symlinking does not seem to work properly, useing Alias instead.
#
#   Make the post-commit.sh executable from the repository root with:
#
#     $ chmod u+x .git-hooks/post-commit.sh
#
#   In Finder open the .git-hooks folder (Shortcut: CMD + SHIFT + . Press once to show hidden files).
#   Rigth click on the post-commit.sh file and select 'Make Alias'
#   A file called 'post-commit.sh alias' will appear.
#   Cut and past this file to the .git/hooks/ folder
#   Rename the file to 'post-commit'
#

git-secrets --scan -r
