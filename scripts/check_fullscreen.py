import sys

import win32gui
import win32api

whitelist: list[str] = []
blacklist: list[str] = ["Default IME", "MSCTFIME UI",
                        # "Program Manager", "Widgets", "##VSO###MCVSSHLD##",
                        # "McPlatformSingleExeFramework", "MediaContextNotificationWindow", "SystemResourceNotifyWindow",
                        "Windows Input Experience",
                        # "SystemResourceNotifyWindow", "WinUI Desktop", "Hidden Window",
                        "MediaContextNotificationWindow", "The Event Manager Dashboard", "DesktopWindowXamlSource",
                        "NVIDIA GeForce Overlay"]
found_hwnd = None


def get_window_size(hwnd):
    rect = win32gui.GetWindowRect(hwnd)
    width = rect[2] - rect[0]
    height = rect[3] - rect[1]
    return width, height


def is_window_fullscreen(hwnd):
    size = get_window_size(hwnd)
    screen_size = win32api.GetSystemMetrics(0), win32api.GetSystemMetrics(1)
    return size == screen_size


def win_match_patterns(hwnd):
    win_title = str(win32gui.GetWindowText(hwnd)).lower()

    for pat in blacklist:
        if pat.lower() in win_title:
            return False

    for pat in whitelist:
        if pat in win_title:
            return True

    return len(whitelist) == 0


def win_lookup(hwnd, _):
    global found_hwnd

    if win32gui.IsWindowVisible(hwnd) and \
            win_match_patterns(hwnd) and \
            is_window_fullscreen(hwnd):
        found_hwnd = hwnd
        # return 0
    # return 1


""" 
needs to get a list of window names to include in the search.
Separated_by_"_"
"""


def main():
    global whitelist, found_hwnd
    if len(sys.argv) >= 2:
        whitelist = list(map(lambda s: s.replace("_", " ").lower(), sys.argv[1:]))

    win32gui.EnumWindows(win_lookup, None)

    if found_hwnd is not None:
        print(f"{found_hwnd}")
    else:
        print("false")


if __name__ == '__main__':
    main()
