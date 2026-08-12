# Localization
d-i debian-installer/locale string en_US
d-i keyboard-configuration/xkb-keymap select us

# Network configuration
d-i netcfg/choose_interface select auto
d-i netcfg/get_hostname string unassigned-hostname
d-i netcfg/get_domain string unassigned-domain
d-i netcfg/wireless_wep string

# Disable online mirror during initial install
d-i mirror/http/hostname string
d-i mirror/http/directory string
d-i apt-setup/use_mirror boolean false

# Optional: Disable online security repository during install
d-i apt-setup/security_host string

# # Standard Debian Security repository config for Debian 12
# d-i apt-setup/security_host string security.debian.org
# d-i apt-setup/security_path string /debian-security

# Account setup
d-i passwd/root-login boolean false
d-i passwd/user-fullname string kevin
d-i passwd/username string kevin
# Hash matches your Ubuntu config
d-i passwd/user-password-crypted password $6$HFFPPnhKmtgvZKvJ$HPlCLq8z9Dswz8nEJxUvtMsG3z4ZhriLpZiYirybfzy0vTb6boR//sErEIhZ0mhnyqIUrUrr6HYZjWRykCLXu/
d-i user-setup/allow-password-weak boolean true
d-i user-setup/encrypt-home boolean false

# Clock and time zone setup
d-i clock-setup/utc boolean true
d-i time/zone string US/Eastern

# Partitioning (Standard recipe: one partition, no swap)
d-i partman-auto/method string regular
d-i partman-lvm/device_remove_lvm boolean true
d-i partman-md/device_remove_md boolean true
d-i partman-partitioning/confirm_write_new_label boolean true
d-i partman/choose_partition select finish
d-i partman/confirm boolean true
d-i partman/confirm_nooverwrite boolean true

# Package selection
tasksel tasksel/first multiselect standard, ssh-server
d-i pkgsel/include string qemu-guest-agent sudo curl cloud-init rsync systemd-resolved jq
d-i pkgsel/upgrade select none

# Boot loader installation
d-i grub-installer/only_debian boolean true
d-i grub-installer/with_other_os boolean true
d-i grub-installer/bootdev string default

# Ensure network configuration finishes properly before package installation
d-i netcfg/choose_interface select auto

# Official Debian mirror for extra package fetching
d-i mirror/country string manual
d-i mirror/http/hostname string deb.debian.org
d-i mirror/http/directory string /debian
d-i mirror/http/proxy string

# Match ISO base release
d-i mirror/suite string bookworm
d-i mirror/codename string bookworm

d-i apt-setup/use_mirror boolean true
d-i apt-setup/security_host string security.debian.org
d-i apt-setup/security_path string /debian-security

d-i preseed/late_command string \
    echo "nameserver 192.168.11.99 > /target/etc/resolv.conf; \
    in-target mkdir -p /home/kevin/.ssh; \
    echo "${ssh_key}" > /target/home/kevin/.ssh/authorized_keys; \
    in-target chown -R kevin:kevin /home/kevin/.ssh; \
    in-target chmod 700 /home/kevin/.ssh; \
    in-target chmod 600 /home/kevin/.ssh/authorized_keys; \
    echo "kevin ALL=(ALL) NOPASSWD:ALL" > /target/etc/sudoers.d/kevin; \
    in-target chmod 440 /etc/sudoers.d/kevin; \
    in-target systemctl enable qemu-guest-agent; \
    mkdir -p /target/etc/cloud/cloud.cfg.d/; \
    echo "system_info:" > /target/etc/cloud/cloud.cfg.d/99_renderers.cfg; \
    echo "  network:" >> /target/etc/cloud/cloud.cfg.d/99_renderers.cfg; \
    echo "    renderers: [netplan, eni]" >> /target/etc/cloud/cloud.cfg.d/99_renderers.cfg


# Avoid that last "Installation complete" message
d-i finish-install/reboot_inplace boolean true
d-i cdrom-detect/eject boolean true
