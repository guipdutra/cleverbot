#!/bin/sh
set -e

# Ensure the app's dependencies are installed
mix deps.get

echo "\n Launching Phoenix web server..."
# Start the phoenix web server
mix phx.server
