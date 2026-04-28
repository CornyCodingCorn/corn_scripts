#!/bin/fish

source "$SCRIPT_DIR/utils.fish"

set GAME_DIR $PROJECT_DIR/games
set SCRIPT_CONFIG $SCRIPT_DIR/config.yaml

function switch_directory -a name
    set -l YAML_OPTION ".quick.switch_directory.last"
    set -l directory ""

    switch $name
        case l last .
            set directory $(command yq -r "$YAML_OPTION" $SCRIPT_CONFIG)
            if [ -z "$directory" ]
                set directory "."
            end
        case n nvim
            set directory $HOME/.config/nvim
        case f fish
            set directory $HOME/.config/fish
        case s script
            set directory $PROJECT_DIR/scripts
        case h hypr
            set directory $HOME/.config/hypr
        case e engine
            set directory $ENGINE_DIR
        case g game
            set -l projects
            for game_dir in (find $GAME_DIR/* -type d)
                set projects $projects (basename -- $game_dir)
            end

            set -l selected_projects (echo $projects | fzf)
            if test -z "$selected_projects"
                log switch_directory "not selecting anything" warn
                return 1
            end

            set directory $GAME_DIR/$selected_projects
        case "*"
            log switch_directory "not a supported value ($name)" error
            return 1
    end

    if test -z "$directory"
        log switch_directory "empty directory" error
        return 1
    end

	if not test -e $SCRIPT_CONFIG
		echo "Hi"
		touch $SCRIPT_CONFIG
	end

    command yq -iy "$YAML_OPTION = \"$directory\"" $SCRIPT_CONFIG
    echo $directory
end

function open_folder -a name
    set directory $(switch_directory $name)
    set -l __temp_status $status
    if [ $__temp_status -ne 0 ]
        return $__temp_status
    end

    cd $directory
end

function open_nvim -a name
    open_folder $name
    set -l __temp_status $status
    if [ $__temp_status -ne 0 ]
        return $__temp_status
    end

    command nvim .
    cd -
end

function quick
    argparse \
        a/alter_code= \
        c/cd= \
        r/reload \
        -- $argv

    if set -q _flag_alter_code
        open_nvim $_flag_alter_code
    end

    if set -q _flag_cd
        open_folder $_flag_cd
    end

    if set -q _flag_reload
        source ~/.config/fish/user.fish
    end
end

alias qi quick
