#!/bin/sh
set +ex

bundle exec rails db:migrate
bundle exec rails data:migrate

set -ex

printf '\e[33mINFO: Launching Puma\e[0m\n'
bundle exec puma -C config/puma.rb -e production
