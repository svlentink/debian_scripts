#!/bin/sh
exec tmux 
    -S /tmp/shared_tmux_session \
    new \
    -s mainsession
