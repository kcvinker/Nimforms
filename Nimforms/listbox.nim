# listbox module Created on 01-Apr-2023 03:55 AM; Author kcvinker
#[===========================================ListBox Docs========================================
  constructor - newListBox
  functions
        createHandle() - Create the handle of listBox
        selectAll*()
        clearSelection*()
        addItem*( item: auto)
        addItems*(args: varargs[string, `$`])
        insertItem*(item: auto, index: int32)
        removeItem*(item: auto)
        removeItem*(index: int32)
        removeAll*()
        indexOf*(item: auto): int32

    Properties:
        All props inherited from Control type 
        items               : seq[string]
        hotIndex            : int32
        hotItem             : string
        horizontalScroll    : bool
        verticalScroll      : bool
        selectedIndex       : int32
        selectedIndices     : seq[int32]
        multiSelection      : bool
        selectedItem        : string
        selctedItems        : seq[string]

    Events
        All events inherited from Control type 
        EventHandler - proc(c: Control, e: EventArgs)
            onSelectionChanged
            onSelectionCancelled
=======================================================================================================]#
# Constants
const
    # LB_CTLCODE = 0
    # LB_OKAY = 0
    LB_ERR = -1
    # LB_ERRSPACE = -2
    # LBN_ERRSPACE = -2
    LBN_SELCHANGE = 1
    LBN_DBLCLK = 2
    LBN_SELCANCEL = 3
    LBN_SETFOCUS = 4
    LBN_KILLFOCUS = 5
    LB_ADDSTRING = 0x0180
    LB_INSERTSTRING = 0x0181
    LB_DELETESTRING = 0x0182
    LB_SELITEMRANGEEX = 0x0183
    LB_RESETCONTENT = 0x0184
    LB_SETSEL = 0x0185
    LB_SETCURSEL = 0x0186
    LB_GETSEL = 0x0187
    LB_GETCURSEL = 0x0188
    LB_GETTEXT = 0x0189
    LB_GETTEXTLEN = 0x018A
    LB_GETCOUNT = 0x018B
    LB_SELECTSTRING = 0x018C
    # LB_DIR = 0x018D
    # LB_GETTOPINDEX = 0x018E
    # LB_FINDSTRING = 0x018F
    LB_GETSELCOUNT = 0x0190
    LB_GETSELITEMS = 0x0191
    # LB_SETTABSTOPS = 0x0192
    # LB_GETHORIZONTALEXTENT = 0x0193
    # LB_SETHORIZONTALEXTENT = 0x0194
    # LB_SETCOLUMNWIDTH = 0x0195
    # LB_ADDFILE = 0x0196
    # LB_SETTOPINDEX = 0x0197
    # LB_GETITEMRECT = 0x0198
    # LB_GETITEMDATA = 0x0199
    # LB_SETITEMDATA = 0x019A
    # LB_SELITEMRANGE = 0x019B
    # LB_SETANCHORINDEX = 0x019C
    # LB_GETANCHORINDEX = 0x019D
    # LB_SETCARETINDEX = 0x019E
    LB_GETCARETINDEX = 0x019F
    # LB_SETITEMHEIGHT = 0x01A0
    # LB_GETITEMHEIGHT = 0x01A1
    LB_FINDSTRINGEXACT = 0x01A2
    # LB_SETLOCALE = 0x01A5
    # LB_GETLOCALE = 0x01A6
    # LB_SETCOUNT = 0x01A7
    # LB_INITSTORAGE = 0x01A8
    # LB_ITEMFROMPOINT = 0x01A9
    # LB_MULTIPLEADDSTRING = 0x01B1
    # LB_GETLISTBOXINFO = 0x01B2
    # LB_MSGMAX = 0x01B3
    LBS_NOTIFY = 0x0001
    LBS_SORT = 0x0002
    LBS_NOREDRAW = 0x0004
    LBS_MULTIPLESEL = 0x0008
    LBS_OWNERDRAWFIXED = 0x0010
    LBS_OWNERDRAWVARIABLE = 0x0020
    LBS_HASSTRINGS = 0x0040
    LBS_USETABSTOPS = 0x0080
    LBS_NOINTEGRALHEIGHT = 0x0100
    LBS_MULTICOLUMN = 0x0200
    LBS_WANTKEYBOARDINPUT = 0x0400
    LBS_EXTENDEDSEL = 0x0800
    LBS_DISABLENOSCROLL = 0x1000
    LBS_NODATA = 0x2000
    LBS_NOSEL = 0x4000
    LBS_COMBOBOX = 0x8000
    LBS_STANDARD = LBS_NOTIFY or LBS_SORT or WS_VSCROLL or WS_BORDER


