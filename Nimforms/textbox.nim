# textbox module Created on 04-Apr-2023 03:44 AM; Author kcvinker
#[=================================================TextBox Docs===============================================
  Constructor - newTextBox
  Functions
        createHandle() - Create the handle of textBox

    Properties:
        All props inherited from Control type 
        textAlign     TextAlignment - {taLeft, taCenter, taRight}
        textCase      TextCase - {tcNormal, tcLowerCase, tcUpperCase}
        textType      TextType - {ttNormal, ttNumberOnly, ttPasswordChar}
        cueBanner     string
        multiLine     bool
        hideSelection bool
        readOnly      bool

    Events
        All events inherited from Control type 
        EventHandler type - proc(c: Control, e: EventArgs)
            onTextChanged
=========================================================================================================]#
# Constants
const
    ECM_FIRST = 0x1500
    ES_AUTOHSCROLL = 128
    ES_MULTILINE = 4
    ES_WANTRETURN = 4096
    ES_NOHIDESEL = 256
    ES_READONLY = 0x800
    ES_LOWERCASE = 16
    ES_UPPERCASE = 8
    ES_PASSWORD = 32
    EM_SETCUEBANNER = ECM_FIRST + 1
    EN_CHANGE = 0x0300

var tbCount = 1
# let tbClsName = toWcharPtr("Edit")
let tbClsName : array[5, uint16] = [0x45, 0x64, 0x69, 0x74, 0]


let TBSTYLE : DWORD = WS_CHILD or WS_VISIBLE or ES_LEFT or WS_TABSTOP or ES_AUTOHSCROLL or WS_MAXIMIZEBOX or WS_OVERLAPPED
let TBEXSTYLE: DWORD = WS_EX_LEFT or WS_EX_LTRREADING or WS_EX_CLIENTEDGE or WS_EX_NOPARENTNOTIFY

# Forward declaration
proc tbWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.}
proc createHandle*(this: TextBox)
# TextBox constructor
proc newTextBox*(parent: Form, text: string = "", x: int32 = 10, y: int32 = 10, w: int32 = 120, h: int32 = 27): TextBox =
    new(result)
    result.mKind = ctTextBox
    result.mClassName = cast[LPCWSTR](tbClsName[0].addr)
    result.mName = "TextBox_" & $tbCount
    result.mParent = parent
    result.mXpos = x
    result.mYpos = y
    result.mWidth = w
    result.mHeight = h
    result.mText = text
    result.mFont = parent.mFont
    result.mHasFont = true
    result.mBackColor = CLR_WHITE
    # result.mTxtFlag = DT_SINGLELINE or DT_VCENTER
    result.mForeColor = CLR_BLACK
    result.mStyle = TBSTYLE
    result.mExStyle = TBEXSTYLE
    tbCount += 1
    parent.mControls.add(result)
    if parent.mCreateChilds: result.createHandle()

proc setTBStyle(this: TextBox) =
    if this.mMultiLine: this.mStyle = this.mStyle or ES_MULTILINE or ES_WANTRETURN
    if not this.mHideSel: this.mStyle = this.mStyle or ES_NOHIDESEL
    if this.mReadOnly: this.mStyle = this.mStyle or ES_READONLY

    if this.mTextCase == tcLowerCase:
        this.mStyle = this.mStyle or ES_LOWERCASE
    elif this.mTextCase == tcUpperCase:
        this.mStyle = this.mStyle or ES_UPPERCASE

    if this.mTextType == ttNumberOnly:
        this.mStyle = this.mStyle or ES_NUMBER
    elif this.mTextType == ttPasswordChar:
        this.mStyle = this.mStyle or ES_PASSWORD

    if this.mTextAlign == taCenter:
        this.mStyle = this.mStyle or ES_CENTER
    elif this.mTextAlign == taRight:
        this.mStyle = this.mStyle or ES_RIGHT
    this.mBkBrush = CreateSolidBrush(this.mBackColor.cref)

