#!/usr/bin/env bash
# OSD de volumen / brillo / micro con dunst.
# Uso: osd.sh {vol_up|vol_down|vol_mute|mic_mute|bri_up|bri_down}
id=2593   # id fijo: reemplaza siempre la misma notificacion
bat_id=2594 # id para bateria

bar() {   # $1 = porcentaje 0-100  ->  barra de 20 bloques
    local p=$1 filled empty out=""
    [ "$p" -gt 100 ] && p=100
    filled=$(( p / 5 )); empty=$(( 20 - filled ))
    while [ $filled -gt 0 ]; do out+="█"; filled=$((filled-1)); done
    while [ $empty  -gt 0 ]; do out+="░"; empty=$((empty-1)); done
    echo "$out"
}

notify_vol() {
    local vol mute
    vol=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+(?=%)' | head -1)
    mute=$(pactl get-sink-mute @DEFAULT_SINK@ | grep -oP '(yes|no)')
    if [ "$mute" = "yes" ]; then
        dunstify -r $id -u low -h int:value:0 "🔇  Silenciado"
    else
        dunstify -r $id -u low -h int:value:"$vol" "🔊  $vol%   $(bar "$vol")"
    fi
}

notify_bri() {
    local b
    b=$(brightnessctl -m | awk -F, '{print $4}' | tr -d '%')
    dunstify -r $id -u low -h int:value:"$b" "☀  $b%   $(bar "$b")"
}

notify_bat_low() {
    local p status
    p=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null)
    status=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null)
    [ -z "$p" ] && return
    if [ "$p" -le 10 ] && [ "$status" = "Discharging" ]; then
        dunstify -r $bat_id -u critical -h int:value:"$p" "🔋  Batería baja: $p%   $(bar "$p")"
    fi
}

case "$1" in
    vol_up)   wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+;  notify_vol ;;
    vol_down) pactl set-sink-volume @DEFAULT_SINK@ -5%;  notify_vol ;;
    vol_mute) pactl set-sink-mute   @DEFAULT_SINK@ toggle; notify_vol ;;
    mic_mute) pactl set-source-mute @DEFAULT_SOURCE@ toggle
              m=$(pactl get-source-mute @DEFAULT_SOURCE@ | grep -oP '(yes|no)')
              if [ "$m" = "yes" ]; then
                  dunstify -r $id -u low "🎤  Micro silenciado"
              else
                  dunstify -r $id -u low "🎤  Micro activo"
              fi ;;
    bri_up)   brightnessctl set +10%; notify_bri ;;
    bri_down) brightnessctl set 10%-; notify_bri ;;
    bat_check)
        while sleep 60; do notify_bat_low; done &
        ;;
    *) echo "uso: $0 {vol_up|vol_down|vol_mute|mic_mute|bri_up|bri_down|bat_check}" ;;
esac
