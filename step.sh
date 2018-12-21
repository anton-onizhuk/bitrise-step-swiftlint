#!/bin/bash
set -ex

#
# Flags 

FLAGS=''

if [ "${strict}" = "yes" ] ; then
  FLAGS=$FLAGS' --strict'
fi

if [ -s "${lint_config_file}" ] ; then
  FLAGS=$FLAGS' --config '"${lint_config_file}"  
fi

if [ "${reporter}" != "none" ] ; then
  FLAGS=$FLAGS' --reporter '"${reporter}"  
fi

#
# Folder
 
if [ -z "${linting_path}" ] ; then
  linting_path="."
fi


#
# Call

pushd "${linting_path}"

if [ -f "${executable_path}" ] ; then
    $"executable_path" ${FLAGS}
elif [ "${executable_path}" == "swiftlint" ]
    swiftlint lint ${FLAGS}
else
  echo " [!] SwiftLint executable should be a path to file or a system swiftlint call. Received: '${executable_path}'"
  exit 1
fi

popd
