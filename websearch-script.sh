#!/usr/bin/env bash
# Set with the flags "-e", "-u","-o pipefail" cause the script to fail
# if certain things happen, which is a good thing.  Otherwise, we can
# get hidden bugs that are hard to discover.
set -euo pipefail

dependencies=("jq")

# Source the helper script
# shellcheck disable=SC1090
. ~/scripts/helper-script.sh "${dependencies[@]}" || exit 1

main() {
    # As this is loaded from other file it is technically not defined
    # shellcheck disable=SC2154 # Choosing  a search engine by name from array above.
    engine=$(printf '%s\n' "${!websearch[@]}" | sort | ${DMENU} 'Choose search engine:') || exit 1

    # Getting the URL of the search engine we chose.
    url="${websearch["${engine}"]}"

    # Searching the chosen engine.
    query=$(printf '%s' "$engine" | ${DMENU} 'Enter search query:')

    query="$(echo -n "${query}" | jq -s -R -r @uri)"
    # Display search results in web browser
    # shellcheck disable=SC2154
    ${DMBROWSER} "${url}${query}"
}

main
