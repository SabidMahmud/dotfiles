"""Stream live speeds and vnStat usage totals to Waybar."""

import argparse
import json
import subprocess
from datetime import date
from pathlib import Path
from time import monotonic, sleep

NETWORK_DEVICES = Path("/sys/class/net")
SAMPLE_INTERVAL = 2
USAGE_INTERVAL = 60


def format_bytes(size, separator=""):
    for unit in ("B", "KiB", "MiB", "GiB", "TiB", "PiB", "EiB"):
        if size < 1024 or unit == "EiB":
            return f"{size:.1f}".removesuffix(".0") + separator + unit
        size /= 1024


def totals(interfaces, period, current_date):
    downloaded = uploaded = 0
    for interface in interfaces:
        for entry in interface["traffic"][period]:
            if entry["date"] == current_date:
                downloaded += entry["rx"]
                uploaded += entry["tx"]
    return downloaded, uploaded


def usage_section(label, downloaded, uploaded):
    return (
        f"{label} · {format_bytes(downloaded + uploaded)} total\n"
        f"Downloaded {format_bytes(downloaded)} · Uploaded {format_bytes(uploaded)}"
    )


def usage():
    try:
        result = subprocess.run(
            ["vnstat", "--config", "/etc/vnstat.conf", "--json", "s"],
            capture_output=True,
            check=True,
            timeout=5,
        )
        interfaces = json.loads(result.stdout)["interfaces"]
        names = [interface["name"] for interface in interfaces]
        if not interfaces or not any(
            interface["traffic"]["day"] or interface["traffic"]["month"]
            for interface in interfaces
        ):
            return names, "Waiting for vnStat to save traffic data"

        today = date.today()
        month = {"year": today.year, "month": today.month}
        daily = totals(interfaces, "day", {**month, "day": today.day})
        monthly = totals(interfaces, "month", month)
    except FileNotFoundError:
        return None, "vnStat is missing. Install vnstat and enable vnstat.service."
    except (OSError, subprocess.SubprocessError, ValueError, KeyError, TypeError):
        return None, "Usage totals unavailable. Check vnstat.service."

    return names, "\n\n".join((
        usage_section("Today", *daily),
        usage_section("This month", *monthly),
        f"Interfaces: {', '.join(names)}",
    ))


def read_counters(interfaces):
    counters = {}
    for name in interfaces:
        stats = NETWORK_DEVICES / name / "statistics"
        try:
            counters[name] = (
                int((stats / "rx_bytes").read_text()),
                int((stats / "tx_bytes").read_text()),
            )
        except (OSError, ValueError):
            # An adapter can disappear between samples.
            continue
    return counters


def byte_rates(previous, current, elapsed):
    available = previous.keys() & current.keys()
    if not available:
        return None

    downloaded = uploaded = 0
    for name in available:
        downloaded += max(0, current[name][0] - previous[name][0])
        uploaded += max(0, current[name][1] - previous[name][1])
    return downloaded / elapsed, uploaded / elapsed


def speed_display(rates, usage_tooltip, compact):
    if rates is None:
        return "↕ —", usage_tooltip

    downloaded, uploaded = rates
    if compact:
        down = format_bytes(round(downloaded), " ")
        up = format_bytes(round(uploaded), " ")
        return f"↓{down}/s", f"Live speed\nDownload {down}/s · Upload {up}/s\n\n{usage_tooltip}"

    return f"↓{format_bytes(downloaded)}/s ↑{format_bytes(uploaded)}/s", usage_tooltip


def main(compact):
    interfaces = []
    previous = {}
    previous_time = monotonic()
    next_usage = previous_time

    while True:
        if monotonic() >= next_usage:
            names, usage_tooltip = usage()
            if names is not None:
                interfaces = names
            next_usage = monotonic() + USAGE_INTERVAL

        current = read_counters(interfaces)
        now = monotonic()
        rates = byte_rates(previous, current, now - previous_time)
        text, tooltip = speed_display(rates, usage_tooltip, compact)
        print(json.dumps({"text": text, "tooltip": tooltip}), flush=True)
        previous, previous_time = current, now
        sleep(SAMPLE_INTERVAL)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--compact", action="store_true", help="Show upload speed in the tooltip")
    main(parser.parse_args().compact)
