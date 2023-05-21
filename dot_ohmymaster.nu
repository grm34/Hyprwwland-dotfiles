#!/usr/bin/env nu
# Hyprwwland > by darkmaster grm34.

# Configuration.
let-env config = ($env.config | upsert show_banner false
                              | upsert cursor_shape.emacs block
                              | upsert render_right_prompt_on_last_line true)

# Variables.
let-env RUST_BACKTRACE = 1
let-env LANG = 'en_US.UTF-8'
let-env KEYMAP = 'fr'
let-env EDITOR = 'helix'
let-env PAGER = 'most'
let-env TERM = 'alacritty'
let-env DELTA_PAGER = 'less -R'
let-env LS_COLORS = (vivid generate molokai | str trim)
let-env PATH = ($env.PATH | append ['~/.cargo/bin',
                                    '~/.local/bin',
                                    '/opt/android-sdk/platform-tools'])

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

# Private.
source ~/.private.nu

# Aliases.
alias c = clear
alias q = exit
alias hx = helix
alias fx = felix
alias cp = cp -p
alias ld = ls -d
alias lsa = ls -a
alias lsd = ls -da
alias gl = git log --oneline
alias gs = git status
alias gd = git diff
alias net = ss -tulpn
alias z = __zoxide_z
alias zi = __zoxide_zi
alias omz = helix ~/.ohmymaster.nu 

# Dotfiles.
def update_dotfiles [repo_reset: string, commit_msg: string] {
  if ($repo_reset != '' and $commit_msg != '') {
    let dotfiles = [
      $"($env.HOME)/.ohmymaster.nu"
      $"($env.HOME)/.gitconfig"
      $"($env.HOME)/.gtkrc-2.0"
      $"($env.HOME)/.icons/default"
      $"($env.HOME)/.librewolf/bookmarks.json"
      $"($env.HOME)/.local/bin"
      $"($env.HOME)/.config/alacritty"
      $"($env.HOME)/.config/bat"
      $"($env.HOME)/.config/broot"
      $"($env.HOME)/.config/dunst"
      $"($env.HOME)/.config/eww"
      $"($env.HOME)/.config/felix"
      $"($env.HOME)/.config/fuzzel"
      $"($env.HOME)/.config/gtk-2.0"
      $"($env.HOME)/.config/gtk-3.0"
      $"($env.HOME)/.config/gtk-4.0"
      $"($env.HOME)/.config/helix"
      $"($env.HOME)/.config/himalaya"
      $"($env.HOME)/.config/hypr"
      $"($env.HOME)/.config/neofetch"
      $"($env.HOME)/.config/nushell"
      $"($env.HOME)/.config/qt5ct"
      $"($env.HOME)/.config/qt6ct"
      $"($env.HOME)/.config/starship"
      $"($env.HOME)/.config/systemd"
      $"($env.HOME)/.config/xsettingsd"
      $"($env.HOME)/.config/zathura"
      $"($env.HOME)/.config/zellij"
    ]
    let conf = (ls $"($env.HOME)/.local/share/chezmoi")
    for $entry in $conf.name {
      if $entry =~ 'README.md' { continue } else { rm -rf $entry }
    }
    for $entry in $dotfiles { chezmoi add $entry }
    (rm -rf ~/.local/share/chezmoi/private_dot_config/eww/dot_git
            ~/.local/share/chezmoi/private_dot_config/nushell/history.txt
            ~/.local/share/chezmoi/private_dot_config/systemd/user/default*)
    if $repo_reset == 'yes' {
      chezmoi git -- checkout --orphan patch_latest
      chezmoi git -- add -A
      chezmoi git -- commit -am $commit_msg
      chezmoi git -- branch -D main
      chezmoi git -- branch -m main
    } else {
      chezmoi git -- add -A
      chezmoi git -- commit -m $commit_msg
    }
    chezmoi git -- push -f origin main
  } else { print 'Aborted.' }
}

# Hyprwwland-dotfiles.
def hww [action?: string] {
  if $action == 'push' {
    let commit_msg = (input 'Enter commit message: ')
    let repo_reset = 'no'
    update_dotfiles $repo_reset $commit_msg
  } else if $action == 'reset' {
    let commit_msg = 'Hyprwwland-dotfiles'
    let repo_reset = (input 'Reset repository? (yes/no) ')
    update_dotfiles $repo_reset $commit_msg
  } else {
    print 'Hyprwwland-dotfiles (https://github.com/grm34/Hyprwwland-dotfiles)'
    print '-------------------'
    print 'Push the changes:      hww push'
    print 'Reset commit history:  hww reset'
  }
}

