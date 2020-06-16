# Janet Fuzzy Finder

My exercise in command-line programming. Think of it as fzf, but without all the
fancy stuff, but with one crucial addition: it prints what user has typed if
there is no remaining choice, which is excellent in combination with the Tab key.

Even with its simplicity, it has replaced wofi/dmenu utility for me.

## Implementation

I am using simple matching and scoring. Best score if choice starts or end
with the user input. Second best score if the user input is anywhere in the
string. Then fuzzy search with every intermittent char not in user input lower
score by -1. All scores start as 0.

Program is stable and responsive until around 1000 (depends on the machine)
when the delay starts to be perceivable. I guess it is Janet GC kicking in, as I
am not optimizing for memory consumption at all.

## Installation:

You need the latest development version of Janet programming language installed.
Then you can install jff with the jpm package manager:

`[sudo] jpm install https://github.com/pepe/jff`.

## Usage:

`ls Code/**/* | jff` will show the choices, and you can start fuzzy finding.
List of choices starts to narrow on every char. There are some special, yet
standard key combos for navigation:

- Down/Ctrl-n/Ctrl-j moves the selection down one item
- Up/Ctrl-p/Ctrl-k moves the selection up one item
- Tab replaces typed chars with the text of the selection
- Ctrl-c/Escape exits with error without printing anything
- Enter confirms the current selection and prints it to stdout



