#!/bin/env sh

scripts=$(dirname -- "$0")

echo "This application uses third party libraries which are distributed under the lincenses which differ from the this application's license. Such libraries and their licenses are listed below." | fmt

echo ""

"${scripts}"/collect_dependencies.sh | while read -r repo
do
  echo "${repo} : https://github.com/${repo}/"
  echo "==== ==== ==== START LICENSE FOR ${repo} ==== ==== ===="
  echo "${repo}" |
    "${scripts}"/fetch_license.sh |
    fmt
  echo "==== ==== ====  END LICENSE FOR ${repo} ==== ==== ===="
done
