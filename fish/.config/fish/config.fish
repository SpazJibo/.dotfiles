source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting
# potentially disabling fastfetch
# function fish_greeting
# end
set -gx LD_LIBRARY_PATH /usr/lib \$LD_LIBRARY_PATH

if status is-interactive
  keychain --eval --quiet ~/.ssh/id_ed25519 | source
end
