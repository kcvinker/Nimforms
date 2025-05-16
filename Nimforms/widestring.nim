# Created on 13-May-2025 14:35


converter wptr(this: WideString): LPWSTR {.inline.} =
    result = this.mData[0].addr

converter cptr(this: WideString): LPCWSTR {.inline.} =
    result = this.mData[0].addr

template `&`(this: WideString): ptr WCHAR = this.mData[0].addr
    
proc strLen(this: WideString): int32 {.inline.} = this.mInputLen
proc wcLen(this: WideString): int32 {.inline.} = this.mWcLen

# proc toWstrPtr(txt: string): LPWSTR =
#     let inpstr = txt.cstring
#     let slen = MultiByteToWideChar(CP_UTF8, 0, inpstr[0].addr, len(txt), nil, 0)
#     let bytes = (slen + 1) * 2         
#     var wptr = cast[WArrayPtr](alloc0(bytes))
#     let x = MultiByteToWideChar(CP_UTF8, 0, inpstr[0].addr, len(txt), wptr[0].addr, slen)
#     result = cast[LPWSTR](wptr)

proc updateBuffer(this: var WideString, txt: string) =
    this.mInputStr = txt.cstring
    let slen = MultiByteToWideChar(CP_UTF8, 0, this.mInputStr[0].addr, int32(len(txt)), nil, 0)
    if slen > 0:
        if slen > this.mWcLen:
            dealloc(this.mData)
            this.mBytes = (slen + 1) * 2
            this.mData = cast[WArrayPtr](alloc0(this.mBytes))

        let x = MultiByteToWideChar(CP_UTF8, 0, this.mInputStr[0].addr, int32(len(txt)), &this, slen)
        this.mWcLen = slen
        this.mData[slen] = cast[WCHAR](0)


proc fillWstring(buffer: LPWSTR, txt: string) =
    let inpstr = txt.cstring
    let slen = MultiByteToWideChar(CP_UTF8, 0, inpstr[0].addr, int32(len(txt)), nil, 0)
    if slen > 0:
        let x = MultiByteToWideChar(CP_UTF8, 0, inpstr[0].addr, int32(len(txt)), buffer, slen)
        # buffer[slen] = cast[WCHAR](0)
        

proc convertToUTF16(this: var WideString) =
    let slen = MultiByteToWideChar(CP_UTF8, 0, this.mInputStr[0].addr, this.mInputLen, nil, 0)
    this.mBytes = (slen + 1) * 2         
    this.mData = cast[WArrayPtr](alloc0(this.mBytes))
    let x = MultiByteToWideChar(CP_UTF8, 0, this.mInputStr[0].addr, this.mInputLen, &this, slen)
    this.mWcLen = slen
    this.mData[slen] = cast[WCHAR](0)
    # echo this.mInputStr, " - slen ", slen, ", data len ", this.mBytes, " bytes, x ", x

proc newWideString*(txt: string): WideString =
    result.mInputStr = txt.cstring
    result.mInputLen = cast[int32](len(txt))
    if result.mInputLen > 0:
        result.convertToUTF16() 
    # echo "New Memory ",  cast[int](result.mData)


proc newWideString*(src: WideString): WideString =
    result.mInputStr = src.mInputStr
    result.mInputLen = src.mInputLen
    result.mWcLen = src.mWcLen
    result.mBytes = src.mBytes
    if result.mInputLen > 0:
        result.mData = cast[WArrayPtr](alloc0(result.mBytes))
        copyMem(&result, &src, result.mBytes)

proc initWideString*(this: var WideString, src: WideString) =
    this.mInputStr = src.mInputStr
    this.mInputLen = src.mInputLen
    this.mBytes = src.mBytes
    if this.mInputLen > 0:
        this.mData = cast[WArrayPtr](alloc0(this.mBytes))
        # echo "Allocated memory ", cast[int](this.mData)
        copyMem(&this, &src, this.mBytes)

proc copyFrom(this: var WideString, src: WideString ) =
    this.mInputStr = src.mInputStr
    this.mInputLen = src.mInputLen
    copyMem(&this, &src, this.mBytes)

proc finalize(this: var WideString) =
    # echo "WidesString dtor started, mem ",  cast[int](this.mData)
    if this.mData != nil:
        dealloc(this.mData)
        echo "WidesString ", this.mInputStr, " deleted!"