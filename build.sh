#!/usr/bin/sh

CFLAGS='pkg-config --cflags libcurl'
LIBS='pkg-config --libs libcurl'

clang -Wall -Wextra -std=c11 `$CFLAGS` -o cat cat.ll `$LIBS`
