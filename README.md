# Wildcard paper

This paper is set up so it can compile to both the Programming conference proceedings format, and an online essay.

## Compile

First install `paru` for ruby: `sudo gem install paru`. (May require a ruby upgrade)

To view HTML with a live preview: `./watch.sh`

To compile to HTML (including copying assets to my personal homepage dir): `./compile-html.sh`
To compile to PDF through Latex: `./compile-latex.sh && open paper.pdf`

## Notes

There are ".sections" files that control which sections get included in each output version.

Assets used in the HTML version are inside the `wildcard` directory within this directory. This helps relative links play more nicely with the eventual deploy target, my personal website. (eg, links like `geoffreylitt.com/wildcard/media/video.mp4`)

