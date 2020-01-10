# Wildcard paper

This paper uses pandoc to compile to both the Programming conference proceedings format, and an online essay.

The goal is to keep both versions in sync as closely as possible and avoid divergences.

## Compile

First install `paru` for ruby: `sudo gem install paru`. (May require a ruby upgrade)

Also install ImageMagick: `brew install imagemagick` for png conversion.

To view HTML with a live preview: `./watch.sh`

To compile to HTML (including copying assets to my personal homepage dir): `./compile-html.sh`
To compile to PDF through Latex: `./compile-latex.sh && open paper.pdf`

## notes

* image sizes and Latex output interact weirdly. I use high-res pngs exported from Sketch at 72dpi, and then in the latex compile script I use ImageMagick to set higher dpi so that the final size comes out correctly in the pdf.