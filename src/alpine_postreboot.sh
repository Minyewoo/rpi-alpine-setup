# Uncommenting community repository for apk
doas sed -i '/community/s/^#//g' /etc/apk/repositories
doas apk update

# Installing LXQt
doas setup-xorg-base
doas apk add lxqt-desktop lximage-qt obconf-qt pavucontrol-qt screengrab arandr sddm dbus adwaita-icon-theme

# Enabling dbus and sddm to start on boot
doas rc-update add dbus
doas rc-update add sddm

# Allowing shut down and reboot for users
doas apk add elogind polkit-elogind

# Adding elogind to start on boot for privilege escalation GUI
doas rc-update add elogind

# Auto-mounting USB drives
doas apk add gvfs udisks2

doas reboot