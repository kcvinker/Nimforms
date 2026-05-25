    # combobox module Created on 30-Mar-2023 03:23 AM; Author kcvinker
#[======================================= ComboBox Docs==================================================
    Constructor - newComboBox
    Functions:
        createHandle
        addItem
        addItems
        removeItem
        removeItem
        removeAll

    Properties:
        All props inherited from Control type 
        hasInput      bool
        selectedIndex int32
        selctedItem   string
        items         seq[string]

    Events
        All events inherited from Control type
        EventHandler type - proc(c: Control, e: EventArgs)
            onSelectionChanged
            onTextChanged
            onTextUpdated
            onListOpened
            onListClosed
            onSelectionCommitted
            onSelectionCancelled
========================================================================================================]#





var cmbCount = 1
let cmbClsName : array[9, uint16] = [0x43, 0x6F, 0x6D, 0x62, 0x6F, 0x42, 0x6F, 0x78, 0]

# Forward declaration
proc cmbWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.}
proc cmbEditWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.}
proc createCmbHandle(ctl: Control)

# ComboBox constructor
proc newComboBox*(parent: Control, x: int32 = 10, y: int32 = 10, 
                    w: int32 = 140, h: int32 = 27, enableInput: bool = false): ComboBox =
    new(result)
    result.mKind = ctComboBox
    controlBaseInit(result, parent, x, y, w, h, cmbCount)
    result.mHasInput = enableInput
    result.mSelIndex = -1
    result.mCreateHwndProc = createCmbHandle
    

proc setCmbStyle(this: ComboBox) =
    if this.mReEnabled:
        if this.mHasInput:
            if (this.mStyle and CBS_DROPDOWNLIST) == CBS_DROPDOWNLIST:
                this.mStyle = this.mStyle xor CBS_DROPDOWNLIST
            this.mStyle = this.mStyle or CBS_DROPDOWN
        else:
            if (this.mStyle and CBS_DROPDOWN) == CBS_DROPDOWN:
                this.mStyle = this.mStyle xor CBS_DROPDOWN
            this.mStyle = this.mStyle or CBS_DROPDOWNLIST
    else:
        this.mStyle = (if this.mHasInput: this.mStyle or CBS_DROPDOWN else: this.mStyle or CBS_DROPDOWNLIST)
    this.mBkBrush = this.mBackColor.makeHBRUSH()

proc getComboInfo(this: ComboBox) =
        var cmbInfo : COMBOBOXINFO
        cmbInfo.cbSize = DWORD(cmbInfo.sizeof)
        this.sendMsg(CB_GETCOMBOBOXINFO, 0, cmbInfo.unsafeAddr)
        this.mOwnerForm.mComboData[cmbInfo.hwndList] = cmbInfo.hwndCombo # Put the handle in parent's dic
        SetWindowSubclass(cmbInfo.hwndItem, cmbEditWndProc, globalSubClassID, cast[DWORD_PTR](cast[PVOID](this)))
        globalSubClassID += 1
        SetRect(&this.mSpRect, 0, 0, this.mWidth, this.mHeight)


proc getBiggerLength(this: ComboBox): int32 = 
    var biggerItem = this.mitems[0]
    for item in this.mitems:
        if len(item) > len(biggerItem):
            biggerItem = item 
            
    result = int32(len(biggerItem))

proc insertItemsInternal(this: ComboBox) =
    if this.mItems.len > 0:
        let nChars = this.getBiggerLength()
        # var wptr = cast[WArrayPtr](alloc0(bytes))
        appData.sendMsgBuffer.ensureSize(nChars)
        for item in this.mItems: 
            # fillWstring(wptr[0].addr, item)
            appData.sendMsgBuffer.updateBuffer(item)
            this.sendMsg(CB_ADDSTRING, 0, &appData.sendMsgBuffer)
        
    if this.mSelIndex > -1: this.sendMsg(CB_SETCURSEL, this.mSelIndex, 0)

# Create ComboBox's hwnd
proc createCmbHandle(ctl: Control) =
    var this = cast[ComboBox](ctl)
    this.setCmbStyle()
    this.createHandleInternal(this.mWidth, this.mHeight)
    if this.mHandle != nil:
        this.setSubclass(cmbWndProc)
        this.getComboInfo()
        this.insertItemsInternal()
        this.mReEnabled = false

