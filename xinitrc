setxkbmap -option ctrl:nocaps
picom &
num_wallpapers=$(ls $HOME/Wallpapers | wc -l)
feh --bg-scale ~/Wallpapers/$(shuf -i 1-$num_wallpapers | head -n 1).jpg
exec dwm
