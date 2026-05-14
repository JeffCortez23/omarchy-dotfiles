#!/usr/bin/env bash

time=$(date +"%H:%M")
date_str=$(date +"%A, %d/%m")

printf '{"text":"%s  %s"}\n' "$time" "$date_str"