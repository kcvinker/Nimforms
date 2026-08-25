
# button module Created on 27-Mar-2023 01:56 PM 

#[========================================Button Docs========================================
    constructor - newButton(): Button
    Properties
        All props inherited from Control type
   
   Functions
         createHandle - Create the handle of button
         setGradientColor - Set gradient back color     

    Events
        All events inherited from Control type.

======================================================================================================]#

# Constants
const DIB_RGB: uint32 =  0
import math

var btnCount = 1

# Forward declaration
proc btnWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.}
proc createBtnHandle(ctl: Control)

# Button constructor
proc newButton*(parent: Control, txt: string = "", x: int32 = 10, y: int32 = 10, 
                w: int32 = 110, h: int32 = 34, evtFn: EventHandler = nil): Button =
    new(result)
    result.mKind = ctButton
    result.mText = (if txt == "": "Button_" & $btnCount else: txt)
    controlBaseInit(result, parent, x, y, w, h, btnCount, txt)
    result.mCreateHwndProc = createBtnHandle
    if evtFn != nil: result.onClick = evtFn
    # result.mDmode = BtnDraw(kind: bdmFlat, fdraw: FlatDraw(isActive: true))



# Create button's hwnd
proc createBtnHandle(ctl: Control) =
    var this = cast[Button](ctl)
    this.createHandleInternal(this.mWidth, this.mHeight)
    if this.mHandle != nil:
        this.setSubclass(btnWndProc)
        
        


# Set necessery data for a flat colored button
proc newFlatDraw(clr: Color, tintOnHvr: bool, intensity: float) : FlatDraw =
    new(result)
    result.color = clr
    let inten = (if tintOnHvr: intensity / 10 else: intensity)
    result.defBrush = CreateSolidBrush(clr.cref)
    result.hotBrush = CreateSolidBrush(clr.shadedColorRef(tintOnHvr, inten))
    result.defPen = CreatePen(PS_SOLID, 1, clr.shadedColorRef(false, 0.8))
    result.hotPen = CreatePen(PS_SOLID, 2, clr.shadedColorRef(false, 0.5))


# Set necessery data for a gradient colored button.
proc newGradientDraw(c1, c2: uint32, toh: bool, hi: float) : GradDraw =
    new(result)
    result.stColor = newColor(c1)
    result.enColor = newColor(c2)
    result.tintOnHover = toh
    result.hoverIntensity = hi
    result.hoverStColor = result.stColor.shadedColorObj(result.tintOnHover, result.hoverIntensity)
    result.hoverEnColor = result.enColor.shadedColorObj(result.tintOnHover, result.hoverIntensity)
    
    result.bPen = CreatePen(PS_SOLID, 1, result.stColor.shadedColorRef(false, 0.8))
    result.hPen = CreatePen(PS_SOLID, 2, result.stColor.shadedColorRef(false, 0.4))
    result.dirty = false


# Overriding Control's property because, button class needs a different treatment
proc `backColor=`*(this: Button, clr: uint32) =
    this.mBackColor = newColor(clr)
    this.mFdraw = newFlatDraw(this.mBackColor, true, 0.5)
    this.mDmode = BtnDrawMode.bdmFlat
    if (this.mDrawMode and 2) != 2: this.mDrawMode += 2
    this.checkRedraw()

proc setBackColor*(this: Button, clr: uint32, hoverIntensity: float = 0.2, tintOnHover : bool = false) =
    this.mBackColor = newColor(clr)
    this.mFdraw = newFlatDraw(this.mBackColor, tintOnHover, hoverIntensity)
    this.mDmode = BtnDrawMode.bdmFlat
    if (this.mDrawMode and 2) != 2: this.mDrawMode += 2
    this.checkRedraw()

proc lerp8(a, b: uint8, t: float32): uint8 {. inline .} =
    let math = a.float32 + (b.float32 - a.float32)
    let mulT = math * t
    let mathres = a.float32 + (b.float32 - a.float32) * t

    # echo "math: ", math
    # echo "*t: ", mulT
    # echo "result: ", mathres
    # echo "round: ", round(mathres)

    return round(mathres).uint8


proc buildGradientBitmap(c1, c2: Color, width, height: int32): HBITMAP =
    if width <= 0 or height <= 0: return nil
    var bmi: BITMAPINFO
    bmi.bmiHeader.biSize = cast[DWORD](sizeof(bmi))
    bmi.bmiHeader.biWidth = width
    bmi.bmiHeader.biHeight = -height; # top-down DIB
    bmi.bmiHeader.biPlanes = 1
    bmi.bmiHeader.biBitCount = 32
    bmi.bmiHeader.biCompression = 0 #BI_RGB

    var bits: ptr uint32 = nil
    var hbm = CreateDIBSection(nil, addr bmi, DIB_RGB, cast[ptr pointer](addr bits), nil, 0)
    if (hbm == nil) or (bits == nil):
        print("nil hbitmap");
        return nil

    let srdiff = c2.red - c1.red
    # let sgdiff = c2.green - c1.green
    # let sbdiff = c2.blue - c1.blue
    # echo "c1 red ", c1.red, ", c2 red ", c2.red, ", r diff ", srdiff
    let uncheckedBits = cast[ptr UncheckedArray[uint32]](bits)

    # Fill pixels: DIB is 0xAARRGGBB, but we set alpha = 0
    for y in 0 ..< height: 
        let t = y.float32 / (if height > 1: (height - 1).float32 else: 1.0)

        let r = lerp8(c1.red, c2.red, t)
        let g = lerp8(c1.green, c2.green, t)
        let b = lerp8(c1.blue, c2.blue, t)

        
        let color = (r.uint32 shl 16) or (g.uint32 shl 8) or b.uint32
        # echo "clr ", color
        let rowIndex = y * width
        for x in 0 ..< width:
            uncheckedBits[rowIndex + x] = color

    return hbm

