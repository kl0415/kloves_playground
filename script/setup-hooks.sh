#!/bin/bash
HOOK_NAMES="commit-msg "
# assuming the script is in a bin directory, one level into the repo
HOOK_DIR=.git/hooks

CDIR=`pwd`

if [ ! -d "$HOOK_DIR" ]; then
   printf %s\\n 'You must be in the root directory of a `git` project to use this script!' >&2
   exit 1 ;fi

if [ -f "$CDIR/script/commit_template.txt" ]; then
   cp $CDIR/script/commit_template.txt $CDIR/.git/commit_template.txt
   echo "Setting up your commit template: as '$CDIR/.git/commit_template.txt"
   git config --global commit.template $CDIR/.git/commit_template.txt
fi

if [ -f "$CDIR/script/git-hooks/validate-commit-msg.rb" ]; then
   cp $CDIR/script/git-hooks/validate-commit-msg.rb $CDIR/.git/hooks/
   echo "Copying ruby validator to hooks dir"
fi


for hook in $HOOK_NAMES; do
    # If the hook already exists, is executable, and is not a symlink
    if [ ! -h $HOOK_DIR/$hook -a -x $HOOK_DIR/$hook ]; then
        echo" Found $HOOK_DIR/$hook and moving to  $HOOK_DIR/$hook.local"
        mv $HOOK_DIR/$hook $HOOK_DIR/$hook.local
    fi
    # create the symlink, overwriting the file if it exists
    # probably the only way this would happen is if you're using an old 
    # version of git
    # -- back when the sample hooks were not executable, instead of being 
    #    named ____.sample
    #echo " linking to: $CDIR/script/hooks-wrapper.sh"
    echo " Linking $CDIR/script/git-hooks/$hook to $HOOK_DIR/$hook"
    ln -s -f $CDIR/script/git-hooks/$hook $HOOK_DIR/$hook
done
