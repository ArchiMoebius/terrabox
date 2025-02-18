#!/usr/bin/env python3

import os
import queue
import re
import threading
import time

from pathlib import PosixPath

try:
    from rich.console import Console
    from rich.live import Live
    from rich.panel import Panel
    from rich.table import Table
    from rich.text import Text
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

def parse_line(line):
    m = LOG_RE.match(line)

    if m:
        entry = m.groupdict()
        din = entry.get("in", "")
        direction = "[green]IN"

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
            extras = f"[/]:[bold grey69]{spt}"

        dip = entry.get("dip", "[/][red]unknown")
        dpt = entry.get("dpt", "[/][red]-1")
        extrad = ""

        if dpt:
            extrad = f"[/]:[bold tan]{dpt}"

        return f"{direction.strip()}\t[/]{proto:<20}[/][light_steel_blue]{sip+extras:<42}[/][misty_rose3]{(dip+extrad):<42}[/][misty_rose3]{entry.get("ttl", ""):<10}[/][misty_rose3]{entry.get("length", ""):<10}[/]".strip()

    return None

def tailf(stop_event, table_queue, thefile):
    # thefile.seek(0, os.SEEK_END)

    while not stop_event.is_set():
        line = thefile.readline()
        if not line:
            time.sleep(0.1)
            continue
        
        try:
            entry = parse_line(line)
            if entry != None:
                table_queue.put(entry)
        except Exception:
            pass

if __name__ == "__main__":
    logfile = open("/var/log/iptables.log", "r")
    table_queue = queue.Queue(0)
    stop_event = threading.Event()

    # Start the table updating thread
    table_thread = threading.Thread(target=tailf, args=(stop_event, table_queue, logfile))
    table_thread.daemon = True
    table_thread.start()

    console = Console()
    header = Text("\nDir     Proto   Source                    Destination                  TTL       Size", style="bold cyan")
    console.print(header)

    cnt = 0
    try:
        while True:
            while not table_queue.empty():
                try:
                    row = table_queue.get(block=False, timeout=2)
                    console.print(row)
                except queue.Empty:
                    break
                finally:
                    cnt +=1

                if cnt %21 == 0:
                    console.print(header)
                    cnt = 1

    except KeyboardInterrupt:
        pass
    except Exception:
        import traceback
        traceback.print_exc()
    finally:
        stop_event.set()
        table_thread.join(timeout=1)
        logfile.close()