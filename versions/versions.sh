#!/bin/bash

dpkg -l | awk '{if ($1=="ii") print $2" "$3}'
