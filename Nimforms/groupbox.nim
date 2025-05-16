# groupbox module Created on 31-Mar-2023 11:14 PM; Author kcvinker

#[========================================GroupBox Docs====================================================
  constructor - newGroupBox*
  functions
        createHandle() - Create the handle of GroupBox

    Properties:
        All props inherited from Control type       
        font          Font      (See commons.nim)
        text          string
        width         int32
        height        int32
        xpos          int32
        ypos          int32
        backColor     Color     (See colors.nim)
        foreColor     Color

    Events:
        All events inherited from Control type              
=========================================================================================================]#
# Constants
# const

var gbCount = 1
# let gbClsName = toWcharPtr("Button")

let gbStyle: DWORD = WS_CHILD or WS_VISIBLE or BS_GROUPBOX or BS_NOTIFY or BS_TOP or WS_OVERLAPPED or WS_CLIPCHILDREN or WS_CLIPSIBLINGS

# Forward declaration
proc gbWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.}
proc createHandle*(this: GroupBox)
# GroupBox constructor
proc newGroupBox*(parent: Form, text: string, x: int32 = 10, y: int32 = 10, w: int32 = 150, h: int32 = 150 ): GroupBox =
    new(result)
    result.mKind = ctGroupBox
    result.mClassName = cast[LPCWSTR](BtnClass[0].addr)
    result.mName = "GroupBox_" & $gbCount
    result.mParent = parent
    result.mXpos = x
    result.mYpos = y
    result.mWidth = w
    result.mHeight = h
    result.mText = text
    result.mWtext = newWideString(text)
    result.mFont = parent.mFont
    result.mHasFont = true
    result.mDBFill = true
    result.mGetWidth = true
    result.mBackColor = parent.mBackColor
    result.mForeColor = CLR_BLACK
    result.mStyle = gbStyle
    result.mExStyle = WS_EX_CONTROLPARENT
    gbCount += 1
    parent.mControls.add(result)
    if parent.mCreateChilds: result.createHandle()


# proc doubleBufferFill(this: GroupBox) =
#     var hdc : HDC = GetDC(this.mHandle)
#     var size : SIZE
#     SelectObject(hdc, this.mFont.handle)
#     GetTextExtentPoint32(hdc, &this.mWtext, this.mWtext.wcLen, size.unsafeAddr)
#     ReleaseDC(this.mHandle, hdc)
#     this.mTextWidth = size.cx + 10

# Create GroupBox's hwnd
proc createHandle*(this: GroupBox) =
    this.mBkBrush = CreateSolidBrush(this.mBackColor.cref)
    this.mPen = CreatePen(PS_SOLID, 2, this.mBackColor.cref)
    this.mRect = RECT(left: 0, top: 0, right: this.mWidth, bottom: this.mHeight)
    this.createHandleInternal()
    if this.mHandle != nil:
        this.setSubclass(gbWndProc)
        this.setFontInternal()
        # this.doubleBufferFill()

proc resetGdiObjects(this: GroupBox, brpn: bool) =
    if brpn:
        if this.mBkBrush != nil: DeleteObject(this.mBkBrush)
        if this.mPen != nil: DeleteObject(this.mPen)
        this.mBkBrush = CreateSolidBrush(this.mBackColor.cref)
        this.mPen = CreatePen(PS_SOLID, 2, this.mBackColor.cref)
    #------------------------------------------------
    if this.mHdc != nil: DeleteDC(this.mHdc)
    if this.mBmp != nil: DeleteObject(this.mBmp)    
    this.mDBFill = true
       
# Overriding Control's property because, groupBox needs a different treatment
proc `backColor=`*(this: GroupBox, clr: uint) =
    this.mBackColor = newColor(clr)
    this.resetGdiObjects(true)
    this.checkRedraw()

