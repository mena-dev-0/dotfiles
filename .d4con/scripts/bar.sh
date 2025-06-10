#!/bin/bash

# Auto detect interfaces
ifaces=$(ls /sys/class/net | grep -E '^(eno|enp|ens|enx|eth|wlan|wlp)')

last_time=0
last_rx=0
last_tx=0
rate=""
rx_data="?"
brightness_level="?"

readable() {
  local bytes=$1
  local kib=$(( bytes >> 10 ))
  if [ $kib -lt 0 ]; then
    echo "? K"
  elif [ $kib -gt 1024 ]; then
    local mib_int=$(( kib >> 10 ))
    local mib_dec=$(( kib % 1024 * 976 / 10000 ))
    if [ "$mib_dec" -lt 10 ]; then
      mib_dec="0${mib_dec}"
    fi
    echo "${mib_int}.${mib_dec} M"
  else
    echo "${kib} K"
  fi
}

update_rate() {
  local time=$(date +%s)
  local rx=0 tx=0 tmp_rx tmp_tx

  for iface in $ifaces; do
    read tmp_rx < "/sys/class/net/${iface}/statistics/rx_bytes"
    read tmp_tx < "/sys/class/net/${iface}/statistics/tx_bytes"
    rx=$(( rx + tmp_rx ))
    tx=$(( tx + tmp_tx ))
  done

  local interval=$(( $time - $last_time ))
  if [ $interval -gt 0 ]; then
    rate="$(readable $(( (rx - last_rx) / interval )))↓ $(readable $(( (tx - last_tx) / interval )))↑"
  else
    rate=""
  fi

  last_time=$time
  last_rx=$rx
  last_tx=$tx
}

update_rx_data() {
  rx_data=$(vnstat | awk '/wlan0:/ {f=1} f && /today/ {print $2; exit}')
}

update_brightness() {
  local brightness_path="/sys/class/backlight/amdgpu_bl0/brightness"
  local max_brightness_path="/sys/class/backlight/amdgpu_bl0/max_brightness"

  if [[ -f "$brightness_path" && -f "$max_brightness_path" ]]; then
    local brightness=$(cat "$brightness_path")
    local max_brightness=$(cat "$max_brightness_path")
    brightness_level=$(( 100 * brightness / max_brightness ))
  else
    brightness_level="?"
  fi
}

i3status | (
  read line && echo "$line"
  read line && echo "$line"
  read line && echo "$line"
  update_rate
  update_rx_data
  update_brightness
  while :; do
    read line
    update_rate
    update_rx_data
    update_brightness
    echo ",[{\"full_text\":\"  ${rate} 〱 Today: ${rx_data} 〱 ☀ ${brightness_level}%\" },${line#,\[}" || exit 1
  done
)
