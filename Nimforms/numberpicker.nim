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
    result.mtid = 2
    result.mKind = ctNumberPicker
    result.mClassName = cast[LPCWSTR](npClsName[0].addr)
    result.mName = "NumberPicker_" & $npCount
    result.mParent = parent
    result.mXpos = x
    result.mYpos = y
    result.mWidth = w
    result.mHeight = h
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
    this.mBkBrush = CreateSolidBrush(this.mBackColor.cref)
    this.mPen = CreatePen(PS_SOLID, 1, this.backColor.cref)
    prct(this.mMyRect, POINT(x:0, y:0), false)


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
    # this.mMyRect.right = this.mMyRect.left + this.mBuddyRect.right + this.mUpdRect.right
    # this.mMyRect.bottom = this.mMyRect.top + this.mBuddyRect.bottom
    this.displayValue()
    if oldBuddy != nil: SendMessageW(oldBuddy, MM_BUDDY_RESIZE, 0, 0) # This is a hack
    SetRect(&this.mMyRect, this.mXpos, this.mYpos, (this.mXpos + this.mWidth), (this.mYpos + this.mHeight))
    UnionRect(&this.mSpRect, &this.mUpdRect, &this.mBuddyRect)


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


    
method `onMouseHover=`*(this: NumberPicker, evtProc: EventHandler) =
    procCall `onMouseHover=`(cast[Control](this), evtProc)
    this.mHoverTimer = newTimer(400, nil, this.mHandle)

method mouseMoveHandler(this: NumberPicker, hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM) : MsgHandlerResult =
    result = MsgHandlerResult.mhrCallDefProc      
    if this.onMouseMove != nil:
        var mea = newMouseEventArgs(msg, wpm, lpm)
        this.onMouseMove(this, mea)

    if mouseHoverEvent in this.mMouseEvents and not this.mHoverTriggered:
        this.mLastMpos.x = cast[int32](LOWORD(lpm))
        this.mLastMpos.y = cast[int32](HIWORD(lpm))
        this.mHoverTimer.tryReset()
        this.mHoverTriggered = true

    if mouseEnterEvent in this.mMouseEvents and not this.mMouseEntered: 
        this.mMouseEntered = true
        this.mOnMouseEnter(this, newEventArgs())


method mouseLeaveHandler(this: NumberPicker): MsgHandlerResult =
    # tmeMLeave is handling onMouseEnter & onMouseLeave events.
    # tmeMHover is handling onMouseHover event.
    if tmeMLeave in this.mTmeFlags or tmeMHover in this.mTmeFlags: 
        if this.mIsMouseTracking or this.mMouseEntered or this.mHoverTriggered:  
            # It's tricky to implement mouse leave event in NumberPicker.
            # We get mouse leave message from edit and arrow buttons.
            # So we can't rely on just that message. So we are checking...
            # if mouse is really upon our permeter or not. It is safe to convert
            # all the mouse points relative to Form's coordinates.                 
            var pt : POINT
            GetCursorPos(&pt)
            ScreenToClient(this.mParent.mHandle, &pt)      
            let inside = cast[bool](PtInRect(&this.mMyRect, pt))     
            if not inside:
                this.mIsMouseTracking = false
                this.mMouseEntered = false
                if this.mHoverTriggered:
                    this.mHoverTriggered = false
                    this.mHoverTimer.stop()

                if this.mOnMouseLeave != nil: this.mOnMouseLeave(this, newEventArgs())            

    return MsgHandlerResult.mhrCallDefProc

    

# Create NumberPicker's hwnd
proc createHandle*(this: NumberPicker) =
    this.setNPStyle()
    this.createHandleInternal()
    if this.mHandle != nil:
        this.setSubclass(npWndProc)
        this.setFontInternal()
        this.createBuddy()
        this.postCreationTasks()
        

method autoCreate(this: NumberPicker) = this.createHandle()


# Properties---------------------------------------------------------------------------

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


var c1 = 1
proc npWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.} =
    var this = cast[NumberPicker](refData)

    let res = this.commonMsgHandler(hw, msg, wpm, lpm)
    if res == MsgHandlerResult.mhrCallDefProc:
        return DefSubclassProc(hw, msg, wpm, lpm)
    elif res == MsgHandlerResult.mhrReturnZero or res == MsgHandlerResult.mhrReturnOne:
        return cast[LRESULT](res)    

    case msg
    of WM_TIMER:
        if this.mOnMouseHover != nil:
            this.mHoverTimer.stop()
            this.mOnMouseHover(this, newEventArgs())
        return 0

    of WM_DESTROY:
        RemoveWindowSubclass(hw, npWndProc, scID)
        if this.mPen != nil: DeleteObject(this.mPen)
        this.destructor()

    of MM_NOTIFY_REFLECT:
        let nm = cast[LPNMUPDOWN](lpm)
        if nm.hdr.code == UDN_DELTAPOS:
            let valStrz = getControlText(this.mBuddyHandle)
            let valStr = valStrz[0..<valStrz.len]
            this.mValue = parseFloat(valStr)
            this.setValueInternal(nm.iDelta)
            if this.onValueChanged != nil: this.onValueChanged(this, newEventArgs())

    else: return DefSubclassProc(hw, msg, wpm, lpm)
    return DefSubclassProc(hw, msg, wpm, lpm)


proc npEditWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.} =
   
    var this = cast[NumberPicker](refData)

    let res = this.commonMsgHandler(hw, msg, wpm, lpm)
    if res == MsgHandlerResult.mhrCallDefProc:
        return DefSubclassProc(hw, msg, wpm, lpm)
    elif res == MsgHandlerResult.mhrReturnZero or res == MsgHandlerResult.mhrReturnOne:
        return cast[LRESULT](res)
    
    case msg
    of WM_DESTROY:
        RemoveWindowSubclass(hw, npEditWndProc, scID)

    of MM_BUDDY_RESIZE: 
        this.resizeBuddy()

    of WM_PAINT:
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
        var hdc = cast[HDC](wpm)
        if (this.mDrawMode and 1) == 1: SetTextColor(hdc, this.mForeColor.cref)
        SetBkColor(hdc, this.mBackColor.cref)
        return cast[LRESULT](this.mBkBrush)

    of EM_SETSEL:
        return 1
  
    of MM_CTL_COMMAND:
        let nCode = HIWORD(wpm)
        if nCode == EN_UPDATE:
            if this.mHideCaret: HideCaret(hw)

    else: return DefSubclassProc(hw, msg, wpm, lpm)
    return DefSubclassProc(hw, msg, wpm, lpm)