proc `text=`*(this: GroupBox, txt: string) =
    this.mText = txt
    this.mWtext.updateBuffer(txt)
    this.mGetWidth = true
    if this.mIsCreated: SetWindowTextW(this.mHandle, &this.mWtext)
    this.checkRedraw()

proc `width=`*(this: GroupBox, value: int32) =
    this.mWidth = value
    this.resetGdiObjects(false)
    if this.mIsCreated: this.ctlSetPos()

proc `height=`*(this: GroupBox, value: int32) =
    this.mHeight = value
    this.resetGdiObjects(false)
    if this.mIsCreated: this.ctlSetPos()

proc `font=`*(this: GroupBox, value: Font) =
    this.mFont = value 
    this.mGetWidth = true
    this.checkRedraw()

proc changeFont*(this: GroupBox, fname: string, fsize: int32, fweight: FontWeight = FontWeight.fwNormal) =
    var fnt = newFont(fname, fsize, fweight)
    this.mFont = fnt 
    this.mGetWidth = true
    this.checkRedraw()

method autoCreate(this: GroupBox) = this.createHandle()

proc gbWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.} =
    # echo msg
    case msg
    of WM_DESTROY:
        RemoveWindowSubclass(hw, gbWndProc, scID)
        var this = cast[GroupBox](refData)
        if this.mPen != nil: DeleteObject(this.mPen)
        DeleteDC(this.mHdc)
        DeleteObject(this.mBmp)

        this.destructor()

    of WM_LBUTTONDOWN:
        var this = cast[GroupBox](refData)
        this.leftButtonDownHandler(msg, wpm, lpm)

    of WM_LBUTTONUP:
        var this = cast[GroupBox](refData)
        this.leftButtonUpHandler(msg, wpm, lpm)

    of WM_RBUTTONDOWN:
        var this = cast[GroupBox](refData)
        this.rightButtonDownHandler(msg, wpm, lpm)

    of WM_RBUTTONUP:
        var this = cast[GroupBox](refData)
        this.rightButtonUpHandler(msg, wpm, lpm)

    of WM_MOUSEMOVE:
        var this = cast[GroupBox](refData)
        this.mouseMoveHandler(msg, wpm, lpm)

    of WM_MOUSELEAVE:
        var this = cast[GroupBox](refData)
        this.mouseLeaveHandler()

    of WM_GETTEXTLENGTH:
        # var this = cast[GroupBox](refData)
        return 0
    
    of WM_CONTEXTMENU:
        var this = cast[GroupBox](refData)
        if this.mContextMenu != nil: this.mContextMenu.showMenu(lpm)

    of WM_ERASEBKGND:
        var this = cast[GroupBox](refData)
        let hdc = cast[HDC](wpm)
        if this.mGetWidth:
            var size : SIZE
            SelectObject(hdc, this.mFont.handle)
            GetTextExtentPoint32(hdc, &this.mWtext, this.mWtext.wcLen, size.unsafeAddr)
            this.mTextWidth = size.cx + 10
            this.mGetWidth = false  
        #------------------------------
        if this.mDBFill:
            this.mHdc = CreateCompatibleDC(hdc)
            this.mBmp = CreateCompatibleBitmap(hdc, this.mWidth, this.mHeight)
            SelectObject(this.mHdc, this.mBmp)
            FillRect(this.mHdc, &this.mRect, this.mBkBrush)
            this.mDBFill = false
        #------------------------------------
        BitBlt(hdc, 0, 0, this.mWidth, this.mHeight, this.mHdc, 0, 0, SRCCOPY)
        return 1

    of WM_PAINT:
        var this = cast[GroupBox](refData)
        let ret = DefSubclassProc(hw, msg, wpm, lpm)
        let gfx = newGraphics(hw)
        gfx.drawHLine(this.mPen, 10, 9, this.mTextWidth)
        gfx.drawText(this, 12, 0)
        return ret

    else: return DefSubclassProc(hw, msg, wpm, lpm)
    return DefSubclassProc(hw, msg, wpm, lpm)
