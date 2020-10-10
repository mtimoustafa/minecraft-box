#!/usr/bin/env bash
set -eu

port=8080
eval "ruby -r webrick -e'WEBrick::HTTPServer.new(:BindAddress => \"0.0.0.0\", :Port => $port, :MimeTypes => {\"rhtml\" => \"text/html\"}, :DocumentRoot => Dir.pwd).start'"
