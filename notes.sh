#!/usr/bin/env bash

dropbox_dir=~/"Dropbox/work/notes"
notes_dirname=".notes"
# switch to commit the notes dir
((commit_notes='0'))
# has to be regex escaped
note_done_marker='✔'

init() {
	name="$(pwd)"
	name="${name##*/}"
	notes_dir="$dropbox_dir/$name"

	if ! git status &>/dev/null; then
		git init
	fi

	if ! [[ -d "$notes_dir" ]]; then
		mkdir "$notes_dir"
	fi

	ln -s "$notes_dir" "$notes_dirname"

	if ! grep -q "$notes_dirname" '.gitignore' && ! ((commit_notes)); then
		echo "$notes_dirname" >> '.gitignore'
		git add '.gitignore'
		git commit -m "add .notes dir"
		echo ""
		echo "================================"
		echo "To change the commit message run"
		echo "git commit --amend"
		echo "================================"
	fi
}

commit() {
	for file in "$notes_dirname"/*; do
		if ! [[ -f "$file" ]]; then
			continue
		fi

		name="${file##*/}"
		prev_file="$notes_dirname/prev/$name"

		if ! [[ -f "$prev_file" ]]; then
			touch "$prev_file"
		fi

		git diff "$prev_file" "$file" | grep -E -h "+\s+$note_done_marker" > commit_template

		git commit -t commit_template

		if [[ "$?" = "0" ]]; then
			mv "$file" "$prev_file"
		fi

		rm commit_template
	done
}

help() {
	cat <<EOF
usage: notes <command>

Following commands can be used

init 	init a new note for the current project
help 	print this help message
EOF
}

command="$1"

case "$command" in
	"init") init ;;
	"commit") commit ;;
	"") help ;;
esac
