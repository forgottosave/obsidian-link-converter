# Obsidian-link Converter
This script replaces all obsidian-style links in a file, or folder with 'proper' markdown links.

`[[markdownlink#chapter|replacename]]` $\rightarrow$ `[replacename](relative/path/to/markdownlink.md)`

More simple links (without a #chapter, or |replacename) are of course also possible.

*inline-html images currently don't work in Obsidian, only in most other markdown editors (and Github). To stop the html-image conversion, set the variable on top of the script to false*

## Usage
The goal of this script is to be very light weight, compared to other big obsidian plugins, that exist. This is also why `olc.sh` is the only required file to ensure functionality. Make sure that is has execution rights with `chmod +x olc.sh` before using it.

Provide a file, or folder as the first argument:
```
./olc.sh folder-name/
```
Changes are made in-place.

## Warning
It is recommended to create a backup before using the script, just in case...
- some special case was not concidered in the script
- some conversion did not go as you wanted it