proc updateBitmaps(this: Button) =
    if this.mDmode != BtnDrawMode.bdmGradient: return
    var grad = this.mGdraw
    let width = this.mWidth
    let height = this.mHeight
    if grad.dirty:
        if grad.defBmp != nil: DeleteObject(grad.defBmp)
        if grad.hotBmp != nil: DeleteObject(grad.hotBmp)
        grad.defBmp = buildGradientBitmap(grad.stColor, grad.enColor, width, height)
        if grad.tintOnHover:
            grad.hotBmp = buildGradientBitmap(grad.hoverStColor, grad.hoverEnColor, width, height)
        else:
            grad.hotBmp = buildGradientBitmap(grad.hoverStColor, grad.hoverEnColor, width, height)

        grad.dirty = false


# Set gradient colors for this button.
proc setGradientColor*(this: Button, clr1, clr2: uint32, 
                        hoverIntensity: float32 = 0.5, tintOnHover: bool = false) =
    this.mGdraw = newGradientDraw(clr1, clr2, tintOnHover, hoverIntensity)
    this.mDmode = BtnDrawMode.bdmGradient
    let w = this.mWidth
    let h = this.mHeight
    this.mGdraw.defBmp = buildGradientBitmap(this.mGdraw.stColor, this.mGdraw.enColor, w, h)
    this.mGdraw.hotBmp = buildGradientBitmap(this.mGdraw.hoverStColor, this.mGdraw.hoverEnColor, w, h)
    if (this.mDrawMode and 4) != 4: this.mDrawMode += 4
    this.checkRedraw()
    


# Helper function for drawing a flat color button.
proc paintFlatBtnRoundRect(nmcd: LPNMCUSTOMDRAW, hbr: HBRUSH, pen: HPEN, hot: bool = false): LRESULT =
    SelectObject(nmcd.hdc, pen)
    SelectObject(nmcd.hdc, hbr)
    if hot: InflateRect(&nmcd.rc, -1, -1)
    
    RoundRect(nmcd.hdc, nmcd.rc.left, nmcd.rc.top, nmcd.rc.right, nmcd.rc.bottom, 5, 5);
    result = CDRF_NOTIFYPOSTPAINT


# Helper function for drawing text on a button.
proc drawTextColor(this: Button, ncd: LPNMCUSTOMDRAW): LRESULT =
    SetTextColor(ncd.hdc, this.mForeColor.cref)
    SetBkMode(ncd.hdc, 1)
    DrawTextW(ncd.hdc, &this.mWtext, this.mWtext.wcLen, ncd.rc.unsafeAddr, this.mTxtFlag )
    return CDRF_NOTIFYPOSTPAINT


# Helper function dealing wm_notify message in a button's wndproc.
proc drawBackColor(this: Button, ncd: LPNMCUSTOMDRAW): LRESULT =
    case ncd.dwDrawStage
    # of CDDS_PREERASE: # This happens when the paint starts
    #     return CDRF_NOTIFYPOSTERASE # Telling the program to inform us after erase
    of CDDS_PREPAINT: # We get the notification after erase happened.
        if (ncd.uItemState and MOUSECLICKFLAG) == MOUSECLICKFLAG:
            return paintFlatBtnRoundRect(ncd, this.mFDraw.defBrush, this.mFDraw.defPen, true)
        elif (ncd.uItemState and MOUSEOVERFLAG) == MOUSEOVERFLAG:
           return paintFlatBtnRoundRect(ncd, this.mFDraw.hotBrush, this.mFDraw.hotPen, true)
        else:
            return paintFlatBtnRoundRect(ncd, this.mFDraw.defBrush, this.mFDraw.defPen)
    else: discard
    return CDRF_DODEFAULT


