set -e

cat html.sections | xargs pandoc \
  --filter pandoc-citeproc -s -o paper.html --css base.css --toc --variable=toc-title:"Contents" --template=templates/pandoc-template-html.html