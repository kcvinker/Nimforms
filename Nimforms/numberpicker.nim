# numberpicker module Created on 03-Apr-2023 01:57 PM

# Constants
const
    UDN_FIRST = cast[UINT](0-721)
    UDS_WRAP = 0x0001
    UDS_SETBUDDYINT = 0x0002
    UDS_ALIGNRIGHT = 0x0004
    UDS_ALIGNLEFT = 0x0008
    UDS_AUTOBUDDY = 0x0010
    UDS_ARROWKEYS = 0x0020
    UDS_HORZ = 0x0040
    UDS_NOTHOUSANDS = 0x0080
    UDS_HOTTRACK = 0x0100
    UDM_SETRANGE = (WM_USER+101)
    UDM_GETRANGE = (WM_USER+102)
    UDM_SETPOS = (WM_USER+103)
    UDM_GETPOS = (WM_USER+104)
    UDM_SETBUDDY = (WM_USER+105)
    UDM_GETBUDDY = (WM_USER+106)
    UDM_SETACCEL = (WM_USER+107)
    UDM_GETACCEL = (WM_USER+108)
    UDM_SETBASE = (WM_USER+109)
    UDM_GETBASE = (WM_USER+110)
    UDM_SETRANGE32 = (WM_USER+111)
    UDM_GETRANGE32 = (WM_USER+112) #- wParam & lParam are LPINT
    UDM_SETPOS32 = (WM_USER+113)
    UDM_GETPOS32 = (WM_USER+114)
    UDN_DELTAPOS = (UDN_FIRST - 1)

var npCount = 1
let NPSTYLE: DWORD = WS_VISIBLE or WS_CHILD or UDS_ALIGNRIGHT or UDS_ARROWKEYS or UDS_AUTOBUDDY or UDS_HOTTRACK
let SWP_FLAG: DWORD = SWP_SHOWWINDOW or SWP_NOACTIVATE or SWP_NOZORDER

# Forward declaration
proc npWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.}
proc npEditWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.}

# NumberPicker constructor
proc newNumberPicker*(parent: Form, x, y: int32 = 10, w: int32 = 100, h: int32 = 27): NumberPicker =
    new(result)
    result.mKind = ctNumberPicker
    result.mClassName = "msctls_updown32"
    result.mName = "NumberPicker_" & $npCount
    result.mParent = parent
    result.mXpos = x
    result.mYpos = y
    result.mWidth = w
    result.mHeight = h
    result.mFont = parent.mFont
    result.mBackColor = CLR_WHITE
    result.mForeColor = CLR_BLACK
    result.mStyle = NPSTYLE
    result.mExStyle = 0
    result.mTopEdgeFlag = BF_TOPLEFT
    result.mBotEdgeFlag = BF_BOTTOM
    result.mMinRange = 0
    result.mMaxRange = 100
    result.mDeciPrec = 0
    result.mStep = 1
    result.mBuddyStyle = WS_CHILD or WS_VISIBLE or ES_NUMBER or WS_TABSTOP or WS_BORDER
    result.mBuddyExStyle = WS_EX_LTRREADING or WS_EX_LEFT
    result.mTxtFlag = DT_SINGLELINE or DT_VCENTER
    npCount += 1


proc setNPStyle(this: NumberPicker) =
    if this.mButtonLeft:
        this.mStyle = this.mStyle xor UDS_ALIGNRIGHT
        this.mStyle = this.mStyle or UDS_ALIGNLEFT
        this.mTopEdgeFlag = BF_TOP
        this.mBotEdgeFlag = BF_BOTTOMRIGHT
        if this.mTxtPos == taLeft: this.mTxtPos = taRight

    case this.mTxtPos
    of taLeft: this.mBuddyStyle = this.mBuddyStyle or ES_LEFT
    of taCenter: this.mBuddyStyle = this.mBuddyStyle or ES_CENTER
    of taRight: this.mBuddyStyle = this.mBuddyStyle or ES_RIGHT
    this.mMyRect = RECT(left: this.mXpos, top: this.mYpos, right: (this.mXpos - this.mWidth), bottom: (this.mYpos - this.mHeight))
    this.mBkBrush = CreateSolidBrush(this.mBackColor.cref)
    this.mPen = CreatePen(PS_SOLID, 1, this.backColor.cref)