# Create TextBox's hwnd
proc createHandle*(this: TextBox) =
    this.setTBStyle()
    this.createHandleInternal()
    if this.mHandle != nil:
        this.setSubclass(tbWndProc)
        this.setFontInternal()
        if this.mCueBanner.len > 0: this.sendMsg(EM_SETCUEBANNER, 1, toWcharPtr(this.mCueBanner))

method autoCreate(this: TextBox) = this.createHandle()
# Properties--------------------------------------------------------------------------

proc `textAlign=`*(this: TextBox, value: TextAlignment) = this.mTextAlign = value
proc textAlign*(this: TextBox): TextAlignment = this.mTextAlign

proc `textCase=`*(this: TextBox, value: TextCase) = this.mTextCase = value
proc textCase*(this: TextBox): TextCase = this.mTextCase

proc `textType=`*(this: TextBox, value: TextType) = this.mTextType = value
proc textType*(this: TextBox): TextType = this.mTextType

proc `cueBanner=`*(this: TextBox, value: string) = this.mCueBanner = value
proc cueBanner*(this: TextBox): string = this.mCueBanner

proc `multiLine=`*(this: TextBox, value: bool) = this.mMultiLine = value
proc multiLine*(this: TextBox): bool = this.mMultiLine

proc `hideSelection=`*(this: TextBox, value: bool) = this.mHideSel = value
proc hideSelection*(this: TextBox): bool = this.mHideSel

proc `readOnly=`*(this: TextBox, value: bool) = this.mReadOnly = value
proc readOnly*(this: TextBox): bool = this.mReadOnly




proc tbWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.} =
    
    case msg
    of WM_DESTROY:
        RemoveWindowSubclass(hw, tbWndProc, scID)
        var this = cast[TextBox](refData)
        this.destructor()

    of WM_LBUTTONDOWN:
        var this = cast[TextBox](refData)
        this.leftButtonDownHandler(msg, wpm, lpm)

    of WM_LBUTTONUP:
        var this = cast[TextBox](refData)
        this.leftButtonUpHandler(msg, wpm, lpm)

    of WM_RBUTTONDOWN:
        var this = cast[TextBox](refData)
        this.rightButtonDownHandler(msg, wpm, lpm)

    of WM_RBUTTONUP:
        var this = cast[TextBox](refData)
        this.rightButtonUpHandler(msg, wpm, lpm)

    of WM_MOUSEMOVE:
        var this = cast[TextBox](refData)
        this.mouseMoveHandler(msg, wpm, lpm)

    of WM_MOUSELEAVE:
        var this = cast[TextBox](refData)
        this.mouseLeaveHandler()

    of WM_KEYDOWN:
        var this = cast[TextBox](refData)
        this.keyDownHandler(wpm)

    of WM_KEYUP:
        var this = cast[TextBox](refData)
        this.keyUpHandler(wpm)

    of WM_CHAR:
        var this = cast[TextBox](refData)
        this.keyPressHandler(wpm)
        
    of WM_CONTEXTMENU:
        var this = cast[TextBox](refData)
        if this.mContextMenu != nil: this.mContextMenu.showMenu(lpm)

    of MM_EDIT_COLOR:
        var this = cast[TextBox](refData)
        if this.mDrawMode > 0:
            let hdc = cast[HDC](wpm)
            if (this.mDrawMode and 1) == 1: SetTextColor(hdc, this.mForeColor.cref)
            if (this.mDrawMode and 2) == 2: SetBkColor(hdc, this.mBackColor.cref)
        return cast[LRESULT](this.mBkBrush)

    of MM_CTL_COMMAND:
        var this = cast[TextBox](refData)
        let ncode = HIWORD(wpm)
        if ncode == EN_CHANGE:
            if this.onTextChanged != nil: this.onTextChanged(this, newEventArgs())

    else: return DefSubclassProc(hw, msg, wpm, lpm)
    return DefSubclassProc(hw, msg, wpm, lpm)
