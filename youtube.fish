#!/bin/fish

function dlsinglem -a url
	command yt-dlp --js-runtimes node -x --audio-format mp3 -o "~/Storage/Music/DadMusic/%(title)s.%(ext)s" $url
end

function dlmultim
	command parallel dlsinglem ::: $argv
end
