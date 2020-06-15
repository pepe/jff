# Janet Fuzzy Finder

My exercise in command line programming. Think of it as fzf, but without all the
fancy stuff.

Even with its simplicity, it has replace wofi/dmenu utility for me.

## Installation:

You need latest development version of Janet programming language installed.
Then you can install jff with jpm package manager:

`[sudo] jpm install https://github.com/pepe/jff`.

## Usage:

`ls Code/**/* | jff` will show the choices and you can start fuzzy finding. On
enter it will print current choice to stdout.


