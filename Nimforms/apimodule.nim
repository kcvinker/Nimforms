# api module - Created on 24-Mar-2023

# import system/widestrs # for wchar string conversion
import strutils, sequtils
import std/strformat
import macros

    

# Windows API Data types
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

    # WcharArray* = ptr UncheckedArray[WCHAR]
    # Wstring* = ref object 
    #     length: int32 
    #     data: WcharArray #ptr UncheckedArray[WCHAR]

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
    ULONG* = int32
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
    USHORT* = uint16

    # These are created for com module
    LPCVOID* = pointer
    va_list* = pointer


    # wstring* = ref object
    #     size: uint32
    #     data: UncheckedArray[WCHAR]

    # pwstring* = ptr object
    #     size: uint32
    #     data: UncheckedArray[WCHAR]

    WNDPROC = proc(hWnd: HWND, uMsg: UINT, wParam: WPARAM, lParam: LPARAM): LRESULT {.stdcall.}
    SUBCLASSPROC = proc (hWnd: HWND, uMsg: UINT, wParam: WPARAM, lParam: LPARAM,
                            uIdSubclass: UINT_PTR, dwRefData: DWORD_PTR): LRESULT {.stdcall.}

    TIMERPROC = proc (hWnd: HWND, uID: UINT, uIDp: UINT_PTR, dw: DWORD) {.stdcall.}

# This macro takes a dll name and a bool to use 'discardable' pragma.
macro dll(lib: static string, disc: static bool, x: untyped): untyped =
    let dynlibPragma = newTree(nnkExprColonExpr, ident("dynlib"), newLit(lib))
    x.addPragma(dynlibPragma)
    x.addPragma(newIdentNode("stdcall"))
    x.addPragma(newIdentNode("importc"))
    if disc:
        x.addPragma(newIdentNode("discardable"))
    result = x




# Windows API constants
const
    CP_UTF8 = 65001
    PS_SOLID: cint = 0
    DT_TOP = 0x00000000
    DT_LEFT = 0x00000000
    DT_CENTER = 0x00000001
    DT_RIGHT = 0x00000002
    DT_VCENTER = 0x00000004
    DT_BOTTOM = 0x00000008
    DT_WORDBREAK = 0x00000010
    DT_SINGLELINE = 0x00000020
    DT_EXPANDTABS = 0x00000040
    DT_TABSTOP = 0x00000080
    DT_NOCLIP = 0x00000100
    DT_EXTERNALLEADING = 0x00000200
    DT_CALCRECT = 0x00000400
    DT_NOPREFIX = 0x00000800
    DT_INTERNAL = 0x00001000
    DT_EDITCONTROL = 0x00002000
    DT_PATH_ELLIPSIS = 0x00004000
    DT_END_ELLIPSIS = 0x00008000
    DT_MODIFYSTRING = 0x00010000
    DT_RTLREADING = 0x00020000
    DT_WORD_ELLIPSIS = 0x00040000
    DT_NOFULLWIDTHCHARBREAK = 0x00080000
    DT_HIDEPREFIX = 0x00100000
    DT_PREFIXONLY = 0x00200000
    LF_FACESIZE = 32
    FORMAT_MESSAGE_FROM_SYSTEM* = 0x00001000
    FORMAT_MESSAGE_IGNORE_INSERTS* = 0x00000200
    SUBLANG_DEFAULT* = 0x01
    LANG_NEUTRAL* = 0x00