# Helper function for drawing a gradient color button.
proc paintGradientRound(this: Button, nmcd: LPNMCUSTOMDRAW, hbmp: HBITMAP): LRESULT =
    var gd: GradDraw = this.mGdraw
    let border : int32 = 1
    let rf : int32 = 6
    let inset_rc = RECT(left: nmcd.rc.left + border,
                        top: nmcd.rc.top + border,
                        right: nmcd.rc.right - border,
                        bottom: nmcd.rc.bottom - border,
    )
    let width : int32 = inset_rc.right - inset_rc.left
    let height : int32 = inset_rc.bottom - inset_rc.top
    if gd.dirty == true: this.updateBitmaps()
    if gd.clipRgn == nil:
        gd.clipRgn = CreateRoundRectRgn(inset_rc.left, inset_rc.top, 
                                        inset_rc.right + 1, inset_rc.bottom + 1,
                                        3, 3);

    SelectClipRgn(nmcd.hdc, gd.clipRgn)
    defer : SelectClipRgn(nmcd.hdc, nil) # reset clip when done
    if hbmp != nil:
        if gd.memDC == nil: gd.memDC = CreateCompatibleDC(nmcd.hdc)
        let old : HGDIOBJ = SelectObject(gd.memDC, hbmp)
        BitBlt(nmcd.hdc, inset_rc.left, inset_rc.top, width, height, gd.memDC, 0, 0, SRCCOPY)
        SelectObject(gd.memDC, old)
        SelectClipRgn(nmcd.hdc, nil)
        
        let old_pen : HGDIOBJ = SelectObject(nmcd.hdc, gd.bPen)
        let old_brush : HGDIOBJ = SelectObject(nmcd.hdc, GetStockObject(5)); # NULL_BRUSH

        RoundRect(nmcd.hdc, nmcd.rc.left, nmcd.rc.top, nmcd.rc.right, nmcd.rc.bottom, rf, rf)
        SelectObject(nmcd.hdc, old_brush)
        SelectObject(nmcd.hdc, old_pen)
    else:
        echo "hbm is nil"

    result = CDRF_DODEFAULT


# Helper function dealing wm_notify message in a button's wndproc.
proc drawGradientBackColor(this: Button, ncd: LPNMCUSTOMDRAW): LRESULT =
    case ncd.dwDrawStage
    # of CDDS_PREERASE: return  CDRF_NOTIFYPOSTERASE
    of CDDS_PREPAINT:
        if (ncd.uItemState and MOUSECLICKFLAG) == MOUSECLICKFLAG:
            return paintGradientRound(this, ncd, this.mGdraw.defBmp)
        elif (ncd.uItemState and MOUSEOVERFLAG) == MOUSEOVERFLAG:
            return paintGradientRound(this, ncd, this.mGdraw.hotBmp)
        else:
            return paintGradientRound(this, ncd, this.mGdraw.defBmp)
    else: discard


proc flatDrawFinalize(this: FlatDraw) =
    if this.defBrush != nil: DeleteObject(this.defBrush)
    if this.hotBrush != nil: DeleteObject(this.hotBrush)
    if this.defBrush != nil: DeleteObject(this.defPen)
    if this.hotBrush != nil: DeleteObject(this.hotPen)
    # echo "flat draw finished"


proc gradDrowFinalize(this: GradDraw) =
    if this.defBmp != nil: DeleteObject(this.defBmp)
    if this.hotBmp != nil: DeleteObject(this.hotBmp)
    if this.bPen != nil: DeleteObject(this.bPen)
    if this.hPen != nil: DeleteObject(this.hPen)
    if this.clipRgn != nil: DeleteObject(this.clipRgn)
    if this.memDC != nil: DeleteDC(this.memDC)
    # echo "grad draw finished"


# Deleting certain resources for this button.
proc btnDtor(this: Button) =
    if this.mDmode == BtnDrawMode.bdmFlat:
        this.mFdraw.flatDrawFinalize()
    
    if this.mDmode == BtnDrawMode.bdmGradient:
        this.mGdraw.gradDrowFinalize() 

    controlBaseDtor(this)



proc btnWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, 
                        scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.} =  
                        
    var this = cast[Button](refData)
    let res = this.commonMsgHandler(hw, msg, wpm, lpm)
    if res == MsgHandlerResult.mhrCallDefProc:
        return DefSubclassProc(hw, msg, wpm, lpm)
    elif res == MsgHandlerResult.mhrReturnZero or res == MsgHandlerResult.mhrReturnOne:
        return cast[LRESULT](res)
    case msg
    of WM_NCDESTROY:
        RemoveWindowSubclass(hw, btnWndProc, scID)
        this.btnDtor()        

    of MM_NOTIFY_REFLECT:
        var ret : LRESULT= CDRF_DODEFAULT
        if this.mDrawMode > 0:
            var nmcd = cast[LPNMCUSTOMDRAW](lpm)
            case this.mDrawMode
            of 1: ret = this.drawTextColor(nmcd) # ForeColor only
            of 2: ret = this.drawBackColor(nmcd) # BackColor only
            of 3:
                discard this.drawBackColor(nmcd) # Back & Fore colors
                ret = this.drawTextColor(nmcd)
            of 4: ret = this.drawGradientBackColor(nmcd) # Gradient only
            of 5: #------------------------------------------------Gradient & fore colors
                discard this.drawGradientBackColor(nmcd)
                ret = this.drawTextColor(nmcd)
            else: discard
        return ret

    else: return DefSubclassProc(hw, msg, wpm, lpm)
    return DefSubclassProc(hw, msg, wpm, lpm)

