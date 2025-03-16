setxkbmap -option ctrl:nocaps
redshift &
picom &
feh --bg-scale ~/Wallpapers/$(shuf -i 1-4 | head -n 1).jpg
exec dwm
