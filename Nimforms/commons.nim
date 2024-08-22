# commons module - Created on 26-Mar-2023 07:05 PM
# This module implements common functions & declarations.

# Window style combinations
# import macros
# import std/tables
let
    fixedSingleExStyle : DWORD = WS_EX_LEFT or WS_EX_LTRREADING or WS_EX_RIGHTSCROLLBAR or WS_EX_WINDOWEDGE or WS_EX_CONTROLPARENT or WS_EX_APPWINDOW
    fixedSingleStyle : DWORD = WS_OVERLAPPED or WS_TABSTOP or WS_MAXIMIZEBOX or WS_MINIMIZEBOX or WS_GROUP or WS_SYSMENU or WS_DLGFRAME or WS_BORDER or WS_CAPTION or WS_CLIPCHILDREN or WS_CLIPSIBLINGS
    fixed3DExStyle : DWORD = WS_EX_LEFT or WS_EX_LTRREADING or WS_EX_RIGHTSCROLLBAR or WS_EX_WINDOWEDGE or WS_EX_CLIENTEDGE or WS_EX_CONTROLPARENT or WS_EX_APPWINDOW or WS_EX_OVERLAPPEDWINDOW
    fixed3DStyle : DWORD = WS_OVERLAPPED or WS_TABSTOP or WS_MAXIMIZEBOX or WS_MINIMIZEBOX or WS_GROUP or WS_SYSMENU or WS_DLGFRAME or WS_BORDER or WS_CAPTION or WS_CLIPCHILDREN or WS_CLIPSIBLINGS
    fixedDialogExStyle : DWORD = WS_EX_LEFT or WS_EX_LTRREADING or WS_EX_RIGHTSCROLLBAR or WS_EX_DLGMODALFRAME or WS_EX_WINDOWEDGE or WS_EX_CONTROLPARENT or WS_EX_APPWINDOW
    fixedDialogStyle : DWORD = WS_OVERLAPPED or WS_TABSTOP or WS_MAXIMIZEBOX or WS_MINIMIZEBOX or WS_GROUP or WS_SYSMENU or WS_DLGFRAME or WS_BORDER or WS_CAPTION or WS_CLIPCHILDREN or WS_CLIPSIBLINGS
    normalWinExStyle : DWORD = WS_EX_LEFT or WS_EX_LTRREADING or WS_EX_RIGHTSCROLLBAR or WS_EX_WINDOWEDGE or WS_EX_CONTROLPARENT or WS_EX_APPWINDOW
    normalWinStyle : DWORD = WS_OVERLAPPEDWINDOW or WS_TABSTOP or  WS_CLIPCHILDREN or WS_CLIPSIBLINGS
    fixedToolExStyle : DWORD = WS_EX_LEFT or WS_EX_LTRREADING or WS_EX_RIGHTSCROLLBAR or WS_EX_TOOLWINDOW or WS_EX_WINDOWEDGE or WS_EX_CONTROLPARENT or WS_EX_APPWINDOW
    fixedToolStyle : DWORD = WS_OVERLAPPED or WS_TABSTOP or WS_MAXIMIZEBOX or WS_MINIMIZEBOX or WS_GROUP or WS_SYSMENU or WS_DLGFRAME or WS_BORDER or WS_CAPTION or WS_CLIPCHILDREN or WS_CLIPSIBLINGS
    sizableToolExStyle : DWORD = WS_EX_LEFT or WS_EX_LTRREADING or WS_EX_RIGHTSCROLLBAR or WS_EX_TOOLWINDOW or WS_EX_WINDOWEDGE or WS_EX_CONTROLPARENT or WS_EX_APPWINDOW
    sizableToolStyle : DWORD = WS_OVERLAPPED or WS_TABSTOP or WS_MAXIMIZEBOX or WS_MINIMIZEBOX or WS_GROUP or WS_THICKFRAME or WS_SYSMENU or WS_DLGFRAME or WS_BORDER or WS_CAPTION or WS_OVERLAPPEDWINDOW or WS_CLIPCHILDREN or WS_CLIPSIBLINGS

const # These 4 constants are used by ListView
    HDM_FIRST = 0x1200
    HDM_LAYOUT = HDM_FIRST+5
    HDM_HITTEST = HDM_FIRST+6
    HDM_GETITEMRECT = HDM_FIRST+7
    GWLP_USERDATA = -21


# Font related functions
const
    LOGPIXELSY = 90
    DEFAULT_CHARSET = 1
    OUT_STRING_PRECIS = 1
    CLIP_DEFAULT_PRECIS = 0
    DEFAULT_QUALITY = 0

let CLR_WHITE = newColor(0xFFFFFF)
let CLR_BLACK = newColor(0x000000)

proc createHandle(this: Font) # Foreard declaration


proc adjDpi(x: int32) : int32 {.inline.} = int32(float(x) * appData.scaleF)
    



