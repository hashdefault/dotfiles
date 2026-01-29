#!/usr/bin/env python3
import calendar
import tkinter as tk
from datetime import datetime

BG = "#1e1e2e"
FG = "#cdd6f4"
ACCENT = "#89dceb"
BORDER = "#89fdff"
MUTED = "#6c7086"


def create_calendar():
    root = tk.Tk()
    root.title("Calendar")
    root.attributes("-type", "dialog")
    root.overrideredirect(True)

    now = datetime.now()
    current_year = now.year
    current_month = now.month
    today = now.day

    # Card container
    frame = tk.Frame(
        root,
        bg=BG,
        bd=0,
        relief="solid",
        highlightthickness=0,
        highlightbackground=BORDER
    )
    frame.pack(padx=3, pady=3)

    # Header with navigation buttons
    header_frame = tk.Frame(frame, bg=BG)
    header_frame.pack(fill="x", pady=8)

    prev_btn = tk.Button(
        header_frame,
        text="<",
        bg=BG,
        fg=FG,
        font=("JetBrains Mono Nerd Font", 11, "bold"),
        bd=0,
        padx=8,
        activebackground=ACCENT,
        activeforeground=BG,
        cursor="hand2"
    )
    prev_btn.pack(side="left", padx=(8, 0))

    header = tk.Label(
        header_frame,
        text="",
        bg=BG,
        fg=FG,
        font=("JetBrains Mono Nerd Font", 13, "bold")
    )
    header.pack(side="left", expand=True)

    next_btn = tk.Button(
        header_frame,
        text=">",
        bg=BG,
        fg=FG,
        font=("JetBrains Mono Nerd Font", 11, "bold"),
        bd=0,
        padx=8,
        activebackground=ACCENT,
        activeforeground=BG,
        cursor="hand2"
    )
    next_btn.pack(side="right", padx=(0, 8))

    # Calendar grid (single grid for alignment)
    calendar_grid = tk.Frame(frame, bg=BG)
    calendar_grid.pack(padx=8, pady=6)

    # Force uniform columns
    for c in range(7):
        calendar_grid.grid_columnconfigure(c, weight=1, uniform="cal")

    # Weekday header
    weekdays = ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
    for c, day_name in enumerate(weekdays):
        tk.Label(
            calendar_grid,
            text=day_name,
            bg=BG,
            fg=MUTED,
            width=3,
            font=("JetBrains Mono Nerd Font", 10, "bold")
        ).grid(row=0, column=c, padx=2, pady=(0, 6))

    def update_calendar():
        nonlocal current_year, current_month

        # Update header
        month_name = calendar.month_name[current_month]
        header.config(text=f"{month_name} {current_year}")

        # Clear existing day labels (keep weekday header)
        for widget in calendar_grid.winfo_children():
            info = widget.grid_info()
            if info and info.get("row", 0) > 0:
                widget.destroy()

        # Draw month days
        cal = calendar.monthcalendar(current_year, current_month)
        for r, week in enumerate(cal, start=1):
            for c, day in enumerate(week):
                if day == 0:
                    text = ""
                    fg = MUTED
                    bg = BG
                    weight = "normal"
                else:
                    text = str(day)
                    is_today = (day == today and current_month == now.month and current_year == now.year)
                    fg = BG if is_today else FG
                    bg = ACCENT if is_today else BG
                    weight = "bold" if is_today else "normal"

                tk.Label(
                    calendar_grid,
                    text=text,
                    width=3,
                    bg=bg,
                    fg=fg,
                    font=("JetBrains Mono Nerd Font", 10, weight)
                ).grid(row=r, column=c, padx=2, pady=2)

    def prev_month():
        nonlocal current_year, current_month
        if current_month == 1:
            current_month = 12
            current_year -= 1
        else:
            current_month -= 1
        update_calendar()

    def next_month():
        nonlocal current_year, current_month
        if current_month == 12:
            current_month = 1
            current_year += 1
        else:
            current_month += 1
        update_calendar()

    prev_btn.config(command=prev_month)
    next_btn.config(command=next_month)

    # Initial calendar draw
    update_calendar()

    # Close behavior
    def on_focus_out(event):
        # Only react to focus leaving the root window itself, not child widgets
        if event.widget == root:
            def check_focus():
                try:
                    if root.focus_get() is None:
                        root.destroy()
                except tk.TclError:
                    pass
            root.after(150, check_focus)

    root.bind("<Escape>", lambda e: root.destroy())
    root.bind("<FocusOut>", on_focus_out)

    # Position top-right
    root.update_idletasks()
    screen_width = root.winfo_screenwidth()
    window_width = root.winfo_width()
    x = screen_width - window_width - 20
    y = 30
    root.geometry(f"+{x}+{y}")

    root.mainloop()


if __name__ == "__main__":
    create_calendar()

