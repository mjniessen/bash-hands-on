#!/usr/bin/env bash

EMAIL_SUBJECT="${1:-Notification}"
EMAIL_CONTENT="${2:-This is a test.}"

EMAIL_RECEIVER=$(femail)
EMAIL_RECEIVER=${EMAIL_RECEIVER:1:-1}

printf "Subject: %s\n\n%s" "$EMAIL_SUBJECT" "$EMAIL_CONTENT" |
  msmtp -a default "${EMAIL_RECEIVER,,}"

# vim: ft=bash ts=2 sw=2 sts=2 fileencoding=utf-8 foldmethod=marker
