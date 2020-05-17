#!/bin/env sh

scripts=$(dirname -- "$0")

"${scripts}"/collect_dependencies.sh | while read -r repo
do
  echo "${repo} : https://github.com/${repo}/"
  echo "==== ==== ==== START LICENSE FOR ${repo} ==== ==== ===="
  echo "${repo}" |
    "${scripts}"/fetch_license.sh
  echo "==== ==== ====  END LICENSE FOR ${repo} ==== ==== ===="
done
