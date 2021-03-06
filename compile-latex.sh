set -e

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
