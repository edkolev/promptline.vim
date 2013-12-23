# promptline.vim

Simple shell prompt generator with support for powerline symbols and airline integration

![promptline_head](https://f.cloud.github.com/assets/1532071/1797552/21be199a-6aef-11e3-8397-67754f12998d.png)

## Features

- **Create a plain .sh file to manage the prompt.** The generated file can be sourced by the shell on login.
- **Very fast prompt.** No external binaries are spawned to render the prompt (no python, not even grep or sed)
- **Use [vim-airline][1] colors**, so the prompt shares the same colors with vim's statusline
- **Preloaded with stock themes and presets**, which can be combined in multiple ways
- **Configure the prompt with a simple hash**, in case stock presets don't meet your needs
- **Preloaded with commonly used prompt sections** e.g. branch name, last exit code (if not zero)

The plugin has been tested in bash and zsh

#### Quick Start with airline installed

1. In vim `:PromptlineSnapshot ~/.shell_prompt.sh airline`
2. In bash/zsh `source ~/.shell_prompt.sh`

#### Quick Start

1. In vim `:PromptlineSnapshot ~/.shell_prompt.sh`
2. In bash/zsh `source ~/.shell_prompt.sh`

## Usage

Create a snapshot file with default prompt.
```
:PromptlineSnapshot [file]
```

Specify theme:
```
:PromptlineSnapshot [file] [theme]
```

Specify theme and preset:
```
:PromptlineSnapshot [file] [theme] [preset]
```

The created file should be sourced by the shell
```
# in .bash.rc / .zshrc
source [file]
```

## Configuration

### Stock preset

Set `g:promptline_preset` to a stock preset. Running `:PromptlineSnapshot [file]` will use `g:promptline_preset` as `[preset]`

```
let g:promptline_preset = 'clear'
" or
let g:promptline_preset = 'full'
" other presets available in autoload/promptline/presets/*
```

### Stock theme

Set `g:promptline_theme` to a stock theme. Running `:PromptlineSnapshot [file]` will use `g:promptline_theme` as `[theme]`

```
let g:promptline_theme = 'airline'
" or
let g:promptline_theme = 'jelly'
" other themes available in autoload/promptline/themes/*
```

## Customization

### Custom preset

Contents of the prompt are configured with a simple hash, with optional keys `a, b, c, warn`
```
let g:promptline_preset = {
      \'a'    : [ '\h' ],
      \'b'    : [ '\u' ],
      \'c'    : [ '\w' ]}
```

TODO screenshot

bash will replace `\h \u \w`. zsh's syntax for replacements is a bit different:

bash | zsh | excerpts from bash man page
:---: | :---: | ---
\u | %n |   the username of the current user
\w | %~ |   the current working directory, with $HOME abbreviated with a tilde
\W | %d |   the basename of the current working directory, with $HOME abbreviated with a tilde
\h | %m |  the hostname up to the first `.'
\H | %M |  the hostname
\j | %j | the number of jobs currently managed by the shell
\$ | %# | if the effective UID is 0, a #, otherwise a $
$(command) | $(command) | allows the output of a command to replace the command name
\t | %* |  the current time in 24-hour HH:MM:SS format
\A | %T |  the current time in 24-hour HH:MM format

If the arrays in `g:promptline_preset` hold multiple values, a powerline separator will be placed between them.
```
let g:promptline_preset = {
      \'a'    : [ '\h', '\u', '\j' ],
      \'c'    : [ '\w' ]}
```

TODO screenshot

bash allows any command in the prompt. Also, `g:promptline_preset` accepts an optional `order` key, which can be used to re-order the sections
```
let g:promptline_preset = {
      \'a'    : [ '$(hostname)' ],
      \'b'    : [ '$(whoami)' ],
      \'c'    : [ '$(pwd)' ],
      \'order': [ 'c', 'b', 'c']}
```

promptline comes preloaded with a few commonly used commands:
- current directory (with dir truncation and powerline separators)
- git branch (displayed in git repos only)
- job count (displayed if jobs != 0)
- last exit code (displayed if exit code != 0)

```
let g:promptline_preset = {
        \'a'    : [ '\h', '\u' ],
        \'b'    : [ promptline#slices#cwd() ],
        \'c'    : [ promptline#slices#vcs_branch() ],
        \'warn' : [ promptline#slices#last_exit_code() ]}
```

TODO screenshot

### Symbols

Use `let g:promptline_powerline_symbols = 0` to disable using powerline symbols

To configure symbols:
```
let g:promptline_symbols = {
    \ 'left'       : '',
    \ 'left_alt'   : '>',
    \ 'dir_sep'    : ' / ',
    \ 'truncation' : '...',
    \ 'vcs_branch' : '',
    \ 'space'      : ' '}
```

## Installation

The plugin's files follow the standard layout for vim plugins.

- [Pathogen][4] `git clone https://github.com/edkolev/promptline.vim ~/.vim/bundle/promptline.vim`
- [Vundle][5] `Bundle 'edkolev/promptline.vim'`
- [NeoBundle][6] `NeoBundle 'edkolev/promptline.vim'`

## Inspired by

- Bailey Ling's [vim-airline][1]
- Kim Silkebækken's [Powerline][2]

## Rationale

I wanted unified colors throughout my most often used terminal applications (editor, multiplexer, shell).
That motivated me to create this plugin, as well as [tmuxline][3]

There are similar plugins, but all of them seem to use an external (to the shell) program, e.g. python, nodejs.
I think the shell's prompt should be as fast as possible, without being slowed by an external process.
The only external process, spawned by promptline-generated prompt, is used to get VCS branch (i.e. `git`)

## License

MIT License. Copyright (c) 2013 Evgeni Kolev.

[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/edkolev/promptline.vim/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

[1]: https://github.com/bling/vim-airline
[2]: https://github.com/Lokaltog/powerline
[3]: https://github.com/edkolev/tmuxline.vim
[4]: https://github.com/tpope/vim-pathogen
[5]: https://github.com/gmarik/vundle
[6]: https://github.com/Shougo/neobundle.vim
