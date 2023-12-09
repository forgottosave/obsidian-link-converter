# Obsidian-link Converter
This script replaces all obsidian-style links in a file, or folder with 'proper' markdown links.

`[[markdownlink#chapter|replacename]]` $\rightarrow$ `[replacename](path/to/markdownlink.md)`

More simple links (without a #chapter, or |replacename) are of course also possible.
Be aware, that chapters are currently ignored.

## Usage
The goal of this script is to be very light weight, compared to other big obsidian plugins, that exist. This is also why `olc.sh` is the only required file to ensure functionality. Make sure that is has execution rights with `chmod +x olc.sh` before using it.

Provide a file, or folder as the first argument:
```
./olc.sh folder-name/
```
Changes are made in-place.

## Warning
There are special cases not covered yet (like having `&` in the part behind a `|`).
It is recommended to create a backup before starting the conversion, just in case.

The `test.sh` includes some tests with special cases and can be run, to see which cases are covered and which not.
Please create a new issue, should you find that an important case is missing in the tests.
