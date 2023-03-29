# api module - Created on 24-Mar-2023

# import system/widestrs # for wchar string conversion

# Windows API types
type
    UINT* = cuint
    DWORD* = int32
    LPCCH* = ptr char
    WCHAR* = Utf16Char
    LPWSTR* = ptr Utf16Char
    LPCWSTR* = ptr Utf16Char
    LPCWCH* = ptr Utf16Char
    LPTSTR* = LPWSTR
    LPSTR* = ptr char
    BOOL* = int32
    INT* = int32
    LPBOOL* = ptr BOOL
    wstring* = seq[WCHAR]
    HANDLE* = pointer
    HWND* = HANDLE
    HBITMAP* = HANDLE
    HFONT* = HANDLE
    HDC* = HANDLE
    HGDIOBJ* = HANDLE
    HINSTANCE* = HANDLE
    HICON* = HANDLE
    HCURSOR* = HANDLE
    HBRUSH* = HANDLE
    HPEN* = HANDLE
    HMENU* = HANDLE
    HMODULE* = HANDLE
    HRGN* = HANDLE
    HTREEITEM* = HANDLE
    HRESULT* = clong
    LONG* = clong
    INT_PTR* = int64
    LONG_PTR* = int64
    LRESULT* = int64
    UINT_PTR* = uint64
    ULONG_PTR* = uint64
    DWORD_PTR* = ULONG_PTR
    COLORREF* = DWORD
    WORD* = cushort
    ATOM* = WORD
    WPARAM* = UINT_PTR
    LPARAM* = LONG_PTR
    VOID* = void
    PVOID* = pointer
    LPVOID* = pointer
    PUINT* = ptr cuint
    BYTE* = uint8
    SHORT* = int16

    WNDPROC* = proc(hWnd: HWND, uMsg: UINT, wParam: WPARAM, lParam: LPARAM): LRESULT {.stdcall.}
    SUBCLASSPROC* = proc (hWnd: HWND, uMsg: UINT, wParam: WPARAM, lParam: LPARAM,
                            uIdSubclass: UINT_PTR, dwRefData: DWORD_PTR): LRESULT {.stdcall.}

# Windows API constants
const
    CP_UTF8 = 65001
    PS_SOLID: cint = 0
    DT_TOP* = 0x00000000
    DT_LEFT* = 0x00000000
    DT_CENTER* = 0x00000001
    DT_RIGHT* = 0x00000002
    DT_VCENTER* = 0x00000004
    DT_BOTTOM* = 0x00000008
    DT_WORDBREAK* = 0x00000010
    DT_SINGLELINE* = 0x00000020
    DT_EXPANDTABS* = 0x00000040
    DT_TABSTOP* = 0x00000080
    DT_NOCLIP* = 0x00000100
    DT_EXTERNALLEADING* = 0x00000200
    DT_CALCRECT* = 0x00000400
    DT_NOPREFIX* = 0x00000800
    DT_INTERNAL* = 0x00001000
    DT_EDITCONTROL* = 0x00002000
    DT_PATH_ELLIPSIS* = 0x00004000
    DT_END_ELLIPSIS* = 0x00008000
    DT_MODIFYSTRING* = 0x00010000
    DT_RTLREADING* = 0x00020000
    DT_WORD_ELLIPSIS* = 0x00040000
    DT_NOFULLWIDTHCHARBREAK* = 0x00080000
    DT_HIDEPREFIX* = 0x00100000
    DT_PREFIXONLY* = 0x00200000
    LF_FACESIZE* = 32

