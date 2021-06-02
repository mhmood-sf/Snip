
<h4 align=center>
    <h1>Snap</h1>
    <img src="https://i.imgur.com/f6f4pxV.gif" alt="Snap preview"/>
</h4>

---

### Quick Start

Create a `/snap` directory in the same directory as `$MYVIMRC`, create a
`<filetype>.snap` file within the snap directory and you can start adding snips
to the file. For example, inside `snap/java.snap`:

```
# main #
snip psvm {
public static void main()<Left>
}
```

Then, inside a java file, type `0psvm` and it will be expanded once you press
space.

See `:h snap` for a more thorough introduction.

### Snap files

You can find and share snap files at
[quintik/snapfiles](https://github.com/quintik/snapfiles).

### Contributing

There are several ways you can contribute:
- You can, of course, help by directly making improvements to the code. The
  parser for snap files in particular could be much better.
- You can also help with improving the documentation if you find errors or
  find it confusing.
- You can help improve the syntax highlighting if you find issues with it.
- You can share your snap files at
  [quintik/snapfiles](https://github.com/quintik/snapfiles) to help others
  discover them easily!

### License

[MIT License](https://github.com/quintik/snap.vim/blob/master/LICENSE)

