set -e

cat html.sections | xargs pandoc \
  --filter conditional-render \
  --filter pandoc-citeproc \
  --metadata=format:html \
  -s \
  -o paper.html \
  --css basic.css \
  --toc \
  --toc-depth=2 \
  --variable=toc-title:"Contents" \
  --template=templates/pandoc-template-html.html

cp ./paper.html ~/dev/homepage/source/wildcard/index.html
cp ./basic.css ~/dev/homepage/source/wildcard
cp -r ./media ~/dev/homepage/source/wildcard