# Custom draw consts
const
    CDRF_DODEFAULT = 0x0
    CDRF_NEWFONT = 0x2
    CDRF_SKIPDEFAULT = 0x4
    CDRF_DOERASE = 0x8
    CDRF_SKIPPOSTPAINT = 0x100
    CDRF_NOTIFYPOSTPAINT = 0x10
    CDRF_NOTIFYITEMDRAW = 0x20
    CDRF_NOTIFYSUBITEMDRAW = 0x20
    CDRF_NOTIFYPOSTERASE = 0x40
    CDDS_PREPAINT = 0x1
    CDDS_POSTPAINT = 0x2
    CDDS_PREERASE = 0x3
    CDDS_POSTERASE = 0x4
    CDDS_ITEM = 0x10000
    CDDS_ITEMPREPAINT = CDDS_ITEM or CDDS_PREPAINT
    CDDS_ITEMPOSTPAINT = CDDS_ITEM or CDDS_POSTPAINT
    CDDS_ITEMPREERASE = CDDS_ITEM or CDDS_PREERASE
    CDDS_ITEMPOSTERASE = CDDS_ITEM or CDDS_POSTERASE
    CDDS_SUBITEM = 0x20000
    CDIS_SELECTED = 0x1
    CDIS_GRAYED = 0x2
    CDIS_DISABLED = 0x4
    CDIS_CHECKED = 0x8
    CDIS_FOCUS = 0x10
    CDIS_DEFAULT = 0x20
    CDIS_HOT = 0x40
    CDIS_MARKED = 0x80
    CDIS_INDETERMINATE = 0x100
    CDIS_SHOWKEYBOARDCUES = 0x200
    CDIS_NEARHOT = 0x0400
    CDIS_OTHERSIDEHOT = 0x0800
    CDIS_DROPHILITED = 0x1000

# Structs
type
    WNDCLASSEXW {.pure.} = object
        cbSize: UINT
        style: UINT
        lpfnWndProc: WNDPROC
        cbClsExtra: INT
        cbWndExtra: INT
        hInstance: HINSTANCE
        hIcon: HICON
        hCursor: HCURSOR
        hbrBackground: HBRUSH
        lpszMenuName: LPCWSTR
        lpszClassName: LPCWSTR
        hIconSm: HICON

    PWNDCLASSEXW = ptr WNDCLASSEXW

    POINT {.pure.} = object
        x : LONG
        y : LONG
    LPPOINT = ptr POINT

    MSG {.pure.} = object
        hwnd: HWND
        message: UINT
        wparam: WPARAM
        lparam: LPARAM
        time: DWORD
        pt: POINT
        lPrivate: DWORD
    LPMSG = ptr MSG

    RECT {.pure.} = object
        left: LONG
        top: LONG
        right: LONG
        bottom: LONG
    LPRECT = ptr RECT

    LOGFONTW {.pure.} = object
        lfHeight: LONG
        lfWidth: LONG
        lfEscapement: LONG
        lfOrientation: LONG
        lfWeight: LONG
        lfItalic: BYTE
        lfUnderline: BYTE
        lfStrikeOut: BYTE
        lfCharSet: BYTE
        lfOutPrecision: BYTE
        lfClipPrecision: BYTE
        lfQuality: BYTE
        lfPitchAndFamily: BYTE
        lfFaceName: array[LF_FACESIZE, WCHAR]
    PLOGFONTW = ptr LOGFONTW

    TRACKMOUSEEVENT {.pure.} = object
        cbSize: DWORD
        dwFlags: DWORD
        hwndTrack: HWND
        dwHoverTime: DWORD
    LPTRACKMOUSEEVENT = ptr TRACKMOUSEEVENT

    NMHDR {.pure.} = object
        hwndFrom: HWND
        idFrom: UINT_PTR
        code: UINT
    LPNMHDR = ptr NMHDR

    NMCUSTOMDRAW {.pure.} = object
        hdr: NMHDR
        dwDrawStage: DWORD
        hdc: HDC
        rc: RECT
        dwItemSpec: DWORD_PTR
        uItemState: UINT
        lItemlParam: LPARAM
    LPNMCUSTOMDRAW = ptr NMCUSTOMDRAW




# Kernel32 functions
proc MultiByteToWideChar(CodePage: UINT, dwFlags: DWORD, lpMultiByteStr: LPCCH, cbMultiByte: INT,
                        lpWideCharStr: LPWSTR, cchWideChar: INT): INT {.stdcall, dynlib: "kernel32", importc.}
