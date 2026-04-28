#!/bin/fish
#godot manager = G.O.M

source "$SCRIPT_DIR/utils.fish"

set ENGINE_DIR $PROJECT_DIR/godot
set ENGINE_SRC_DIR $ENGINE_DIR/godot
set ENGINE_BIN_DIR $ENGINE_DIR/editors
set ENGINE_LOG_DIR $SCRIPT_DIR/gom.logs

function build_godot -a build_type
	cd $ENGINE_SRC_DIR
	rm -ri bin/godot*

	set -l selected_branch (git branch -a | grep -e "remotes/origin/*" | fzf)
	set selected_branch (basename -- $selected_branch)
	if test -z "$selected_branch"
		return 1
	end

	git switch $selected_branch
	git pull

	set -l scons_args "platform=linuxbsd use_llvm=yes"
	set -l build_type_name ""
	switch $build_type
		case "*" debug d
			set build_type_name "debug"
			set scons_args $scons_args "use_asan=yes"
		case release r
			set build_type_name "release"
			set scons_args $scons_args "production=yes"
	end

	log "build_godot" "building [$build_type_name] godot editor version [$selected_branch]"
	read -P "Continue? [Y/n] " -l confirmation
	if test $confirmation = "n"
		echo "Canceling"
		return
	end

	scons $scons_args

	for binary in (find bin/* -type f)
		mv $binary $ENGINE_BIN_DIR/$selected_branch
	end

	cd -
end

function open_godot_editor
	set -l versions ""
	for binary in (find $ENGINE_BIN_DIR/* -type f)
		set versions $versions\n(basename -- $binary)
	end

	set -l selected_editor $ENGINE_BIN_DIR/(echo $versions | fzf)
	set -l log_file $ENGINE_LOG_DIR/(date +"%Y-%m-%d_%H:%M")

	echo "Opening version $selected_editor" > $log_file
	echo "=================================================================" >> $log_file
	echo "" >> $log_file

	fish -c "$selected_editor &>> $log_file" &
end

function clear_log
	log "clear_log" "Removing logs in $ENGINE_LOG_DIR"
	rm -rI $ENGINE_LOG_DIR/*
end

function gom
    argparse \
        'b/build_godot=?' \
        o/open_godot_editor \
        c/clear_log \
        -- $argv

    if set -q _flag_build_godot
		build_godot _flag_build_godot
    end

	if set -q _flag_clear_log
		clear_log
	end

	if set -q _flag_open_godot_editor
		open_godot_editor
	end

end
