# Janet Fuzzy Finder - get through some stdout almost omnisciently and friendly


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

Command line arguments:

```
 Optional:
 -c, --code VALUE                            Janet function definition to run. The selected choice or the PEG match if grammar provided. Default is
print.
 -f, --file VALUE                            Read a file rather than stdin for choices.
 -g, --grammar VALUE                         PEG grammar to match with the result.
 -h, --help                                  Show this help message.
 -x, --prefix VALUE=                         Prefix to remove when listing choices. Default ''.
 -r, --prompt VALUE=>                        Change the prompt. Default: '> '.
```

`jff < $choides` will show the choices, and you can start fuzzy finding.
List of choices starts to narrow on every char. There are some special, yet
standard key combos for navigation:

- Down/Ctrl-n/Ctrl-j moves the selection down one item
- Up/Ctrl-p/Ctrl-k moves the selection up one item
- Tab replaces typed chars with the text of the selection. To narrow the search.
- Ctrl-c/Escape exits with error without printing anything
- Enter confirms the current selection and matches/transforms/prints it to stdout

## Examples

Run the function on the result:

```
lr -1 | janet jff.janet -c '|(print (string/ascii-upper $))'
```

Match the result with the grammar and then runs the function:

```
lr -1 | janet jff.janet -g '(<- (to "."))'
                        -c '|(print (string/ascii-upper (first $)))'
```

