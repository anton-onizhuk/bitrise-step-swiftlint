#!/bin/bash

set -x


FLAGS=''

if [ "${strict}" = "yes" ] ; then
  FLAGS=$FLAGS' --strict'
fi

if [ $override_reporter ] && [ "${override_reporter}" != "read_from_config" ] ; then
  FLAGS=$FLAGS' --reporter'"$override_reporter"
fi

if [ -d "${working_directory}" ] ; then
  cd "${working_directory}"
fi

if [ ! -s "${executable_path}" ] ; then
  echo " [!] SwiftLint executable does not exists at ${executable_path}"
  exit 1
fi

"${executable_path}" --strict ${FLAGS} --config "${lint_config_file}" > "swiftlint_errors.txt" 2> "swiftlint_log.txt"
swiftlint_exit_code=$?

cat "swiftlint_log.txt"
cat "swiftlint_errors.txt"

SWIFTLINT_RESULT_SUMMARY=$(cat swiftlint_log.txt | tail -1 )
SWIFTLINT_VIOLATIONS_FILE=$(realpath swiftlint_errors.txt)

envman add --key SWIFTLINT_RESULT_SUMMARY --value $SWIFTLINT_RESULT_SUMMARY
envman add --key SWIFTLINT_VIOLATIONS_FILE --value $SWIFTLINT_VIOLATIONS_FILE

echo SWIFTLINT_RESULT_SUMMARY
echo "$SWIFTLINT_RESULT_SUMMARY"
echo SWIFTLINT_VIOLATIONS_FILE
echo "$SWIFTLINT_VIOLATIONS_FILE"

exit $swiftlint_exit_code