# Custom  consts
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

    NM_FIRST = cast[UINT](0-0)
    NM_CLICK = NM_FIRST-2
    NM_DBLCLK = NM_FIRST-3
    NM_CUSTOMDRAW_NM = NM_FIRST-12
    NM_HOVER = NM_FIRST-13

    SWP_NOZORDER = 0x0004
    SWP_SHOWWINDOW = 0x0040
    SWP_NOACTIVATE = 0x0010
    SWP_FRAMECHANGED = 0x0020

    HWND_TOP = cast[HWND](0)
    HWND_MESSAGE = cast[HWND](-3)

    ICC_DATE_CLASSES = 0x100

    BDR_RAISEDOUTER = 0x0001
    BDR_SUNKENOUTER = 0x0002
    BDR_RAISEDINNER = 0x0004
    BDR_SUNKENINNER = 0x0008
    BDR_OUTER = BDR_RAISEDOUTER or BDR_SUNKENOUTER
    BDR_INNER = BDR_RAISEDINNER or BDR_SUNKENINNER
    BDR_RAISED = BDR_RAISEDOUTER or BDR_RAISEDINNER
    BDR_SUNKEN = BDR_SUNKENOUTER or BDR_SUNKENINNER
    EDGE_RAISED = BDR_RAISEDOUTER or BDR_RAISEDINNER
    EDGE_SUNKEN = BDR_SUNKENOUTER or BDR_SUNKENINNER
    EDGE_ETCHED = BDR_SUNKENOUTER or BDR_RAISEDINNER
    EDGE_BUMP = BDR_RAISEDOUTER or BDR_SUNKENINNER
    BF_LEFT = 0x0001
    BF_TOP = 0x0002
    BF_RIGHT = 0x0004
    BF_BOTTOM = 0x0008
    BF_TOPLEFT = BF_TOP or BF_LEFT
    BF_TOPRIGHT = BF_TOP or BF_RIGHT
    BF_BOTTOMLEFT = BF_BOTTOM or BF_LEFT
    BF_BOTTOMRIGHT = BF_BOTTOM or BF_RIGHT
    BF_RECT = BF_LEFT or BF_TOP or BF_RIGHT or BF_BOTTOM
    BF_DIAGONAL = 0x0010
    BF_DIAGONAL_ENDTOPRIGHT = BF_DIAGONAL or BF_TOP or BF_RIGHT
    BF_DIAGONAL_ENDTOPLEFT = BF_DIAGONAL or BF_TOP or BF_LEFT
    BF_DIAGONAL_ENDBOTTOMLEFT = BF_DIAGONAL or BF_BOTTOM or BF_LEFT
    BF_DIAGONAL_ENDBOTTOMRIGHT = BF_DIAGONAL or BF_BOTTOM or BF_RIGHT
    BF_MIDDLE = 0x0800
    BF_SOFT = 0x1000
    BF_ADJUST = 0x2000
    BF_FLAT = 0x4000
    BF_MONO = 0x8000

    GWL_STYLE = -16

    # Menu Constants
    MF_POPUP = 0x00000010
    MF_STRING = 0x00000000
    MF_SEPARATOR = 0x00000800
    MF_CHECKED = 0x00000008
    MNS_NOTIFYBYPOS = 0x08000000
    MIM_STYLE = 0x00000010
    TPM_LEFTBUTTON = 0x0000
    TPM_RIGHTBUTTON = 0x0002
    MF_OWNERDRAW = 0x00000100

    MIIM_STATE = 0x00000001
    MIIM_ID = 0x00000002
    MIIM_SUBMENU = 0x00000004
    MIIM_CHECKMARKS = 0x00000008
    MIIM_TYPE = 0x00000010
    MIIM_DATA = 0x00000020
    MIIM_STRING = 0x00000040
    MIIM_BITMAP = 0x00000080
    MIIM_FTYPE = 0x00000100
    MIM_MENUDATA = 0x00000008

    MF_INSERT = 0x00000000
    MF_CHANGE = 0x00000080
    MF_APPEND = 0x00000100
    MF_DELETE = 0x00000200
    MF_REMOVE = 0x00001000
    MF_BYCOMMAND = 0x00000000
    MF_BYPOSITION = 0x00000400
    MF_ENABLED = 0x00000000
    MF_GRAYED = 0x00000001
    MF_DISABLED = 0x00000002
    MF_UNCHECKED = 0x00000000

    MF_USECHECKBITMAPS = 0x00000200

    MF_BITMAP = 0x00000004

    MF_MENUBARBREAK = 0x00000020
    MF_MENUBREAK = 0x00000040
    MF_UNHILITE = 0x00000000
    MF_HILITE = 0x00000080
    MF_DEFAULT = 0x00001000
    MF_SYSMENU = 0x00002000
    MF_HELP = 0x00004000
    MF_RIGHTJUSTIFY = 0x00004000
    MF_MOUSESELECT = 0x00008000
    MF_END = 0x00000080

