# Created on 14-May-2025 08:27

const 
    DTT_TEXTCOLOR = 0x1
    BP_GROUPBOX = 0x4
    GBS_NORMAL = 0x1

proc newGraphics(hw: HWND, dcMode: DCFreeMode): Graphics =
    result.mHwnd = hw 
    result.mFreeMode = dcMode
    if dcMode == DCFreeMode.dfmRelease:
        result.mHdc = GetDC(hw)
    elif dcMode == DCFreeMode.dfmPaint:
        result.mHdc = BeginPaint(hw, result.mPS.addr)
        result.mDcNum = SaveDC(result.mHdc)

    result.mFree = true 

proc newGraphics(wp: WPARAM): Graphics = 
    result.mHdc = cast[HDC](wp)
    result.mFree = false 

proc `=destroy`(this: var Graphics)=
    if this.mFreeMode == DCFreeMode.dfmRelease:
        ReleaseDC(this.mHwnd, this.mHdc)
    elif this.mFreeMode == DCFreeMode.dfmPaint:
        RestoreDC(this.mHwnd, this.mDcNum)
        EndPaint(this.mHwnd, this.mPS.addr)

proc getTextSize(g: typedesc[Graphics], pc: Control): SIZE =
    var dc = GetDC(pc.mHandle)    
    SelectObject(dc, pc.mFont.handle)
    GetTextExtentPoint32(dc, &pc.mWtext, pc.mWtext.mInputLen, result.unsafeAddr)
    let x = ReleaseDC(pc.mHandle, dc)
    # print "HDC released for "; pc.name

proc getTextSize2(this: Graphics, pc: Control, sz: var SIZE) =   
    SelectObject(this.mHdc, pc.mFont.handle)
    GetTextExtentPoint32(this.mHdc, &pc.mWtext, pc.mWtext.mInputLen, addr sz)
    

proc drawHLine(this: Graphics, mPen: HPEN, sx, y, ex : int32) =
    SelectObject(this.mHdc, mPen)
    MoveToEx(this.mHdc, sx, y, nil)
    LineTo(this.mHdc, ex, y)

proc drawText(this: Graphics, pc: Control, x, y: int32) =
    SetBkMode(this.mHdc, 1)
    SelectObject(this.mHdc, pc.mFont.handle)
    SetTextColor(this.mHdc, pc.mForeColor.cref)
    TextOut(this.mHdc, x, y, pc.mWtext.cptr, pc.mWtext.wcLen)

proc drawThemeText(this: Graphics, pc: Control) =
    var hTheme = OpenThemeData(pc.mHandle, pc.mClassName)
    if hTheme != nil:
        # // Use themed text with custom color
        var opts : DTTOPTS 
        opts.dwSize = cast[int32](sizeof(opts))
        opts.dwFlags = DTT_TEXTCOLOR
        opts.crText = pc.mForeColor.cref #RGB(255, 0, 0)  // Red text

        var rc : RECT
        GetClientRect(pc.mHandle, rc.unsafeAddr)
        rc.left += 9 # // Offset to align text
        rc.top += 1

        DrawThemeTextEx(
            hTheme, this.mHdc, BP_GROUPBOX, GBS_NORMAL, pc.mWtext.cptr,
            pc.mWtext.wcLen, DT_LEFT or DT_SINGLELINE, rc.unsafeAddr, opts.unsafeAddr
        )
        CloseThemeData(hTheme)
        echo "draw theme text"
