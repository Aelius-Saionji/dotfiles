# Add ~/.bin to the path
typeset -U path
path=(~/.bin $path)

# mmh tweaks
export MMHP=~/.mmh-profile
export MMHEDITOR=~/.bin/vimeditmail
export MMHPAGER=~/.bin/vimpagermail

# Steam fixes
find ~/.steam/root/ \( -name "libgcc_s.so*" -o -name "libstdc++.so*" -o -name "libxcb.so*" -o -name "libgpg-error.so*" \) -delete
export STEAM_RUNTIME=0

# qt programs use GTK themes
export QT_STYLE_OVERRIDE=GTK+

# Various custom things
export DMENU_FONT=inconsolata:size=8
export SUDO_ASKPASS=~/.bin/daskpass

# for the benefit of ranger shell -t
export TERMCMD=st
export LESS=-R

# Start X at VT1 login
[ -z "$DISPLAY" -a "$(fgconsole)" -eq 1 ] && exec startx