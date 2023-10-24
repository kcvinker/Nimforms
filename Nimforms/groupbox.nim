# groupbox module Created on 31-Mar-2023 11:14 PM; Author kcvinker

# GroupBox type
#   constructor - newGroupBox*(parent: Form, text: string, x, y: int32 = 10, w, h: int32 = 150): GroupBox
#   functions
        # createHandle() - Create the handle of GroupBox

#     Properties - Getter & Setter available
#       Name            Type
        # font          Font
        # text          string
        # width         int32
        # height        int32
        # xpos          int32
        # ypos          int32
        # backColor     Color
        # foreColor     Color

    # Events
    #     onMouseEnter*, onClick*, onMouseLeave*, onRightClick*, onDoubleClick*,
    #     onLostFocus*, onGotFocus*: EventHandler - proc(c: Control, e: EventArgs)

    #     onMouseWheel*, onMouseHover*, onMouseMove*, onMouseDown*, onMouseUp*
    #     onRightMouseDown*, onRightMouseUp*: MouseEventHandler - - proc(c: Control, e: MouseEventArgs)

# Constants
# const

var gbCount = 1
let gbClsName = toWcharPtr("Button")

let gbStyle: DWORD = WS_CHILD or WS_VISIBLE or BS_GROUPBOX or BS_NOTIFY or BS_TOP or WS_OVERLAPPED or WS_CLIPCHILDREN or WS_CLIPSIBLINGS

# Forward declaration
proc gbWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.}
proc createHandle*(this: GroupBox)
# GroupBox constructor
proc newGroupBox*(parent: Form, text: string, x: int32 = 10, y: int32 = 10, w: int32 = 150, h: int32 = 150, autoc : bool = false ): GroupBox =
    new(result)
    result.mKind = ctGroupBox
    result.mClassName = gbClsName
    result.mName = "GroupBox_" & $gbCount
    result.mParent = parent
    result.mXpos = x
    result.mYpos = y
    result.mWidth = w
    result.mHeight = h
    result.mText = text
    result.mFont = parent.mFont
    result.mBackColor = parent.mBackColor
    result.mForeColor = CLR_BLACK
    result.mStyle = gbStyle
    result.mExStyle = WS_EX_TRANSPARENT or WS_EX_CONTROLPARENT
    gbCount += 1
    parent.mControls.add(result)
    if autoc: result.createHandle()


proc getTextSize(this: GroupBox) =
    var hdc : HDC = GetDC(this.mHandle)
    var size : SIZE
    SelectObject(hdc, this.mFont.handle)
    GetTextExtentPoint32(hdc, this.mText.toWcharPtr, int32(this.mText.len), size.unsafeAddr)
    ReleaseDC(this.mHandle, hdc)
    this.mTextWidth = size.cx + 10

# Create GroupBox's hwnd
proc createHandle*(this: GroupBox) =
    this.mBkBrush = CreateSolidBrush(this.mBackColor.cref)
    this.mPen = CreatePen(PS_SOLID, 2, this.mBackColor.cref)
    this.mRect = RECT(left: 0, top: 10, right: this.mWidth, bottom: (this.mHeight - 2))
    this.createHandleInternal()
    if this.mHandle != nil:
        this.setSubclass(gbWndProc)
        this.setFontInternal()
        this.getTextSize()

method autoCreate(this: GroupBox) = this.createHandle()

proc gbWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.} =
    var this = cast[GroupBox](refData)
    case msg
    of WM_DESTROY:
        if this.mPen != nil: DeleteObject(this.mPen)
        this.destructor()
        RemoveWindowSubclass(hw, gbWndProc, scID)
    of WM_LBUTTONDOWN: this.leftButtonDownHandler(msg, wpm, lpm)
    of WM_LBUTTONUP: this.leftButtonUpHandler(msg, wpm, lpm)
    of WM_RBUTTONDOWN: this.rightButtonDownHandler(msg, wpm, lpm)
    of WM_RBUTTONUP: this.rightButtonUpHandler(msg, wpm, lpm)
    of WM_MOUSEMOVE: this.mouseMoveHandler(msg, wpm, lpm)
    of WM_MOUSELEAVE: this.mouseLeaveHandler()
    of WM_GETTEXTLENGTH: return 0
    of WM_CONTEXTMENU:
        if this.mContextMenu != nil: this.mContextMenu.showMenu(lpm)

    of WM_ERASEBKGND:
        if this.mDrawMode > 0:
            var rc: RECT
            GetClientRect(hw, rc.unsafeAddr)
            FillRect(cast[HDC](wpm), rc.unsafeAddr, this.mBkBrush)
            return 1

    of WM_PAINT:
        let ret = DefSubclassProc(hw, msg, wpm, lpm)
        let yp: int32 = 9
        var hdc = GetDC(hw)
        SelectObject(hdc, this.mPen)
        MoveToEx(hdc, 10, yp, nil)
        LineTo(hdc, this.mTextWidth, yp)

        SetBkMode(hdc, 1)
        SelectObject(hdc, this.mFont.handle)
        SetTextColor(hdc, this.mForeColor.cref)
        TextOut(hdc, 10, 0, this.mText.toWcharPtr, int32(this.mText.len))
        ReleaseDC(hw, hdc)
        return ret

    else: return DefSubclassProc(hw, msg, wpm, lpm)
    return DefSubclassProc(hw, msg, wpm, lpm)