proc newFont*(fname: string, fsize: int32, 
                fweight: FontWeight = FontWeight.fwNormal,
                italic: bool = false, underline: bool = false, 
                strikeout: bool = false, autoc: bool = false) : Font =
    new(result)
    if fname.len > 32 : raise newException(OSError, "Length of font name exceeds 32 characters")
    result.name = fname
    result.size = fsize
    result.weight = fweight
    result.italics = italic
    result.underLine = underline
    result.strikeOut = strikeout
    if autoc: result.createHandle()

proc createHandle(this: Font) =    
    let scale = appData.scaleFactor / 100
    let fsiz = int32(scale * float(this.size))   
    let iHeight = -MulDiv(fsiz , appData.sysDPI, 72)
    
    var fname = newWideCString(this.name)
    var lf : LOGFONTW
    lf.lfItalic = cast[BYTE](this.italics)
    lf.lfUnderline = cast[BYTE](this.underLine)
    for i in 0..fname.len :
        lf.lfFaceName[i] = fname[i]

    lf.lfHeight = iHeight
    lf.lfWeight = cast[LONG](this.weight)
    lf.lfCharSet = cast[BYTE](DEFAULT_CHARSET)
    lf.lfOutPrecision = cast[BYTE](OUT_STRING_PRECIS)
    lf.lfClipPrecision = cast[BYTE](CLIP_DEFAULT_PRECIS)
    lf.lfQuality = cast[BYTE](DEFAULT_QUALITY)
    lf.lfPitchAndFamily = 1
    this.handle = CreateFontIndirectW(lf.unsafeAddr)

# End of Font related area

proc u16_to_i16(value: uint16): int16 = cast[int16]((value and 0xFFFF))

# Some control needs to extract mouse position from lparam value.
proc getMousePos(pt: ptr POINT, lpm: LPARAM) =
    if lpm == 0:
        GetCursorPos(pt)
    else:
        # echo "hwd lpm ", HIWORD(lpm), ", lpm ", lpm 
        pt.x = int32(u16_to_i16(LOWORD(lpm)))
        pt.y = int32(u16_to_i16(HIWORD(lpm)))

proc getMousePos(lpm: LPARAM): POINT =
    result = POINT( x: int32(u16_to_i16(LOWORD(lpm))), 
                    y: int32(u16_to_i16(HIWORD(lpm)))
                   )
    

proc getMousePosOnMsg(): POINT =
    let dw_value = GetMessagePos()
    result.x = LONG(LOWORD(dw_value))
    result.y = LONG(HIWORD(dw_value))

# template strLiteralToWChrPtr(s: string): LPCWSTR = 
#     cast[LPCWSTR](cast[ptr UncheckedArray[byte]](s[0].addr).toOpenArray(0, s.len).map(a => a.uint16)[0].addr)
 
proc registerMessageWindowClass(clsName: LPCWSTR, pFunc: WNDPROC) =
    var wc : WNDCLASSEXW
    wc.cbSize = cast[UINT](sizeof(wc))
    wc.lpfnWndProc = pFunc
    wc.hInstance = appData.hInstance
    wc.lpszClassName = clsName
    RegisterClassExW(wc.addr)


#==========MENU FILE INCLUDE==============================================
include menu
#=========================================================================

proc getWidthOfString(value: string, ctlHwnd: HWND, fontHwnd: HFONT): int =
    var
        txtlen: int = value.len
        ss : SIZE
        hdc: HDC = GetDC(ctlHwnd)
    SelectObject(hdc, cast[HGDIOBJ](fontHwnd))
    GetTextExtentPoint32(hdc, toWcharPtr(value), int32(txtlen), ss.unsafeAddr)
    ReleaseDC(ctlHwnd, hdc)
    result = ss.cx

proc getWidthOfColumnNames(lv: ListView, names: varargs[string, `$`]) : OrderedTable[string, int32] =
    var
        txtlen: int
        ss : SIZE
        hdc: HDC = GetDC(lv.mHandle)
        res : OrderedTable[string, int32]
    SelectObject(hdc, cast[HGDIOBJ](lv.mFont.handle))
    for value in names:
        # echo value
        txtlen = value.len
        GetTextExtentPoint32(hdc, toWcharPtr(value), int32(txtlen), ss.unsafeAddr)
        res[value] = int32(ss.cx + 20)

    ReleaseDC(lv.mHandle, hdc)
    return res

proc getAccumulatedColWidth(lv: ListView): int32 =
    for col in lv.mColumns:
        result += col.mWidth
    result += 20

proc sendThreadMsg(hwnd: HWND, wpm: WPARAM, lpm: LPARAM) =
    SendNotifyMessageW(hwnd, MM_THREAD_MSG, wpm, lpm)


# Connects an event handler to a function.
# usage : proce sample(c: Control, e: EventHandler) {.handles(btn.onClick).} =
macro handles*(evt: untyped, fn: untyped): untyped =
    # Creates the function pointer assignment code (btn.onClick = funcName)
    let func_assign = newStmtList(newAssignment(newDotExpr(evt[0], evt[1]), fn[0]))

    # Now, creates a new statement. First the function and after that our newly created assignment statement.
    let new_code = newStmtList(fn, func_assign)
    result = new_code

# macro name(arguments): return type =
