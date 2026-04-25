source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting
# potentially disabling fastfetch
# function fish_greeting
# end
set -gx LD_LIBRARY_PATH /usr/lib \$LD_LIBRARY_PATH

if not set -q SSH_AUTH_SOCK
  eval (ssh-agent -c)
  set -Ux SSH_AUTH_SOCK $SSH_AUTH_SOCK
  set -Ux SSH_AGENT_PID $SSH_AGENT_PID
end