proc WideCharToMultiByte(CodePage: UINT, dwFlags: DWORD, lpWideCharStr: LPCWCH, cchWideChar: INT,
                        lpMultiByteStr: LPSTR, cbMultiByte: INT, lpDefaultChar: LPCCH,
                        lpUsedDefaultChar: LPBOOL): INT {.stdcall, dynlib: "kernel32", importc.}
proc GetModuleHandleW*(lpModuleName: LPCWSTR): HMODULE {.stdcall, dynlib: "kernel32", importc.}
proc GetLastError*(): DWORD {. stdcall, dynlib: "kernel32", importc.}
proc MulDiv*(nNumber: int32, nNumerator: int32, nDenominator: int32): int32 {. stdcall, dynlib: "kernel32", importc.}



# User32 functions
proc MessageBoxW*(hWnd: HWND, lpText: LPCWSTR, lpCaption: LPCWSTR, uType: UINT): INT {.stdcall, dynlib: "user32", importc, discardable.}
proc LoadIconW*(hInstance: HINSTANCE, lpIconName: LPCWSTR): HICON {. stdcall, dynlib: "user32", importc.}
proc LoadCursorW*(hInstance: HINSTANCE, lpCursorName: LPCWSTR): HCURSOR {.stdcall, dynlib: "user32", importc.}
proc RegisterClassEx*(P1: ptr WNDCLASSEXW): ATOM {.stdcall, dynlib: "user32", importc: "RegisterClassExW".}
proc PostQuitMessage*(nExitCode: int32): VOID {.stdcall, dynlib: "user32", importc.}
proc DefWindowProcW*(hWnd: HWND, Msg: UINT, wParam: WPARAM, lParam: LPARAM): LRESULT {.stdcall, dynlib: "user32", importc.}
proc CreateWindowExW*(dwExStyle: DWORD, lpClassName: LPCWSTR, lpWindowName: LPCWSTR, dwStyle: DWORD, X: int32, Y: int32, nWidth: int32, nHeight: int32, hWndParent: HWND, hMenu: HMENU, hInstance: HINSTANCE, lpParam: LPVOID): HWND {.stdcall, dynlib: "user32", importc.}
proc ShowWindow*(hWnd: HWND, nCmdShow: int32): BOOL {. stdcall, dynlib: "user32", importc, discardable.}
proc UpdateWindow*(hWnd: HWND): BOOL {. stdcall, dynlib: "user32", importc, discardable.}
proc GetMessageW*(lpMsg: LPMSG, hWnd: HWND, wMsgFilterMin: UINT, wMsgFilterMax: UINT): BOOL {.stdcall, dynlib: "user32", importc.}
proc TranslateMessage*(lpMsg: ptr MSG): BOOL {.stdcall, dynlib: "user32", importc, discardable.}
proc DispatchMessageW*(lpMsg: ptr MSG): LRESULT {. stdcall, dynlib: "user32", importc, discardable.}
proc GetSystemMetrics*(nIndex: int32): int32 {.stdcall, dynlib: "user32", importc.}
proc DestroyWindow*(hWnd: HWND): BOOL {.stdcall, dynlib: "user32", importc, discardable.}
proc SetWindowLongPtrW*(hWnd: HWND, nIndex: int32, dwNewLong: LONG_PTR): LONG_PTR {.stdcall, dynlib: "user32", importc, discardable.}
proc GetWindowLongPtrW*(hWnd: HWND, nIndex: int32): LONG_PTR {.stdcall, dynlib: "user32", importc.}
proc SendMessageW*(hWnd: HWND, Msg: UINT, wParam: WPARAM, lParam: LPARAM): LRESULT {.stdcall, dynlib: "user32", importc, discardable.}
proc GetDC*(hWnd: HWND): HDC {. stdcall, dynlib: "user32", importc.}
proc ReleaseDC*(hWnd: HWND, hDC: HDC): int32 {.stdcall, dynlib: "user32", importc, discardable.}
proc InvalidateRect*(hWnd: HWND, lpRect: ptr RECT, bErase: BOOL): BOOL {.stdcall, dynlib: "user32", importc, discardable.}
proc TrackMouseEventFunc*(lpEventTrack: LPTRACKMOUSEEVENT): BOOL {.stdcall, dynlib: "user32", importc:"TrackMouseEvent", discardable.}
proc DrawTextW*(hdc: HDC, lpchText: LPCWSTR, cchText: int32, lprc: LPRECT, format: UINT): int32 {.stdcall, dynlib: "user32", importc, discardable.}
proc FillRect*(hDC: HDC, lprc: ptr RECT, hbr: HBRUSH): int32 {.stdcall, dynlib: "user32", importc, discardable.}