# Structs
type
    WNDCLASSEXW* {.pure.} = object
        cbSize*: UINT
        style*: UINT
        lpfnWndProc*: WNDPROC
        cbClsExtra*: INT
        cbWndExtra*: INT
        hInstance*: HINSTANCE
        hIcon*: HICON
        hCursor*: HCURSOR
        hbrBackground*: HBRUSH
        lpszMenuName*: LPCWSTR
        lpszClassName*: LPCWSTR
        hIconSm*: HICON

    PWNDCLASSEXW* = ptr WNDCLASSEXW

    POINT {.pure.} = object
        x : LONG
        y : LONG
    LPPOINT = ptr POINT

    MSG* {.pure.} = object
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

    SYSTEMTIME {.pure.} = object
        wYear: WORD
        wMonth: WORD
        wDayOfWeek: WORD
        wDay: WORD
        wHour: WORD
        wMinute: WORD
        wSecond: WORD
        wMilliseconds: WORD
    LPSYSTEMTIME = ptr SYSTEMTIME

    NMSELCHANGE {.pure.} = object
        nmhdr: NMHDR
        stSelStart: SYSTEMTIME
        stSelEnd: SYSTEMTIME
    LPNMSELCHANGE = ptr NMSELCHANGE

    NMVIEWCHANGE {.pure.} = object
        nmhdr: NMHDR
        dwOldView: DWORD
        dwNewView: DWORD
    LPNMVIEWCHANGE = ptr NMVIEWCHANGE

    SIZE {.pure.} = object
        cx: LONG
        cy: LONG
    LPSIZE = ptr SIZE

    COMBOBOXINFO {.pure.} = object
        cbSize: DWORD
        rcItem: RECT
        rcButton: RECT
        stateButton: DWORD
        hwndCombo: HWND
        hwndItem: HWND
        hwndList: HWND
    LPCOMBOBOXINFO = ptr COMBOBOXINFO

    INITCOMMONCONTROLSEX {.pure.} = object
        dwSize: DWORD
        dwICC: DWORD
    LPINITCOMMONCONTROLSEX = ptr INITCOMMONCONTROLSEX

    NMDATETIMESTRINGW {.pure.} = object
        nmhdr: NMHDR
        pszUserString: LPCWSTR
        st: SYSTEMTIME
        dwFlags: DWORD
    LPNMDATETIMESTRINGW = ptr NMDATETIMESTRINGW

    NMDATETIMECHANGE {.pure.} = object
        nmhdr: NMHDR
        dwFlags: DWORD
        st: SYSTEMTIME
    LPNMDATETIMECHANGE = ptr NMDATETIMECHANGE

    LVCOLUMNW {.pure.} = object
        mask: UINT
        fmt: int32
        cx: int32
        pszText: LPWSTR
        cchTextMax: int32
        iSubItem: int32
        iImage: int32
        iOrder: int32
        cxMin: int32
        cxDefault: int32
        cxIdeal: int32
    LPLVCOLUMNW = ptr LVCOLUMNW

    LVITEMW {.pure.} = object
        mask: UINT
        iItem: int32
        iSubItem: int32
        state: UINT
        stateMask: UINT
        pszText: LPWSTR
        cchTextMax: int32
        iImage: int32
        lParam: LPARAM
        iIndent: int32
        iGroupId: int32
        cColumns: UINT
        puColumns: PUINT
        piColFmt: ptr int32
        iGroup: int32
    LPLVITEMW = ptr LVITEMW

    WINDOWPOS {.pure.} = object
        hwnd: HWND
        hwndInsertAfter: HWND
        x: int32
        y: int32
        cx: int32
        cy: int32
        flags: UINT
    LPWINDOWPOS = ptr WINDOWPOS

    HDLAYOUT {.pure.} = object
        prc: ptr RECT
        pwpos: ptr WINDOWPOS
    LPHDLAYOUT = ptr HDLAYOUT

    HDHITTESTINFO {.pure.} = object
        pt: POINT
        flags: UINT
        iItem: int32
    LPHDHITTESTINFO = ptr HDHITTESTINFO

    NMLVCUSTOMDRAW {.pure.} = object
        nmcd: NMCUSTOMDRAW
        clrText: COLORREF
        clrTextBk: COLORREF
        iSubItem: int32
        dwItemType: DWORD
        clrFace: COLORREF
        iIconEffect: int32
        iIconPhase: int32
        iPartId: int32
        iStateId: int32
        rcText: RECT
        uAlign: UINT
    LPNMLVCUSTOMDRAW = ptr NMLVCUSTOMDRAW

    NMLISTVIEW {.pure.} = object
        hdr: NMHDR
        iItem: int32
        iSubItem: int32
        uNewState: UINT
        uOldState: UINT
        uChanged: UINT
        ptAction: POINT
        lParam: LPARAM
    LPNMLISTVIEW = ptr NMLISTVIEW

    NMITEMACTIVATE {.pure.} = object
        hdr: NMHDR
        iItem: int32
        iSubItem: int32
        uNewState: UINT
        uOldState: UINT
        uChanged: UINT
        ptAction: POINT
        lParam: LPARAM
        uKeyFlags: UINT
    LPNMITEMACTIVATE = ptr NMITEMACTIVATE

    NMUPDOWN {.pure.} = object
        hdr: NMHDR
        iPos: int32
        iDelta: int32
    LPNMUPDOWN = ptr NMUPDOWN

    TVITEMEXW {.pure.} = object
        mask: UINT
        hItem: HTREEITEM
        state: UINT
        stateMask: UINT
        pszText: LPWSTR
        cchTextMax: int32
        iImage: int32
        iSelectedImage: int32
        cChildren: int32
        lParam: LPARAM
        iIntegral: int32
        uStateEx: UINT
        hwnd: HWND
        iExpandedImage: int32
    LPTVITEMEXW = ptr TVITEMEXW

    TVINSERTSTRUCTW {.pure.} = object
        hParent: HTREEITEM
        hInsertAfter: HTREEITEM
        itemex: TVITEMEXW
    LPTVINSERTSTRUCTW = ptr TVINSERTSTRUCTW

    NMTVCUSTOMDRAW {.pure.} = object
        nmcd: NMCUSTOMDRAW
        clrText: COLORREF
        clrTextBk: COLORREF
        iLevel: int32
    LPNMTVCUSTOMDRAW = ptr NMTVCUSTOMDRAW

    NMTVITEMCHANGE {.pure.} = object
        hdr: NMHDR
        uChanged: UINT
        hItem: HTREEITEM
        uStateNew: UINT
        uStateOld: UINT
        lParam: LPARAM
    LPNMTVITEMCHANGE = ptr NMTVITEMCHANGE

    TVITEMW {.pure.} = object
        mask: UINT
        hItem: HTREEITEM
        state: UINT
        stateMask: UINT
        pszText: LPWSTR
        cchTextMax: int32
        iImage: int32
        iSelectedImage: int32
        cChildren: int32
        lParam: LPARAM
    LPTVITEMW* = ptr TVITEMW

    NMTREEVIEWW {.pure.} = object
        hdr: NMHDR
        action: UINT
        itemOld: TVITEMW
        itemNew: TVITEMW
        ptDrag: POINT
    LPNMTREEVIEWW = ptr NMTREEVIEWW

    NMTVSTATEIMAGECHANGING {.pure.} = object
        hdr: NMHDR
        hti: HTREEITEM
        iOldStateImageIndex: int32
        iNewStateImageIndex: int32
    LPNMTVSTATEIMAGECHANGING = ptr NMTVSTATEIMAGECHANGING

    MENUITEMINFOW {.pure.} = object
        cbSize: UINT
        fMask: UINT
        fType: UINT
        fState: UINT
        wID: UINT
        hSubMenu: HMENU
        hbmpChecked: HBITMAP
        hbmpUnchecked: HBITMAP
        dwItemData: ULONG_PTR
        dwTypeData: LPWSTR
        cch: UINT
        hbmpItem: HBITMAP
    LPMENUITEMINFOW = ptr MENUITEMINFOW

    MEASUREITEMSTRUCT {.pure.} = object
        CtlType: UINT
        CtlID: UINT
        itemID: UINT
        itemWidth: UINT
        itemHeight: UINT
        itemData: ULONG_PTR
    LPMEASUREITEMSTRUCT = ptr MEASUREITEMSTRUCT

    DRAWITEMSTRUCT {.pure.} = object
        CtlType: UINT
        CtlID: UINT
        itemID: UINT
        itemAction: UINT
        itemState: UINT
        hwndItem: HWND
        hDC: HDC
        rcItem: RECT
        itemData: ULONG_PTR
    LPDRAWITEMSTRUCT = ptr DRAWITEMSTRUCT

    DISPLAY_DEVICE_TYPE {.pure.} = enum
        DEVICE_PRIMARY = 0, DEVICE_IMMERSIVE = 1

    DEVICE_SCALE_FACTOR {.pure.} = enum
        SCALE_100_PERCENT = 100,
        SCALE_120_PERCENT = 120,
        SCALE_125_PERCENT = 125,
        SCALE_140_PERCENT = 140,
        SCALE_150_PERCENT = 150,

    BROWSECBPROC = proc(p1: HWND, p2: UINT, p3: WPARAM, p4: LPARAM): int32 {.stdcall.}
    OFNHOOKPROC = proc(p1: HWND, p2: UINT, p3: WPARAM, p4: LPARAM): UINT_PTR {.stdcall.}

    OPENFILENAMEW {.pure.} = object
        lStructSize: DWORD
        hwndOwner: HWND
        hInstance: HINSTANCE
        lpstrFilter: LPCWSTR
        lpstrCustomFilter: LPWSTR
        nMaxCustFilter: DWORD
        nFilterIndex: DWORD
        lpstrFile: LPWSTR
        nMaxFile: DWORD
        lpstrFileTitle: LPWSTR
        nMaxFileTitle: DWORD
        lpstrInitialDir: LPCWSTR
        lpstrTitle: LPCWSTR
        Flags: DWORD
        nFileOffset: WORD
        nFileExtension: WORD
        lpstrDefExt: LPCWSTR
        lCustData: LPARAM
        lpfnHook: OFNHOOKPROC
        lpTemplateName: LPCWSTR
        pvReserved: pointer
        dwReserved: DWORD
        FlagsEx: DWORD

    LPOPENFILENAMEW = ptr OPENFILENAMEW

    SHITEMID {.pure.} = object
        cb: USHORT
        abID: array[1, BYTE]

    LPSHITEMID = ptr SHITEMID

    ITEMIDLIST {.pure, packed.} = object
        mkid: SHITEMID

    ITEMIDLIST_RELATIVE = ITEMIDLIST
    ITEMID_CHILD = ITEMIDLIST
    ITEMIDLIST_ABSOLUTE = ITEMIDLIST
    LPITEMIDLIST = ptr ITEMIDLIST
    LPCITEMIDLIST = ptr ITEMIDLIST
    PIDLIST_ABSOLUTE = ptr ITEMIDLIST_ABSOLUTE
    PCIDLIST_ABSOLUTE = ptr ITEMIDLIST_ABSOLUTE


    BROWSEINFOW {.pure.} = object
        hwndOwner: HWND
        pidlRoot: PCIDLIST_ABSOLUTE
        pszDisplayName: LPWSTR
        lpszTitle: LPCWSTR
        ulFlags: UINT
        lpfn: BROWSECBPROC
        lParam: LPARAM
        iImage: cint

    LPBROWSEINFOW = ptr BROWSEINFOW


