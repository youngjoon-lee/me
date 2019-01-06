# i3 on Ubuntu 18.04 with GNOME

Install i3 and i3-gnome in the account which has well-operated GNOME settings.

```bash
sudo apt install i3
sudo apt install gnome-flashback
git clone https://github.com/csxr/i3-gnome.git && cd i3-gnome
sudo make install
```

Reboot. In login menu, select `i3 + GNOME` window manager.

Then, download the `config` file into the `~/.config/i3/`.
