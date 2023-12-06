# commons module - Created on 26-Mar-2023 07:05 PM
# This module implements common functions & declarations.

# Window style combinations
import macros
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



# Font related functions
const
    LOGPIXELSY = 90
    DEFAULT_CHARSET = 1
    OUT_STRING_PRECIS = 1
    CLIP_DEFAULT_PRECIS = 0
    DEFAULT_QUALITY = 0

let CLR_WHITE = newColor(0xFFFFFF)
let CLR_BLACK = newColor(0x000000)


proc newFont*(fname: string, fsize: int32, fweight: FontWeight = FontWeight.fwNormal,
                italic: bool = false, underline: bool = false, strikeout: bool = false) : Font =
    new(result)
    if fname.len > 32 : raise newException(OSError, "Length of font name exceeds 32 characters")
    result.name = fname
    result.size = fsize
    result.weight = fweight
    result.italics = italic
    result.underLine = underline
    result.strikeOut = strikeout

proc createHandle(this: Font, hw: HWND) =
    var hdc = GetDC(hw)
    let scale = appData.scaleFactor / 100
    let fsiz = int32(scale * float(this.size))
    let iHeight = -MulDiv(fsiz , GetDeviceCaps(hdc, LOGPIXELSY), 72)
    ReleaseDC(hw, hdc)
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

# Some control needs to extract mouse position from lparam value.
proc getMousePos(lpm: LPARAM): POINT = POINT(x: int32(LOWORD(lpm)), y: int32(HIWORD(lpm)))

proc getMousePosOnMsg(): POINT =
    let dw_value = GetMessagePos()
    result.x = LONG(LOWORD(dw_value))
    result.y = LONG(HIWORD(dw_value))


#===========================================MENU SECTION==============================================
var staticMenuID : uint32 = 100

proc newMenuBar*(parent: Form, menuFont: Font = nil ) : MenuBar {.discardable.} =
    new(result)
    result.mHandle = CreateMenu()
    result.mFormPtr = parent
    result.mFont = newFont("Tahoma", 11)
    result.mFormPtr.mMenubar = result
    result.mFormPtr.mIsMenuUsed = true
    result.mMenuGrayBrush = newColor(0xced4da).makeHBRUSH()
    result.mMenuGrayCref = newColor(0x979dac).cref


proc newMenuItem*(txt: string, mtyp: MenuType, parentHmenu : HMENU, indexNum: uint32): MenuItem =
    new(result)
    if mtyp == mtSeparator:
        result.mType = mtyp
        result.mParentHandle = parentHmenu
    else:
        # echo "new menu : ", txt
        result.mPopup = if mtyp == mtBaseMenu or mtyp == mtPopup: true else: false
        result.mHandle = if result.mPopup : CreatePopupMenu() else: CreateMenu()
        result.mIndex = indexNum
        result.mId = staticMenuID
        result.mText = txt
        result.mWideText = toWcharPtr(result.mText)
        result.mType = mtyp
        result.mParentHandle = parentHmenu
        result.mBgColor = newColor(0xe9ecef)
        result.mFgColor = newColor(0x000000)
        result.mIsEnabled = true

    staticMenuID += 1

proc insertMenuInternal(this: MenuItem, parentHmenu: HMENU) =
    var mii : MENUITEMINFOW
    mii.cbSize = cast[UINT](mii.sizeof)
    mii.fMask = MIIM_ID or MIIM_TYPE or MIIM_DATA or MIIM_SUBMENU or MIIM_STATE
    mii.fType = MF_OWNERDRAW
    mii.dwTypeData = this.mText.toLPWSTR()
    mii.cch = cast[UINT](len(this.mText))
    mii.dwItemData = cast[ULONG_PTR](cast[PVOID](this))
    mii.wID = cast[UINT](this.mId)
    mii.hSubMenu = if this.mPopup : this.mHandle else: nil
    InsertMenuItemW(parentHmenu, UINT(this.mIndex), 1, mii.unsafeAddr)
    this.mIsCreated = true
    # echo "insert menu : ", this.mText, ", popup : ", this.mPopup

proc create(this: MenuItem) =
    case this.mType
    of mtBaseMenu, mtPopup:
        if len(this.mMenus) > 0:
            for key, menu in this.mMenus: menu.create()

        this.insertMenuInternal(this.mParentHandle)

    of mtMenuItem:
        this.insertMenuInternal(this.mParentHandle)
    of mtSeparator:
        AppendMenuW(this.mParentHandle, MF_SEPARATOR, 0, nil)
    else: discard


proc addItem*(this: MenuBar, txt: string, txtColor: uint = 0x000000): MenuItem {.discardable.} =
    result = newMenuItem(txt, mtBaseMenu, this.mHandle, this.mMenuCount)
    result.mFormHwnd = this.mFormPtr.mHandle
    result.mFgColor = newColor(txtColor)
    result.mFormMenu = true
    result.mBar = this
    this.mMenuCount += 1
    this.mMenus[txt] = result
    this.mFormPtr.mMenuItemDict[result.mId] = result