# Kernel32 functions 
proc MultiByteToWideChar*(CodePage: UINT, dwFlags: DWORD, lpMultiByteStr: LPCCH, cbMultiByte: INT,
                        lpWideCharStr: LPWSTR, cchWideChar: INT): INT {.dll("kernel32", false).}
proc WideCharToMultiByte(CodePage: UINT, dwFlags: DWORD, lpWideCharStr: LPCWCH, cchWideChar: INT,
                        lpMultiByteStr: LPSTR, cbMultiByte: INT, lpDefaultChar: LPCCH,
                        lpUsedDefaultChar: LPBOOL): INT {.dll("kernel32", false).}
proc GetModuleHandleW*(lpModuleName: LPCWSTR): HMODULE {.dll("kernel32", false).}
proc GetLastError*(): DWORD {.dll("kernel32", false).}
proc MulDiv(nNumber: int32, nNumerator: int32, nDenominator: int32): int32 {.dll("kernel32", false).}
#-------------------------------------------------------------------------------------------------------

# User32 functions
proc MessageBoxW(hWnd: HWND, lpText: LPCWSTR, lpCaption: LPCWSTR, uType: UINT): INT {.dll("user32", true).} 
proc LoadIconW*(hInstance: HINSTANCE, lpIconName: LPCWSTR): HICON {.dll("user32", false).} 
proc LoadCursorW*(hInstance: HINSTANCE, lpCursorName: LPCWSTR): HCURSOR {.dll("user32", false).}
proc RegisterClassEx*(P1: ptr WNDCLASSEXW): ATOM {.stdcall, dynlib: "user32", importc: "RegisterClassExW".}
proc PostQuitMessage*(nExitCode: int32): VOID {.dll("user32", false).}
proc DefWindowProcW*(hWnd: HWND, Msg: UINT, wParam: WPARAM, lParam: LPARAM): LRESULT {.dll("user32", false).}
proc CreateWindowExW*(dwExStyle: DWORD, lpClassName: LPCWSTR, 
                        lpWindowName: LPCWSTR, dwStyle: DWORD, 
                        X: int32, Y: int32, nWidth: int32, 
                        nHeight: int32, hWndParent: HWND, 
                        hMenu: HMENU, hInstance: HINSTANCE, 
                        lpParam: LPVOID): HWND {.dll("user32", false).}
