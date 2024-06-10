#!/usr/bin/env bash

SMS_CONTENT="${1:-This is a test.}"

SMS_SENDER="Mr.Bash"

SMS_RECEIVER=$(fsms)
SMS_RECEIVER=${SMS_RECEIVER:1:-1}
SMS_RECEIVER=${SMS_RECEIVER// /,}

sendsms -r "$SMS_RECEIVER" -s "$SMS_SENDER" "$SMS_CONTENT"

# vim: ft=bash ts=2 sw=2 sts=2 fileencoding=utf-8 foldmethod=marker
