#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$DIR/config.sh"

WATCHER="$DIR/../footswitch-watcher/footswitch-watcher"
BYPASS_SCRIPT="$DIR/set-passthrough.sh"

nohup $WATCHER $FOOTSWITCH1_GPIO "$BYPASS_SCRIPT -1" &
#nohup $WATCHER $FOOTSWITCH2_GPIO "your command" &
#nohup $WATCHER $FOOTSWITCH3_GPIO "your command" &
#nohup $WATCHER $FOOTSWITCH4_GPIO "your command" &

