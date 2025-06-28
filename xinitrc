setxkbmap -option ctrl:nocaps
picom &
/usr/lib/notification-daemon-1.0/notification-daemon &
num_wallpapers=$(ls $HOME/Wallpapers | wc -l)
feh --bg-scale ~/Wallpapers/$(shuf -i 1-$num_wallpapers | head -n 1).jpg
date "+%r" | grep -E --silent "(07|08|09|10|11):.*PM" && redshift -O 1000
exec dwm
