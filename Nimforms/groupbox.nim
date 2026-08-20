# groupbox module Created on 31-Mar-2023 11:14 PM; Author kcvinker

#[========================================GroupBox Docs====================================================
  constructor - newGroupBox*
  functions (params not shown, check the source code.)
        createHandle()  - Create the handle of GroupBox
        setFont()       - Set font for GroupBox, 2 overloads.
        setBackColor()  - Set back color for GroupBox
        setForeColor()  - Set fore color for GroupBox
        setSize()       - Set width and height of GroupBox

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
        lineColor     Color 
        style         GroupBoxStyle (enum, it determines how to draw group box)

    Events:
        All events inherited from Control type              
=========================================================================================================]#
import std/bitops

# Constants
const
    HTTRANSPARENT = -1
    HTCLIENT = 1
    GB_MEAS_TXT = 0
    GB_SET_BORDR = 1
    GB_RECR_BMP = 2
    GB_FILL_BKG = 3
    GB_DR_BORDER = 4
    GB_DRAW_TXT = 5

var gbCount = 1
let penwidth : int32 = 4

let gbStyle: DWORD = WS_CHILD or WS_VISIBLE or BS_GROUPBOX or BS_NOTIFY or BS_TOP or WS_OVERLAPPED or WS_CLIPCHILDREN or WS_CLIPSIBLINGS

# Forward declaration
proc gbWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.}
proc createGbHandle(ctl: Control)
proc newLabel*(parent: Control, text: string, x: int32 = 10, y: int32 = 10, w: int32 = 0, h: int32 = 0): Label 

proc setBorderPoints(this: GroupBox) =
    let startX : clong = this.mRect.left + 10
    let startY : clong = cast[clong](this.mTxtSize.cy div 2)
    this.mBorderPts[0] = POINT(x:startX + this.mTxtSize.cx, y: startY)
    this.mBorderPts[1] = POINT(x:this.mRect.right - 1, y: startY)
    this.mBorderPts[2] = POINT(x:this.mRect.right - 1, y: this.mRect.bottom - 1)
    this.mBorderPts[3] = POINT(x:this.mRect.left, y: this.mRect.bottom - 1)
    this.mBorderPts[4] = POINT(x:this.mRect.left, y: startY)
    this.mBorderPts[5] = POINT(x:startX - 1, y: startY)
    echo "brd pt ", this.mBorderPts[0]


# GroupBox constructor
proc newGroupBox*(parent: Control, text: string, x: int32 = 10, y: int32 = 10, 
                    w: int32 = 150, h: int32 = 150 ): GroupBox =
    new(result)
    result.mKind = ctGroupBox
    controlBaseInit(result, parent, x, y, w, h, gbCount, text)
    result.mGBStyle = GroupBoxStyle.gbsSystem  
    result.mLineColor = newColor(0xACACAC) 
    result.mCreateHwndProc = createGbHandle
    if result.mOwnerForm.mEnablePrintPoint:
        result.onMouseUp = printPointProc
    

proc addControls*(this: GroupBox, args: varargs[Control]) =
    for item in args:
        this.mControls.add(item)
        if item.mKind == ControlType.ctLabel:
            item.mBackColor = this.mBackColor


# Create GroupBox's hwnd
proc createGbHandle(ctl: Control) =
    var this = cast[GroupBox](ctl)
    this.mBkBrush = CreateSolidBrush(this.mBackColor.cref)
    if this.mForeColor.value != 0x000000 and this.mGBStyle == GroupBoxStyle.gbsSystem:
        this.mGBStyle = GroupBoxStyle.gbsClassic

    if this.mGBStyle == GroupBoxStyle.gbsOverride:
        this.mCreateDC = true
        this.mDFlag.setBits(0, 1, 2, 3, 4, 5)
        this.mPen = CreatePen(PS_SOLID, 1, this.mLineColor.cref)
    #----------------------------------------------------------------
    this.createHandleInternal(this.mWidth, this.mHeight)
    if this.mHandle != nil:
        GetClientRect(this.handle, this.mRect.unsafeAddr)
        if this.mGBStyle == GroupBoxStyle.gbsClassic:
            SetWindowTheme(this.mHandle, emptyWStrPtr, emptyWStrPtr)
            this.mThemeOff = true
        #---------------------------
        this.setSubclass(gbWndProc)
        

proc prepareCustomDraw(this: GroupBox) {.inline.} =
    this.mCreateDC = true
    this.mDFlag.setBits(0, 1, 2, 3, 4, 5)
    this.mPen = CreatePen(PS_SOLID, 1, this.mLineColor.cref)

       
# Overriding Control's property because, groupBox needs a different treatment
proc `backColor=`*(this: GroupBox, clr: uint) =
    this.mBackColor = newColor(clr)
    if this.mGBStyle == GroupBoxStyle.gbsOverride:
        this.mDFlag.setBits(GB_FILL_BKG, GB_DR_BORDER, GB_DRAW_TXT)

    this.checkRedraw()

