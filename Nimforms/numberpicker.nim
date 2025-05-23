# numberpicker module Created on 03-Apr-2023 01:57 PM; Author kcvinker
#[=============================================NumberPicker Docs=================================================
    Constructor - newNumberPicker

    Functions
        createHandle() - Create the handle of numberPicker

    Properties:
        All props inherited from Control type 
        value           : float/int
        buttonLeft      : bool
        autoRotate      : bool
        hideCaret       : bool
        minRange        : float
        maxRange        : float
        step            : float/int
        textAlign       : TextAlignment - {taLeft, taCenter, taRight}
        decimalDigits   : int

    Events:
        EventHandler type - proc(c: Control, e: EventArgs)
            onValueChanged
============================================================================================================]#
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
# let npClsName = toWcharPtr("msctls_updown32")
let npClsName : array[16, uint16] = [0x6D, 0x73, 0x63, 0x74, 0x6C, 0x73, 0x5F, 0x75, 0x70, 0x64, 0x6F, 0x77, 0x6E, 0x33, 0x32, 0]


let NPSTYLE: DWORD = WS_VISIBLE or WS_CHILD or UDS_ALIGNRIGHT or UDS_ARROWKEYS or UDS_AUTOBUDDY or UDS_HOTTRACK
let SWP_FLAG: DWORD = SWP_SHOWWINDOW or SWP_NOACTIVATE or SWP_NOZORDER

# Forward declaration
proc npWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.}
proc npEditWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.}
proc createHandle*(this: NumberPicker)

# NumberPicker constructor
proc newNumberPicker*(parent: Form, x: int32 = 10, y: int32 = 10, w: int32 = 75, h: int32 = 27): NumberPicker =
    new(result)
    result.mKind = ctNumberPicker
    result.mClassName = cast[LPCWSTR](npClsName[0].addr)
    result.mName = "NumberPicker_" & $npCount
    result.mParent = parent
    result.mXpos = x
    result.mYpos = y
    result.mWidth = w
    result.mHeight = h
    # result.mFont = parent.mFont
    result.cloneParentFont()
    result.mHasFont = true
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
    parent.mControls.add(result)
    if parent.mCreateChilds: result.createHandle()


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
    this.mMyRect.right = this.mMyRect.left + this.mBuddyRect.right + this.mUpdRect.right
    this.mMyRect.bottom = this.mMyRect.top + this.mBuddyRect.bottom
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
        this.mcRect = this.mMyRect
        # var pArr : array[4, POINT]
        # pArr[0] = POINT(x : this.mMyRect.left, y: this.mMyRect.top)
        # pArr[1] = POINT(x: this.mMyRect.right, y: this.mMyRect.top)
        # pArr[2] = POINT(x: this.mMyRect.right, y: this.mMyRect.bottom)
        # pArr[3] = POINT(x: this.mMyRect.left, y: this.mMyRect.bottom)
        # var pnt : POINT = POINT(x : this.mUpdRect.right, y: this.mUpdRect.bottom)
        # for i, p in pArr:
        # MapWindowPoints(this.mBuddyHandle, this.mParent.mHandle, pnt.unsafeAddr, 1)
        # echo "left ", this.mMyRect.left
        # echo "top ", this.mMyRect.top
        # echo "right ", (this.mMyRect.right - this.mMyRect.left) + (this.mUpdRect.right - this.mUpdRect.left)
        # echo "bottom ", pnt.y
        # for i, p in pArr:
        #     echo "point ", i, " x: ", p.x, " y: ", p.y

        # echo " my rect ", this.mMyRect
        # echo " BuddyRect ", this.mBuddyRect
        # echo " UpdRect ", this.mUpdRect

method autoCreate(this: NumberPicker) = this.createHandle()


# Properties---------------------------------------------------------------------------

# proc `value=`*(this: NumberPicker, fValue: float) =
#     if this.mIsCreated:
#         discard
#     else:
#         this.mValue = fValue

proc `value=`*(this: NumberPicker, fValue: auto) = # Accepts int or float
    this.mValue = (if fValue is int: float(fValue) else: fValue)
    if this.mIsCreated: this.displayValue()

proc value*(this: NumberPicker): auto = # Return int or float
    result = (if this.mDeciPrec > 0: this.mValue else: this.mValue)

proc `buttonLeft=`*(this: NumberPicker, value: bool) = this.mButtonLeft = value
proc buttonLeft*(this: NumberPicker): bool = this.mButtonLeft

proc `autoRotate=`*(this: NumberPicker, value: bool) = this.mAutoRotate = value
proc autoRotate*(this: NumberPicker): bool = this.mAutoRotate

proc `hideCaret=`*(this: NumberPicker, value: bool) = this.mHideCaret = value
proc hideCaret*(this: NumberPicker): bool = this.mHideCaret

proc `minRange=`*(this: NumberPicker, value: float) = this.mMinRange = value
proc minRange*(this: NumberPicker): float = this.mMinRange

proc `maxRange=`*(this: NumberPicker, value: float) = this.mMaxRange = value
proc maxRange*(this: NumberPicker): float = this.mMaxRange

proc `step=`*(this: NumberPicker, value: auto) =
    if value is int: this.mIntStep = true
    this.mStep = float(value)

template step*(this: NumberPicker): auto =
    result = (if this.mIntStep: int(this.mStep) else: this.mStep)