var lbxCount = 1
# let lbxClsName = toWcharPtr("Listbox")
let lbxClsName : array[8, uint16] = [0x4C, 0x69, 0x73, 0x74, 0x62, 0x6F, 0x78, 0]


# Forward declaration
proc lbxWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.}
proc createHandle*(this: ListBox)

# ListBox constructor
proc newListBox*(parent: Form, x: int32 = 10, y: int32 = 10, w: int32 = 140, h: int32 = 140 ): ListBox =
    new(result)
    result.mKind = ctListBox
    result.mClassName = cast[LPCWSTR](lbxClsName[0].addr)
    result.mName = "ListBox_" & $lbxCount
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
    result.mDummyIndex = -1
    result.mSelIndex = -1
    result.mStyle = WS_VISIBLE or WS_CHILD or WS_BORDER  or LBS_NOTIFY or LBS_HASSTRINGS
    result.mExStyle = 0
    lbxCount += 1
    parent.mControls.add(result)
    if parent.mCreateChilds: result.createHandle()

proc setLbxStyle(this: ListBox) =
    if this.mHasSort: this.mStyle = this.mStyle or LBS_SORT
    if this.mMultiSel: this.mStyle = this.mStyle or LBS_EXTENDEDSEL or LBS_MULTIPLESEL
    if this.mMultiColumn: this.mStyle = this.mStyle or LBS_MULTICOLUMN
    if this.mNoSelection: this.mStyle = this.mStyle or LBS_NOSEL
    if this.mKeyPreview: this.mStyle = this.mStyle or LBS_WANTKEYBOARDINPUT
    if this.mHorizScroll: this.mStyle = this.mStyle or WS_HSCROLL
    if this.mVertScroll: this.mStyle = this.mStyle or WS_VSCROLL
    this.mBkBrush = CreateSolidBrush(this.mBackColor.cref)

proc manageItems(this: ListBox) =
    for item in this.mItems:
        this.sendMsg(LB_ADDSTRING, 0, item.toWcharPtr)

    if this.mDummyIndex > -1: this.sendMsg(LB_SETCURSEL, this.mDummyIndex, 0)

proc getItemInternal(this: ListBox, index: int32) : string =
    let iLen = int32(this.sendMsg(LB_GETTEXTLEN, index, 0))
    var buffer = new_wstring(iLen + 1)
    this.sendMsg(LB_GETTEXT, index, &buffer)
    result = buffer.toString
    
    



# Create ListBox's hwnd
proc createHandle*(this: ListBox) =
    this.setLbxStyle()
    this.createHandleInternal()
    if this.mHandle != nil:
        this.setSubclass(lbxWndProc)
        this.setFontInternal()
        if this.mItems.len > 0: this.manageItems()

method autoCreate(this: ListBox) = this.createHandle()

# Public functions-------------------------------------------------------------
proc indexOf*(this: ListBox, item: auto): int32 {.inline.} =
    result = -1
    if this.mIsCreated:
        let sitem : string = (if item is string: item else: $item)
        result = int32(this.sendMsg(LB_FINDSTRINGEXACT, -1, sitem.toWcharPtr))

proc selectAll*(this: ListBox) =
    if this.mIsCreated and this.mMultiSel: this.sendMsg(LB_SETSEL, 1, -1)

