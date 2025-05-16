# Created on 14-May-2025 08:27

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