proc createBuddy(this: NumberPicker) =
    if this.mButtonLeft: this.mWidth -= 2
    this.mBuddyHandle = CreateWindowExW(this.mBuddyExStyle, toWcharPtr("Edit"), nil, this.mBuddyStyle,
                                        this.mXpos, this.mYpos, this.mWidth, this.mHeight,
                                        this.mParent.mHandle, cast[HMENU](this.mBuddyCID), this.mParent.hInstance, nil)
    if this.mBuddyHandle != nil:
        SetWindowSubclass(this.mBuddyHandle, npEditWndProc, globalSubClassID, cast[DWORD_PTR](cast[PVOID](this)))
        globalSubClassID += 1
        SendMessageW(this.mBuddyHandle, WM_SETFONT, cast[WPARAM](this.mFont.handle), 1)

proc resizeBuddy(this: NumberPicker) =
    if this.mButtonLeft:
        this.mLineX = this.mBuddyRect.left
        SetWindowPos(this.mBuddyHandle, HWND_TOP,
                        (this.mXpos + this.mUpdRect.right), this.mYpos,
                        this.mBuddyRect.right, this.mBuddyRect.bottom, cast[UINT](SWP_FLAG))
    else:
        this.mLineX = this.mBuddyRect.right - 3
        SetWindowPos(this.mBuddyHandle, HWND_TOP, this.mXpos, this.mYpos,
                        (this.mBuddyRect.right - 2), this.mBuddyRect.bottom, cast[UINT](SWP_FLAG))

proc displayValue(this: NumberPicker) =
    if this.mDeciPrec > 0:
        this.mBuddyStr = this.mValue.formatFloat(ffDecimal, this.mDeciPrec)
    else:
        this.mBuddyStr = $(int(this.mValue))
    SetWindowTextW(this.mBuddyHandle, toWcharPtr(this.mBuddyStr))

proc postCreationTasks(this: NumberPicker) =
    let oldBuddy = cast[HWND](this.sendMsg(UDM_SETBUDDY, this.mBuddyHandle, 0)) # set the edit as updown's buddy.
    this.sendMsg(UDM_SETRANGE32, int32(this.mMinRange), int32(this.mMaxRange))
    GetClientRect(this.mBuddyHandle, this.mBuddyRect.unsafeAddr)
    GetClientRect(this.mHandle, this.mUpdRect.unsafeAddr)
    this.resizeBuddy()
    this.displayValue()
    if oldBuddy != nil: SendMessageW(oldBuddy, MM_BUDDY_RESIZE, 0, 0) # This is a hack

proc setValueInternal(this: NumberPicker, delta: int32) =
    let newValue = this.mValue + (float(delta) * this.mStep)
    if this.mAutoRotate:
        if newValue > this.mMaxRange:
            this.mValue = this.mMaxRange
        elif newValue < this.mMinRange:
            this.mValue = this.mMinRange
        else:
            this.mValue = newValue
    else:
        this.mValue = clamp(newValue, this.mMinRange, this.mMaxRange)
    this.displayValue()

proc isMouseUponMe(this: NumberPicker): bool =
    var pt: POINT
    GetCursorPos(pt.unsafeAddr)
    ScreenToClient(this.mParent.mHandle, pt.unsafeAddr)
    let ret = PtInRect(this.mMyRect.unsafeAddr, pt)
    result = bool(ret)

# Create NumberPicker's hwnd
proc createHandle*(this: NumberPicker) =
    this.setNPStyle()
    this.createHandleInternal()
    if this.mHandle != nil:
        this.setSubclass(npWndProc)
        this.setFontInternal()
        this.createBuddy()
        this.postCreationTasks()






# Properties---------------------------------------------------------------------------





