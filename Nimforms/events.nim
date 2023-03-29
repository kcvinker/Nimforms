
# Event module - Created on 28-Mar-2023 12:47 AM

proc newEventArgs(): EventArgs = new(result)

proc getXFromLp(lp: LPARAM): int32 = cast[int32](LOWORD(lp))
proc getYFromLp(lp: LPARAM): int32 = cast[int32](HIWORD(lp))

proc newMouseEventArgs(msg: UINT, wp: WPARAM, lp: LPARAM): MouseEventArgs =
    new(result)
    let fwKeys = LOWORD(wp)
    result.mDelta = cast[int32](GET_WHEEL_DELTA_WPARAM(wp))
    case fwKeys   # IMPORTANT*********** Work here --> change 4 to 5, 8 to 9 etc
    of 4 : result.mShiftPressed = true
    of 8 : result.mCtrlPressed = true
    of 16 : result.mButton = mbMiddle
    of 32 : result.mButton = mbXButton1
    else: discard

    case msg
    of WM_LBUTTONDOWN, WM_LBUTTONUP: result.mButton = mbLeft
    of WM_RBUTTONDOWN, WM_RBUTTONUP: result.mButton = mbRight
    else: discard

    result.mx = getXFromLp(lp)
    result.my = getYFromLp(lp)


proc newKeyEventArgs(wp: WPARAM): KeyEventArgs =
    new(result)
    result.mKeyCode = cast[Keys](wp)
    case result.mKeyCode
    of keyShift :
        result.mShiftPressed = true
        result.mModifier = keyShiftModifier
    of keyCtrl :
        result.mCtrlPressed = true
        result.mModifier = keyCtrlModifier
    of keyAlt :
        result.mAltPressed = true
        result.mModifier = keyAltModifier
    else : discard
    result.mKeyValue = cast[int32](result.mKeyCode)

proc newKeyPressEventArgs(wp: WPARAM): KeyPressEventArgs =
    new(result)
    result.keyChar = cast[char](wp)

proc newSizeEventArgs(msg: UINT, lp: LPARAM): SizeEventArgs =
    new(result)
    if msg == WM_SIZING:
        result.mWinRect = cast[LPRECT](lp)
    else:
        result.mClientArea.width = cast[int32](LOWORD(lp))
        result.mClientArea.height = cast[int32](HIWORD(lp))
