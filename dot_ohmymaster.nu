#!/usr/bin/env nu
# Hyprwwland > by darkmaster grm34.

# Configuration.
let-env config = ($env.config | upsert show_banner false)
let-env config = ($env.config | upsert cursor_shape.emacs block)
let-env config = ($env.config | upsert buffer_editor 'helix')
let-env config = ($env.config | upsert render_right_prompt_on_last_line true)

# Variables.
let-env LANG = 'en_US.UTF-8'
let-env KEYMAP = 'fr'
let-env EDITOR = 'helix'
let-env PAGER = 'most'
let-env TERM = 'alacritty'
let-env DELTA_PAGER = 'less -R'
let-env PATH = ($env.PATH | append ['~/.cargo/bin'])
let-env LS_COLORS = (vivid generate molokai | str trim)
let-env RUST_BACKTRACE = 1

# Starship.
let-env STARSHIP_SESSION_KEY = (random chars -l 16)
let-env STARSHIP_CONFIG = '~/.config/starship/config.toml'
def-env create_left_prompt [] {
  (^starship prompt $"--cmd-duration=($env.CMD_DURATION_MS)"
                    $"--status=($env.LAST_EXIT_CODE)")
}
let-env PROMPT_COMMAND = {|| create_left_prompt }
let-env PROMPT_COMMAND_RIGHT = {|| '' }
let-env PROMPT_INDICATOR = {|| '' }
let-env PROMPT_MULTILINE_INDICATOR = {|| '❯❯❯ ' }

# Zoxide.
if (not ($env | default false __zoxide_hooked | get __zoxide_hooked)) {
  let-env __zoxide_hooked = true
  let-env config = ($env | default {} config).config
  let-env config = ($env.config | default {} hooks)
  let-env config = ($env.config | update hooks (
    $env.config.hooks | default {} env_change))
  let-env config = ($env.config | update hooks.env_change (
    $env.config.hooks.env_change | default [] PWD))
  let-env config = ($env.config | update hooks.env_change.PWD (
    $env.config.hooks.env_change.PWD | append {|_, dir|
      zoxide add -- $dir }))
}
def-env __zoxide_z [...rest:string] {
  let arg0 = ($rest | append '~').0
  let path = if (
    ($rest | length) <= 1) and (
      $arg0 == '-' or ($arg0 | path expand | path type) == dir) {
        $arg0
  } else {
    (zoxide query --exclude $env.PWD -- $rest | str trim -r -c "\n")
  }
  cd $path
}
def-env __zoxide_zi  [...rest:string] {
  cd $'(zoxide query -i -- $rest | str trim -r -c "\n")'
}

# Completions.
source ~/.config/nushell/completions/git.nu
source ~/.config/nushell/completions/pass.nu
source ~/.config/nushell/completions/zellij.nu

# Scripts.
source ~/.config/nushell/scripts/hyprwwland.nu
source ~/.config/nushell/scripts/wireguard.nu

# Aliases.
alias c = clear
alias q = exit
alias hx = helix
alias fx = felix
alias ls = ls -d
alias lsa = ls -da
alias gl = git log --oneline
alias gs = git status
alias gd = git diff
alias net = ss -tulpn
alias z = __zoxide_z
alias zi = __zoxide_zi