proc npWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.} =
    var this = cast[NumberPicker](refData)
    case msg
    of WM_DESTROY:
        RemoveWindowSubclass(hw, npWndProc, scID)

    of WM_LBUTTONDOWN: this.leftButtonDownHandler(msg, wpm, lpm)
    of WM_LBUTTONUP: this.leftButtonUpHandler(msg, wpm, lpm)
    of WM_RBUTTONDOWN: this.rightButtonDownHandler(msg, wpm, lpm)
    of WM_RBUTTONUP: this.rightButtonUpHandler(msg, wpm, lpm)
    of WM_MOUSEMOVE: this.mouseMoveHandler(msg, wpm, lpm)
    of WM_MOUSELEAVE:
        if this.mTrackMouseLeave:
            if not this.isMouseUponMe():
                this.mIsMouseEntered = false
                if this.onMouseLeave != nil: this.onMouseLeave(this, newEventArgs())

    of MM_NOTIFY_REFLECT:
        let nm = cast[LPNMUPDOWN](lpm)
        if nm.hdr.code == UDN_DELTAPOS:
            let valStrz = getControlText(this.mBuddyHandle)
            let valStr = valStrz[0..<valStrz.len - 1]
            this.mValue = parseFloat(valStr)
            this.setValueInternal(nm.iDelta)
            if this.onValueChanged != nil: this.onValueChanged(this, newEventArgs())

    else: return DefSubclassProc(hw, msg, wpm, lpm)
    return DefSubclassProc(hw, msg, wpm, lpm)


proc npEditWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.} =
    var this = cast[NumberPicker](refData)
    case msg
    of WM_DESTROY:
        RemoveWindowSubclass(hw, npEditWndProc, scID)

    of MM_BUDDY_RESIZE: this.resizeBuddy()

    of WM_PAINT:
        discard DefSubclassProc(hw, msg, wpm, lpm)
        var hdc : HDC = GetDC(hw)
        DrawEdge(hdc, this.mBuddyRect.unsafeAddr, BDR_SUNKENOUTER, this.mTopEdgeFlag)
        DrawEdge(hdc, this.mBuddyRect.unsafeAddr, BDR_RAISEDINNER, this.mBotEdgeFlag)
        MoveToEx(hdc, this.mLineX, this.mBuddyRect.unsafeAddr.top + 1, nil)
        SelectObject(hdc, this.mPen)
        LineTo(hdc, this.mLineX, this.mBuddyRect.unsafeAddr.bottom - 1)
        ReleaseDC(hw, hdc)
        return 1

    of MM_EDIT_COLOR:
        var hdc = cast[HDC](wpm)
        if (this.mDrawMode and 1) == 1: SetTextColor(hdc, this.mForeColor.cref)
        SetBkColor(hdc, this.mBackColor.cref)
        return cast[LRESULT](this.mBkBrush)

    of WM_KEYDOWN:
        this.mKeyPressed = true
        this.keyDownHandler(wpm)
    of WM_KEYUP: this.keyUpHandler(wpm)
    of WM_CHAR: this.keyPressHandler(wpm)
    of EM_SETSEL: return 1
    of WM_MOUSEMOVE: this.mouseMoveHandler(msg, wpm, lpm)
    of WM_MOUSELEAVE:
        if this.mTrackMouseLeave:
            if not this.isMouseUponMe():
                this.mIsMouseEntered = false
                if this.onMouseLeave != nil: this.onMouseLeave(this, newEventArgs())

    of MM_CTL_COMMAND:
           let nCode = HIWORD(wpm)
           if nCode == EN_UPDATE:
            if this.mHideCaret: HideCaret(hw)

    of WM_LBUTTONDOWN: this.leftButtonDownHandler(msg, wpm, lpm)
    of WM_LBUTTONUP: this.leftButtonUpHandler(msg, wpm, lpm)
    of WM_RBUTTONDOWN: this.rightButtonDownHandler(msg, wpm, lpm)
    of WM_RBUTTONUP: this.rightButtonUpHandler(msg, wpm, lpm)

    else: return DefSubclassProc(hw, msg, wpm, lpm)
    return DefSubclassProc(hw, msg, wpm, lpm)