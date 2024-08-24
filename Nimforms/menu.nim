
# menu module - Created on 13-Aug-2024 01:45 
# NOTE: This file is included in the middle of 'commons.nim'
#================================================================================
var staticMenuID : uint32 = 100 # Global static menu id.

proc newMenuBar*(parent: Form, menuFont: Font = nil ) : MenuBar {.discardable.} =
    new(result)
    result.mHandle = CreateMenu()
    result.mFormPtr = parent
    result.mFont = newFont("Tahoma", 11)
    result.mFormPtr.mMenubar = result
    result.mFormPtr.mIsMenuUsed = true
    result.mMenuGrayBrush = newColor(0xced4da).makeHBRUSH()
    result.mMenuGrayCref = newColor(0x979dac).cref
    

proc menuItemDtor(this: MenuItem) # forward declaration

proc menuBarDtor(this: MenuBar) =
    if len(this.mMenus) > 0:
        for key, menu in this.mMenus: menu.menuItemDtor()
    DestroyMenu(this.mHandle)    
    DeleteObject(this.mMenuDefBgBrush)
    DeleteObject(this.mMenuHotBgBrush)
    DeleteObject(this.mMenuFrameBrush)
    DeleteObject(this.mMenuGrayBrush )
    # echo "MenuBar destroy worked"


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

proc menuItemDtor(this: MenuItem) =
    if len(this.mMenus) > 0:
        for key, menu in this.mMenus: menu.menuItemDtor()
    DestroyMenu(this.mHandle)
    # echo "MenuItem destroy worked"

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
        # echo "Name: ", mi.mText, ", type: ", mi.mType


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
    if this.mFont.handle == nil: this.mFont.createHandle()
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