# method autoCreate(this: ComboBox) = this.createHandle()

proc addItem*(this: ComboBox, item: auto) =
    let sitem : string = (if item is string: item else: $item)    
    if this.mIsCreated: 
        appData.sendMsgBuffer.updateBuffer(sitem)
        this.sendMsg(CB_ADDSTRING, 0, &appData.sendMsgBuffer)

    this.mItems.add(sitem)

proc addItems*(this: ComboBox, args: varargs[string, `$`]) =
    for item in args:
        if this.mIsCreated: 
            appData.sendMsgBuffer.updateBuffer(item)
            this.sendMsg(CB_ADDSTRING, 0, &appData.sendMsgBuffer)

        this.mItems.add(item)

proc removeItem*(this: ComboBox, item: auto) =
    if this.mIsCreated:
        let sitem : string = (if item is string: item else: $item)
        let index = int32(this.sendMsg(CB_FINDSTRINGEXACT, -1, &appData.sendMsgBuffer))
        if index != CB_ERR:
            this.sendMsg(CB_DELETESTRING, index, 0)
            this.mItems = filter(seq, proc(x: string): bool = x != sitem)

proc removeItem*(this: ComboBox, index: int32) =
    if this.mIsCreated and index > -1:
        this.sendMsg(CB_DELETESTRING, index, 0)
        this.mItems.delete(index)

proc removeAll*(this: ComboBox) =
    if this.mItems.len > 0:
        this.mItems.setLen(0)
        if this.mIsCreated: this.sendMsg(CB_DELETESTRING, 0, 0)


# Set the hasInput property
proc `hasInput=`*(this: ComboBox, value: bool) {.inline.} =
    if this.mHasInput != value:
        this.mHasInput = value
        if this.mIsCreated:
            this.mSelIndex = int32(this.sendMsg(CB_GETCURSEL, 0, 0 ))
            this.mReEnabled = true
            DestroyWindow(this.mHandle)
            this.mCreateHwndProc(this)

# Get the checked property
proc hasInput*(this: ComboBox): bool {.inline.} = this.mHasInput

proc `selectedIndex=`*(this: ComboBox, value: int32) =
    this.mSelIndex = value
    if this.mIsCreated: this.sendMsg(CB_SETCURSEL, value, 0)

proc selectedIndex*(this: ComboBox): int32 =
    result = (if this.mIsCreated: int32(this.sendMsg(CB_GETCURSEL, 0, 0)) else: -1)

proc `selctedItem=`*(this: ComboBox, value: auto) =
    if this.mIsCreated and this.mItems.len > 0:
        let sitem : string = (if value is string: value else: $value)
        appData.sendMsgBuffer.updateBuffer(sitem)
        let index = int32(this.sendMsg(CB_FINDSTRINGEXACT, -1, &appData.sendMsgBuffer))
        if index != CB_ERR: this.sendMsg(CB_SETCURSEL, index, 0)

proc selctedItem*(this: ComboBox): string =
    if this.mIsCreated:
        this.mSelIndex = int32(this.sendMsg(CB_GETCURSEL, 0, 0))
        if this.mSelIndex != CB_ERR:
            let iLen = int32(this.sendMsg(CB_GETLBTEXTLEN, this.mSelIndex, 0))
            appData.sendMsgBuffer.ensureSize(iLen + 1)
            this.sendMsg(CB_GETLBTEXT, this.mSelIndex, &appData.sendMsgBuffer)
            result = appData.sendMsgBuffer.toStr      
        #end if
    else:
        result = ""

proc items*(this: ComboBox) : seq[string] = this.mItems


proc getComboMousePoints(): POINT =
    let value: DWORD = GetMessagePos()
    let x = int32(LOWORD(value))
    let y = int32(HIWORD(value))
    result = POINT(x:x, y:y)


method `onMouseHover=`*(this: ComboBox, evtProc: EventHandler) =
    procCall `onMouseHover=`(cast[Control](this), evtProc)
    this.mHoverTimer = newTimer(400, nil, this.mHandle) 

method mouseMoveHandler(this: ComboBox, hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM) : MsgHandlerResult =
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