proc addItems*(this: MenuBar, args: varargs[string, `$`]) =
    for item in args:
        let typ : MenuType = (if item == "|": mtSeparator else: mtBaseMenu)
        var mi = newMenuItem(item, typ, this.mHandle, this.mMenuCount)
        mi.mFormHwnd = this.mFormPtr.mHandle
        mi.mFgColor = newColor(0x000000)
        mi.mFormMenu = true
        mi.mBar = this
        this.mMenuCount += 1
        this.mMenus[item] = mi
        this.mFormPtr.mMenuItemDict[mi.mId] = mi


proc addItem*(this: MenuItem, txt: string, txtColor: uint = 0x000000) : MenuItem {.discardable.} =
    if this.mType == mtMenuItem:
        this.mHandle = CreatePopupMenu()
        this.mPopup = true

    if this.mFormMenu:
        let mtyp : MenuType = (if txt == "|": mtSeparator else: mtMenuItem)
        result = newMenuItem(txt, mtyp, this.mHandle, this.mMenuCount)
        result.mFgColor = newColor(txtColor)
        result.mFormHwnd = this.mFormHwnd
        result.mFormMenu = this.mFormMenu
        result.mBar = this.mBar
        if this.mType != mtBaseMenu: this.mType = mtPopup
        this.mBar.mFormPtr.mMenuItemDict[result.mId] = result # Put new item in form's dict.
    else:
        raise newException(Exception, "Proc 'addItem' is only supporting menus in Menubar")

    this.mMenuCount += 1
    this.mMenus[txt] = result # Put new item in parent menu's dict

proc addItems*(this: MenuItem, args: varargs[string, `$`]) =
    if this.mType == mtMenuItem:
        this.mHandle = CreatePopupMenu()
        this.mPopup = true

    for item in args:
        let mtyp : MenuType = (if item == "|": mtSeparator else: mtMenuItem)
        var mi = newMenuItem(item, mtyp, this.mHandle, this.mMenuCount)
        mi.mFgColor = newColor(0x000000)
        mi.mFormHwnd = this.mFormHwnd
        mi.mFormMenu = this.mFormMenu
        mi.mBar = this.mBar
        if this.mType != mtBaseMenu: this.mType = mtPopup
        this.mMenuCount += 1
        this.mMenus[item] = mi # Put new item in parent menu's dict
        this.mBar.mFormPtr.mMenuItemDict[mi.mId] = mi # Put new item in form's dict.



# proc addSeparator*(this: MenuItem) =
    # var mi = newMenuItem("", mtSeparator, this.mHmenu, this.mChildCount)
    # this.mChildCount += 1
    # this.mMenus[mi.mText] = mi

proc createHandle*(this: MenuBar) =
    this.mMenuDefBgBrush = newColor(0xe9ecef).makeHBRUSH()
    this.mMenuHotBgBrush = newColor(0x90e0ef).makeHBRUSH()
    this.mMenuFrameBrush = newColor(0x0077b6).makeHBRUSH()
    if this.mFont.handle == nil: this.mFont.createHandle(this.mFormPtr.mHandle)
    if len(this.mMenus) > 0:
        for key, menu in this.mMenus: menu.create()

    SetMenu(this.mFormPtr.mHandle, this.mHandle)

proc getChildFromIndex(this: MenuItem, index: uint32): MenuItem =
    for key, menu in this.mMenus:
        if menu.mIndex == index:
            return menu
    return nil

proc menus*(this: MenuBar): Table[string, MenuItem] = this.mMenus
proc menus*(this: MenuItem): Table[string, MenuItem] = this.mMenus

# Without this overload, we can't use the index operator on 'menus' proc.
proc `[]`*(this: Table[string, MenuItem], key: string): MenuItem = tables.`[]`(this, key)

proc foreColor*(this : MenuItem): Color = this.mFgColor

proc `foreColor=`*(this: MenuItem, value: uint) =
    this.mFgColor = newColor(value)
    if this.mType == mtBaseMenu: InvalidateRect(this.mHandle, nil, 0)

proc `foreColor=`*(this: MenuItem, value: Color) =
    this.mFgColor = value
    if this.mType == mtBaseMenu: InvalidateRect(this.mHandle, nil, 0)


proc enabled*(this: MenuItem): bool = this.mIsEnabled

proc `enabled=`*(this: MenuItem, value: bool) =
    this.mIsEnabled = value
    if this.mType == mtBaseMenu: InvalidateRect(this.mHandle, nil, 0)

proc font*(this: MenuItem): Font = this.mFont

proc `font=`*(this: MenuItem, value: Font) =
    this.mFont = value
    if this.mType == mtBaseMenu: InvalidateRect(this.mHandle, nil, 0)

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
