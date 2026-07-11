xrdb -merge <<< "Xft.dpi: 144"
xrandr --output DP-0 --mode 3840x2160 --rate 120
picom &
redshift &
feh --bg-scale "$(find $HOME/.local/share/wallpapers -type f -name '*.jpg' | shuf -n 1)"
dunst &
export PATH="$PATH:$HOME/.local/bin"
dwmblocks &
exec dwm
