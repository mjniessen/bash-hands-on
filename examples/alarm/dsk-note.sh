#!/usr/bin/env bash

reply_action() {
  echo "REPLY"
}

forward_action() {
  echo "FORWARD"
}

handle_dismiss() {
  echo "DISMISS"
}

ACTION=$(dunstify --action="default,Reply" --action="forwardAction,Forward" "Message Received" "Nachrricht")

case "$ACTION" in
"default")
  reply_action
  ;;
"forwardAction")
  forward_action
  ;;
"2")
  handle_dismiss
  ;;
esac

# vim: ft=bash ts=2 sw=2 sts=2 fileencoding=utf-8 foldmethod=marker
