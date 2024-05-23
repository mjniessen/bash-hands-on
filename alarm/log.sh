#!/usr/bin/env bash

logger --id=$$ <<EOF
MESSAGE_ID=my_custom_id
PRIORITY=info
SYSLOG_IDENTIFIER=my_app
This is a structured log message with PID.
EOF
