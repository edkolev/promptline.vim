# promptline.vim

Simple shell prompt generator with support for powerline symbols and airline integration

> bash

![promptline_head](https://f.cloud.github.com/assets/1532071/1797552/21be199a-6aef-11e3-8397-67754f12998d.png)

> zsh

![promptline_head2](https://f.cloud.github.com/assets/1532071/1811043/4419f3ce-6e41-11e3-89cf-f495325ab1a2.png)

> fish

![promptline_head3](https://cloud.githubusercontent.com/assets/1532071/4437991/6b687cba-47a4-11e4-8efe-b53aa1ef34bb.png)


## Features

- **Create a plain .sh file to manage the prompt.** The generated file can be sourced by the shell on login.
- **Very fast prompt.** No external binaries are spawned to render the prompt (no python, not even grep or sed)
- **Use [vim-airline][1]/[lightline.vim][8] colors**, so the prompt shares the same colors with vim's statusline
- **Preloaded with stock themes and presets**, which can be combined in multiple ways
- **Configure the prompt with a simple associative array**, in case stock presets don't meet your needs
- **Preloaded with commonly used prompt sections** e.g. branch name, last exit code (if not zero)

The plugin has been tested in bash, zsh and fish

More screenshots can be found in the [wiki](https://github.com/edkolev/promptline.vim/wiki/Screenshots)

#### Quick Start with airline installed

1. In vim `:PromptlineSnapshot ~/.promptline.sh airline`
2. In bash/zsh `source ~/.promptline.sh`

#### Quick Start with lightline installed

1. In vim `:PromptlineSnapshot ~/.promptline.sh lightline`
2. In bash/zsh `source ~/.promptline.sh`

#### Quick Start

1. In vim `:PromptlineSnapshot ~/.promptline.sh`
2. In bash/zsh `source ~/.promptline.sh`

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

The created file should be sourced by bash/zsh:
```
# in .bash.rc / .zshrc
source [file]
```

For fish:
```
# in .config.fish
function fish_prompt
  env FISH_VERSION=$FISH_VERSION PROMPTLINE_LAST_EXIT_CODE=$status bash ~/.promptline.sh left
end

function fish_right_prompt
  env FISH_VERSION=$FISH_VERSION PROMPTLINE_LAST_EXIT_CODE=$status bash ~/.promptline.sh right
end
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

### TL;DR (starting point for a personalized prompt)

```
" sections (a, b, c, x, y, z, warn) are optional
let g:promptline_preset = {
        \'a' : [ promptline#slices#host() ],
        \'b' : [ promptline#slices#user() ],
        \'c' : [ promptline#slices#cwd() ],
        \'y' : [ promptline#slices#vcs_branch() ],
        \'warn' : [ promptline#slices#last_exit_code() ]}

" available slices:
"
" promptline#slices#cwd() - current dir, truncated to 3 dirs. To configure: promptline#slices#cwd({ 'dir_limit': 4 })
" promptline#slices#vcs_branch() - branch name only. By default, only git branch is enabled. Use promptline#slices#vcs_branch({ 'hg': 1, 'svn': 1, 'fossil': 1}) to enable check for svn, mercurial and fossil branches. Note that always checking if inside a branch slows down the prompt
" promptline#slices#last_exit_code() - display exit code of last command if not zero
" promptline#slices#jobs() - display number of shell jobs if more than zero
" promptline#slices#battery() - display battery percentage (on OSX and linux) only if below 10%. Configure the threshold with promptline#slices#battery({ 'threshold': 25 })
" promptline#slices#host() - current hostname.  To hide the hostname unless connected via SSH, use promptline#slices#host({ 'only_if_ssh': 1 })
" promptline#slices#user()
" promptline#slices#python_virtualenv() - display which virtual env is active (empty is none)
" promptline#slices#git_status() - count of commits ahead/behind upstream, count of modified/added/unmerged files, symbol for clean branch and symbol for existing untraced files
" promptline#slices#conda_env() - display which conda env is active (empty is none)
"
" any command can be used in a slice, for example to print the output of whoami in section 'b':
"       \'b' : [ '$(whoami)'],
"
" more than one slice can be placed in a section, e.g. print both host and user in section 'a':
"       \'a': [ promptline#slices#host(), promptline#slices#user() ],
"
" to disable powerline symbols
" `let g:promptline_powerline_symbols = 0`

```

### Custom preset

Contents of the prompt are configured with a simple hash, with optional keys `a, b, c, x, y, z, warn`. In zsh, `x, y, z, warn` will be placed in the right prompt.
```
let g:promptline_preset = {
      \'a'    : [ '\h' ],
      \'b'    : [ '\u' ],
      \'c'    : [ '\w' ]}
```

![screen shot 2013-12-26 at 4 58 15 pm](https://f.cloud.github.com/assets/1532071/1811021/c71e2ac6-6e3f-11e3-9498-08c1e70d2835.png)

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

![screen shot 2013-12-26 at 4 59 42 pm](https://f.cloud.github.com/assets/1532071/1811006/02c1aeb4-6e3f-11e3-8a65-4b370c023362.png)

Any command can be used in the prompt with `$(command)`. Also, order of the sections in `g:promptline_preset` can be configured with `left_sections, right_sections, left_only_sections`. `left_sections` and `right_sections` will be used to order the sections in zsh (zsh supports left and right prompt via PROMPT and RPROMPT), `left_only_sections` will be used for bash (which doesn't support right prompt).
```
let g:promptline_preset = {
      \'a'    : [ '$(hostname)' ],
      \'b'    : [ '$(whoami)' ],
      \'c'    : [ '$(pwd)' ],
      \'options': {
          \'left_sections' : [ 'b', 'a' ],
          \'right_sections' : [ 'c' ],
          \'left_only_sections' : [ 'b', 'a', 'c' ]}}
```

promptline comes preloaded with a few commonly used commands:
- current directory (with dir truncation and powerline separators)
- git branch (displayed in git repos only)
- job count (displayed if jobs != 0)
- last exit code (displayed if exit code != 0)

These commands (which are actually functions) reside in autoload/promptline/slices.vim

Sections `x, y, z, warn` will be printed on the right by default if the shell supports it.

```
let g:promptline_preset = {
        \'a'    : [ '$USER' ],
        \'b'    : [ promptline#slices#cwd() ],
        \'c'    : [ promptline#slices#vcs_branch() ],
        \'warn' : [ promptline#slices#last_exit_code() ],
        \'z'    : [ promptline#slices#host() ]}
```

bash:

![screen shot 2013-12-26 at 5 01 54 pm](https://f.cloud.github.com/assets/1532071/1811007/02c934b8-6e3f-11e3-986f-2611024f6e1a.png)

zsh:

![screen shot 2013-12-26 at 5 02 58 pm](https://f.cloud.github.com/assets/1532071/1811023/d084a2e8-6e3f-11e3-86de-dd9a856d591c.png)

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

### Custom slice

#### git sha1

Example: include git short sha1 hash in the prompt. Desired output:

![screen shot 2013-12-30 at 3 33 55 pm](https://f.cloud.github.com/assets/1532071/1822221/15a4a2f0-7157-11e3-92be-67efd210da01.png)


##### simple one-liners

Slices (a.k.a. segments) can be any custom command/function. To include the sha1 after the branch:
```
let g:promptline_preset = {
        \'a' : [ promptline#slices#cwd() ],
        \'c' : [ promptline#slices#vcs_branch(), '$(git rev-parse --short HEAD 2>/dev/null)']}
```

As a result, the sha1 will be displayed next to the branch name. If the current dir is not a git repository, the section will be empty:

![screen shot 2013-12-30 at 3 17 55 pm](https://f.cloud.github.com/assets/1532071/1822208/6f96ea12-7156-11e3-8418-dda03084b760.png)

##### functions

If the desired output cannot be achieved with a one-liner, a shell function can be used. This is specified with a hash, containing the function name and body:

```
let git_sha_slice = {
      \'function_name': 'git_sha',
      \'function_body': [
        \'function git_sha {',
        \'  local sha',
        \'  sha=$(git rev-parse --short HEAD 2>/dev/null) || return 1',
        \'  printf "%s" "$sha"',
        \'}']}

let g:promptline_preset = {
        \'a' : [ promptline#slices#cwd() ],
        \'b' : [ promptline#slices#vcs_branch(), git_sha_slice ]}
```

Two things to note here:
* `function_name` (string) is the name of the shell function. It's only used to make sure the function is not added more than once in the generated .sh file
* `function_body` (array) is the shell function which will be placed in the generated .sh file.

The result is the same.

![screen shot 2013-12-30 at 3 17 55 pm](https://f.cloud.github.com/assets/1532071/1822208/6f96ea12-7156-11e3-8418-dda03084b760.png)

## Installation

The plugin's files follow the standard layout for vim plugins.

- [Pathogen][4] `git clone https://github.com/edkolev/promptline.vim ~/.vim/bundle/promptline.vim`
- [Vundle][5] `Bundle 'edkolev/promptline.vim'`
- [NeoBundle][6] `NeoBundle 'edkolev/promptline.vim'`

For the powerline symbols (the arrows), a [powerline font][9] is required.

## Inspired by

- Bailey Ling's [vim-airline][1]
- Kim Silkebækken's [Powerline][2]
- Olivier Verdier's [zsh-git-prompt][7] (git_status slice)

## Rationale

I wanted unified colors throughout my most often used terminal applications (editor, multiplexer, shell).
That motivated me to create this plugin, as well as [tmuxline][3]

There are similar plugins, but all of them seem to use an external (to the shell) program, e.g. python, nodejs.
I think the shell's prompt should be as fast as possible, without being slowed by an external process.
The only external process, spawned by promptline-generated prompt, is used to get VCS branch (i.e. `git`)

## Known Issues

- zsh empty whitespace on right prompt

  Up until version 5.0.5, zsh had a hard-coded space at the end of the right prompt. To remove the extra space, install zsh 5.0.5 (or later) and set `ZLE_RPROMPT_INDENT=0` in zshrc.

## License

MIT License. Copyright (c) 2013-2019 Evgeni Kolev.

[1]: https://github.com/bling/vim-airline
[2]: https://github.com/Lokaltog/powerline
[3]: https://github.com/edkolev/tmuxline.vim
[4]: https://github.com/tpope/vim-pathogen
[5]: https://github.com/gmarik/vundle
[6]: https://github.com/Shougo/neobundle.vim
[7]: https://github.com/olivierverdier/zsh-git-prompt
[8]: https://github.com/itchyny/lightline.vim
[9]: https://github.com/Lokaltog/powerline-fonts
