set -e

cat latex.sections | xargs pandoc --filter pandoc-citeproc -s -o paper.tex --template=templates/pandoc-template-programming.pandoc --biblatex
pdflatex -interaction=batchmode paper.tex
biber paper
pdflatex -interaction=batchmode paper.tex
pdflatex -interaction=batchmode paper.tex
open paper.pdf