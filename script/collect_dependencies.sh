#!/bin/env sh

cat elm.json | jq -r ".dependencies.direct, .dependencies.indirect|keys[]"