proc `decimalDigits=`*(this: NumberPicker, value: int) = this.mDeciPrec = int32(value)
proc decimalDigits*(this: NumberPicker): int = int(this.mDeciPrec)

proc `textAlign=`*(this: NumberPicker, value: TextAlignment) = this.mTxtPos = value
proc textAlign*(this: NumberPicker): TextAlignment = this.mTxtPos

# , mUpdRect
# proc right*(this: NumberPicker): int32 = int32(this.mBuddyRect.left + this.mWidth + this.mUpdRect.right)
# proc bottom*(this: NumberPicker): int32 = int32(this.mBuddyRect.bottom)



proc npWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.} =
    
    case msg
    of WM_DESTROY:
        RemoveWindowSubclass(hw, npWndProc, scID)
        var this = cast[NumberPicker](refData)
        if this.mPen != nil: DeleteObject(this.mPen)
        this.destructor()

    of WM_LBUTTONDOWN:
        var this = cast[NumberPicker](refData)
        this.leftButtonDownHandler(msg, wpm, lpm)

    of WM_LBUTTONUP:
        var this = cast[NumberPicker](refData)
        this.leftButtonUpHandler(msg, wpm, lpm)

    of WM_RBUTTONDOWN:
        var this = cast[NumberPicker](refData)
        this.rightButtonDownHandler(msg, wpm, lpm)

    of WM_RBUTTONUP:
        var this = cast[NumberPicker](refData)
        this.rightButtonUpHandler(msg, wpm, lpm)

    of WM_MOUSEMOVE:
        var this = cast[NumberPicker](refData)
        this.mouseMoveHandler(msg, wpm, lpm)
        
    of WM_CONTEXTMENU:
        var this = cast[NumberPicker](refData)
        if this.mContextMenu != nil: this.mContextMenu.showMenu(lpm)

    of WM_MOUSELEAVE:
        var this = cast[NumberPicker](refData)
        if this.mTrackMouseLeave:
            if not this.isMouseUponMe():
                this.mIsMouseEntered = false
                if this.onMouseLeave != nil: this.onMouseLeave(this, newEventArgs())

    of MM_NOTIFY_REFLECT:
        var this = cast[NumberPicker](refData)
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
   
    case msg
    of WM_DESTROY:
        var this = cast[NumberPicker](refData)
        RemoveWindowSubclass(hw, npEditWndProc, scID)

    of MM_BUDDY_RESIZE: 
        var this = cast[NumberPicker](refData)
        this.resizeBuddy()

    of WM_PAINT:
        var this = cast[NumberPicker](refData)
        discard DefSubclassProc(hw, msg, wpm, lpm)
        var hdc : HDC = GetDC(hw)
        DrawEdge(hdc, this.mBuddyRect.unsafeAddr, BDR_SUNKENOUTER, this.mTopEdgeFlag)
        DrawEdge(hdc, this.mBuddyRect.unsafeAddr, BDR_RAISEDINNER, this.mBotEdgeFlag)
        MoveToEx(hdc, this.mLineX, this.mBuddyRect.top + 1, nil)
        SelectObject(hdc, this.mPen)
        LineTo(hdc, this.mLineX, this.mBuddyRect.bottom - 1)
        ReleaseDC(hw, hdc)
        return 1

    of MM_EDIT_COLOR:
        var this = cast[NumberPicker](refData)
        var hdc = cast[HDC](wpm)
        if (this.mDrawMode and 1) == 1: SetTextColor(hdc, this.mForeColor.cref)
        SetBkColor(hdc, this.mBackColor.cref)
        return cast[LRESULT](this.mBkBrush)

    of WM_KEYDOWN:
        var this = cast[NumberPicker](refData)
        this.mKeyPressed = true
        this.keyDownHandler(wpm)

    of WM_KEYUP:
        var this = cast[NumberPicker](refData)
        this.keyUpHandler(wpm)
    of WM_CHAR:
        var this = cast[NumberPicker](refData)
        this.keyPressHandler(wpm)
    of EM_SETSEL:
        var this = cast[NumberPicker](refData)
        return 1
    of WM_MOUSEMOVE:
        var this = cast[NumberPicker](refData)
        this.mouseMoveHandler(msg, wpm, lpm)
    of WM_MOUSELEAVE:
        var this = cast[NumberPicker](refData)
        if this.mTrackMouseLeave:
            if not this.isMouseUponMe():
                this.mIsMouseEntered = false
                if this.onMouseLeave != nil: this.onMouseLeave(this, newEventArgs())

    of MM_CTL_COMMAND:
        var this = cast[NumberPicker](refData)
        let nCode = HIWORD(wpm)
        if nCode == EN_UPDATE:
            if this.mHideCaret: HideCaret(hw)

    of WM_LBUTTONDOWN: 
        var this = cast[NumberPicker](refData)
        this.leftButtonDownHandler(msg, wpm, lpm)

    of WM_LBUTTONUP: 
        var this = cast[NumberPicker](refData)
        this.leftButtonUpHandler(msg, wpm, lpm)

    of WM_RBUTTONDOWN: 
        var this = cast[NumberPicker](refData)
        this.rightButtonDownHandler(msg, wpm, lpm)

    of WM_RBUTTONUP: 
        var this = cast[NumberPicker](refData)
        this.rightButtonUpHandler(msg, wpm, lpm)

    else: return DefSubclassProc(hw, msg, wpm, lpm)
    return DefSubclassProc(hw, msg, wpm, lpm)
