#!/bin/fish

function log -a name message type
	set -l log_name
	switch $type
		case e error
			set log_name "Error"
		case w warning
			set log_name "Warning"
		case "*"
			set log_name "Log"
	end

	set message "[ $log_name $name ] : $message"
    echo $message >> $SCRIPT_DIR/log.txt
	echo $message
end

function try_create_dir -a name
	if test -d $name
		return
	end

	command mkdir -p $name
end

function try_create_file -a name
	if test -f $name
		return
	end

	touch $name
end
