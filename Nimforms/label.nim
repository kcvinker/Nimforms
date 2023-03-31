# label module Created on 01-Apr-2023 12:32 AM

# Constants
const
    SS_NOTIFY = 0x00000100
    SS_SUNKEN = 0x00001000
    SWP_NOMOVE = 0x0002

var lbCount = 1

# Forward declaration
proc lbWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.}

# Label constructor
proc newLabel*(parent: Form, text: string, x, y: int32 = 10, w, h: int32 = 0): Label =
    new(result)
    result.mKind = ctLabel
    result.mClassName = "Static"
    result.mName = "Label_" & $lbCount
    result.mParent = parent
    result.mXpos = x
    result.mYpos = y
    result.mWidth = w
    result.mHeight = h
    result.mText = text
    result.mFont = parent.mFont
    result.mBackColor = parent.mBackColor
    result.mForeColor = CLR_BLACK
    result.mAutoSize = true
    result.mMultiLine = false
    result.mStyle = WS_VISIBLE or WS_CHILD or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or SS_NOTIFY
    result.mExStyle = 0
    lbCount += 1


proc setLbStyle(this: Label) =
    if this.mBorder != lbNone:
        this.mStyle = (if this.mBorder == lbSunken: this.mStyle or SS_SUNKEN else: this.mStyle or WS_BORDER)
    if this.mMultiLine or this.mWidth > 0 or this.mHeight > 0: this.mAutoSize = false
    this.mBkBrush = CreateSolidBrush(this.mBackColor.cref)

proc setAutoSize(this: Label, redraw: bool) =
    var hdc: HDC = GetDC(this.mHandle)
    var ss : SIZE
    SelectObject(hdc, this.mFont.handle)
    GetTextExtentPoint32(hdc, this.mText.toWcharPtr, int32(this.mText.len), ss.unsafeAddr)
    ReleaseDC(this.mHandle, hdc)
    this.mWidth = ss.cx + 3
    this.mHeight = ss.cy
    SetWindowPos(this.mHandle, nil, this.mXpos, this.mYpos, this.mWidth, this.mHeight, SWP_NOMOVE)
    if redraw: InvalidateRect(this.mHandle, nil, 1)

# Create Label's hwnd
proc createHandle*(this: Label) =
    this.setLbStyle()
    this.createHandleInternal()
    if this.mHandle != nil:
        this.setSubclass(lbWndProc)
        this.setFontInternal()
        if this.mAutoSize: this.setAutoSize(false)


proc `autoSize=`*(this: Label, value: bool) {.inline.} = this.mAutoSize = value
proc autoSize*(this: Label): bool {.inline.} = this.mAutoSize

proc `multiLine=`*(this: Label, value: bool) {.inline.} = this.mMultiLine = value
proc multiLine*(this: Label): bool {.inline.} = this.mMultiLine

proc `textAlign=`*(this: Label, value: TextAlignment) {.inline.} = this.mTextAlign = value
proc textAlign*(this: Label): TextAlignment {.inline.} = this.mTextAlign

proc `borderStyle=`*(this: Label, value: LabelBorder) {.inline.} = this.mBorder = value
proc borderStyle*(this: Label): LabelBorder {.inline.} = this.mBorder




proc lbWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.} =
    var this = cast[Label](refData)
    case msg
    of WM_DESTROY:
        RemoveWindowSubclass(hw, lbWndProc, scID)
    of WM_LBUTTONDOWN: this.leftButtonDownHandler(msg, wpm, lpm)
    of WM_LBUTTONUP: this.leftButtonUpHandler(msg, wpm, lpm)
    of WM_RBUTTONDOWN: this.rightButtonDownHandler(msg, wpm, lpm)
    of WM_RBUTTONUP: this.rightButtonUpHandler(msg, wpm, lpm)
    of WM_MOUSEMOVE: this.mouseMoveHandler(msg, wpm, lpm)
    of WM_MOUSELEAVE: this.mouseLeaveHandler()
    of MM_LABEL_COLOR:
        let hdc = cast[HDC](wpm)
        if (this.mDrawMode and 1) == 1: SetTextColor(hdc, this.mForeColor.cref)
        SetBkColor(hdc, this.mBackColor.cref)
        return cast[LRESULT](this.mBkBrush)

    else: return DefSubclassProc(hw, msg, wpm, lpm)
    return DefSubclassProc(hw, msg, wpm, lpm)