proc setBackColor*(this: GroupBox, clr: uint, style: GroupBoxStyle) =
    this.mBackColor = newColor(clr)
    this.mBkBrush = CreateSolidBrush(this.mBackColor.cref)
    if style == GroupBoxStyle.gbsOverride:
        if this.mGBStyle == GroupBoxStyle.gbsOverride:
            this.mDFlag.setBits(GB_FILL_BKG, GB_DR_BORDER, GB_DRAW_TXT)
        else:
            this.prepareCustomDraw()

    this.mGBStyle = style
    this.checkRedraw()

proc setforeColor*(this: GroupBox, value: uint, style: GroupBoxStyle = GroupBoxStyle.gbsNone) =
    this.mForeColor = newColor(value)
    if style == GroupBoxStyle.gbsNone: this.mGBStyle = GroupBoxStyle.gbsOverride
    if this.mGBStyle == GroupBoxStyle.gbsClassic:
        if not this.mThemeOff:
            SetWindowTheme(this.mHandle, emptyWStrPtr, emptyWStrPtr)
            this.mThemeOff = true

    elif this.mGBStyle == GroupBoxStyle.gbsOverride:
        if this.mHdc == nil: 
           this.prepareCustomDraw()
        else:
            let txtRc = RECT(left:10, top:0, right: this.mTxtSize.cx, bottom: this.mTxtSize.cy)
            this.mDFlag.setBits(GB_DRAW_TXT, GB_DR_BORDER)
            InvalidateRect(this.mHandle, addr txtRc, 1)
            
    this.checkRedraw()
    #------------------------
    
proc setSize*(this: GroupBox, width, height: int32) =
    this.mWidth = width
    this.mHeight = height
    if this.mGBStyle == GroupBoxStyle.gbsOverride:
        this.mDflag.setBits(GB_SET_BORDR, GB_DR_BORDER, GB_DRAW_TXT)

    if this.mIsCreated: 
        this.mRect.bottom = this.mHeight
        this.ctlSetPos()



proc `text=`*(this: GroupBox, txt: string) =
    this.mText = txt
    this.mWtext.updateBuffer(txt)
    if this.mIsCreated: SetWindowTextW(this.mHandle, &this.mWtext)
    if this.mGBStyle == GroupBoxStyle.gbsOverride:
        this.mDflag.setBits(GB_MEAS_TXT, GB_SET_BORDR, GB_FILL_BKG, GB_DR_BORDER, GB_DRAW_TXT)

    this.checkRedraw()

proc `width=`*(this: GroupBox, value: int32) =
    this.mWidth = value
    if this.mGBStyle == GroupBoxStyle.gbsOverride:
        this.mDflag.setBits(GB_SET_BORDR, GB_DR_BORDER, GB_DRAW_TXT)

    if this.mIsCreated: 
        this.mRect.bottom = this.mHeight
        this.ctlSetPos()

proc `height=`*(this: GroupBox, value: int32) =
    this.mHeight = value
    if this.mGBStyle == GroupBoxStyle.gbsOverride:
        this.mDflag.setBits(GB_SET_BORDR, GB_DR_BORDER, GB_DRAW_TXT)

    if this.mIsCreated: 
        this.mRect.bottom = this.mHeight
        this.ctlSetPos()

proc `lineColor=`*(this: GroupBox, clr: uint) =
    this.mLineColor = newColor(clr)
    if this.mPen != nil: DeleteObject(this.mPen)
    if this.mGBStyle != GroupBoxStyle.gbsOverride:
        this.mGBStyle = GroupBoxStyle.gbsOverride
        this.prepareCustomDraw()   
    else:
        this.mPen = CreatePen(PS_SOLID, 1, this.mLineColor.cref)
        this.mDflag.setBit(GB_DR_BORDER)  
    
    this.checkRedraw()

proc lineColor*(this: GroupBox) : Color {. inline .} = return this.mLineColor


proc `font=`*(this: GroupBox, value: Font) =
    this.mFont.finalize()
    this.mFont = value 
    if this.mFont.handle == nil: this.mFont.createHandle()
    this.sendMsg(WM_SETFONT, this.mFont.handle, 1)
    if this.mGBStyle == GroupBoxStyle.gbsOverride:
        this.mDflag.setBits(GB_MEAS_TXT, GB_SET_BORDR, GB_FILL_BKG, GB_DR_BORDER, GB_DRAW_TXT)

    this.checkRedraw()

proc `style=`*(this: GroupBox, value: GroupBoxStyle) =
    this.mGBStyle = value
    if value == GroupBoxStyle.gbsClassic:
        if this.mHdc != nil: DeleteDC(this.mHdc)
        if not this.mThemeOff:
            SetWindowTheme(this.mHandle, emptyWStrPtr, emptyWStrPtr)
            this.mThemeOff = true
        #}
    #}
    if value == GroupBoxStyle.gbsOverride: this.prepareCustomDraw()
    if this.mIsCreated: InvalidateRect(this.mHandle, nil, 0)

