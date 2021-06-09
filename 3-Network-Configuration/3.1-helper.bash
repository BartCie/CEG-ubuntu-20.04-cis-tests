#!/bin/bash

function test_3_1_2() {
  if command -v nmcli >/dev/null 2>&1; then
    if nmcli radio all | grep -Eq '\s*\S+\s+disabled\s+\S+\s+disabled\b'; then
      echo "Wireless is not enabled"
    else
      nmcli radio all
    fi
  elif [ -n "$(find /sys/class/net/*/ -type d -name wireless)" ]; then
    t=0
    mname=$(for driverdir in $(find /sys/class/net/*/ -type d -name wireless |
      xargs -0 dirname); do basename "$(
        readlink -f
        "$driverdir"/device/driver/module
      )"; done | sort -u)
    for dm in $mname; do
      if
        grep -Eq "^\s*install\s+$dm\s+/bin/(true|false)" /etc/modprobe.d/*.conf
      then
        /bin/true
      else
        echo "$dm is not disabled"
        t=1
      fi
    done
    [ "$t" -eq 0 ] && echo "Wireless is not enabled"
  else
    echo "Wireless is not enabled"
  fi
}

function test_3_1_1_ipv6_grub() {
  local grub_config_check
  grub_config_check=$(grep "^\s*linux" /boot/grub/grub.cfg | grep -v "ipv6.disable=1")
  [ "$grub_config_check" = "" ]
}
