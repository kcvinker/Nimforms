
# Event module - Created on 28-Mar-2023 12:47 AM
const
    TVN_FIRST = cast[UINT](0-400)
    TVN_SELCHANGINGW = TVN_FIRST-50
    TVN_SELCHANGEDW = TVN_FIRST-51
    TVN_ITEMEXPANDINGW = TVN_FIRST-54
    TVN_ITEMEXPANDEDW = TVN_FIRST-55
    TVN_DELETEITEMW = TVN_FIRST-58



proc newEventArgs(): EventArgs = new(result)
var GEA = newEventArgs()

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

proc newDateTimeEventArgs(dtpStr: LPCWSTR): DateTimeEventArgs =
    new(result)
    result.mDateStr = wcharArrayToString(dtpStr)

proc newTreeEventArgs(ntv: LPNMTREEVIEWW): TreeEventArgs =
    new(result)
    if ntv.hdr.code == TVN_SELCHANGINGW or ntv.hdr.code == TVN_SELCHANGEDW:
        case ntv.action
        of 0 : result.mAction = tvaUnknown
        of 1 : result.mAction = tvaByMouse
        of 2 : result.mAction = tvaByKeyboard
        else: discard
        # echo "mAction in sel change " & $result.mAction
    elif ntv.hdr.code == TVN_ITEMEXPANDEDW or ntv.hdr.code == TVN_ITEMEXPANDINGW:
        case ntv.action
        of 0 : result.mAction = tvaUnknown
        of 1 : result.mAction = tvaCollapse
        of 2 : result.mAction = tvaExpand
        else: discard
        # echo "mAction in expand " & $result.mAction
    result.mNode = cast[TreeNode](cast[PVOID](ntv.itemNew.lParam))
    if ntv.itemOld.lParam > 0:
        result.mOldNode = cast[TreeNode](cast[PVOID](ntv.itemOld.lParam))

proc newTreeEventArgs(ntv: LPNMTVITEMCHANGE): TreeEventArgs =
    new(result)
    result.mNewState = ntv.uStateNew
    result.mOldState = ntv.uStateOld
    result.mNode = cast[TreeNode](cast[PVOID](ntv.lParam))


# Event properties
proc x*(this: MouseEventArgs): int32 = this.mx
proc y*(this: MouseEventArgs): int32 = this.my
proc delta*(this: MouseEventArgs): int32 = this.mDelta
proc shiftPressed*(this: MouseEventArgs): bool = this.mShiftPressed
proc ctrlPressed*(this: MouseEventArgs): bool = this.mCtrlPressed
proc mouseButton*(this: MouseEventArgs): MouseButtons = this.mButton