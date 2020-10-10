#!/usr/bin/env bash
set -eu

port=${1:-${PORT:-8080}}
eval "ruby -rwebrick -e'WEBrick::HTTPServer.new(:BindAddress => \"0.0.0.0\", :Port => $port, :MimeTypes => {\"rhtml\" => \"text/html\"}, :DocumentRoot => Dir.pwd).start'"
