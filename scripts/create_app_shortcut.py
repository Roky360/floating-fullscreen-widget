import sys
import os

import win32com.client


def create_shortcut(target_path, shortcut_path, description):
    try:
        ws = win32com.client.Dispatch("WScript.Shell")
        scut = ws.CreateShortcut(shortcut_path)
        scut.TargetPath = target_path
        scut.Description = description
        scut.WorkingDirectory = os.path.dirname(target_path)
        scut.Save()
        return True
    except Exception as e:
        raise e
        return False


"""
script.py path/to/exe path/of/link.lnk
"""


def main():
    if len(sys.argv) < 3:
        return -1

    target_path = sys.argv[1]
    shortcut_path = sys.argv[2]
    description = ""
    if len(sys.argv) >= 4:
        description = sys.argv[3]

    success = create_shortcut(target_path, shortcut_path, description)

    # output result
    print("true" if success else "false")
    return 0


if __name__ == '__main__':
    main()