proc ShowWindow*(hWnd: HWND, nCmdShow: int32): BOOL {.dll("user32", true).}
proc UpdateWindow*(hWnd: HWND): BOOL {.dll("user32", true).}
proc GetMessageW*(lpMsg: LPMSG, hWnd: HWND, wMsgFilterMin: UINT, wMsgFilterMax: UINT): BOOL {.dll("user32", false).}
proc TranslateMessage*(lpMsg: ptr MSG): BOOL {.dll("user32", true).}
proc DispatchMessageW*(lpMsg: ptr MSG): LRESULT {.dll("user32", true).}
proc GetSystemMetrics(nIndex: int32): int32 {.dll("user32", false).}
proc DestroyWindow(hWnd: HWND): BOOL {.dll("user32", true).}
proc SetWindowLongPtrW(hWnd: HWND, nIndex: int32, dwNewLong: LONG_PTR): LONG_PTR {.dll("user32", true).}
proc GetWindowLongPtrW(hWnd: HWND, nIndex: int32): LONG_PTR {.dll("user32", false).}
proc SendMessageW(hWnd: HWND, Msg: UINT, wParam: WPARAM, lParam: LPARAM): LRESULT {.dll("user32", true).}
proc SendNotifyMessageW(hWnd: HWND, Msg: UINT, wParam: WPARAM, lParam: LPARAM): LRESULT {.dll("user32", true).}
proc GetDC(hWnd: HWND): HDC {.dll("user32", false).}
proc ReleaseDC(hWnd: HWND, hDC: HDC): int32 {.dll("user32", true).}
proc InvalidateRect(hWnd: HWND, lpRect: ptr RECT, bErase: BOOL): BOOL {.dll("user32", true).}
proc TrackMouseEventFunc(lpEventTrack: LPTRACKMOUSEEVENT): BOOL 
                            {.stdcall, dynlib: "user32", importc:"TrackMouseEvent", discardable.}
