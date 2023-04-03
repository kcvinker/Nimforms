# radiobutton module Created on 04-Apr-2023 02:34 AM

# Constants
# const

var rbCount = 1

# Forward declaration
proc rbWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.}

# RadioButton constructor
proc newRadioButton*(parent: Form, text: string, x: int32 = 10, y: int32 = 10, w, h: int32 = 0): RadioButton =
    new(result)
    result.mKind = ctRadioButton
    result.mClassName = "Button"
    result.mName = "RadioButton_" & $rbCount
    result.mParent = parent
    result.mXpos = x
    result.mYpos = y
    result.mWidth = w
    result.mHeight = h
    result.mText = text
    result.mFont = parent.mFont
    result.mBackColor = parent.mBackColor
    result.mAutoSize = true
    result.mTxtFlag = DT_SINGLELINE or DT_VCENTER
    result.mForeColor = CLR_BLACK
    result.mStyle = WS_CHILD or WS_VISIBLE or WS_TABSTOP or BS_AUTORADIOBUTTON
    result.mExStyle = WS_EX_LTRREADING or WS_EX_LEFT
    # result.mTextStyle = DT_SINGLELINE or DT_VCENTER
    rbCount += 1

proc setRBStyle(this: RadioButton) =
    if this.mRightAlign:
        this.mStyle = this.mStyle or BS_RIGHTBUTTON
        this.mTxtFlag = this.mTxtFlag or DT_RIGHT
    this.mBkBrush = CreateSolidBrush(this.mBackColor.cref)


# Create RadioButton's hwnd
proc createHandle*(this: RadioButton) =
    this.setRBStyle()
    this.createHandleInternal()
    if this.mHandle != nil:
        this.setSubclass(rbWndProc)
        this.setFontInternal()
        this.setIdealSize()
        if this.mChecked: this.sendMsg(BM_SETCHECK, 1, 0)

# # Set the checked property
proc `checked=`*(this: RadioButton, value: bool) {.inline.} =
    this.mChecked = value
    if this.mIsCreated: this.sendMsg(BM_SETCHECK, int32(value), 0)

# # Get the checked property
proc checked*(this: RadioButton): bool {.inline.} = this.mChecked


proc rbWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.} =
    var this = cast[RadioButton](refData)
    case msg
    of WM_DESTROY:
        RemoveWindowSubclass(hw, rbWndProc, scID)
    of WM_LBUTTONDOWN: this.leftButtonDownHandler(msg, wpm, lpm)
    of WM_LBUTTONUP: this.leftButtonUpHandler(msg, wpm, lpm)
    of WM_RBUTTONDOWN: this.rightButtonDownHandler(msg, wpm, lpm)
    of WM_RBUTTONUP: this.rightButtonUpHandler(msg, wpm, lpm)
    of WM_MOUSEMOVE: this.mouseMoveHandler(msg, wpm, lpm)
    of WM_MOUSELEAVE: this.mouseLeaveHandler()
    of MM_LABEL_COLOR:
        let hdc = cast[HDC](wpm)
        SetBkColor(hdc, this.mBackColor.cref)
        return cast[LRESULT](this.mBkBrush)

    of MM_CTL_COMMAND:
        this.mChecked = bool(this.sendMsg(BM_GETCHECK, 0, 0))
        if this.onCheckedChanged != nil: this.onCheckedChanged(this, newEventArgs())

    of MM_NOTIFY_REFLECT:
        let nmcd = cast[LPNMCUSTOMDRAW](lpm)
        case nmcd.dwDrawStage
        of CDDS_PREERASE: return CDRF_NOTIFYPOSTERASE
        of CDDS_PREPAINT:
            if not this.mRightAlign:
                nmcd.rc.left += 18
            else:
                nmcd.rc.right -= 18
            if (this.mDrawMode and 1) == 1: SetTextColor(nmcd.hdc, this.mForeColor.cref)
            DrawTextW(nmcd.hdc, this.mText.toWcharPtr, -1, nmcd.rc.unsafeAddr, this.mTxtFlag)
            return CDRF_SKIPDEFAULT
        else: discard
        return 0

    else: return DefSubclassProc(hw, msg, wpm, lpm)
    return DefSubclassProc(hw, msg, wpm, lpm)