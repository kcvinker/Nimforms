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


# Constants
const
    CB_ERR = -1
    CBN_SELCHANGE = 1
    CBN_SETFOCUS = 3
    CBN_KILLFOCUS = 4
    CBN_EDITCHANGE = 5
    CBN_EDITUPDATE = 6
    CBN_DROPDOWN = 7
    CBN_CLOSEUP = 8
    CBN_SELENDOK = 9
    CBN_SELENDCANCEL = 10
    CBS_SIMPLE = 0x0001
    CBS_DROPDOWN = 0x0002
    CBS_DROPDOWNLIST = 0x0003
    CBS_AUTOHSCROLL = 0x0040
    CBS_OEMCONVERT = 0x0080
    CBS_SORT = 0x0100
    CBS_HASSTRINGS = 0x0200
    CBS_NOINTEGRALHEIGHT = 0x0400
    CBS_DISABLENOSCROLL = 0x0800
    CBS_UPPERCASE = 0x2000
    CBS_LOWERCASE = 0x4000
    CB_GETEDITSEL = 0x0140
    CB_LIMITTEXT = 0x0141
    CB_SETEDITSEL = 0x0142
    CB_ADDSTRING = 0x0143
    CB_DELETESTRING = 0x0144
    CB_DIR = 0x0145
    CB_GETCOUNT = 0x0146
    CB_GETCURSEL = 0x0147
    CB_GETLBTEXT = 0x0148
    CB_GETLBTEXTLEN = 0x0149
    CB_INSERTSTRING = 0x014A
    CB_RESETCONTENT = 0x014B
    CB_FINDSTRING = 0x014C
    CB_SELECTSTRING = 0x014D
    CB_SETCURSEL = 0x014E
    CB_SHOWDROPDOWN = 0x014F
    CB_GETITEMDATA = 0x0150
    CB_SETITEMDATA = 0x0151
    CB_GETDROPPEDCONTROLRECT = 0x0152
    CB_SETITEMHEIGHT = 0x0153
    CB_GETITEMHEIGHT = 0x0154
    CB_SETEXTENDEDUI = 0x0155
    CB_GETEXTENDEDUI = 0x0156
    CB_GETDROPPEDSTATE = 0x0157
    CB_FINDSTRINGEXACT = 0x0158
    CB_SETLOCALE = 0x0159
    CB_GETLOCALE = 0x015A
    CB_GETTOPINDEX = 0x015b
    CB_SETTOPINDEX = 0x015c
    CB_GETHORIZONTALEXTENT = 0x015d
    CB_SETHORIZONTALEXTENT = 0x015e
    CB_GETDROPPEDWIDTH = 0x015f
    CB_SETDROPPEDWIDTH = 0x0160
    CB_INITSTORAGE = 0x0161
    CB_MULTIPLEADDSTRING = 0x0163
    CB_GETCOMBOBOXINFO = 0x0164

var cmbCount = 1
let cmbClsName : array[9, uint16] = [0x43, 0x6F, 0x6D, 0x62, 0x6F, 0x42, 0x6F, 0x78, 0]

# Forward declaration
proc cmbWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.}
proc cmbEditWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.}
proc createHandle*(this: ComboBox)

# ComboBox constructor
proc newComboBox*(parent: Form, x: int32 = 10, y: int32 = 10, w: int32 = 140, h: int32 = 27): ComboBox =
    new(result)
    result.mKind = ctComboBox
    result.mClassName = cast[LPCWSTR](cmbClsName[0].addr)
    result.mName = "ComboBox_" & $cmbCount
    result.mParent = parent
    result.mXpos = x
    result.mYpos = y
    result.mWidth = w
    result.mHeight = h
    # result.mFont = parent.mFont
    result.cloneParentFont()
    result.mHasFont = true
    result.mSelIndex = -1
    result.mBackColor = CLR_WHITE
    result.mForeColor = CLR_BLACK
    result.mStyle = WS_CHILD or WS_VISIBLE or WS_TABSTOP
    result.mExStyle = WS_EX_CLIENTEDGE
    cmbCount += 1
    parent.mControls.add(result)
    if parent.mCreateChilds: result.createHandle()

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
        this.mParent.mComboData[cmbInfo.hwndList] = cmbInfo.hwndCombo # Put the handle in parent's dic
        SetWindowSubclass(cmbInfo.hwndItem, cmbEditWndProc, globalSubClassID, cast[DWORD_PTR](cast[PVOID](this)))
        globalSubClassID += 1

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
proc createHandle*(this: ComboBox) =
    this.setCmbStyle()
    this.createHandleInternal(this.mReEnabled)
    if this.mHandle != nil:
        this.setSubclass(cmbWndProc)
        this.setFontInternal()
        this.getComboInfo()
        this.insertItemsInternal()
        this.mReEnabled = false

method autoCreate(this: ComboBox) = this.createHandle()

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
            this.createHandle()

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