proc DrawTextW(hdc: HDC, lpchText: LPCWSTR, cchText: int32, lprc: LPRECT, format: UINT): int32 {.dll("user32", true).}
proc FillRect(hDC: HDC, lprc: ptr RECT, hbr: HBRUSH): int32 {.dll("user32", true).}
proc SetWindowPos(hWnd: HWND, hWndInsertAfter: HWND, X: int32, Y: int32, 
                    cx: int32, cy: int32, uFlags: UINT): BOOL {.dll("user32", true).}
proc MoveWindow(hWnd: HWND, X: int32, Y: int32, nWidth: int32, nHeight: int32, 
                        bRepaint: BOOL): BOOL {.dll("user32", true).}
proc GetMessagePos(): DWORD {.dll("user32", false).}
proc GetWindowRect(hWnd: HWND, lpRect: LPRECT): BOOL {.dll("user32", true).}
proc PtInRect(lprc: ptr RECT, pt: POINT): BOOL {.dll("user32", false).}
proc GetClientRect(hWnd: HWND, lpRect: LPRECT): BOOL {.dll("user32", true).}
proc SetWindowTextW*(hWnd: HWND, lpString: LPCWSTR): BOOL {.dll("user32", true).}
proc GetWindowTextLengthW(hWnd: HWND): int32 {.dll("user32", false).}
proc GetWindowTextW(hWnd: HWND, lpString: LPWSTR, nMaxCount: int32): int32 {.dll("user32", true).}
proc GetCursorPos(lpPoint: LPPOINT): BOOL {.dll("user32", true).}
proc ScreenToClient(hWnd: HWND, lpPoint: LPPOINT): BOOL {.dll("user32", true).}
proc DrawEdge(hdc: HDC, qrc: LPRECT, edge: UINT, grfFlags: UINT): BOOL {.dll("user32", true).}
proc HideCaret(hWnd: HWND): BOOL {.dll("user32", true).}
proc SetWindowLongPtr(hWnd: HWND, nIndex: int32, 
                        dwNewLong: LONG_PTR): LONG_PTR 
                        {.stdcall, dynlib: "user32", importc: "SetWindowLongPtrW", discardable.}
