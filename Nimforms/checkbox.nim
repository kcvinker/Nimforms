# checkbox module Created on 29-Mar-2023 11:23 PM; Author kcvinker
# CheckBox type
#     Constructor - newCheckBox*(parent: Form, x: int32 = 10, y: int32 = 10): CheckBox
#     Functions - createHandle - Create handle of a CheckBox
#     Properties - Getter & Setter available
#       Name            Type
        # font          Font
        # text          string
        # width         int32
        # height        int32
        # xpos          int32
        # ypos          int32
        # backColor     Color
        # foreColor     Color
        # checked       bool

    # Events
    #     onMouseEnter*, onClick*, onMouseLeave*, onRightClick*, onDoubleClick*,
    #     onLostFocus*, onGotFocus*: EventHandler - proc(c: Control, e: EventArgs)

    #     onMouseWheel*, onMouseHover*, onMouseMove*, onMouseDown*, onMouseUp*
    #     onRightMouseDown*, onRightMouseUp*: MouseEventHandler - - proc(c: Control, e: MouseEventArgs)
    #     onCheckedChanged*: EventHandler


# Constants
# const

var cbCount = 1

# Forward declaration
proc cbWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.}

# CheckBox constructor
proc newCheckBox*(parent: Form, text: string, x: int32 = 10, y: int32 = 10, w, h: int32 = 0): CheckBox =
    new(result)
    result.mKind = ctCheckBox
    result.mClassName = "Button"
    result.mName = "CheckBox_" & $cbCount
    result.mParent = parent
    result.mXpos = x
    result.mYpos = y
    result.mWidth = w
    result.mHeight = h
    result.mText = text
    result.mFont = parent.mFont
    result.mBackColor = parent.mBackColor
    result.mAutoSize = true
    result.mForeColor = CLR_BLACK
    result.mStyle = WS_CHILD or WS_VISIBLE or WS_TABSTOP or BS_AUTOCHECKBOX
    result.mExStyle = WS_EX_LTRREADING or WS_EX_LEFT
    result.mTextStyle = DT_SINGLELINE or DT_VCENTER
    cbCount += 1

proc setCbStyle(this: CheckBox) =
    if this.mRightAlign:
        this.mStyle = this.mStyle or BS_RIGHTBUTTON
        this.mTextStyle = this.mTextStyle or DT_RIGHT
    this.mBkBrush = CreateSolidBrush(this.mBackColor.cref)


# Create CheckBox's hwnd
proc createHandle*(this: CheckBox) =
    this.setCbStyle()
    this.createHandleInternal()
    if this.mHandle != nil:
        this.setSubclass(cbWndProc)
        this.setFontInternal()
        this.setIdealSize()
        if this.mChecked: this.sendMsg(BM_SETCHECK, 1, 0)

# # Set the checked property
proc `checked=`*(this: CheckBox, value: bool) {.inline.} =
    this.mChecked = value
    if this.mIsCreated: this.sendMsg(BM_SETCHECK, int32(value), 0)

# # Get the checked property
proc checked*(this: CheckBox): bool = this.mChecked


proc cbWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.} =
    var this = cast[CheckBox](refData)
    case msg
    of WM_DESTROY:
        this.destructor()
        RemoveWindowSubclass(hw, cbWndProc, scID)
    of WM_LBUTTONDOWN: this.leftButtonDownHandler(msg, wpm, lpm)
    of WM_LBUTTONUP: this.leftButtonUpHandler(msg, wpm, lpm)
    of WM_RBUTTONDOWN: this.rightButtonDownHandler(msg, wpm, lpm)
    of WM_RBUTTONUP: this.rightButtonUpHandler(msg, wpm, lpm)
    of WM_MOUSEMOVE: this.mouseMoveHandler(msg, wpm, lpm)
    of WM_MOUSELEAVE: this.mouseLeaveHandler()
    of WM_CONTEXTMENU:
        if this.mContextMenu != nil: this.mContextMenu.showMenu(lpm)

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
            DrawTextW(nmcd.hdc, this.mText.toWcharPtr, -1, nmcd.rc.unsafeAddr, this.mTextStyle)
            return CDRF_SKIPDEFAULT
        else: discard
        return 0

    else: return DefSubclassProc(hw, msg, wpm, lpm)
    return DefSubclassProc(hw, msg, wpm, lpm)
