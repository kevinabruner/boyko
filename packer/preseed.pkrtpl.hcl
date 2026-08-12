# Early command: Ensure target resolv.conf is copied during disk mount
d-i preseed/early_command string \
    mkdir -p /target/etc; \
    cp -f /etc/resolv.conf /target/etc/resolv.conf

# Localization
d-i debian-installer/locale string en_US
d-i keyboard-configuration/xkb-keymap select us

# Network configuration
d-i netcfg/choose_interface select auto
d-i netcfg/disable_dhcp boolean false
d-i netcfg/get_hostname string unassigned-hostname
d-i netcfg/get_domain string unassigned-domain
d-i netcfg/get_nameservers string 192.168.11.99 1.1.1.1
d-i netcfg/wireless_wep string

# Mirror settings
d-i mirror/country string manual
d-i mirror/http/hostname string deb.debian.org
d-i mirror/http/directory string /debian
d-i mirror/http/proxy string
d-i mirror/suite string bookworm
d-i mirror/codename string bookworm

# Force copying DNS into target system before apt-setup runs
d-i apt-setup/local0/repository string deb http://deb.debian.org/debian bookworm main
d-i apt-setup/use_mirror boolean true
d-i apt-setup/services-select multiselect security, updates
d-i apt-setup/security_host string security.debian.org
d-i apt-setup/security_path string /debian-security

# Account setup
d-i passwd/root-login boolean false
d-i passwd/user-fullname string kevin
d-i passwd/username string kevin
d-i passwd/user-password-crypted password $6$HFFPPnhKmtgvZKvJ$HPlCLq8z9Dswz8nEJxUvtMsG3z4ZhriLpZiYirybfzy0vTb6boR//sErEIhZ0mhnyqIUrUrr6HYZjWRykCLXu/
d-i user-setup/allow-password-weak boolean true
d-i user-setup/encrypt-home boolean false

# Clock and time zone setup
d-i clock-setup/utc boolean true
d-i time/zone string US/Eastern

# Partitioning
d-i partman-auto/method string regular
d-i partman-lvm/device_remove_lvm boolean true
d-i partman-md/device_remove_md boolean true
d-i partman-partitioning/confirm_write_new_label boolean true
d-i partman/choose_partition select finish
d-i partman/confirm boolean true
d-i partman/confirm_nooverwrite boolean true

# Package selection
tasksel tasksel/first multiselect standard, ssh-server
d-i pkgsel/include string qemu-guest-agent sudo cloud-init netplan.io
d-i pkgsel/upgrade select full-upgrade

# Boot loader installation
d-i grub-installer/only_debian boolean true
d-i grub-installer/with_other_os boolean true
d-i grub-installer/bootdev string default

# Final commands
d-i preseed/late_command string \
    cp -f /etc/resolv.conf /target/etc/resolv.conf; \
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

# Finish installation without prompting
d-i finish-install/reboot_inplace boolean true
d-i cdrom-detect/eject boolean true