proc CreateMenu(): HMENU {.dll("user32", false).}
proc DestroyMenu(hMenu: HMENU): BOOL {.dll("user32", true).}
proc CreatePopupMenu(): HMENU {.dll("user32", false).}
proc TrackPopupMenu(hMenu: HMENU, uFlags: UINT, x, y, nReserved: int32, hwnd: HWND, 
                                prcRect: LPRECT): BOOL {.dll("user32", true).}
proc SetMenuItemInfoW(hMenu: HMENU, item: UINT, fByPos: BOOL, lpmii: LPMENUITEMINFOW): BOOL {.dll("user32", true).}
proc AppendMenuW(hMenu: HMENU, uFlags: UINT, uIdNewItem: UINT_PTR, lpNewItem: LPCWSTR): BOOL {.dll("user32", true).}
proc SetMenu(hwnd: HWND, hMenu: HMENU): BOOL {.dll("user32", true).}
proc InsertMenuItemW(hMenu: HMENU, item: UINT, fByPos: BOOL, lpmii: LPMENUITEMINFOW): BOOL {.dll("user32", true).}
proc ClientToScreen(hwnd: HWND, lpp: LPPOINT): BOOL {.dll("user32", true).}
proc FrameRect(hDc: HDC, lprc: LPRECT, hBr: HBRUSH): INT {.dll("user32", true).}
proc MapWindowPoints(hwndFrom: HWND, hwndTo: HWND, lpnt: LPPOINT, cpnt: UINT): INT {.dll("user32", true).}
proc SetTimer(hwnd: HWND, nID: UINT_PTR, uEla: UINT, lpfn: TIMERPROC): UINT_PTR {.dll("user32", true).}
proc KillTimer(hwnd: HWND, nID: UINT_PTR): BOOL {.dll("user32", true).}
# End of User32---------------------------------------------------------------------------------------------

# Gdi32 functions {.dll("gdi32", true).}
proc CreateSolidBrush*(color: COLORREF): HBRUSH {.dll("gdi32", false).}
proc GetDeviceCaps(hdc: HDC, index: int32): int32 {.dll("gdi32", false).}
proc CreateFontIndirectW(lplf: ptr LOGFONTW): HFONT {.dll("gdi32", false).}
proc SetTextColor(hdc: HDC, color: COLORREF): COLORREF {.dll("gdi32", true).}
proc SetBkMode(hdc: HDC, mode: int32): int32 {.dll("gdi32", true).}
proc SelectObject(hdc: HDC, h: HGDIOBJ): HGDIOBJ {.dll("gdi32", true).}
proc RoundRect(hdc: HDC, left: int32, top: int32, right: int32, bottom: int32, 
                    width: int32, height: int32): BOOL {.dll("gdi32", true).}
proc FillPath(hdc: HDC): BOOL {.dll("gdi32", true).}
proc CreatePen(iStyle: int32, cWidth: int32, color: COLORREF): HPEN {.dll("gdi32", false).}
proc DeleteObject(ho: HGDIOBJ): BOOL {.dll("gdi32", true).}
proc CreateCompatibleDC(hdc: HDC): HDC {. stdcall, dynlib: "gdi32", importc.}
proc CreateCompatibleBitmap(hdc: HDC, cx: int32, cy: int32): HBITMAP {.dll("gdi32", false).}
proc CreatePatternBrush(hbm: HBITMAP): HBRUSH {.dll("gdi32", false).}
proc DeleteDC(hdc: HDC): BOOL {.dll("gdi32", true).}
proc SetBkColor(hdc: HDC, color: COLORREF): COLORREF {.dll("gdi32", true).}
proc GetTextExtentPoint32(hdc: HDC, lpString: LPCWSTR, c: int32, psizl: LPSIZE): BOOL 
                        {.stdcall, dynlib: "gdi32", importc: "GetTextExtentPoint32W", discardable.}
proc MoveToEx(hdc: HDC, x: int32, y: int32, lppt: LPPOINT): BOOL {.dll("gdi32", true).}
proc LineTo(hdc: HDC, x: int32, y: int32): BOOL {.dll("gdi32", true).}
proc TextOut(hdc: HDC, x: int32, y: int32, lpString: LPCWSTR, c: int32): BOOL 
                    {.stdcall, dynlib: "gdi32", importc: "TextOutW", discardable.}
