# Created on 17-May-2025 14:06

# Font related functions
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
    if fname.len > 32 : raise newException(OSError, "Length of font name exceeds 32 characters")
    result.name = fname
    result.size = fsize
    result.weight = fweight
    result.italics = italic
    result.underLine = underline
    result.strikeOut = strikeout
    # result.wtext = newWideString(fname)
    if autoc: result.createHandle()

proc createHandle(this: var Font) =    
    let scale = appData.scaleFactor / 100
    let fsiz = int32(scale * float(this.size))   
    let iHeight = -MulDiv(fsiz , appData.sysDPI, 72)

    var lf : LOGFONTW
    WideString.fillBuffer(lf.lfFaceName[0].addr, this.name)
    lf.lfItalic = cast[BYTE](this.italics)
    lf.lfUnderline = cast[BYTE](this.underLine)

    # for i in 0..this.wtext.mBytes:
    #     lf.lfFaceName[i] = this.wtext.mData[i]

    lf.lfHeight = iHeight
    lf.lfWeight = cast[LONG](this.weight)
    lf.lfCharSet = cast[BYTE](DEFAULT_CHARSET)
    lf.lfOutPrecision = cast[BYTE](OUT_STRING_PRECIS)
    lf.lfClipPrecision = cast[BYTE](CLIP_DEFAULT_PRECIS)
    lf.lfQuality = cast[BYTE](DEFAULT_QUALITY)
    lf.lfPitchAndFamily = 1
    this.handle = CreateFontIndirectW(lf.unsafeAddr)

proc createPrimaryHandle(this: var Font) =
    let scale = appData.scaleFactor / 100
    let fsiz = int32(scale * float(this.size))   
    let iHeight = -MulDiv(fsiz , appData.sysDPI, 72)
    WideString.fillBuffer(appData.logfont.lfFaceName[0].addr, this.name)
    appData.logfont.lfItalic = cast[BYTE](this.italics)
    appData.logfont.lfUnderline = cast[BYTE](this.underLine)
    appData.logfont.lfHeight = iHeight
    appData.logfont.lfWeight = cast[LONG](this.weight)
    appData.logfont.lfCharSet = cast[BYTE](DEFAULT_CHARSET)
    appData.logfont.lfOutPrecision = cast[BYTE](OUT_STRING_PRECIS)
    appData.logfont.lfClipPrecision = cast[BYTE](CLIP_DEFAULT_PRECIS)
    appData.logfont.lfQuality = cast[BYTE](DEFAULT_QUALITY)
    appData.logfont.lfPitchAndFamily = 1
    this.handle = CreateFontIndirectW(appData.logfont.unsafeAddr)

proc cloneParentFontHandle(this: var Font, parentHandle: HFONT) =
    if parentHandle == nil:
        this.handle = CreateFontIndirectW(appData.logfont.addr)
    else:
        var lf : LOGFONTW
        let x = GetObjectW(parentHandle, cast[int32](sizeof(lf)), cast[LPVOID](lf.addr))
        if x > 0 :
            this.handle = CreateFontIndirectW(lf.addr)

proc `=copy`*(dst: var Font, src: Font) =
    if dst.handle != nil: DeleteObject(dst.handle)
    dst.name = src.name
    dst.size = src.size
    dst.weight = src.weight
    dst.italics = src.italics
    dst.underLine = src.underLine
    dst.strikeOut = src.strikeOut
    var lf : LOGFONTW
    let x = GetObjectW(src.handle, cast[int32](sizeof(lf)), cast[LPVOID](lf.addr))
    if x > 0: dst.handle = CreateFontIndirectW(lf.addr)
    
    
        




proc finalize(this: var Font) =
    if this.handle != nil:
        # echo "Deleting my font handle"
        DeleteObject(this.handle)

# End of Font related area