#!/bin/env bash

# Exit if any command fails, if any undefined variable is used, or if a pipeline fails
set -euo pipefail

# Source the helper script
# shellcheck disable=SC1090
. ~/scripts/helper-script.sh || exit 1

# <<------ Directories ------>> #
book_library="$HOME/Documents/books"
note_library="$HOME/Documents/notes"
article_library="$HOME/Documents/Articles"

# <<------ Main ------>> #
create_document() {
    # Use dmenu to prompt the user to select the type of document to create
    document_type=$(echo -e "Basic\nOrg\nLaTeX\nBeamer\nRmark" | ${LAUNCHER} "What kind of note?")

    # Check if the user cancelled the prompt
    if [ -z "$document_type" ]; then
        return
    fi

    case "$document_type" in
        Basic)
            template="SimpleNote.md"
            EXTENSION="md"
            message="Basic Document Created!"
            ;;
        Org)
            template="Note.org"
            EXTENSION="org"
            message="Basic Document Created!"
            ;;
        LaTeX)
            template="LaTeX.tex"
            EXTENSION="tex"
            message="LaTeX Document Created!"
            ;;
        Beamer)
            template="Presentation.tex"
            EXTENSION="tex"
            message="Beamer Presentation Created!"
            ;;
        Rmark)
            template="RMarkdown.rmd"
            EXTENSION="rmd"
            message="R Markdown Document Created!"
            ;;
        *)
            err "Invalid option"
            ;;
    esac

    # Use dmenu to prompt the user to enter a name for the note
    cn_name=$(echo "" | ${LAUNCHER} "Enter a name for the note:")

    # Check if the user cancelled the prompt
    if [ -z "$cn_name" ]; then
        return
    fi

    # Check if the file already exists
    if [ -f "$directory/$cn_name.$EXTENSION" ]; then
        # Prompt the user to confirm if they want to overwrite the file
        if ! (echo -e "Yes\nNo" | ${LAUNCHER} "Note already exists. Overwrite?" | grep -q "Yes"); then
            return
        fi
    fi

    notify-send "$message"
    cp "$directory/Templates/$template" "$directory/$cn_name.$EXTENSION"
    $TEXT_EDITOR "$directory/$cn_name.$EXTENSION"
}

open_document() {
    # case insensitive search with ripgrep
    document=$(find "$directory" -type f \( -name '*.pdf' -o -name '*.epub' -o -name '*.mobi' \)) 
    selected_document=$(echo "$document" | awk -F/ '{print $NF}' | ${LAUNCHER} "📖 Open:")
    if [ -n "$selected_document" ]; then
        file_to_open=$(find "$directory" -type f -name "$selected_file")
        $PDF_VIEWER "$file_to_open"
    fi
}

edit_notes() {
    document=$(find "$directory" -type f \( -name '*.md' -o -name '*.wiki' -o -name '*.tex' -o -name '*.org' \))
    selected_file=$(echo "$document" | awk -F/ '{print $NF}' | ${LAUNCHER} "📖 Open:")
    if [[ -n $selected_file ]]; then
        file_to_open=$(find "$directory" -type f -name "$selected_file")
        $TEXT_EDITOR "$file_to_open"
    fi
}


main() {
    # Prompt the user to select "Library" or "Articles" using dmenu
    selected_dir=$(echo -e "📑 Create Note\n🔖 View Notes\n📚 Library\n📜 Articles" | ${LAUNCHER} "📂 Choose an action:")
    # Set the directory based on the user's selection
    # if selected_dir is not empty
    if [[ -n $selected_dir ]]; then
        case $selected_dir in
            "📑 Create Note")
                directory=$note_library
                create_document
                ;;
            "🔖 View Notes")
                directory=$note_library
                edit_notes
                ;;
            "📚 Library")
                directory=$book_library
                open_document
                ;;
            "📜 Articles")
                directory=$article_library
                open_document
                ;;
        esac
    else
        exit 0
    fi
}
main
