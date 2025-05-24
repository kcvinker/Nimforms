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
        style         GroupBoxStyle (enum, it determines how to draw group box)

    Events:
        All events inherited from Control type              
=========================================================================================================]#
# Constants
# const

var gbCount = 1
let penwidth : int32 = 4

let gbStyle: DWORD = WS_CHILD or WS_VISIBLE or BS_GROUPBOX or BS_NOTIFY or BS_TOP or WS_OVERLAPPED or WS_CLIPCHILDREN or WS_CLIPSIBLINGS

# Forward declaration
proc gbWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.}
proc createHandle*(this: GroupBox)
proc newLabel*(parent: Form, text: string, x: int32 = 10, y: int32 = 10, w: int32 = 0, h: int32 = 0): Label 
# GroupBox constructor
proc newGroupBox*(parent: Form, text: string, x: int32 = 10, y: int32 = 10, w: int32 = 150, 
                    h: int32 = 150, style: GroupBoxStyle = GroupBoxStyle.gbsSystem ): GroupBox =
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
    result.cloneParentFont()
    result.mHasFont = true
    result.mDBFill = true
    result.mGetWidth = true
    result.mBackColor = parent.mBackColor
    result.mForeColor = CLR_BLACK
    result.mStyle = gbStyle
    result.mGBStyle = style
    result.mExStyle = WS_EX_CONTROLPARENT #or WS_EX_TRANSPARENT
    gbCount += 1
    parent.mControls.add(result)
    if parent.mCreateChilds: result.createHandle()

proc addControls*(this: GroupBox, args: varargs[Control]) =
    for item in args:
        this.mControls.add(item)
        if item.mKind == ControlType.ctLabel:
            item.mBackColor = this.mBackColor

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
    if this.mGBStyle == GroupBoxStyle.gbsOverride:
        this.mPen = CreatePen(PS_SOLID, penwidth, this.mBackColor.cref)
    #----------------------------------------------------------------
    this.mRect = RECT(left: 0, top: 0, right: this.mWidth, bottom: this.mHeight)
    this.createHandleInternal()
    if this.mHandle != nil:
        if this.mGBStyle == GroupBoxStyle.gbsClassic:
            SetWindowTheme(this.mHandle, emptyWStrPtr, emptyWStrPtr)
            this.mThemeOff = true
        #---------------------------
        this.setSubclass(gbWndProc)
        this.setFontInternal()


proc resetGdiObjects(this: GroupBox, brpn: bool) =
    # brpn = Reset Hbrush and Hpen
    if brpn:
        if this.mBkBrush != nil: DeleteObject(this.mBkBrush)        
        this.mBkBrush = CreateSolidBrush(this.mBackColor.cref)
        if this.mGBStyle == GroupBoxStyle.gbsOverride:
            if this.mPen != nil: DeleteObject(this.mPen)
            this.mPen = CreatePen(PS_SOLID, penwidth, this.mBackColor.cref)
    #------------------------------------------------
    if this.mHdc != nil: DeleteDC(this.mHdc)
    if this.mBmp != nil: DeleteObject(this.mBmp)    
    this.mDBFill = true
       
# Overriding Control's property because, groupBox needs a different treatment
proc `backColor=`*(this: GroupBox, clr: uint) =
    this.mBackColor = newColor(clr)
    this.resetGdiObjects(true)
    this.checkRedraw()

proc setforeColor*(this: GroupBox, value: uint, style: GroupBoxStyle = GroupBoxStyle.gbsClassic) =
    this.mForeColor = newColor(value)
    this.mGBStyle = style
    if this.mGBStyle == GroupBoxStyle.gbsClassic:
        if not this.mThemeOff:
            SetWindowTheme(this.mHandle, emptyWStrPtr, emptyWStrPtr)
            this.mThemeOff = true
        #-----------------		
    if this.mGBStyle == GroupBoxStyle.gbsOverride:
        this.mGetWidth = true
        if this.mPen == nil: this.mPen = CreatePen(PS_SOLID, penwidth, this.mBackColor.cref)
    #------------------------
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
    if this.mFont.handle == nil: this.mFont.createHandle()
    this.sendMsg(WM_SETFONT, this.mFont.handle, 1)
    this.mGetWidth = true
    this.checkRedraw()

proc `style=`*(this: GroupBox, value: GroupBoxStyle) =
    this.mGBStyle = value
    if value == GroupBoxStyle.gbsClassic:
        if not this.mThemeOff:
            # this.mGBStyle = GroupBoxStyle.gbsClassic
            SetWindowTheme(this.mHandle, emptyWStrPtr, emptyWStrPtr)
            this.mThemeOff = true
        #--------------------------------
    #-------------------------------------
    if value == GroupBoxStyle.gbsOverride:
        this.mGetWidth = true
        if this.mPen == nil: this.mPen = CreatePen(PS_SOLID, penwidth, this.mBackColor.cref)
    #----------------------------------------------------------
    if this.mIsCreated: InvalidateRect(this.mHandle, nil, 0)

proc changeFont*(this: GroupBox, fname: string, fsize: int32, fweight: FontWeight = FontWeight.fwNormal) = 
    this.mFont.name = fname
    this.mFont.size = fsize
    this.mFont.weight = fweight
    this.mFont.createHandle()
    this.sendMsg(WM_SETFONT, this.mFont.handle, 1)
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
        if this.mHdc != nil:  DeleteDC(this.mHdc)
        if this.mBmp != nil: DeleteObject(this.mBmp)
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
        var this = cast[GroupBox](refData)
        if this.mGBStyle == GroupBoxStyle.gbsOverride:
            return 0
        # else:
        #     return DefSubclassProc(hw, msg, wpm, lpm)
    
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
       

    of MM_LABEL_COLOR:
        var this = cast[GroupBox](refData)
        if this.mGBStyle == GroupBoxStyle.gbsClassic:
            var hdc = cast[HDC](wpm)
            SetBkMode(hdc, 1)
            # SelectObject(hdc, cast[HGDIOBJ](this.mFont.handle))
            SetTextColor(hdc, this.mForeColor.cref)        
        
        return cast[LRESULT](this.mBkBrush)


    of WM_PAINT:
        var this = cast[GroupBox](refData)
        if this.mGBStyle == GroupBoxStyle.gbsOverride:
            let ret = DefSubclassProc(hw, msg, wpm, lpm)
            let gfx = newGraphics(hw)
            gfx.drawHLine(this.mPen, 10, 10, this.mTextWidth)
            gfx.drawText(this, 12, 0)
            # gfx.drawThemeText(this)

    #         return ret
        # else:
        #     var ps : PAINTSTRUCT
        #     BeginPaint(hw, ps.unsafeAddr)
        #     EndPaint(hw, ps.unsafeAddr)


    else: return DefSubclassProc(hw, msg, wpm, lpm)
    return DefSubclassProc(hw, msg, wpm, lpm)
