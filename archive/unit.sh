#!/bin/bash

if test -e env.src
then source env.src
fi

if cram tests
then echo SUCCESS ; exit 0
else echo FAIL ; exit 1
fi
