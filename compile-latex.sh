set -e

convert media/airbnb-demo.png -density 300 -units pixelsperinch media/airbnb-demo-300dpi.png
convert media/expedia-demo.png -density 300 -units pixelsperinch media/expedia-demo-300dpi.png
convert media/todomvc-demo.png -density 300 -units pixelsperinch media/todomvc-demo-300dpi.png
convert media/overview.png -density 300 -units pixelsperinch media/overview-300dpi.png

pandoc \
  --filter conditional-render \
  --filter pandoc-crossref \
  --filter pandoc-citeproc \
  -s \
  -o \
  paper.tex \
  --template=templates/pandoc-template-programming.pandoc \
  --biblatex \
  --metadata=format:pdf \
  paper.md

pdflatex paper.tex
biber paper
pdflatex -interaction=batchmode paper.tex
pdflatex -interaction=batchmode paper.tex
open paper.pdf
