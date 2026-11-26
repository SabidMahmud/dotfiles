"""Stream the active power profile to Waybar from the system bus."""

import json

from gi.repository import Gio, GLib


SERVICE = "org.freedesktop.UPower.PowerProfiles"
OBJECT = "/org/freedesktop/UPower/PowerProfiles"
PROFILES = {
    "power-saver": ("󰁘", "Power Saver"),
    "balanced": ("󰿥", "Balanced"),
    "performance": ("󰐍", "Performance"),
}


def label(profile):
    icon, name = PROFILES.get(profile, ("󰁘", "Power profile unavailable"))
    return {"text": icon, "tooltip": f"{name}\nClick for power profiles"}


def emit(profile):
    print(json.dumps(label(profile)), flush=True)


def update(proxy, *_signal):
    value = proxy.get_cached_property("ActiveProfile")
    emit(value.get_string() if value is not None else "")


def main():
    try:
        proxy = Gio.DBusProxy.new_for_bus_sync(
            Gio.BusType.SYSTEM, Gio.DBusProxyFlags.NONE, None, SERVICE, OBJECT, SERVICE, None
        )
    except GLib.Error:
        emit("")
        return

    proxy.connect("g-properties-changed", update)
    proxy.connect("notify::g-name-owner", update)
    update(proxy)
    GLib.MainLoop().run()


if __name__ == "__main__":
    main()
