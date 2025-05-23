# color module. Created on 26-Mar-2023 06:56 PM
# This module implements all functions related to colors

proc newColor(clr: uint): Color =
    result.value = clr
    result.red = clr shr 16
    result.green = (clr and 0x00ff00) shr 8
    result.blue = clr and 0x0000ff
    result.cref = cast[COLORREF]((result.blue shl 16) or (result.green shl 8) or result.red)

proc clip(value: auto): auto {.inline.} = clamp(value, 0, 255)

proc isDark(this: Color): bool {.inline.} =
    let x : float = (float(this.red) * 0.2126) +
                    (float(this.green) * 0.7152) +
                    (float(this.blue) * 0.0722)
    result = x < 40

proc getChangedColorRef(this: Color, adj: float): COLORREF =
    let red = clip(uint(float(this.red) * adj))
    let green = clip(uint(float(this.green) * adj))
    let blue = clip(uint(float(this.blue) * adj))
    result = cast[COLORREF]((blue shl 16) or (green shl 8) or red)

proc getChangedColor(this: Color, adj: float): Color =
    result.red = clip(uint(float(this.red) * adj))
    result.green = clip(uint(float(this.green) * adj))
    result.blue = clip(uint(float(this.blue) * adj))
    result.cref = cast[COLORREF]((result.blue shl 16) or (result.green shl 8) or result.red)

proc makeHBRUSH(this: Color): HBRUSH = CreateSolidBrush(this.cref)

proc clrRefFromRGB(red, green, blue: uint): COLORREF = cast[COLORREF]((blue shl 16) or (green shl 8) or red)

proc makeCREF(r, g, b: float): COLORREF = 
    cast[COLORREF]((uint(b) shl 16) or (uint(g) shl 8) or uint(r))
    

proc getHotBrush(this: Color, adj: float): HBRUSH =
    let clrRef = this.getChangedColorRef(adj)
    result = CreateSolidBrush(clrRef)

type
    FlotColor = object
        red, green, blue: float

proc newFlotColor(clr: Color): FlotColor =
    result.red = float(clr.red)
    result.green = float(clr.green)
    result.blue = float(clr.blue)

proc createGradientBrush( this: var GradDraw, dc: HDC, rc: RECT, dmode: GdrawMode) =
    var gc : GradColor
    var isDef : bool = true
    if dmode == gmDefault or dmode == gmClicked:
        gc = this.gcDef 
    else:        
        gc = this.gcHot  
        isDef = false       
    
    let isRtL: bool = false
    var memHDC: HDC = CreateCompatibleDC(dc)
    var hBmp: HBITMAP = CreateCompatibleBitmap(dc, rc.right, rc.bottom)
    let loopEnd: int32 = (if isRtL: rc.right else: rc.bottom)
    let flEnd = float(loopEnd)
    let c1 = newFlotColor(gc.c1)
    let c2 = newFlotColor(gc.c2)
    SelectObject(memHDC, hBmp)
    for i in 0..<loopEnd:
        var tRct: RECT
        var r, g, b: float
        r = c1.red + float(i) * (c2.red - c1.red) / flEnd
        g = c1.green + float(i) * (c2.green - c1.green) / flEnd
        b = c1.blue + float(i) * (c2.blue - c1.blue) / flEnd
        var tBrush: HBRUSH = CreateSolidBrush(makeCREF(r, g, b))
        tRct.left = (if isRtL: i else: 0)
        tRct.top =  (if isRtL: 0 else: i )
        tRct.right = (if isRtL: i + 1 else: rc.right)
        tRct.bottom = (if isRtL: int32(loopEnd) else: int32(i + 1))
        FillRect(memHDC, tRct.unsafeAddr, tBrush)
        DeleteObject(tBrush)

    if isDef:
        this.defBrush =  CreatePatternBrush(hBmp)
    else:
        this.hotBrush =  CreatePatternBrush(hBmp)

    DeleteObject(hBmp)
    DeleteDC(memHDC)

