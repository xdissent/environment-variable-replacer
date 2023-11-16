#!/usr/bin/env bash

set -e

echo "----- Environment Variable Replacer -----"

# Escaping methods from https://stackoverflow.com/questions/29613304/is-it-possible-to-escape-regex-metacharacters-reliably-with-sed
quoteSubst() {
  IFS= read -d '' -r < <(sed -e ':a' -e '$!{N;ba' -e '}' -e 's/[&/\]/\\&/g; s/\n/\\&/g' <<<"$1")
  printf %s "${REPLY%$'\n'}"
}

quoteRe() { sed -e 's/[^^]/[&]/g; s/\^/\\^/g; $!a\'$'\n''\\n' <<<"$1" | tr -d '\n'; }

if [[ -z "${ACTION_INPUTS_FILENAME}" ]] && [[ -z "${ACTION_INPUTS_FILENAMES}" ]]
then
  echo 'One or more file paths are required.'
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

echo "Replacing env vars with a length of ${MIN_LENGTH} or more in the following files: ${FILENAMES}"

while read -r -d "" var; do
  name="${var%%=*}"
  value="${var#*=}"
  if [ ${#name} -ge $MIN_LENGTH  ] && [ "$name" != "ACTION_INPUTS_MIN_VARIABLE_LENGTH" ] && [ "$name" != "ACTION_INPUTS_FILENAME" ] && [ "$name" != "ACTION_INPUTS_FILENAMES" ]
  then
    echo "Setting ${name} to ${value}."
    search="__${name}__"
    searchEscaped=$(quoteRe "$search")

    replace=$value
    replaceEscaped=$(quoteSubst "$replace")

    while read -r file; do
      sed -i -e ':a' -e '$!{N;ba' -e '}' -e "s/${searchEscaped}/${replaceEscaped}/"  file
    done < <($FILENAMES)
  fi
done < <(printenv --null)
