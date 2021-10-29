# kak-bundle-plug

## _`plug` compatibility for `kak-bundle`_

`kak-bundle-plug` provides an identically-named command that emulates [`plug.kak`](https://github.com/andreyorst/plug.kak) `plug` / [`plug-chain`](https://github.com/andreyorst/plug.kak#plug-chain) functionality under [`kak-bundle`](https://codeberg.org/jdugan6240/kak-bundle). It makes it possible to switch back and forth between the `plug` and `kak-bundle` plugin managers with a **single alias** (`alias plug-chain kak-bundle-plug`). It is written in pure `kakscript` (it rewrites `plug` commands as `bundle-register-and-load` equivalents); thus it should have minimal overhead.


## Install

Clone somewhere **outside** of `autoload`, and source the file in `kakrc` before using it. Suggested:
```
# clone under ~/.config/kak/non-autoload/
source %val{config}/non-autoload/kak-bundle-plug/kak-bundle-plug.kak
```


## Usage

As with `plug-chain`,
```
kak-bundle-plug \
  https://github.com/Delapouite/kakoune-select-view config %{
    map global view s '<esc>: select-view<ret>' \
      -docstring 'select view'
  } \
  plug https://github.com/jbomanson/search-doc.kak.git demand search-doc %{
    alias global doc-search search-doc
  } \
  plug https://github.com/occivink/kakoune-find  # etc, one long command
```

Most of `plug` / `plug-chain` syntax is supported (`config`, `demand` / `defer`, `load-path`, `noload`, `branch` / `tag`). Differences:
- no `domain`, either implicit or as a parameter. The full `git` URL must be specified.
- the `config` keyword cannot be omitted (`plug` recognizes codeblocks with no preceding keyword as `config`'s)
- `demand` / `defer` require a codeblock, even if empty
- not directly supported: `theme`, `ensure`. However, themes can be marked as `noload` and manually symlinked / unlinked from `~/.config/kak/colors` (it's enough to link the entire theme folder, as opposed to individual `.kak` files in a theme).

A `kakrc` that obeys these restrictions can switch from `plug` to `kak-bundle` and back by adding (or commenting out) the above-mentioned alias
```
alias plug-chain kak-bundle-plug
```

It is even possible to share the `plugins` directory. Symlink `%opt{bundle_path}/plugins` into `%val{config}/plugins` and maintain via `bundle-install` / `bundle-update`. The other way around does not work, (`bundle` needs symlinks for `load-path` plugins; `plug.kak` ignores those, but also does not create them).

For specific plugins that do not fit the `kak-bundle-plug` paradigm, use native `plug` or `bundle` commands. A few exceptions won't make much of a difference in `kakrc` start-up time.


## Implementation

`bundle-register-and-load` takes a list of "installer" + "postlude" pairs.
- installers can be `git` URLs (no spaces) or commands (containing whitespace); they are obvioulsy used by `bundle-install`, but also for figuring out the plugins' folders under `bundle/plugins`: after removing any final `.git` and `/`, the substring after the last `/` in the installer is the inferred plugin sub-folder.
- the postlude is evaluated after `kak` loads the `.kak` files in the plugin; it corresponds to `plug config` blocks, `defer` (which adds a `ModuleLoaded` hook), and `demand` (`defer` + `require-module`)

Thus:
- for `load-path` plugins, the `bundle` installer is set to `ln -sf $load_path` (with some tweaks)
- for regular plugins, the `bundle` installer is the URL (which `bundle` translates to a `git clone` command); if `tag` or `branch` are specified, `kak-bundle-plug` converts the URL to an appropriate `git clone --branch` command before it reaches `bundle`.

`kak-bundle-plug` iterates over all parameters, extracts individual `plug` clauses (delimited by the `plug` keyword), builds up a `str-list`, and passes it to `bundle-register-and-load`. All this is possible in pure kakscript (I have [described some of the "tricks"](https://discuss.kakoune.com/t/kakscript-has-loop-catch-this-head-tail-shift-int-0-streq-etc/1885) in the `kakoune` forum).


## Copyright

`Alin Mr. <almr.oss@outlook.com>` / MIT license