proc isMouseInCombo(hw: HWND): bool =
    var rc: RECT
    GetWindowRect(hw, rc.unsafeAddr)
    var pts = getComboMousePoints()
    result = bool(PtInRect(rc.unsafeAddr, pts))

proc mouseLeaveHandler(this: ComboBox): LRESULT =
    if this.mHasInput:
        if isMouseInCombo(this.mHandle):
            return 1
        else:
            if this.onMouseLeave != nil: this.onMouseLeave(this, newEventArgs())
    else:
        if this.onMouseLeave != nil: this.onMouseLeave(this, newEventArgs())
    return 0


proc cmbWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.} =
    case msg
    of WM_DESTROY:
        RemoveWindowSubclass(hw, cmbWndProc, scID)
        var this = cast[ComboBox](refData)
        this.destructor()

    of WM_LBUTTONDOWN:
        var this = cast[ComboBox](refData)
        this.leftButtonDownHandler(msg, wpm, lpm)

    of WM_LBUTTONUP:
        var this = cast[ComboBox](refData)
        this.leftButtonUpHandler(msg, wpm, lpm)

    of WM_RBUTTONDOWN:
        var this = cast[ComboBox](refData)
        this.rightButtonDownHandler(msg, wpm, lpm)

    of WM_RBUTTONUP:
        var this = cast[ComboBox](refData)
        this.rightButtonUpHandler(msg, wpm, lpm)

    of WM_MOUSEMOVE:
        var this = cast[ComboBox](refData)
        this.mouseMoveHandler(msg, wpm, lpm)

    of WM_MOUSELEAVE:
        var this = cast[ComboBox](refData)
        return this.mouseLeaveHandler()

    of WM_KEYDOWN:
        var this = cast[ComboBox](refData)
        this.keyDownHandler(wpm)

    of WM_KEYUP:
        var this = cast[ComboBox](refData)
        this.keyUpHandler(wpm)

    of WM_CHAR:
        var this = cast[ComboBox](refData)
        this.keyPressHandler(wpm)

    of WM_CONTEXTMENU:
        var this = cast[ComboBox](refData)
        if this.mContextMenu != nil:
            this.mContextMenu.showMenu(lpm)

    of MM_CTL_COMMAND:
        var this = cast[ComboBox](refData) 
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
        var this = cast[ComboBox](refData)
        if this.mDrawMode > 0:
            let hdc = cast[HDC](wpm)
            if (this.mDrawMode and 1) == 1:
                SetTextColor(hdc, this.mForeColor.cref)
            if (this.mDrawMode and 2) == 2:
                SetBkColor(hdc, this.mBackColor.cref)
        return cast[LRESULT](this.mBkBrush)

    else:
        return DefSubclassProc(hw, msg, wpm, lpm)
    return DefSubclassProc(hw, msg, wpm, lpm)




proc cmbEditWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.} =
    var this = cast[ComboBox](refData)
    case msg
    of WM_DESTROY:
        var this = cast[ComboBox](refData)
        RemoveWindowSubclass(hw, cmbEditWndProc, scID)
    of WM_LBUTTONDOWN:
        var this = cast[ComboBox](refData)
        this.leftButtonDownHandler(msg, wpm, lpm)
    of WM_LBUTTONUP:
        var this = cast[ComboBox](refData)
        this.leftButtonUpHandler(msg, wpm, lpm)
    of WM_RBUTTONDOWN:
        var this = cast[ComboBox](refData)
        this.rightButtonDownHandler(msg, wpm, lpm)
    of WM_RBUTTONUP:
        var this = cast[ComboBox](refData)
        this.rightButtonUpHandler(msg, wpm, lpm)
    of WM_MOUSEMOVE:
        var this = cast[ComboBox](refData)
        this.mouseMoveHandler(msg, wpm, lpm)
    of WM_MOUSELEAVE:
        var this = cast[ComboBox](refData)
        return this.mouseLeaveHandler()
    of WM_KEYDOWN:
        var this = cast[ComboBox](refData)
        if this.hasInput:
            this.keyDownHandler(wpm)
    of WM_KEYUP:
        var this = cast[ComboBox](refData)
        if this.hasInput:
            this.keyUpHandler(wpm)
    of WM_CHAR:
        var this = cast[ComboBox](refData)
        if this.hasInput:
            this.keyPressHandler(wpm)
    of MM_EDIT_COLOR:
        var this = cast[ComboBox](refData)
        if this.mDrawMode > 0:
            let hdc = cast[HDC](wpm)
            if (this.mDrawMode and 1) == 1:
                SetTextColor(hdc, this.mForeColor.cref)
            if (this.mDrawMode and 2) == 2:
                SetBkColor(hdc, this.mBackColor.cref)
        return cast[LRESULT](this.mBkBrush)


    else: return DefSubclassProc(hw, msg, wpm, lpm)
    return DefSubclassProc(hw, msg, wpm, lpm)
