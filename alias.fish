#!/bin/fish

alias mm="cmake -S . -B ./build"
alias mmn="cmake -S . -B ./build -G Ninja"
alias mc="rm -r build && mkdir build"
alias bmn="ninja -C build -j 0"

alias fish_reload="source ~/.config/fish/user.fish"
