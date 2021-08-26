
<h1 align="center">Snip</h1>
<img src="https://i.imgur.com/f6f4pxV.gif" alt="Snip preview"/>

---

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

### Snip files

You can find and share snip files at
[quintik/snipfiles](https://github.com/quintik/snipfiles).

### Contributing

There are several ways you can contribute:
- You can, of course, help by directly making improvements to the code. The
  parser for snip files in particular could be much better.
- You can also help with improving the documentation if you find errors or
  find it confusing.
- You can help improve the syntax highlighting if you find issues with it.
- You can share your snip files at
  [quintik/snipfiles](https://github.com/quintik/snipfiles) to help others
  discover them easily!

### License

[MIT License](https://github.com/quintik/snip/blob/master/LICENSE)

