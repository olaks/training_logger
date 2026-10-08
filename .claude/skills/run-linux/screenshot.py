"""Saves the app window to the PNG named on the command line.

Finds the window by its WM_CLASS rather than taking an id, because
`import -window` with an empty id waits for a click instead of failing.
"""
import subprocess, sys
from Xlib import display


def find(w):
    try:
        cls = w.get_wm_class()
        if cls and 'training_logger' in ''.join(cls) and w.get_geometry().width > 50:
            return w
    except Exception:
        pass
    for child in w.query_tree().children:
        found = find(child)
        if found:
            return found


win = find(display.Display().screen().root)
if not win:
    sys.exit('no training_logger window: is the app running?')
subprocess.run(['timeout', '10', 'import', '-window', hex(win.id), sys.argv[1]],
               check=True)
print(sys.argv[1])
