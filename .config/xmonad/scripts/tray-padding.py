#!/usr/bin/env python3
"""Stream Xmobar padding on tray events; exit when Xmobar closes the pipe.

Requires python-xlib. Only XMOBAR_SCREEN=0 watches X (the primary monitor
in this setup). No polling, XMonad layout changes, or generated image files.
"""
import os
import select
import sys

from Xlib import X, Xatom, display, error


def main():
    output = sys.stdout.fileno()
    poller = select.poll()
    # A closed reader produces POLLERR even without new tray events.
    # Watch it to avoid orphan processes after bar restarts.
    poller.register(output, select.POLLERR | select.POLLHUP)
    if os.environ.get("XMOBAR_SCREEN", "0") != "0":
        print("<hspace=0/>", flush=True)
        poller.poll()
        return

    dpy = display.Display()
    root = dpy.screen().root
    # Windows may disappear between receiving an event and querying them.
    dpy.set_error_handler(lambda err, request: None)
    poller.register(dpy.fileno(), select.POLLIN)
    tracked = {}
    last_width = None

    def identify(window):
        try:
            window.change_attributes(event_mask=X.PropertyChangeMask)
            classes = tuple(s.lower() for s in (window.get_wm_class() or ()))
            # Xmobar 0.51 here sets WM_NAME="xmobar" without WM_CLASS.
            is_bar = "xmobar" in classes or window.get_wm_name() == "xmobar"
            if "trayer" in classes or is_bar:
                tracked[window.id] = (window, "trayer" if "trayer" in classes else "xmobar")
                return True
            return tracked.pop(window.id, None) is not None
        except error.BadWindow:
            return tracked.pop(window.id, None) is not None

    def refresh():
        nonlocal last_width
        trays, bars = [], []
        for wid, (window, kind) in list(tracked.items()):
            try:
                if window.get_attributes().map_state != X.IsViewable:
                    continue
                geom = window.get_geometry()
                (trays if kind == "trayer" else bars).append((window, geom))
            except (error.BadWindow, error.BadDrawable):
                tracked.pop(wid, None)

        width = 0
        order = [w.id for w in root.query_tree().children]
        for tray, tg in trays:
            for bar, bg in bars:
                # Reserve space only where this right-aligned tray overlaps
                # a bar. The other monitor's watcher always emits zero.
                if (tg.x < bg.x + bg.width and tg.x + tg.width > bg.x
                        and tg.y < bg.y + bg.height and tg.y + tg.height > bg.y):
                    width = max(width, min(bg.width, bg.x + bg.width - tg.x + 5))
                    # Lower the bar below the tray, never raise the tray
                    # over apps/fullscreen. Check order to avoid event loops.
                    if tray.id in order and bar.id in order and order.index(bar.id) > order.index(tray.id):
                        bar.configure(sibling=tray, stack_mode=X.Below)
        if width != last_width:
            print(f"<hspace={width}/>", flush=True)
            last_width = width
        dpy.flush()

    root.change_attributes(event_mask=X.SubstructureNotifyMask)
    for window in root.query_tree().children:
        identify(window)
    refresh()
    while True:
        # Queries can queue events inside python-xlib; drain those before
        # waiting for new bytes on the socket.
        dirty = False
        while dpy.pending_events():
            event = dpy.next_event()
            window = getattr(event, "window", None)
            if window is None:
                continue
            if event.type in (X.CreateNotify, X.MapNotify, X.ReparentNotify):
                dirty = identify(window) or dirty
            elif event.type == X.PropertyNotify and event.atom in (Xatom.WM_CLASS, Xatom.WM_NAME):
                dirty = identify(window) or dirty
            elif event.type == X.DestroyNotify:
                dirty = (tracked.pop(window.id, None) is not None) or dirty
            elif event.type in (X.ConfigureNotify, X.UnmapNotify) and window.id in tracked:
                dirty = True
        if dirty:
            refresh()
            continue
        for fd, flags in poller.poll():
            if fd == output or flags & (select.POLLHUP | select.POLLERR):
                dpy.close()
                return


if __name__ == "__main__":
    try:
        main()
    except (BrokenPipeError, error.ConnectionClosedError):
        os._exit(0)
