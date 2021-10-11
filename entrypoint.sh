#!/bin/sh

echo "Starting with STAGE=$STAGE"

# Start spotifyd
spotifyd --no-daemon $SPOTIFYD_ARGS &

# Start frontend
if [ "$STAGE" = "dev" ]; then
    npm --prefix="/frontend" run start
elif [ "$STAGE" = "prod" ]; then
    nginx -g "daemon off;" &
    firefox --kiosk localhost:1313 &
fi

tail -f /dev/null
