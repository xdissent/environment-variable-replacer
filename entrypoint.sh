#!/usr/bin/env bash

set -e

if [[ -z "${ACTION_INPUTS_FILENAME}" ]] && [[ -z "${ACTION_INPUTS_FILENAMES}" ]] then
  echo 'One or more file paths are required.,'
  exit 1
else
  if [[ -z "${ACTION_INPUTS_FILENAME}" ]]
  then
    FILENAMES="${ACTION_INPUTS_FILENAMES}"
  else
    FILENAMES="${ACTION_INPUTS_FILENAME}"
  fi
fi

if [[ -z "${ACTION_INPUTS_MIN_VARIABLE_LENGTH}" ]]
then
  MIN_LENGTH="2"
else
  MIN_LENGTH="${ACTION_INPUTS_MIN_VARIABLE_LENGTH}"
fi
MIN_LENGTH=$(($MIN_LENGTH))


while read -r -d "" var; do
  name="${var%%=*}"
  value="${var#*=}"
  echo "Setting ${name} to ${value}."
  if [ ${#name} -ge $MIN_LENGTH  ] && [ "$name" != "ACTION_INPUTS_MIN_VARIABLE_LENGTH" ] && [ "$name" != "ACTION_INPUTS_FILENAME" ] && [ "$name" != "ACTION_INPUTS_FILENAMES" ]
  then
    # Escaping methods from https://stackoverflow.com/questions/29613304/is-it-possible-to-escape-regex-metacharacters-reliably-with-sed

    search="__${name}__"
    searchEscaped=$(sed 's/[^^]/[&]/g; s/\^/\\^/g' <<<"$search")

    replace=$value
    IFS= read -d '' -r < <(sed -e ':a' -e '$!{N;ba' -e '}' -e 's/[&/\]/\\&/g; s/\n/\\&/g' <<<"$replace")
    replaceEscaped=${REPLY%$'\n'}

    while read -r file; do
      sed -i "s/$searchEscaped/$replaceEscaped/g" file
    done < $FILENAMES
  fi
done < <(printenv --null)
