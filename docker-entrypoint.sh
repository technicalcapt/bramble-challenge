#!/usr/bin/env sh

$1 eval "BrambleChallenge.Release.create_repos" && \
$1 eval "BrambleChallenge.Release.migrate" && \
exec $1 start
