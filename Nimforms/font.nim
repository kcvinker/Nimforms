# Created on 17-May-2025 14:06

# Font related functions
# import std/strformat

const
    LOGPIXELSY = 90
    DEFAULT_CHARSET = 1
    OUT_STRING_PRECIS = 1
    CLIP_DEFAULT_PRECIS = 0
    DEFAULT_QUALITY = 0

proc createHandle(this: var Font) # Foreard declaration



    

# proc updateFont*(this: var Font, src: Font) =


proc newFont*(fname: string, fsize: int32, 
                fweight: FontWeight = FontWeight.fwNormal,
                italic: bool = false, underline: bool = false, 
                strikeout: bool = false, autoc: bool = false) : Font =
    # new(result)
    if fname.len > 31 : raise newException(OSError, "Length of font name exceeds 31 characters")
    # new(result)
    result.mName = fname
    result.mSize = fsize
    result.mWeight = fweight
    result.mItalics = italic
    result.mUnderLine = underline
    result.mStrikeOut = strikeout
    result.mOwnership = FontOwner.foNone
    if autoc: 
        # echo "Primary font handle creation, ", result.mWeight
        result.createHandle()

proc createHandle(this: var Font) =  
    if this.handle != nil and this.mOwnership == FontOwner.foOwner:
        DeleteObject(this.handle) 
  
    let iHeight = MulDiv(this.mSize, cast[int32](appData.sysDPI), 72)
    # echo fmt"iheight {iHeight}, size: {this.mSize}, fsiz: {fsiz}, {appData.scaleFactor}, dpi: {appData.sysDPI}"
    var lf : LOGFONTW
    WideString.fillBuffer(lf.lfFaceName[0].addr, this.mName)
    lf.lfItalic = cast[BYTE](this.mItalics)
    lf.lfUnderline = cast[BYTE](this.mUnderLine)
    lf.lfHeight = int32(iHeight)
    lf.lfWeight = cast[LONG](this.mWeight)
    lf.lfCharSet = cast[BYTE](DEFAULT_CHARSET)
    lf.lfOutPrecision = cast[BYTE](OUT_STRING_PRECIS)
    lf.lfClipPrecision = cast[BYTE](CLIP_DEFAULT_PRECIS)
    lf.lfQuality = cast[BYTE](DEFAULT_QUALITY)
    lf.lfPitchAndFamily = 1
    this.handle = CreateFontIndirectW(lf.unsafeAddr)
    this.mOwnership = FontOwner.foOwner



proc cloneParentFontHandle(this: var Font, parentHandle: HFONT) =
    if parentHandle == nil:
        this.handle = CreateFontIndirectW(appData.logfont.addr)
    else:
        var lf : LOGFONTW
        let x = GetObjectW(parentHandle, cast[int32](sizeof(lf)), cast[LPVOID](lf.addr))
        if x > 0 :
            if this.handle != nil: DeleteObject(this.handle)
            this.handle = CreateFontIndirectW(lf.addr)

# proc `=copy`*(dst: Font, src: Font) =
#     if dst.handle != nil: DeleteObject(dst.handle)
#     dst.mName = src.mName
#     dst.mSize = src.mSize
#     dst.mWeight = src.mWeight
#     dst.mItalics = src.mItalics
#     dst.mUnderLine = src.mUnderLine
#     dst.mStrikeOut = src.mStrikeOut
#     var lf : LOGFONTW
#     let x = GetObjectW(src.handle, cast[int32](sizeof(lf)), cast[LPVOID](lf.addr))
#     if x > 0: dst.handle = CreateFontIndirectW(lf.addr)
    # echo "dst name ", dst.name

proc copyNewFont*( src: Font): Font =
    # new(result)
    result.mName = src.mName
    result.mSize = src.mSize
    result.mWeight = src.mWeight
    result.mItalics = src.mItalics
    result.mUnderLine = src.mUnderLine
    result.mStrikeOut = src.mStrikeOut
    if src.handle != nil: 
        result.handle = src.handle
        result.mOwnership = FontOwner.foUser
    
    
proc notifyParent(this: var Font) =
    if this.pHwnd == nil:
        this.handle = nil
    else:
        SendMessageW(this.pHwnd, MM_FONT_CHANGED, 0, 0)

proc name*(this: Font): string =
    result = this.mName

proc `name=`*(this: var Font, fname: string) =
    this.mName = fname
    this.notifyParent()

proc size*(this: Font): int32 =
    result = this.mSize

proc `size=`*(this: var Font, fsize: int32) =
    this.mSize = fsize
    this.notifyParent() 

proc weight*(this: Font): FontWeight =
    result = this.mWeight 

proc `weight=`*(this: var Font, fweight: FontWeight) =
    this.mWeight = fweight
    this.notifyParent()  

proc italics*(this: Font): bool =
    result = this.mItalics

proc `italics=`*(this: var Font, italic: bool) =
    this.mItalics = italic
    this.notifyParent() 

proc underline*(this: Font): bool =
    result = this.mUnderLine

proc `underline=`*(this: var Font, underline: bool) =
    this.mUnderLine = underline
    this.notifyParent()

proc printHwnd*(this: Font) =
    echo "Font hwnd: ", cast[int](this.pHwnd)


proc finalize(this: var Font) =
    if this.handle != nil and this.mOwnership == FontOwner.foOwner:        
        DeleteObject(this.handle)
        echo "Deleting font handle"

# End of Font related area

proc `=destroy`(obj: var Font) =
  echo "Destroying Font with ctl : ", obj.tag
  # Perform any custom cleanup here

proc getFontData*(obj: HWND) =
    let hFont = cast[HFONT](SendMessageW(obj, WM_GETFONT, 0, 0))
    var lf: LOGFONTW
    let bytes = GetObjectW(obj, cast[int32](sizeof(lf)), cast[LPVOID](lf.addr))
    # let fontName = wcharArrayToString(lf.lfFaceName[0].unsafeAddr)
    echo "Font name: ", cast[int](lf.lfFaceName[0]), cast[int](lf.lfFaceName[1])