proc Rectangle(hdc: HDC, left: int32, top: int32, right: int32, bottom: int32): BOOL {.dll("gdi32", true).}
# End of Gdi32-------------------------------------------------------------------------------------------

# Misc dll functions {.dll("comctl32", false).}
proc SetWindowSubclass(hWnd: HWND, pfnSubclass: SUBCLASSPROC, uIdSubclass: UINT_PTR, 
                            dwRefData: DWORD_PTR): BOOL {.dll("comctl32", true).}
proc RemoveWindowSubclass(hWnd: HWND, pfnSubclass: SUBCLASSPROC, 
                                uIdSubclass: UINT_PTR): BOOL {.dll("comctl32", true).}
proc DefSubclassProc(hWnd: HWND, uMsg: UINT, wParam: WPARAM, lParam: LPARAM): LRESULT {.dll("comctl32", false).}
proc InitCommonControlsFunc(P1: ptr INITCOMMONCONTROLSEX): BOOL 
                                {.stdcall, dynlib: "comctl32", importc: "InitCommonControlsEx", discardable.}
proc wcslen(pstr: LPCWSTR) : csize_t {.cdecl, header: "<wchar.h>",importc.}
proc sprintf(dest: cstring; format: cstring): cint {.importc, varargs, header: "stdio.h", discardable.}
proc GetScaleFactorForDevice*(disp: cint): cint {.importc, dynlib: "Shcore.dll".}
# End of Misc dll funcs------------------------------------------------------------------------------

# COM functions
proc CoInitializeEx*(pvReserved: LPVOID, dwCoInit: DWORD): HRESULT {.stdcall, dynlib: "ole32", importc.}



proc new_wstring(size: Natural): wstring {.inline.} = newSeq[WCHAR](size)

proc toString(buf: wstring): string =
    let blen = cast[int32](buf.len)
    let iLen = WideCharToMultiByte(CP_UTF8, 0, buf[0].addr, blen, nil, 0, nil, nil)
    if iLen <= 0: return ""
    var s: seq[char] = newSeq[char](iLen)
    if WideCharToMultiByte(CP_UTF8, 0, buf[0].addr, blen, 
                                s[0].addr, iLen, nil, nil) != iLen:            
        return ""

    result = s.join()
    


        

# proc toUtf8String(wBuffer: seq[WCHAR]): string =
#     let iLen = WideCharToMultiByte(CP_UTF8, 0, wBuffer[0].addr, int32(wBuffer.len), nil, 0, nil, nil)
#     if iLen <= 0: return ""
#     var s: seq[char] = newSeq[char](iLen)
#     if WideCharToMultiByte(CP_UTF8, 0, wBuffer[0].addr, int32(wBuffer.len), s[0].addr, iLen, nil, nil) != iLen:
#         return ""
#     # result = newStringOfCap(iLen)
#     # for ch in s: add(result, ch)
#     result = s.join()

proc wcharArrayToString(wArrPtr: LPCWSTR|LPWSTR): string =
    let length = cast[int32](wcslen(wArrPtr))
    let iLen = WideCharToMultiByte(CP_UTF8, 0, wArrPtr, length, nil, 0, nil, nil)
    var s: seq[char] = newSeq[char](iLen)
    if WideCharToMultiByte(CP_UTF8, 0, wArrPtr, 
                    length, s[0].addr, iLen, nil, nil) != iLen:
        return ""
    # result = newStringOfCap(iLen)
    # for ch in s: add(result, ch)
    result = s.join()


proc toWcharPtr*(txt: string): LPCWSTR =
    var nws = newWideCString(txt)
    result = nws[0].addr
  

proc toLPWSTR(txt: string): LPWSTR {.inline.} = newWideCString(txt)[0].addr

template LOWORD(l: untyped): WORD  = WORD(l and 0xffff)
template HIWORD(l: untyped): WORD = WORD((l shr 16) and 0xffff)
template GET_WHEEL_DELTA_WPARAM*(wParam: untyped): SHORT = cast[SHORT](HIWORD(wParam))
proc `&`*[T](x: var T): ptr T {.inline.} = result = x.addr ## Use `&` like it in C/C++.
proc `&`*(x: var wstring): ptr WCHAR {.inline.} = result = x[0].addr
