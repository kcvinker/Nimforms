# Created on 14-May-2025 08:27

const 
    DTT_TEXTCOLOR = 0x1
    BP_GROUPBOX = 0x4
    GBS_NORMAL = 0x1

proc newGraphics(hw: HWND): Graphics =
    result.mHwnd = hw 
    result.mHdc = GetDC(hw)
    result.mFree = true 

proc newGraphics(wp: WPARAM): Graphics = 
    result.mHdc = cast[HDC](wp)
    result.mFree = false 

proc `=destroy`(this: var Graphics)=
    if this.mFree:
        ReleaseDC(this.mHwnd, this.mHdc)
        # echo "HDC Released"

proc getTextSize(g: typedesc[Graphics], pc: Control): SIZE =
    var dc = GetDC(pc.mHandle)    
    SelectObject(dc, pc.mFont.handle)
    GetTextExtentPoint32(dc, &pc.mWtext, pc.mWtext.mInputLen, result.unsafeAddr)
    let x = ReleaseDC(pc.mHandle, dc)
    # print "HDC released for "; pc.name

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
