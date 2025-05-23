# label module Created on 01-Apr-2023 12:32 AM; Author kcvinker
#[==========================================Label Docs==========================================
    Constructor - newLabel
    Functions
        createHandle() - Create the handle of Label

    Properties:
        All props inherited from Control type       
        autoSize      bool
        multiLine     bool
        textAlign     TextAlignment - Enum (See typemodule.nim)
        borderStyle   LabelBorder - Enum (See typemodule.nim)

    Events
        All events inherited from Control type 
================================================================================================]#
# Constants
const
    SS_NOTIFY = 0x00000100
    SS_SUNKEN = 0x00001000
    SWP_NOMOVE = 0x0002
    SIZE_FLAG = SWP_NOMOVE #or SWP_NOZORDER #or SWP_NOACTIVATE
var lbCount = 1
# let lbClsName = toWcharPtr("Static")
let lbClsName : array[7, uint16] = [0x53, 0x74, 0x61, 0x74, 0x69, 0x63, 0]


# Forward declaration
proc lbWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.}
proc createHandle*(this: Label)
# Label constructor
proc newLabel*(parent: Form, text: string, x: int32 = 10, y: int32 = 10, w: int32 = 0, h: int32 = 0): Label =
    new(result)
    result.mKind = ctLabel
    result.mClassName = cast[LPCWSTR](lbClsName[0].addr)
    result.mName = "Label_" & $lbCount
    result.mParent = parent
    result.mXpos = x
    result.mYpos = y
    result.mWidth = w
    result.mHeight = h
    result.mText = text
    # result.mFont = parent.mFont
    result.cloneParentFont()
    result.mHasFont = true
    result.mBackColor = parent.mBackColor
    result.mForeColor = CLR_BLACK
    result.mAutoSize = true
    result.mMultiLine = false
    result.mStyle = WS_VISIBLE or WS_CHILD or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or SS_NOTIFY
    result.mExStyle = 0
    lbCount += 1
    parent.mControls.add(result)
    if parent.mCreateChilds: createHandle(result)


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
    this.mWidth = ss.cx #+ 5
    this.mHeight = ss.cy
    SetWindowPos(this.mHandle, nil, this.mXpos, this.mYpos, this.mWidth, this.mHeight, SIZE_FLAG) #SWP_NOMOVE)
    if redraw: InvalidateRect(this.mHandle, nil, 1)
    # echo "After autosize x : ", this.mXpos, ", y: ", this.mYpos #this.mXpos, this.mYpos
    

# Create Label's hwnd
proc createHandle*(this: Label) =
    this.setLbStyle()
    this.createHandleInternal()
    if this.mHandle != nil:
        echo "lb mh"
        this.setSubclass(lbWndProc)
        this.setFontInternal()
        if this.mAutoSize: this.setAutoSize(false)
        echo "lbl hwnd ", cast[int](this.mHandle)

method autoCreate(this: Label) = this.createHandle()

proc `autoSize=`*(this: Label, value: bool) {.inline.} = this.mAutoSize = value
proc autoSize*(this: Label): bool {.inline.} = this.mAutoSize

proc `multiLine=`*(this: Label, value: bool) {.inline.} = this.mMultiLine = value
proc multiLine*(this: Label): bool {.inline.} = this.mMultiLine

proc `textAlign=`*(this: Label, value: TextAlignment) {.inline.} = this.mTextAlign = value
proc textAlign*(this: Label): TextAlignment {.inline.} = this.mTextAlign

proc `borderStyle=`*(this: Label, value: LabelBorder) {.inline.} = this.mBorder = value
proc borderStyle*(this: Label): LabelBorder {.inline.} = this.mBorder




proc lbWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.} =
    
    case msg
    of WM_DESTROY:
        RemoveWindowSubclass(hw, lbWndProc, scID)
        var this = cast[Label](refData)
        this.destructor()

    of WM_LBUTTONDOWN:
        var this = cast[Label](refData)
        this.leftButtonDownHandler(msg, wpm, lpm)
    of WM_LBUTTONUP:
        var this = cast[Label](refData)
        this.leftButtonUpHandler(msg, wpm, lpm)
    of WM_RBUTTONDOWN:
        var this = cast[Label](refData)
        this.rightButtonDownHandler(msg, wpm, lpm)
    of WM_RBUTTONUP:
        var this = cast[Label](refData)
        this.rightButtonUpHandler(msg, wpm, lpm)
    of WM_MOUSEMOVE:
        var this = cast[Label](refData)
        this.mouseMoveHandler(msg, wpm, lpm)
    of WM_MOUSELEAVE:
        var this = cast[Label](refData)
        this.mouseLeaveHandler()
    of WM_CONTEXTMENU:
        var this = cast[Label](refData)
        if this.mContextMenu != nil: this.mContextMenu.showMenu(lpm)

    of MM_LABEL_COLOR:
        var this = cast[Label](refData)
        echo "MMLABEL Color"
        this.printControlRect()
        let hdc = cast[HDC](wpm)
        if (this.mDrawMode and 1) == 1: SetTextColor(hdc, this.mForeColor.cref)
        SetBkColor(hdc, this.mBackColor.cref)
        return cast[LRESULT](this.mBkBrush)

    else: return DefSubclassProc(hw, msg, wpm, lpm)
    return DefSubclassProc(hw, msg, wpm, lpm)
