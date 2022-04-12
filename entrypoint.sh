#!/bin/bash
set -e

rm -f /backend/tmp/pids/server.pid

exec "$@"