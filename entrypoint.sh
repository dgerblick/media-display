#!/bin/sh

# Start spotifyd
spotifyd --no-daemon $SPOTIFYD_ARGS &

# Start frontend
if [ "$STAGE" = "dev" ]; then
    npm --prefix="/frontend" run start
elif [ "$STAGE" = "prod" ]; then
    nginx -g "daemon off;" &
fi

tail -f /dev/null
