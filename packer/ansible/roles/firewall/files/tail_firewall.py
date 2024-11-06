#!/usr/bin/env python3

import os
import re
import time

from pathlib import PosixPath

try:
    from rich.live import Live
    from rich.table import Table
except ModuleNotFoundError:
    print("Run the following: python3 -m pip install rich")

IPTABLES_RSYSLOG_CONF = PosixPath("/etc/rsyslog.d/10-iptables.conf")

if not IPTABLES_RSYSLOG_CONF.exists():
    IPTABLES_RSYSLOG_CONF.write_text(
        """
:msg, regex, "IPTABLES.*" /var/log/iptables.log
& stop"""
    )
    print("Run the following: service rsyslog restart")
    exit(0)

LOG_RE = p = re.compile(
    r".*IPTABLES:DROP: IN=(?P<in>[a-z0-9]*) OUT=(?P<out>[a-z0-9]*) *(MAC=(?P<mac>[0-9a-f:]*))? *SRC=(?P<sip>[0-9.]*) DST=(?P<dip>[0-9.]*) LEN=(?P<length>[0-9]*) .* TTL=(?P<ttl>[0-9]*) .* PROTO=(?P<proto>[A-Z]*) (SPT=(?P<spt>[0-9.]*) DPT=(?P<dpt>[0-9.]*) )?.*",
    re.IGNORECASE,
)


def tailf(thefile):
    thefile.seek(0, os.SEEK_END)

    while True:
        line = thefile.readline()
        if not line:
            time.sleep(0.1)
            continue

        yield line


if __name__ == "__main__":
    logfile = open("/var/log/iptables.log", "r")

    try:
        table = Table()
        table.add_column("Direction")
        table.add_column("Protocol")
        table.add_column("Source")
        table.add_column("Destination")
        table.add_column("TTL")
        table.add_column("Size")
        # table.add_column("MAC")

        with Live(table, refresh_per_second=4):
            for line in tailf(logfile):

                m = LOG_RE.match(line)

                if m:
                    entry = m.groupdict()
                    din = entry.get("in", "")
                    direction = "IN"

                    if len(din) <= 0:
                        direction = "[yellow]OUT"

                    proto = entry.get("proto", False)

                    if not proto:
                        proto = "[bold red]unknown"
                    else:
                        color = "[dark_sea_green4]"

                        if proto.lower() == "udp":
                            color = "[steel_blue]"

                        if proto.lower() == "icmp":
                            color = "[deep_pink4]"

                        proto = f"{color}{proto}"

                    sip = entry.get("sip", "[/][red]unknown")
                    spt = entry.get("spt", "[/][red]-1")
                    extras = ""

                    if spt:
                        extras = f":[bold grey69]{spt}"

                    dip = entry.get("dip", "[/][red]unknown")
                    dpt = entry.get("dpt", "[/][red]-1")
                    extrad = ""

                    if dpt:
                        extrad = f":[bold tan]{dpt}"

                    table.add_row(
                        direction,
                        f"{proto}",
                        f"[light_steel_blue]{sip}[/]{extras}",
                        f"[misty_rose3]{dip}[/]{extrad}",
                        entry.get("ttl", ""),
                        entry.get("length", ""),
                    )
    except Exception:
        pass
    finally:
        logfile.close()
