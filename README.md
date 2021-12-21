### What's this?

Snip is a vim plugin for creating and managing vim abbreviations.

### Installation

Your preferred plugin manager, e.g with Vim-Plug:
```
Plug "quintik/Snip"
```

### Quick Start

Create a `/snip` directory in the same directory as `$MYVIMRC`, create a
`<filetype>.snip` file within the snip directory and you can start adding snips
to the file. For example, inside `snip/java.snip`:

```
# main #
snip psvm {
public static void main()<Left>
}
```

Then, inside a java file, type `0psvm` and it will be expanded once you press
space.

See `:h snip` for a more thorough introduction.

### License

[MIT License](https://github.com/quintik/snip/blob/master/LICENSE)
