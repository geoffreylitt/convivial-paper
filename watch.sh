set -e

ls *.md | entr ./compile-html.sh &
browser-sync start --server --files paper.html --no-notify --no-open --port 9000 &

open "http://localhost:9000/paper.html"