method mouseLeaveHandler(this: ComboBox): MsgHandlerResult =
    # tmeMLeave is handling onMouseEnter & onMouseLeave events.
    # tmeMHover is handling onMouseHover event.
    if tmeMLeave in this.mTmeFlags or tmeMHover in this.mTmeFlags: 
        if this.mIsMouseTracking or this.mMouseEntered or this.mHoverTriggered:  
            # SInce ComboBox is a comnination of edit and button, we need special
            # care to implement mouse leave event. Edit is sitting inside combo's
            # rect. So we get mouse leave message even when mouse is inside combo.
            # So, we need to check if mouse is really inside our perimeter.                 
            var pt : POINT
            GetCursorPos(&pt)
            ScreenToClient(this.mHandle, &pt)      
            let inside = cast[bool](PtInRect(&this.mSpRect, pt))      
            if not inside:
                this.mIsMouseTracking = false
                this.mMouseEntered = false
                if this.mHoverTriggered:
                    this.mHoverTriggered = false
                    this.mHoverTimer.stop()

                if this.mOnMouseLeave != nil: this.mOnMouseLeave(this, newEventArgs())            

    return MsgHandlerResult.mhrCallDefProc


proc cmbWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.} =
    var this = cast[ComboBox](refData)
    let res = this.commonMsgHandler(hw, msg, wpm, lpm)
    if res == MsgHandlerResult.mhrCallDefProc:
        return DefSubclassProc(hw, msg, wpm, lpm)
    elif res == MsgHandlerResult.mhrReturnZero or res == MsgHandlerResult.mhrReturnOne:
        return cast[LRESULT](res)
    case msg
    of WM_NCDESTROY:
        RemoveWindowSubclass(hw, cmbWndProc, scID)
        this.controlBaseDtor()

    of MM_CTL_COMMAND: 
        case HIWORD(wpm)
        of CBN_SELCHANGE:
            if this.onSelectionChanged != nil:
                this.onSelectionChanged(this, newEventArgs())
        of CBN_EDITCHANGE:
            if this.onTextChanged != nil:
                this.onTextChanged(this, newEventArgs())
        of CBN_EDITUPDATE:
            if this.onTextUpdated != nil:
                this.onTextUpdated(this, newEventArgs())
        of CBN_DROPDOWN:
            if this.onListOpened != nil:
                this.onListOpened(this, newEventArgs())
        of CBN_CLOSEUP:
            if this.onListClosed != nil:
                this.onListClosed(this, newEventArgs())
        of CBN_SELENDOK:
            if this.onSelectionCommitted != nil:
                this.onSelectionCommitted(this, newEventArgs())
        of CBN_SELENDCANCEL:
            if this.onSelectionCancelled != nil:
                this.onSelectionCancelled(this, newEventArgs())
        else:
            discard

    of MM_LABEL_COLOR:
        if this.mDrawMode > 0:
            let hdc = cast[HDC](wpm)
            if (this.mDrawMode and 1) == 1:
                SetTextColor(hdc, this.mForeColor.cref)
            if (this.mDrawMode and 2) == 2:
                SetBkColor(hdc, this.mBackColor.cref)
        return cast[LRESULT](this.mBkBrush)

    of WM_TIMER:
        if this.mOnMouseHover != nil:
            this.mHoverTimer.stop()
            this.mOnMouseHover(this, newEventArgs())
        return 0

    else:
        return DefSubclassProc(hw, msg, wpm, lpm)
    return DefSubclassProc(hw, msg, wpm, lpm)




proc cmbEditWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.} =
    var this = cast[ComboBox](refData)
    let res = this.commonMsgHandler(hw, msg, wpm, lpm)
    if res == MsgHandlerResult.mhrCallDefProc:
        return DefSubclassProc(hw, msg, wpm, lpm)
    elif res == MsgHandlerResult.mhrReturnZero or res == MsgHandlerResult.mhrReturnOne:
        return cast[LRESULT](res)

    case msg
    of WM_NCDESTROY:
        RemoveWindowSubclass(hw, cmbEditWndProc, scID)

    of MM_EDIT_COLOR:
        if this.mDrawMode > 0:
            let hdc = cast[HDC](wpm)
            if (this.mDrawMode and 1) == 1:
                SetTextColor(hdc, this.mForeColor.cref)
            if (this.mDrawMode and 2) == 2:
                SetBkColor(hdc, this.mBackColor.cref)
        return cast[LRESULT](this.mBkBrush)


    else: return DefSubclassProc(hw, msg, wpm, lpm)
    return DefSubclassProc(hw, msg, wpm, lpm)
