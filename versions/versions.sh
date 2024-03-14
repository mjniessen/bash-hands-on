#!/usr/bin/env bash

apt list --installed 2>/dev/null | cut -d' ' -f-2 | sed 's/\/[\,A-Za-z0-9\-]*//' | tr ' ' ','
