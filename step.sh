#!/bin/bash

set -x

FLAGS=''

if [ "${strict}" = "yes" ] ; then
  FLAGS=$FLAGS' --strict'
fi

if [ $reporter ] ; then
  FLAGS=$FLAGS' --reporter '"$reporter"
fi

if [ -d "${working_directory}" ] ; then
  pushd "${working_directory}"
else
  pushd "."
fi

if [ ! -s "${executable_path}" ] ; then
  echo " [!] SwiftLint executable does not exists at ${executable_path}"
  exit 1
fi

if [ -d "${logs_directory}" ] ; then
    log_file="${logs_directory}/swiftlint_log.txt"
    errors_file="${logs_directory}/swiftlint_errors"
    clear_cache="false"
else
    echo " (?) Logs directory not found. Storing no logs."
    log_file="swiftlint_log.txt"
    errors_file="swiftlint_errors"
    clear_cache="true"
fi

case $reporter in
    json|csv|html)
        errors_file="${errors_file}.${reporter}"
        ;;
    xcode|emoji)
        errors_file="${errors_file}.txt"
        ;;
    checkstyle|junit)
        errors_file="${errors_file}.xml"
        ;; 
    sonarqube)
        errors_file="${errors_file}.json"
        ;; 
    markdown)
        errors_file="${errors_file}.md"
        ;; 
esac

"${executable_path}" --strict ${FLAGS} --config "${lint_config_file}" > "${errors_file}" 2> "${log_file}"
swiftlint_exit_code=$?

cat "${log_file}"
cat "${errors_file}"

log_last_line=$(cat "${log_file}" | tail -1 )
SWIFTLINT_RESULT_SUMMARY=${log_last_line#Done linting! }

if [ $swiftlint_exit_code = 0 ] ; then
    SWIFTLINT_SCAN_STATUS="success"
else
    SWIFTLINT_SCAN_STATUS="failure"
fi

envman add --key SWIFTLINT_RESULT_SUMMARY --value "$SWIFTLINT_RESULT_SUMMARY"
envman add --key SWIFTLINT_VIOLATIONS_FILE --value "$SWIFTLINT_VIOLATIONS_FILE"

if [ "${clear_cache}" == "true" ] ; then
    rm -f "${log_file}"
    rm -f "${errors_file}"
else
    SWIFTLINT_VIOLATIONS_FILE=$(realpath "${errors_file}")
    SWIFTLINT_LOGS_FILE=$(realpath "${log_file}")
    envman add --key SWIFTLINT_SCAN_STATUS --value "$SWIFTLINT_SCAN_STATUS"
    envman add --key SWIFTLINT_LOGS_FILE --value "$SWIFTLINT_LOGS_FILE"
fi

echo "SWIFTLINT_RESULT_SUMMARY: $SWIFTLINT_RESULT_SUMMARY"
echo "SWIFTLINT_VIOLATIONS_FILE: $SWIFTLINT_VIOLATIONS_FILE"
echo "SWIFTLINT_SCAN_STATUS: $SWIFTLINT_SCAN_STATUS"
echo "SWIFTLINT_LOGS_FILE: $SWIFTLINT_LOGS_FILE"

popd 

exit $swiftlint_exit_code
