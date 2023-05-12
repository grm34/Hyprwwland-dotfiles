# Hyprwwland > by darkmaster grm34.

def update_dotfiles [repo_reset: string, commit_msg: string] {
  if ($repo_reset != '' and $commit_msg != '') {
    let dotfiles = [
      $"($env.HOME)/.ohmymaster.nu"
      $"($env.HOME)/.gitconfig"
      $"($env.HOME)/.gtkrc-2.0"
      $"($env.HOME)/.icons/default"
      $"($env.HOME)/.librewolf/bookmarks.json"
      $"($env.HOME)/.config/alacritty"
      $"($env.HOME)/.config/bat"
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

def hww [action?: string] {
  if $action == 'reload' {
    pkill -f -9 eww
    eww open-many topbar dock
  } else if $action == 'backup-dotfiles' {
    let repo_reset = (input 'Reset repository ? (yes/no) ')
    let commit_msg = (input 'Enter commit message : ')
    update_dotfiles $repo_reset $commit_msg
  } else {
    print 'Reload Hyprwwland (eww):      hww reload'
    print 'Backup Hyprwwland-dotfiles:   hww backup-dotfiles'
  }
}

