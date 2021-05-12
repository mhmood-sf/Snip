# snap

helps me organize vim's abbreviations, and pretend i'm using snippets.

### usage

you need a directory to store your 'snips' - the default is the `snap/`
directory, placed in the same directory as `$MYVIMRC`. to set the directory
yourself, you can set the `g:snap_dir` variable in your vimrc.

#### snap files

in your snap directory, you can create `<filetype>.snap` files. all snips in
this file will be loaded and available when a buffer of that filetype is
opened. the special file `autoload.snap` can be used for snips that will
always be loaded and available everywhere.

snap files are simple files used for storing your snips. for example:
```
# comment #
snip psvm {
public static void main()<Left>
}

```

the keyword 'snip' is used to define an abbreviation, the name comes after
that, and then curly braces inside which is the expansion for the abbreviation.
note the use of `<Left>` - these are just to translated to a vim `inoreabbrev`
command, so everything you're allowed to do the same things here. See
`:h abbreviations` for more.

#### snipexpr

you can use `snipexpr` to create abbreviations where the expansion is a
vimscript expression that will be evaluated and its result will be used as the
expansion:
```
# expr snips #
snipexpr date {
strftime('%H:%M')
}
```

#### moving the cursor

again, this is just a wrapper over abbreviations so you can go into normal mode
and move your cursor around:
```
# tex.snap #
snip begin {
\begin{}<CR>
<CR>
\end{}
<Esc>ki<Tab>
}
```

#### prefix

to make things a bit manageable, all abbreviations are actually prefixed. the
default is '0', so the snip in the example above will be expanded when you type
'0begin' and then a space (or a keyword character). you can change this by
setting the `g:snap_prefix` variable. **note** that the prefix must be a
keyword character otherwise it will make vim angry (see `:h iskeyword`).

#### syntax highlighting

syntax highlighting for snap files is included, but it is very very basic.

#### lazy loading

lazy loading is on by default, meaning your snips from `<filetype>.snap` will
only be loaded when you open a file of that type (or for whatever reason a 
FileType event for that filetype occurs). you can set `g:snap_lazy` to 0 to use
eager loading instead, where all files will be read and loaded on startup, and
then the abbreviations will become available when the FileType event occurs. in
most cases, there shouldn't be much of a difference between them.

#### maxfuncdepth

because of my poor vimscripting and parsing skills, you might get a
'maxfuncdepth' error from vim if your snap file reaches around 17-20 snips. in
this case, just set `maxfuncdepth` to a larger value (see `:h maxfuncdepth`).

