#!/bin/env sh

read -r repo
curl -s "https://raw.githubusercontent.com/${repo}/master/LICENSE" | awk 1
