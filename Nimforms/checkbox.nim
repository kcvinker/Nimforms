# checkbox module Created on 29-Mar-2023 11:23 PM; Author kcvinker
#[============================================CheckBox Docs======================================
    Constructor - newCheckBox
    Functions:
        createHandle 
    Properties:
        All props inherited from Control type 
        checked     : bool

     Events
        EventHandler type - proc(c: Control, e: EventArgs)
            onCheckedChanged
==========================================================================================================]#

# Constants
# const

var cbCount = 1



# Forward declaration
proc cbWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.}
proc createHandle*(this: CheckBox)

# CheckBox constructor
proc newCheckBox*(parent: Form, text: string, x: int32 = 10, y: int32 = 10, w: int32 = 0, h: int32 = 0): CheckBox =
    new(result)
    result.mKind = ctCheckBox
    result.mClassName = cast[LPCWSTR](BtnClass[0].addr)
    result.mName = "CheckBox_" & $cbCount
    result.mParent = parent
    result.mXpos = x
    result.mYpos = y
    result.mWidth = w
    result.mHeight = h
    result.mText = text
    result.mWtext = newWideString(result.mText)
    # result.mFont = parent.mFont
    result.mHasFont = true
    result.mHasText = true
    result.mBackColor = parent.mBackColor
    result.cloneParentFont()
    result.mAutoSize = true
    result.mForeColor = CLR_BLACK
    result.mStyle = WS_CHILD or WS_VISIBLE or WS_TABSTOP or BS_AUTOCHECKBOX
    result.mExStyle = WS_EX_LTRREADING or WS_EX_LEFT
    result.mTextStyle = DT_SINGLELINE or DT_VCENTER
    cbCount += 1
    parent.mControls.add(result)
    if parent.mCreateChilds: result.createHandle()

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

method autoCreate(this: CheckBox) = this.createHandle()

# # Set the checked property
proc `checked=`*(this: CheckBox, value: bool) {.inline.} =
    this.mChecked = value
    if this.mIsCreated: this.sendMsg(BM_SETCHECK, int32(value), 0)

# # Get the checked property
proc checked*(this: CheckBox): bool = this.mChecked


proc cbWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.} =
    
    case msg
    of WM_DESTROY:
        RemoveWindowSubclass(hw, cbWndProc, scID)
        var this = cast[CheckBox](refData)
        this.destructor()
        
    of WM_LBUTTONDOWN:
        var this = cast[CheckBox](refData)
        this.leftButtonDownHandler(msg, wpm, lpm)
    of WM_LBUTTONUP:
        var this = cast[CheckBox](refData)
        this.leftButtonUpHandler(msg, wpm, lpm)
    of WM_RBUTTONDOWN:
        var this = cast[CheckBox](refData)
        this.rightButtonDownHandler(msg, wpm, lpm)
    of WM_RBUTTONUP:
        var this = cast[CheckBox](refData)
        this.rightButtonUpHandler(msg, wpm, lpm)
    of WM_MOUSEMOVE:
        var this = cast[CheckBox](refData)
        this.mouseMoveHandler(msg, wpm, lpm)
    of WM_MOUSELEAVE:
        var this = cast[CheckBox](refData)
        this.mouseLeaveHandler()
    of WM_CONTEXTMENU:
        var this = cast[CheckBox](refData)
        if this.mContextMenu != nil: this.mContextMenu.showMenu(lpm)

    of MM_LABEL_COLOR:
        var this = cast[CheckBox](refData)
        let hdc = cast[HDC](wpm)
        SetBkColor(hdc, this.mBackColor.cref)
        return cast[LRESULT](this.mBkBrush)

    of MM_CTL_COMMAND:
        var this = cast[CheckBox](refData)
        this.mChecked = bool(this.sendMsg(BM_GETCHECK, 0, 0))
        if this.onCheckedChanged != nil: this.onCheckedChanged(this, newEventArgs())

    of MM_NOTIFY_REFLECT:
        var this = cast[CheckBox](refData)
        let nmcd = cast[LPNMCUSTOMDRAW](lpm)
        case nmcd.dwDrawStage
        of CDDS_PREERASE: return CDRF_NOTIFYPOSTERASE
        of CDDS_PREPAINT:
            if not this.mRightAlign:
                nmcd.rc.left += 18
            else:
                nmcd.rc.right -= 18
            if (this.mDrawMode and 1) == 1: SetTextColor(nmcd.hdc, this.mForeColor.cref)
            DrawTextW(nmcd.hdc, &this.mWtext, this.mWtext.wcLen, nmcd.rc.addr, this.mTextStyle)
            return CDRF_SKIPDEFAULT
        else: discard
        return 0

    else: return DefSubclassProc(hw, msg, wpm, lpm)
    return DefSubclassProc(hw, msg, wpm, lpm)
