<h4 align="center">
<bold>
<pre>
    ______                          
   /      \                         
  |  ▓▓▓▓▓▓\_______  __  ______     
  | ▓▓___\▓▓       \|  \/      \    
   \▓▓    \| ▓▓▓▓▓▓▓\\▓▓  ▓▓▓▓▓▓\   
   _\▓▓▓▓▓▓\ ▓▓  | ▓▓\ \ ▓▓  | ▓▓   
  |  \__| ▓▓ ▓▓  | ▓▓ ▓▓ ▓▓__/ ▓▓   
   \▓▓    ▓▓ ▓▓  | ▓▓ ▓▓ ▓▓    ▓▓   
    \▓▓▓▓▓▓ \▓▓   \▓▓\▓▓ ▓▓▓▓▓▓▓    
                       | ▓▓         
                       | ▓▓         
                        \▓▓         
</pre>
<bold>
</h4>

### What's this?

Snip is a plugin for creating and managing vim abbreviations, and is particularly
useful for those who use abbreviations as a lightweight alternative to snippets
(hence a pseudo-snippet-engine).

### Why not UltiSnips or SnipMate or XYZ?

Snip is based on vim abbreviations, rather than being a full-fledged
snippet engine. If you're looking for a powerful snippet engine with lots of
features, this plugin probably isn't what you want.

Instead, Snip is for those who want a quick and lightweight solution
for creating snippets and managing abbreviations, without too much
complexity. It's a lightweight plugin without any other dependencies,
and is written purely in vimscript.

### Installation

If you use Plug:
```
Plug "quintik/Snip"
```
Vundle:
```
Plugin "quintik/Snip"
```
Packer:
```
use "quintik/Snip"
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

### Snip files

> ⚠ Work-in-progress! Contributions appreciated!

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