# End of User32


# Gdi32 functions
proc CreateSolidBrush*(color: COLORREF): HBRUSH {.stdcall, dynlib: "gdi32", importc.}
proc GetDeviceCaps*(hdc: HDC, index: int32): int32 {.stdcall, dynlib: "gdi32", importc.}
proc CreateFontIndirectW*(lplf: ptr LOGFONTW): HFONT {.stdcall, dynlib: "gdi32", importc.}
proc SetTextColor*(hdc: HDC, color: COLORREF): COLORREF {.stdcall, dynlib: "gdi32", importc, discardable.}
proc SetBkMode*(hdc: HDC, mode: int32): int32 {.stdcall, dynlib: "gdi32", importc, discardable.}
proc SelectObject*(hdc: HDC, h: HGDIOBJ): HGDIOBJ {. stdcall, dynlib: "gdi32", importc, discardable.}
proc RoundRect*(hdc: HDC, left: int32, top: int32, right: int32, bottom: int32, width: int32, height: int32): BOOL {.stdcall, dynlib: "gdi32", importc, discardable.}
proc FillPath*(hdc: HDC): BOOL {.stdcall, dynlib: "gdi32", importc, discardable.}
proc CreatePen*(iStyle: int32, cWidth: int32, color: COLORREF): HPEN {.stdcall, dynlib: "gdi32", importc.}
proc DeleteObject*(ho: HGDIOBJ): BOOL {.stdcall, dynlib: "gdi32", importc, discardable.}
proc CreateCompatibleDC*(hdc: HDC): HDC {. stdcall, dynlib: "gdi32", importc.}
proc CreateCompatibleBitmap*(hdc: HDC, cx: int32, cy: int32): HBITMAP {.stdcall, dynlib: "gdi32", importc.}
proc CreatePatternBrush*(hbm: HBITMAP): HBRUSH {.stdcall, dynlib: "gdi32", importc.}
proc DeleteDC*(hdc: HDC): BOOL {.stdcall, dynlib: "gdi32", importc, discardable.}
# End of Gdi32


# Misc functions
proc SetWindowSubclass*(hWnd: HWND, pfnSubclass: SUBCLASSPROC, uIdSubclass: UINT_PTR, dwRefData: DWORD_PTR): BOOL {.stdcall, dynlib: "comctl32", importc, discardable.}
proc RemoveWindowSubclass*(hWnd: HWND, pfnSubclass: SUBCLASSPROC, uIdSubclass: UINT_PTR): BOOL {.stdcall, dynlib: "comctl32", importc, discardable.}
proc DefSubclassProc*(hWnd: HWND, uMsg: UINT, wParam: WPARAM, lParam: LPARAM): LRESULT {.stdcall, dynlib: "comctl32", importc.}
# Misc functions
# proc toWcharArray*(srcString: string): seq[WCHAR] =
#     var wLen: INT = MultiByteToWideChar(cast[UINT](65001), 0, srcString[0].unsafeAddr, INT(srcString.len), nil, 0)
#     var buffer = newSeq[WCHAR](wLen)
#     discard MultiByteToWideChar(cast[UINT](65001), 0, srcString[0].unsafeAddr, INT(srcString.len), result[0].unsafeAddr, wLen)
#     # buffer.add(cast[WCHAR]('\0'))
#     result = buffer

proc toWcharPtr(txt: string): LPCWSTR = newWideCString(txt)[0].unsafeAddr
template LOWORD(l: untyped): WORD = WORD(l and 0xffff)
template HIWORD(l: untyped): WORD = WORD((l shr 16) and 0xffff)
template GET_WHEEL_DELTA_WPARAM*(wParam: untyped): SHORT = cast[SHORT](HIWORD(wParam))
