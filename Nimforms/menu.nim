
# menu module - Created on 13-Aug-2024 01:45 
# NOTE: This file is included in the middle of 'commons.nim'
#================================================================================
#[=====================================Menu Docs==================================================
    MenuBase:
        Abstract base type
        Properties:
            handle  : HMENU
            font    : Font
            menus   : Table[string, MenuItem]
        
    MenuBar ref object of MenuBase
        Constructor: newMenuBar
        Functions:
            addItem
            createHandle
    
    MenuItem ref object of MenuBase
        Constructor : newMenuItem
        Properties:
            foreColor   : Color
            enabled     : bool
            tag         : RootRef # User can store any object here.
        Functions:
            addItem

        Events:
            MenuEventHandler type - proc(m: MenuItem, e: EventArgs)
                onClick
                onPopup
                onCloseup
                onFocus
===================================================================================================]#
var staticMenuID : uint32 = 100 # Global static menu id.

proc newMenuBar*(parent: Form ) : MenuBar {.discardable.} =
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
    this.mFont.finalize()
    # echo "MenuBar destroy worked"

proc handleWmDrawItem(this: MenuBar, lpm: LPARAM) : LRESULT =
    var dis = cast[LPDRAWITEMSTRUCT](lpm)
    var mi = cast[MenuItem](cast[PVOID](dis.itemData))
    var txtClrRef : COLORREF = mi.mFgColor.cref

    if dis.itemState == 320 or dis.itemState == 257:
        # Mouse is over the menu. Check for enable state.
        if mi.mIsEnabled:
            let rcbot: int32 = (if mi.mType == mtBaseMenu: dis.rcItem.bottom else: dis.rcItem.bottom - 2)
            let rctop: int32 = (if mi.mType == mtBaseMenu: dis.rcItem.top + 1 else: dis.rcItem.top + 2)
            let rc = RECT(  left: dis.rcItem.left + 4,
                            top: rctop,
                            right: dis.rcItem.right,
                            bottom: rcbot )
            FillRect(dis.hDC, rc.unsafeAddr, this.mMenuHotBgBrush)
            FrameRect(dis.hDC, rc.unsafeAddr, this.mMenuFrameBrush)
            txtClrRef = 0x00000000
        else:
            FillRect(dis.hDC, dis.rcItem.unsafeAddr, this.mMenuGrayBrush)
            txtClrRef = this.mMenuGrayCref
    else:
        # Default menu drawing.
        FillRect(dis.hDC, dis.rcItem.unsafeAddr, this.mMenuDefBgBrush)
        if not mi.mIsEnabled: txtClrRef = this.mMenuGrayCref

    SetBkMode(dis.hDC, 1)
    if mi.mType == mtBaseMenu:
        dis.rcItem.left += 10
    else:
        dis.rcItem.left += 25
    SelectObject(dis.hDC, this.mFont.handle)
    SetTextColor(dis.hDC, txtClrRef)
    DrawTextW(dis.hDC, &mi.mWideText, -1, dis.rcItem.unsafeAddr, DT_LEFT or DT_SINGLELINE or DT_VCENTER)
    return 0


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
        result.mWideText = newWideString(result.mText)
        result.mType = mtyp
        result.mParentHandle = parentHmenu
        result.mBgColor = newColor(0xe9ecef)
        result.mFgColor = newColor(0x000000)
        result.mIsEnabled = true

    staticMenuID += 1

proc getTextSize(this: MenuItem, hw: HWND) =
    var hdc = GetDC(hw)
    GetTextExtentPoint32(hdc, &this.mWideText, this.mWideText.wcLen, 
                            this.mTxtSize.unsafeAddr)
    ReleaseDC(hw, hdc)
    this.mTxtSizeReady = true

proc menuItemDtor(this: MenuItem) =
    if len(this.mMenus) > 0:
        for key, menu in this.mMenus: menu.menuItemDtor()
    DestroyMenu(this.mHandle)
    # echo "MenuItem destroy worked"


proc handleWMMeasureItem(this: MenuItem, pmi: LPMEASUREITEMSTRUCT, hw: HWND) : LRESULT = 
    if not this.mTxtSizeReady: this.getTextSize(hw)
    if this.mType == mtBaseMenu:        
        pmi.itemWidth = UINT(this.mTxtSize.cx) #+ 10
        pmi.itemHeight = UINT(this.mTxtSize.cy)
    else:
        pmi.itemWidth = 140 #size.cx #+ 10
        pmi.itemHeight = 25
    return 1

proc getMenuState(this: MenuItem): uint32 =
    if this.mState == MenuState.msUnchecked : 
        result = 0 
    else:
        result = cast[uint32](this.mState)
    

proc insertMenuInternal(this: MenuItem, parentHmenu: HMENU, drawFlag: uint32) =
    var mii : MENUITEMINFOW
    mii.cbSize = cast[UINT](mii.sizeof)
    mii.fMask = MIIM_ID or MIIM_TYPE or MIIM_DATA or MIIM_SUBMENU or MIIM_STATE
    mii.fType = drawFlag
    mii.fState = this.getMenuState()
    mii.dwTypeData = &this.mWideText
    mii.cch = cast[UINT](this.mWideText.wcLen)
    mii.dwItemData = cast[ULONG_PTR](cast[PVOID](this))
    mii.wID = cast[UINT](this.mId)
    mii.hSubMenu = if this.mPopup : this.mHandle else: nil
    InsertMenuItemW(parentHmenu, UINT(this.mIndex), 1, mii.unsafeAddr)
    this.mIsCreated = true
    # echo "insert menu : ", this.mText, ", popup : ", this.mPopup


proc create(this: MenuItem, drawFlag: uint32) =
    case this.mType
    of mtBaseMenu, mtPopup:
        this.insertMenuInternal(this.mParentHandle, drawFlag)
        if len(this.mMenus) > 0:
            for key, menu in this.mMenus: menu.create(drawFlag)        

    of mtMenuItem:
        this.insertMenuInternal(this.mParentHandle, drawFlag)
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


proc createHandle*(this: MenuBar) =
    this.mMenuDefBgBrush = newColor(0xe9ecef).makeHBRUSH()
    this.mMenuHotBgBrush = newColor(0x90e0ef).makeHBRUSH()
    this.mMenuFrameBrush = newColor(0x0077b6).makeHBRUSH()
    if this.mFont.handle == nil: this.mFont.createHandle()
    var drawFlag : uint32 = MF_STRING
    if len(this.mMenus) > 0:
        if this.mCustDraw: 
            drawFlag = MF_OWNERDRAW
            var hdcmem : HDC = CreateCompatibleDC(nil)            
            let oldfont : HGDIOBJ = SelectObject(hdcmem, cast[HGDIOBJ](this.mFont.handle))
            for key, menu in this.mMenus:
                GetTextExtentPoint32(hdcmem, menu.mWideText.wptr, 
                                     cast[int32](len(menu.mText)), 
                                     menu.mTxtSize.unsafeAddr)
                if menu.mType == MenuType.mtBaseMenu: 
                    menu.mTxtSize.cx = (if menu.mTxtSize.cx < 100: 100 else: menu.mTxtSize.cx + 20)
            
            SelectObject(hdcmem, oldfont)
            DeleteDC(hdcmem)
        for key, menu in this.mMenus: menu.create(drawFlag)

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

proc `tag=`*(this: MenuItem, value: RootRef) =
    this.mTag = value

proc tag*(this: MenuItem): RootRef = this.mTag