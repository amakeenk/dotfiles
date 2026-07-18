My dotfiles managed by tuckr.

## Installation
```console
# apt-get install tuckr

$ git clone https://altlinux.space/amakeenk/dotfiles ~/.dotfiles && \
  cd ~/.dotfiles

$ tuckr add '*'

$ tuckr status
```

## GNOME workflow profile

The GNOME profile recreates the Hyprland-oriented workflow with fixed workspaces,
custom application shortcuts, automatic window placement, ddterm, Simple Tiling,
and Copyous. Install the required GNOME extensions, link the profile, then apply
its text-based dconf settings:

```console
# apt-get install gnome-shell-extensions \
    gnome-shell-extension-copyous \
    gnome-shell-extension-ddterm \
    gnome-shell-extension-simple-tiling

$ tuckr add gnome
$ ~/.local/bin/apply-hypr-workflow
```

The profile expects Kitty, Fuzzel, Nautilus, Firefox, Thunderbird, Zed, Text
Editor, Fractal, and Telegram to be installed. Log out and back in if GNOME does
not load a newly enabled extension immediately.

After pulling changes to this repository, update the linked files and reapply the
profile:

```console
$ cd ~/.dotfiles
$ git pull
$ tuckr add gnome
$ ~/.local/bin/apply-hypr-workflow
```