proc clearSelection*(this: ListBox) =
    if this.mIsCreated:
        if this.mMultiSel:
            this.sendMsg(LB_SETSEL, 0, -1)
        else:
            this.sendMsg(LB_SETCURSEL, -1, 0)

proc addItem*(this: ListBox, item: auto) =
    let sitem : string = (if item is string: item else: $item)
    if this.mIsCreated: this.sendMsg(LB_ADDSTRING, 0, sitem.toWcharPtr)
    this.mItems.add(sitem)

proc addItems*(this: ListBox, args: varargs[string, `$`]) =
    for item in args:
        if this.mIsCreated: this.sendMsg(LB_ADDSTRING, 0, item.toWcharPtr)
        this.mItems.add(item)

proc insertItem*(this: ListBox, item: auto, index: int32) =
    if this.mIsCreated:
        let sitem : string = (if item is string: item else: $item)
        this.sendMsg(LB_INSERTSTRING, index, sitem.toWcharPtr)
        this.mItems.insert(index, sitem)

proc removeItem*(this: ListBox, item: auto) =
    if this.mIsCreated:
        let sitem : string = (if item is string: item else: $item)
        let index = int32(this.sendMsg(LB_FINDSTRINGEXACT, -1, sitem.toWcharPtr))
        if index != LB_ERR:
            this.sendMsg(LB_DELETESTRING, index, 0)
            this.mItems = filter(seq, proc(x: string): bool = x != sitem)

proc removeItem*(this: ListBox, index: int32) =
    if this.mIsCreated and index > -1:
        this.sendMsg(LB_DELETESTRING, index, 0)
        this.mItems.delete(index)

proc removeAll*(this: ListBox) =
    if this.mItems.len > 0:
        this.mItems = @[]
        if this.mIsCreated: this.sendMsg(LB_RESETCONTENT, 0, 0)


# Properties -----------------------------------------------------------------------
proc items*(this: ListBox): seq[string] {.inline.} = this.mItems

proc `horizontalScroll=`*(this: ListBox, value: bool) {.inline.} = this.mHorizScroll = value
proc horizontalScroll*(this: ListBox): bool {.inline.} = this.mHorizScroll

proc `verticalScroll=`*(this: ListBox, value: bool) {.inline.} = this.mVertScroll = value
proc verticalScroll*(this: ListBox): bool {.inline.} = this.mVertScroll

proc `selectedIndex=`*(this: ListBox, value: int32) =
    if this.mIsCreated and not this.mMultiSel:
        this.mSelIndex = int32(this.sendMsg(LB_SETCURSEL, 0, 0))
    if not this.mIsCreated:
        this.mDummyIndex = value
        this.mSelIndex = value

proc selectedIndex*(this: ListBox): int32 =
    if this.mIsCreated and not this.mMultiSel:
        result = int32(this.sendMsg(LB_GETCURSEL, 0, 0))
    else:
        result = -1

proc selectedIndices*(this: ListBox): seq[int32] =
    result = @[]
    if this.mIsCreated and this.mMultiSel:
        let selCount = int32(this.sendMsg(LB_GETSELCOUNT, 0, 0))
        if selCount != LB_ERR:
            if this.mSelIndices.len == 0:
                this.mSelIndices = newSeq[int32](selCount)
            else:
                this.mSelIndices.setLen(0)
                this.mSelIndices.setLen(selCount)
                this.sendMsg(LB_GETSELITEMS, selCount, this.mSelIndices[0].unsafeAddr)
                result = this.mSelIndices


proc `multiSelection=`*(this: ListBox, value: bool ) {.inline.} = this.mMultiSel = value
proc multiSelection*(this: ListBox): bool {.inline.} = this.mMultiSel

proc `selectedItem=`*(this: ListBox, value: auto) =
    if this.mIsCreated and this.mItems.len > 0:
        let sitem : string = (if value is string: value else: $value)
        let index = int32(this.sendMsg(LB_FINDSTRINGEXACT, -1, sitem.toWcharPtr))
        if index != LB_ERR: this.sendMsg(LB_SETCURSEL, index, 0)

