#!/bin/bash
if [ -x $0.local ]; then
    $0.local "$@" || exit $?
fi

if [ -x ./script/git-hooks/$(basename $0) ]; then
   exec ./script/git-hooks/$(basename $0) "$@" || exit $?
else
   echo "CWD: `pwd`"
   echo "can't find the hooks script './script/git-hooks/$(basename $0)"
   exit 1
fi
