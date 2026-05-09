// IO Aero Shake — minimise every other window when the user shakes the
// active one. Mirrors the Windows 7+ Aero Shake gesture.
//
// Heuristic: track the window's frameGeometry centre on every frame
// while the user is dragging it. If the cursor reverses direction
// horizontally at least four times within a 600ms window, we treat
// that as a "shake" and minimise everything except the dragged window.
// Re-shake within 2s un-minimises the previously minimised set.

var lastX = null;
var lastDir = 0;
var reversals = 0;
var reverseStart = 0;
var minimisedStash = [];
var lastShakeAt = 0;

function isCandidate(window) {
    if (!window || window.specialWindow) return false;
    if (window.skipTaskbar || window.skipPager) return false;
    return true;
}

function captureShake(active) {
    var now = Date.now();
    var stash = [];
    workspace.windowList().forEach(function(w) {
        if (w === active) return;
        if (!isCandidate(w)) return;
        if (w.minimized) return;
        w.minimized = true;
        stash.push(w);
    });
    minimisedStash = stash;
    lastShakeAt = now;
}

function restoreStash() {
    minimisedStash.forEach(function(w) {
        try { w.minimized = false; } catch (e) { /* window gone */ }
    });
    minimisedStash = [];
}

function onMoveResizeStep(window) {
    if (!window || !window.move) {
        // Drag finished — reset shake state.
        lastX = null;
        lastDir = 0;
        reversals = 0;
        return;
    }
    var x = window.frameGeometry.x + window.frameGeometry.width / 2;
    if (lastX === null) {
        lastX = x;
        return;
    }
    var dir = (x > lastX) ? 1 : (x < lastX ? -1 : 0);
    if (dir !== 0 && lastDir !== 0 && dir !== lastDir) {
        var now = Date.now();
        if (reversals === 0 || now - reverseStart > 600) {
            reverseStart = now;
            reversals = 1;
        } else {
            reversals++;
        }
        if (reversals >= 4) {
            reversals = 0;
            // Double-shake within 2s = restore.
            if (Date.now() - lastShakeAt < 2000 && minimisedStash.length) {
                restoreStash();
            } else {
                captureShake(window);
            }
        }
    }
    if (dir !== 0) lastDir = dir;
    lastX = x;
}

workspace.windowAdded.connect(function(w) {
    w.moveResizedChanged.connect(function() { onMoveResizeStep(w); });
});

workspace.windowList().forEach(function(w) {
    w.moveResizedChanged.connect(function() { onMoveResizeStep(w); });
});
