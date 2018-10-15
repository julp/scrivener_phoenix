#!/usr/bin/env bash

#readonly __DIR__=`cd $(dirname -- "${0}"); pwd -P`
declare -r __DIR__=$(dirname $(readlink -f "${BASH_SOURCE}"))

pushd "${__DIR__}" > /dev/null
mix gettext.extract
for locale in `find priv/gettext/ -type d -depth 1 -exec basename {} \;`; do
    mix gettext.merge priv/gettext --locale "${locale}"
done
popd > /dev/null
