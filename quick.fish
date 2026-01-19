#!/bin/fish

set PROJECT_DIR $HOME/Storage/projects
set SCRIPT_DIR $PROJECT_DIR/scripts
set SCRIPT_CONFIG $SCRIPT_DIR/config.yaml

function echo_err -a message
	echo "[Error  ]: $message" 1>2&
end

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
		case g game
			set directory $PROJECT_DIR/cpp-game
		case s script
			set directory $PROJECT_DIR/scripts
		case "*"
			echo_err "not a supported value ($name)"
			return 1
    end

    if [ -z "$directory" ]
		echo_err "empty directory"
        return 1
    end

    command yq -iy "$YAML_OPTION = \"$directory\"" $SCRIPT_CONFIG
    echo $directory
end

function open_nvim -a name
	set directory $(switch_directory $name)
	if [ $status -ne 0 ]
		return $status
	end

	nvim $directory
end

function open_folder -a name
	set directory $(switch_directory $name)
	if [ $status -ne 0 ]
		return $status
	end
	
	cd $directory
end

function quick
    set -l executed 0
    argparse n/nvim= c/cd= -- $argv
    if set -q _flag_nvim
        open_nvim $_flag_nvim
		set executed 1
    end

    if set -q _flag_cd
        open_folder $_flag_cd
		set executed 1
    end

    if [ $executed -eq 0 ]
        echo "Invalid argument $argv"
    end
end

alias qi="quick"
