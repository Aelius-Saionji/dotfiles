#!/bin/sh

# The runtime temporary config
volatileConfig="$HOME/.cache/compton.conf"

# Ensure cache config exists via compton.service ExecStartPre
case $1 in
	createcache)
		[ -e $volatileConfig ] || cp $HOME/.config/compton.conf $volatileConfig
		exit ;;
esac

# Retrieve class name of active window
activeID=$(xprop -root _NET_ACTIVE_WINDOW | sed -e 's/^.*id\s#\s//')
activeClass=$(xprop -id $activeID | sed -e '/^WM_CLASS/!d' -e 's/^.*\,\s//' -e 's/\"/'\''/g')

# Remove active window from config exclude list
if grep $activeClass $volatileConfig ; then
	sed -i $volatileConfig -e '/'$activeClass'/d'
	notifymsg="Transparency Enabled"
# Add active window to config exclude list
else
	sed -i $volatileConfig -e 's/focus-exclude = \[/focus-exclude = [\n\t"class_g = '$activeClass'",/'
	notifymsg="Transparency Disabled"
fi

# Restart compton to apply changes
systemctl --user restart compton.service
sleep 1
notify-send "$notifymsg" "$activeClass"