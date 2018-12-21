#!/bin/bash

set -ex

#
# Flags 

FLAGS=''

if [ "${strict}" = "yes" ] ; then
  FLAGS=$FLAGS' --strict'
fi

#
# Folder
 
if [ -z "${linting_path}" ] ; then
  linting_path="."
fi

#
# Call

pushd "${linting_path}"

if [ -s "${executable_path}" ] ; then
  "${executable_path}" --reporter "${reporter}" --config "${lint_config_file}" ${FLAGS}
elif [ "${executable_path}" == "swiftlint" ] ; then
  swiftlint lint --reporter "${reporter}" "${FLAGS}"
else
  echo " [!] SwiftLint executable should be a path to file or a system swiftlint call. Received: '$executable_path'"
  exit 1
fi

popd
