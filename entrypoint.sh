#!/bin/sh
# The home directory belongs to the user exaequos. A CI runner has another
# uid, and Docker then sets HOME to a directory that user cannot write.
if [ -z "${HOME}" ] || [ "${HOME}" = "/" ] || [ ! -w "${HOME}" ]; then
    export HOME=/tmp
fi
exec "$@"
