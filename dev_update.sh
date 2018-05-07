#!/bin/bash
export APP_VERSION=0.1.0+`date -u +%Y.%m.%d%H%M%S | sed "s/\.0/./g"`
export APP_ARGUMENTS="$@"
if [ $# -eq 0 ]; then
	APP_ARGUMENTS="--upgrade"
fi

# Remove the cached Mix.exs
rm _build/dev/lib/universa/ebin/universa.app

mix release $APP_ARGUMENTS
