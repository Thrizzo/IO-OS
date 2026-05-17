// IO Snap Layouts — Win11-style snap chooser.
//
// Win11 shows a 6-pane overlay when you hover the maximise button.
// KWin scripts can't intercept decoration button hover, so we surface
// the same choices behind a keyboard shortcut (Meta+Z) plus the
// existing Meta+U/I/J/K/O/L quadrant bindings in kglobalshortcutsrc.
//
// Layouts:
//   1 = left half        2 = right half
//   3 = top-left         4 = top-right
//   5 = bottom-left      6 = bottom-right
//   7 = maximise         0 = reset / restore
//
// After Meta+Z, the next digit applies to the active window. We use
// `registerShortcut` for the trigger and a transient `register`...
// approach for the digit by toggling per-digit shortcuts when the
// chooser is "armed".

var ARMED = false;
var DISARM_AFTER_MS = 3000;
var disarmTimer = null;

function disarm() {
    ARMED = false;
    if (disarmTimer) {
        disarmTimer = null;
    }
    notify("");
}

function arm() {
    ARMED = true;
    notify("IO Snap: 1 left · 2 right · 3-6 quads · 7 max · 0 reset");
    // Auto-disarm after 3s so a stray Meta+Z doesn't lock the digits.
    workspace.cursorPos;   // touch to keep KWin awake
    setTimeout(function() { if (ARMED) disarm(); }, DISARM_AFTER_MS);
}

function notify(msg) {
    // KWin scripts can't pop a real OSD; the message gets logged and
    // the (optional) Plasma OSD bridge picks it up if installed.
    if (msg) print("io-snap-layouts: " + msg);
}

function activeArea(win) {
    return workspace.clientArea(KWin.MaximizeArea, win);
}

function applyLayout(digit) {
    var win = workspace.activeWindow;
    if (!win || !win.moveable || !win.resizeable) return;
    var area = activeArea(win);
    var x = area.x, y = area.y, w = area.width, h = area.height;
    var half = Math.floor(w / 2);
    var halfH = Math.floor(h / 2);

    switch (digit) {
        case 1:  win.frameGeometry = { x: x,        y: y,         width: half,    height: h     }; break;
        case 2:  win.frameGeometry = { x: x + half, y: y,         width: w - half, height: h    }; break;
        case 3:  win.frameGeometry = { x: x,        y: y,         width: half,    height: halfH }; break;
        case 4:  win.frameGeometry = { x: x + half, y: y,         width: w - half, height: halfH }; break;
        case 5:  win.frameGeometry = { x: x,        y: y + halfH, width: half,    height: h - halfH }; break;
        case 6:  win.frameGeometry = { x: x + half, y: y + halfH, width: w - half, height: h - halfH }; break;
        case 7:  win.setMaximize(true, true); break;
        case 0:  win.setMaximize(false, false);
                 win.frameGeometry = { x: x + Math.floor(w / 8),
                                       y: y + Math.floor(h / 8),
                                       width: Math.floor(w * 0.75),
                                       height: Math.floor(h * 0.75) };
                 break;
    }
    disarm();
}

registerShortcut("Show Snap Layouts", "Show Snap Layouts Picker",
                 "Meta+Z", arm);

// Number keys are registered up-front so the bindings are visible in
// System Settings -> Shortcuts. They no-op unless the chooser is armed.
function digitHandler(d) {
    return function() {
        if (!ARMED) return;
        applyLayout(d);
    };
}
for (var i = 0; i <= 7; i++) {
    registerShortcut("Snap Apply " + i, "Apply snap layout slot " + i,
                     "", digitHandler(i));
}
