set -e

cat html.sections | xargs pandoc \
  --filter pandoc-citeproc \
  -s \
  -o paper.html \
  --css basic.css \
  --toc \
  --toc-depth=2 \
  --variable=toc-title:"Contents" \
  --template=templates/pandoc-template-html.html

cp ./paper.html ~/dev/homepage/source/wildcard/index.html
cp ./wildcard/basic.css ~/dev/homepage/source/wildcard