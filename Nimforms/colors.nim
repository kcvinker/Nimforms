# color module. Created on 26-Mar-2023 06:56 PM
# This module implements all functions related to colors

proc newColor(clr: uint32): Color =
    result.value = clr
    result.red = (clr shr 16).uint8
    result.green = ((clr and 0x00ff00) shr 8).uint8
    result.blue = (clr and 0x0000ff).uint8
    result.cref = cast[COLORREF]((result.blue.uint32 shl 16) or (result.green.uint32 shl 8) or result.red.uint32)

proc newColor(r, g, b: float) : Color =
    result.red = r.uint8
    result.green = g.uint8
    result.blue = b.uint8
    result.value = (result.red.uint32 shl 16) or (result.green.uint32 shl 8) or result.blue.uint32
    result.cref = cast[COLORREF]((result.blue.uint32 shl 16) or (result.green.uint32 shl 8) or result.red.uint32)

proc clip(value: auto): auto {.inline.} = clamp(value, 0, 255)

proc isDark(this: Color): bool {.inline.} =
    let x : float = (float(this.red) * 0.2126) +
                    (float(this.green) * 0.7152) +
                    (float(this.blue) * 0.0722)
    result = x < 40

proc getChangedColorRef(this: Color, adj: float32): COLORREF =
    let red = clip(uint32(float(this.red) * adj))
    let green = clip(uint32(float(this.green) * adj))
    let blue = clip(uint32(float(this.blue) * adj))
    result = cast[COLORREF]((blue shl 16) or (green shl 8) or red)



proc shadedColorParts(this: Color, isTint: bool, adj: float32) : tuple[r, g, b: float] =
    var 
        r, g, b: float32

    r = this.red.float32
    g = this.green.float32
    b = this.blue.float32
    if isTint:
        r = r + (255 - r) * adj
        g = g + (255 - g) * adj
        b = b + (255 - b) * adj
    else:
        r = r * (1 - adj)
        g = g * (1 - adj)
        b = b * (1 - adj)

    (r, g, b)
    
proc shadedColorRef(this: Color, isTint: bool, adj: float32): COLORREF =
    let res = shadedColorParts(this, isTint, adj)
    result = cast[COLORREF]((res.b.uint32 shl 16) or (res.g.uint32 shl 8) or res.r.uint32)

proc shadedColorObj(this: Color, isTint: bool, adj: float32): Color =
    let res = shadedColorParts(this, isTint, adj)
    return newColor(res.r, res.g, res.b)


proc getChangedColor(this: Color, adj: float32): Color =
    result.red = clip(uint8(float(this.red) * adj))
    result.green = clip(uint8(float(this.green) * adj))
    result.blue = clip(uint8(float(this.blue) * adj))
    result.cref = cast[COLORREF]((result.blue shl 16) or (result.green shl 8) or result.red)

proc makeHBRUSH(this: Color): HBRUSH = CreateSolidBrush(this.cref)

proc clrRefFromRGB(red, green, blue: uint32): COLORREF = cast[COLORREF]((blue shl 16) or (green shl 8) or red)

proc makeCREF(r, g, b: float): COLORREF = 
    cast[COLORREF]((uint32(b) shl 16) or (uint32(g) shl 8) or uint32(r))

proc makeCREF(hexValue: int32): COLORREF = 
    let red = hexValue shr 16
    let green = (hexValue and 0x00ff00) shr 8
    let blue = hexValue and 0x0000ff
    result = cast[COLORREF]((blue shl 16) or (green shl 8) or red)
    
    

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

# proc createGradientBrush( this: var GradDraw, dc: HDC, rc: RECT, dmode: GdrawMode) =
#     var gc : GradColor
#     var isDef : bool = true
#     if dmode == gmDefault or dmode == gmClicked:
#         gc = this.gcDef 
#     else:        
#         gc = this.gcHot  
#         isDef = false       
    
#     let isRtL: bool = false
#     var memHDC: HDC = CreateCompatibleDC(dc)
#     var hBmp: HBITMAP = CreateCompatibleBitmap(dc, rc.right, rc.bottom)
#     let loopEnd: int32 = (if isRtL: rc.right else: rc.bottom)
#     let flEnd = float(loopEnd)
#     let c1 = newFlotColor(gc.c1)
#     let c2 = newFlotColor(gc.c2)
#     SelectObject(memHDC, hBmp)
#     for i in 0..<loopEnd:
#         var tRct: RECT
#         var r, g, b: float
#         r = c1.red + float(i) * (c2.red - c1.red) / flEnd
#         g = c1.green + float(i) * (c2.green - c1.green) / flEnd
#         b = c1.blue + float(i) * (c2.blue - c1.blue) / flEnd
#         var tBrush: HBRUSH = CreateSolidBrush(makeCREF(r, g, b))
#         tRct.left = (if isRtL: i else: 0)
#         tRct.top =  (if isRtL: 0 else: i )
#         tRct.right = (if isRtL: i + 1 else: rc.right)
#         tRct.bottom = (if isRtL: int32(loopEnd) else: int32(i + 1))
#         FillRect(memHDC, tRct.unsafeAddr, tBrush)
#         DeleteObject(tBrush)

#     if isDef:
#         this.defBrush =  CreatePatternBrush(hBmp)
#     else:
#         this.hotBrush =  CreatePatternBrush(hBmp)

#     DeleteObject(hBmp)
#     DeleteDC(memHDC)

