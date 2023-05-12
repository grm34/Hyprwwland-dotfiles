# Hyprwwland > by darkmaster grm34.

def wguard [wg_option: string, wg_arg: string] {
  if ($wg_option == 'add' and $wg_arg != '') {
    nmcli connection add type wireguard ifname wg0 con-name $wg_arg
  } else if ($wg_option == 'rm' and $wg_arg != '') {
    nmcli connection delete $wg_arg
  } else if ($wg_option == 'import' and $wg_arg != '') {
    nmcli connection import type wireguard file $wg_arg
  } else {
    print 'Add new wireguard connection:    wguard add "name"'
    print 'Delete wireguard connection:     wguard rm "name"'
    print 'Import wireguard configuration:  wguard import "file.conf"'
  }
}