proc setFont*(this: GroupBox, fname: string, fsize: int32, fweight: FontWeight = FontWeight.fwNormal) = 
    this.mFont.name = fname
    this.mFont.size = fsize
    this.mFont.weight = fweight
    this.mFont.createHandle()
    this.sendMsg(WM_SETFONT, this.mFont.handle, 1)
    if this.mGBStyle == GroupBoxStyle.gbsOverride:
        this.mDflag.setBits(GB_MEAS_TXT, GB_SET_BORDR, GB_FILL_BKG, GB_DR_BORDER, GB_DRAW_TXT)

    this.checkRedraw()




proc gbWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.} =
    # echo msg
    var this = cast[GroupBox](refData)
    let res = this.commonMsgHandler(hw, msg, wpm, lpm)
    if res == MsgHandlerResult.mhrCallDefProc:
        return DefSubclassProc(hw, msg, wpm, lpm)
    elif res == MsgHandlerResult.mhrReturnZero or res == MsgHandlerResult.mhrReturnOne:
        return cast[LRESULT](res)
    case msg
    of WM_NCDESTROY:
        RemoveWindowSubclass(hw, gbWndProc, scID)
        if this.mPen != nil: DeleteObject(this.mPen)
        if this.mHdc != nil:  DeleteDC(this.mHdc)
        if this.mBmp != nil: DeleteObject(this.mBmp)
        this.controlBaseDtor()

    of WM_GETTEXTLENGTH:
        if this.mGBStyle == GroupBoxStyle.gbsOverride:
            return 0
       
    of WM_NCHITTEST:
        let hit : LRESULT = DefSubclassProc(hw, msg, wpm, lpm);
        if hit == HTTRANSPARENT:
             return HTCLIENT

        return hit

    of WM_ERASEBKGND:
        let hdc = cast[HDC](wpm)
        FillRect(hdc, &this.mRect, this.mBkBrush)
        return 1 
       

    of MM_LABEL_COLOR:
        if this.mGBStyle == GroupBoxStyle.gbsClassic:
            var hdc = cast[HDC](wpm)
            SetBkMode(hdc, 1)
            # SelectObject(hdc, cast[HGDIOBJ](this.mFont.handle))
            SetTextColor(hdc, this.mForeColor.cref)        
        
        return cast[LRESULT](this.mBkBrush)

    of WM_NOTIFY:
        let nmh = cast[LPNMHDR](lpm)
        return SendMessageW(nmh.hwndFrom, MM_NOTIFY_REFLECT, wpm, lpm)

    of WM_CTLCOLOREDIT:
        let ctHwnd = cast[HWND](lpm)
        return SendMessageW(ctHwnd, MM_EDIT_COLOR, wpm, lpm)

    of WM_CTLCOLORSTATIC:
        let ctHwnd = cast[HWND](lpm)
        return SendMessageW(ctHwnd, MM_LABEL_COLOR, wpm, lpm)

    of WM_PAINT:
        if this.mGBStyle == GroupBoxStyle.gbsOverride:
            var gfx = newGraphics(hw, DCFreeMode.dfmPaint)
            if this.mCreateDC:
                this.mHdc = CreateCompatibleDC(gfx.mHdc)
                this.mCreateDC = false

            if this.mDflag.testBit(GB_MEAS_TXT):
                SelectObject(gfx.mHdc, this.mFont.handle)
                GetTextExtentPoint32(gfx.mHdc, &this.mWtext, this.mWtext.wcLen, &this.mTxtSize)
                this.mDFlag.clearBit(GB_MEAS_TXT)
            
            if this.mDflag.testBit(GB_SET_BORDR):
                this.setBorderPoints()
                this.mDFlag.clearBit(GB_SET_BORDR)
            
            if this.mDflag.testBit(GB_RECR_BMP):
                if this.mBmp != nil: DeleteObject(this.mBmp)
                this.mBmp = CreateCompatibleBitmap(gfx.mHdc, this.mWidth, this.mHeight)
                SelectObject(this.mHdc, this.mBmp)
                this.mDFlag.clearBit(GB_RECR_BMP)

            if this.mDflag.testBit(GB_FILL_BKG):
                FillRect(this.mHdc, &this.mRect, this.mBkBrush)
                this.mDFlag.clearBit(GB_FILL_BKG)
            
            if this.mDflag.testBit(GB_DR_BORDER):
                SelectObject(this.mHdc, this.mPen)
                Polyline(this.mHdc, &this.mBorderPts[0], 6)

                this.mDFlag.clearBit(GB_DR_BORDER)
            
            if this.mDflag.testBit(GB_DRAW_TXT):
                SetBkMode(this.mHdc, 1) # TRANSPARENT
                SelectObject(this.mHdc, this.mFont.handle)
                SetTextColor(this.mHdc, this.mForeColor.cref)
                TextOut(this.mHdc, 10, 0, &this.mWtext, this.mWtext.wcLen)
                this.mDFlag.clearBit(GB_DRAW_TXT)

            BitBlt(gfx.mHdc, 0, 0, this.mWidth, this.mHeight, this.mHdc, 0, 0, SRCCOPY) 
            return 1

    else: return DefSubclassProc(hw, msg, wpm, lpm)
    return DefSubclassProc(hw, msg, wpm, lpm)