proc selctedItem*(this: ListBox): string =
    result = ""
    if this.mIsCreated:
        this.mSelIndex = int32(this.sendMsg(LB_GETCURSEL, 0, 0))
        if this.mSelIndex != LB_ERR: result = this.getItemInternal(this.mSelIndex)

proc selctedItems*(this: ListBox): seq[string] =
    result = @[]
    if this.mIsCreated and this.mMultiSel:
        let selCount = int32(this.sendMsg(LB_GETSELCOUNT, 0, 0))
        if selCount != LB_ERR:
            var buffer = newSeq[int](selCount)
            this.sendMsg(LB_GETSELITEMS, selCount, buffer[0].unsafeAddr)
            for index in buffer: result.add(this.getItemInternal(int32(index)))

proc hotIndex*(this: ListBox): int32 {.inline.} =
    result = -1
    if this.mMultiSel: result = int32(this.sendMsg(LB_GETCARETINDEX, 0, 0))

proc hotItem*(this: ListBox): string =
    result = ""
    if this.mMultiSel:
        let hindex = int32(this.sendMsg(LB_GETCARETINDEX, 0, 0))
        if hindex != LB_ERR: result = this.getItemInternal(hindex)



proc lbxWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.} =
    
    case msg
    of WM_DESTROY:
        RemoveWindowSubclass(hw, lbxWndProc, scID)
        var this = cast[ListBox](refData)
        this.destructor()

    of WM_LBUTTONDOWN:
        var this = cast[ListBox](refData)
        this.leftButtonDownHandler(msg, wpm, lpm)

    of WM_LBUTTONUP:
        var this = cast[ListBox](refData)
        this.leftButtonUpHandler(msg, wpm, lpm)

    of WM_RBUTTONDOWN:
        var this = cast[ListBox](refData)
        this.rightButtonDownHandler(msg, wpm, lpm)

    of WM_RBUTTONUP:
        var this = cast[ListBox](refData)
        this.rightButtonUpHandler(msg, wpm, lpm)

    of WM_MOUSEMOVE:
        var this = cast[ListBox](refData)
        this.mouseMoveHandler(msg, wpm, lpm)

    of WM_MOUSELEAVE:
        var this = cast[ListBox](refData)
        this.mouseLeaveHandler()

    of WM_KEYDOWN:
        var this = cast[ListBox](refData)
        this.keyDownHandler(wpm)

    of WM_KEYUP:
        var this = cast[ListBox](refData)
        this.keyUpHandler(wpm)

    of WM_CHAR:
        var this = cast[ListBox](refData)
        this.keyPressHandler(wpm)
        
    of WM_CONTEXTMENU:
        var this = cast[ListBox](refData)
        if this.mContextMenu != nil: this.mContextMenu.showMenu(lpm)

    of MM_LIST_COLOR:
        var this = cast[ListBox](refData)
        let hdc = cast[HDC](wpm)
        if (this.mDrawMode and 1) == 1: SetTextColor(hdc, this.mForeColor.cref)
        SetBkColor(hdc, this.mBackColor.cref)
        return cast[LRESULT](this.mBkBrush)

    of MM_CTL_COMMAND:
        var this = cast[ListBox](refData)
        let ncode = HIWORD(wpm)
        case ncode
        of LBN_DBLCLK:
            if this.onDoubleClick != nil: this.onDoubleClick(this, newEventArgs())
        of LBN_KILLFOCUS:
            if this.onLostFocus != nil: this.onLostFocus(this, newEventArgs())
        of LBN_SELCHANGE:
            if this.onSelectionChanged != nil: this.onSelectionChanged(this, newEventArgs())
        of LBN_SETFOCUS:
            if this.onGotFocus != nil: this.onGotFocus(this, newEventArgs())
        of LBN_SELCANCEL:
            if this.onSelectionCancelled != nil: this.onSelectionCancelled(this, newEventArgs())
        else: discard

    else: return DefSubclassProc(hw, msg, wpm, lpm)
    return DefSubclassProc(hw, msg, wpm, lpm)
