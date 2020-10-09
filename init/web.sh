port=${1:-${PORT:-8080}}

cd ..
eval "ruby -rwebrick -e'WEBrick::HTTPServer.new(:BindAddress => \"0.0.0.0\", :Port => ${port}, :MimeTypes => {\"rhtml\" => \"text/html\"}, :DocumentRoot => Dir.pwd).start'"
