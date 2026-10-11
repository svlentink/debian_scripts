#!/bin/sh
exec tmux \
    -S /tmp/shared_tmux_session \
    attach-session \
    -r \
    -t mainsession
