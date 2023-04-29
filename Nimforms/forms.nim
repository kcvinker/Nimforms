# forms module Created on 23-Mar-2023 08:52 PM

# Form type
#   constructor - newForm*(title: string = "", width: int32 = 550, height: int32 = 400): Form
#   functions
        # createHandle() - Create the handle of form
        # display() - Show the form on screen
        # close() - Closes the form
        # setGradientColor*(clr1, clr2: uint) - Set gradient back color

#     Properties - Getter & Setter available
#       Name            Type
        # font          Font
        # text          string
        # width         int32
        # height        int32
        # xpos          int32
        # ypos          int32
        # backColor     Color
        # foreColor     Color
        # startPos      FormPos
        # formStyle     FormStyle
        # formState     WindowState
        # maximizeBox   bool
        # minimizeBox   bool
        # topMost       bool

    # Events
    #     onMouseEnter*, onClick*, onMouseLeave*, onRightClick*, onDoubleClick*,
    #     onLostFocus*, onGotFocus*: EventHandler - proc(c: Control, e: EventArgs)

    #     onMouseWheel*, onMouseHover*, onMouseMove*, onMouseDown*, onMouseUp*
    #     onRightMouseDown*, onRightMouseUp*: MouseEventHandler - proc(c: Control, e: MouseEventArgs)

    #     onLoad*, onActivate*, onDeActivate*, onMinimized*, onMoving*,
    #     onMoved*, onClosing*, onMaximized*, onRestored*: EventHandler
    #     onSizing*, onSized*: SizeEventHandler - proc(c: Control, e: SizeEventArgs)

template MAKEINTRESOURCE*(i: untyped): untyped = cast[LPTSTR](i and 0xffff)
# const menuTxtFlag : UINT =

# Constants
const
    CS_VREDRAW = 0x0001
    CS_HREDRAW = 0x0002
    CS_DBLCLKS = 0x0008
    CS_OWNDC = 0x0020
    CS_CLASSDC = 0x0040
    CS_PARENTDC = 0x0080
    CS_NOCLOSE = 0x0200
    CS_SAVEBITS = 0x0800
    IDI_APPLICATION = MAKEINTRESOURCE(32512)
    IDC_ARROW = MAKEINTRESOURCE(32512)
    ZERO_HINST = cast[HINSTANCE](0)
    ZERO_HWND = cast[HWND](0)
    ZERO_HMENU = cast[HMENU](0)
    GWLP_USERDATA = -21
    SC_MINIMIZE = 0xF020
    SC_MAXIMIZE = 0xF030
    SC_RESTORE = 0xF120
    TME_HOVER = 0x00000001
    TME_LEAVE = 0x00000002
    HOVER_DEFAULT = 0xFFFFFFFF'i32

proc mainWndProc( hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM): LRESULT {.stdcall.}

type    # A struct to hold essential information.
    AppData = object
        appStarted: bool
        loopStarted: bool
        screenWidth: int32
        screenHeight: int32
        formCount: int32
        mainHwnd: HWND
        isDateInit: bool
        iccEx: INITCOMMONCONTROLSEX

var appData : AppData

proc registerWinClass(this: Form) =
    appData.appStarted = true
    appData.screenWidth = GetSystemMetrics(0)
    appData.screenHeight = GetSystemMetrics(1)
    this.hInstance = GetModuleHandleW(nil)

    this.mClassName = "Nimforms_Window"
    this.mBackColor = newColor(0xF0F0F0)

    var wcex : WNDCLASSEXW
    wcex.cbSize = cast[UINT](sizeof(wcex))
    wcex.style = CS_HREDRAW or CS_VREDRAW or CS_DBLCLKS
    wcex.lpfnWndProc = mainWndProc
    wcex.cbClsExtra = 0
    wcex.cbWndExtra = 0
    wcex.hInstance = this.hInstance
    wcex.hIcon = LoadIconW(ZERO_HINST, cast[LPCWSTR](IDI_APPLICATION))
    wcex.hCursor = LoadCursorW(ZERO_HINST, cast[LPCWSTR](IDC_ARROW))
    wcex.hbrBackground = CreateSolidBrush(this.mBackColor.cref)         #
    wcex.lpszMenuName = nil
    wcex.lpszClassName = toWcharPtr(this.mClassName)
    var ret = RegisterClassEx(wcex.unsafeAddr)
    # echo "Register result ", ret


proc setFormStyles(this: Form) =
    case this.mFormStyle
    of fsFixed3D :
        this.mExStyle = fixed3DExStyle
        this.mStyle = fixed3DStyle
        if not this.mMaximizeBox: this.mStyle = this.mStyle xor WS_MAXIMIZEBOX
        if not this.mMinimizeBox: this.mStyle = this.mStyle xor WS_MINIMIZEBOX
    of fsFixedDialog :
        this.mExStyle = fixedDialogExStyle
        this.mStyle = fixedDialogStyle
        if not this.mMaximizeBox: this.mStyle = this.mStyle xor WS_MAXIMIZEBOX
        if not this.mMinimizeBox: this.mStyle = this.mStyle xor WS_MINIMIZEBOX
    of fsFixedSingle :
        this.mExStyle = fixedSingleExStyle
        this.mStyle = fixedSingleStyle
        if not this.mMaximizeBox: this.mStyle = this.mStyle xor WS_MAXIMIZEBOX
        if not this.mMinimizeBox: this.mStyle = this.mStyle xor WS_MINIMIZEBOX
    of fsNormalWindow :
        this.mExStyle = normalWinExStyle
        this.mStyle = normalWinStyle
        if not this.mMaximizeBox: this.mStyle = this.mStyle xor WS_MAXIMIZEBOX
        if not this.mMinimizeBox: this.mStyle = this.mStyle xor WS_MINIMIZEBOX
    of fsFixedTool :
        this.mExStyle = fixedToolExStyle
        this.mStyle = fixedToolStyle
    of fsSizableTool :
        this.mExStyle = sizableToolExStyle
        this.mStyle = sizableToolStyle
    of fsHidden:
        this.mExStyle = WS_EX_TOOLWINDOW
        this.mStyle = WS_BORDER
    else: discard

    if this.mTopMost: this.mExStyle = this.mExStyle or WS_EX_TOPMOST
    if this.mFormState == wsMaximized: this.mStyle = this.mStyle or WS_MAXIMIZE


proc setFormPosition(this: Form) =
    case this.mFormPos
    of fpCenter:
        this.mXpos = int32((appData.screenWidth - this.mWidth) / 2)
        this.mYpos = int32((appData.screenHeight - this.mHeight) / 2)
    of fpTopMid: this.mXpos = int32((appData.screenWidth - this.mWidth) / 2)
    of fpTopRight: this.mXpos = appData.screenWidth - this.mWidth
    of fpMidLeft: this.mYpos = int32((appData.screenHeight - this.mHeight) / 2)
    of fpMidRight:
        this.mXpos = appData.screenWidth - this.mWidth
        this.mYpos = int32((appData.screenHeight - this.mHeight) / 2)
    of fpBottomLeft: this.mYpos = appData.screenHeight - this.mHeight
    of fpBottomMid:
        this.mXpos = int32((appData.screenWidth - this.mWidth) / 2)
        this.mYpos = appData.screenHeight - this.mHeight
    of fpBottomRight:
        this.mXpos = appData.screenWidth - this.mWidth
        this.mYpos = appData.screenHeight - this.mHeight
    else: discard

proc getMenuFromHmenu(this: Form, menuHandle: HMENU): MenuItem =
    for key, menu in this.mMenuItemDict:
        if menu.mHmenu == menuHandle: return menu
    return nil

proc newForm*(title: string = "", width: int32 = 550, height: int32 = 400): Form =
    new(result)
    if not appData.appStarted: result.registerWinClass()
    appData.formCount += 1
    result.mWidth = width
    result.mHeight = height
    result.mXpos = 100
    result.mYpos = 100
    result.mFont = newFont("Tahoma", 11)
    result.mFormStyle = fsNormalWindow
    result.mFormPos = fpCenter
    result.mMaximizeBox = true
    result.mMinimizeBox = true
    result.mText = (if title == "": "Form_" & $appData.formCount else: title)


proc createHandle*(this: Form) =
    this.setFormStyles()
    this.setFormPosition()
    this.mHandle = CreateWindowExW( this.mExStyle,
                                    toWcharPtr(this.mClassName),
                                    toWcharPtr(this.mText),
                                    this.mStyle, this.mXpos, this.mYpos,
                                    this.mWidth, this.mHeight,
                                    nil, nil, this.hInstance, nil)
    if this.mHandle != nil:
        this.mIsCreated = true
        SetWindowLongPtrW(this.mHandle, GWLP_USERDATA, cast[LONG_PTR](cast[PVOID](this)))
        this.setFontInternal()

# Private function
proc mainLoop() =
    var uMsg : MSG
    while GetMessageW(uMsg.unsafeAddr, nil, 0, 0) != 0 :
        TranslateMessage(uMsg.unsafeAddr)
        DispatchMessageW(uMsg.unsafeAddr)

proc display*(this: Form) =
    ShowWindow(this.mHandle, 5)
    UpdateWindow(this.mHandle)
    if not appData.loopStarted:
        appData.loopStarted = true
        appData.mainHwnd = this.mHandle
        mainLoop()

proc close*(this: Form) = DestroyWindow(this.mHandle)

# Properties
proc `startPos=`*(this: Form, value: FormPos) {.inline.} =
    this.mFormPos = value
    if this.mIsCreated: discard

proc startPos*(this: Form): FormPos {.inline.} = return this.mFormPos

proc `formStyle=`*(this: Form, value: FormStyle) {.inline.} =
    this.mFormStyle = value
    if this.mIsCreated: discard

proc formStyle*(this: Form): FormStyle {.inline.} = return this.mFormStyle

proc `formState=`*(this: Form, value: WindowState) {.inline.} =
    this.mFormState = value
    if this.mIsCreated: discard

proc formState*(this: Form): WindowState {.inline.} = return this.mFormState

proc `maximizeBox=`*(this: Form, value: bool) {.inline.} =
    this.mMaximizeBox = value
    if this.mIsCreated: discard

proc maximizeBox*(this: Form): bool {.inline.} = return this.mMaximizeBox

proc `minimizeBox=`*(this: Form, value: bool) {.inline.} =
    this.mMinimizeBox = value
    if this.mIsCreated: discard

proc minimizeBox*(this: Form): bool {.inline.} = return this.mMinimizeBox

proc `topMost=`*(this: Form, value: bool) {.inline.} =
    this.mTopMost = value
    if this.mIsCreated: discard

proc topMost*(this: Form): bool {.inline.} = return this.mTopMost


proc trackMouseMove(hw: HWND) =
    var tme: TRACKMOUSEEVENT
    tme.cbSize = cast[DWORD](tme.sizeof)
    tme.dwFlags = TME_HOVER or TME_LEAVE
    tme.dwHoverTime = HOVER_DEFAULT
    tme.hwndTrack = hw
    TrackMouseEventFunc(tme.unsafeAddr)


proc mainWndProc( hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM): LRESULT {.stdcall.} =
    var this  = cast[Form](GetWindowLongPtrW(hw, GWLP_USERDATA))
    case msg
    of WM_DESTROY:
        this.destructor()
        if this.mFont.handle != nil: DeleteObject(this.mFont.handle)
        if hw == appData.mainHwnd:
            PostQuitMessage(0)

    of WM_CLOSE:
        if this.onClosing != nil: this.onClosing(this, newEventArgs())

    of WM_SHOWWINDOW:
        if not this.mIsLoaded:
            this.mIsLoaded = true
            if this.onLoad != nil: this.onLoad(this, newEventArgs())

    of WM_ACTIVATEAPP:
        if (this.onActivate != nil) or (this.onDeActivate != nil):
            var ea = newEventArgs()
            let flag = cast[bool](wpm)
            if not flag:
                if this.onDeActivate != nil: this.onDeActivate(this, ea)
                return 0 ;
            else:
                if this.onActivate != nil: this.onActivate(this, ea)

    of WM_SYSCOMMAND :
        let uMsg = cast[UINT](wpm and 0xFFF0)
        case uMsg
        of SC_MINIMIZE:
            if this.onMinimized != nil: this.onMinimized(this, newEventArgs())
        of SC_MAXIMIZE:
            if this.onMaximized != nil: this.onMaximized(this, newEventArgs())
        of SC_RESTORE:
            if this.onRestored != nil: this.onRestored(this, newEventArgs())
        else: discard
    of WM_HSCROLL: return SendMessageW(cast[HWND](lpm), MM_HSCROLL, wpm, lpm)
    of WM_VSCROLL: return SendMessageW(cast[HWND](lpm), MM_VSCROLL, wpm, lpm)
    of WM_LBUTTONDOWN: this.leftButtonDownHandler(msg, wpm, lpm)
    of WM_LBUTTONUP: this.leftButtonUpHandler(msg, wpm, lpm)
    of WM_RBUTTONDOWN: this.rightButtonDownHandler(msg, wpm, lpm)
    of WM_RBUTTONUP: this.rightButtonUpHandler(msg, wpm, lpm)
    of WM_MOUSEWHEEL: this.mouseWheelHandler(msg, wpm, lpm)
    of WM_MOUSEMOVE:
        if not this.mIsMouseTracking:
            this.mIsMouseTracking = true
            trackMouseMove(hw)
            if not this.mIsMouseEntered:
                if this.onMouseEnter != nil:
                    this.mIsMouseEntered = true
                    this.onMouseEnter(this, newEventArgs())
        if this.onMouseMove != nil: this.onMouseMove(this, newMouseEventArgs(msg, wpm, lpm))

    of WM_MOUSEHOVER:
        if this.mIsMouseTracking: this.mIsMouseTracking = false
        if this.onMouseHover != nil: this.onMouseHover(this, newMouseEventArgs(msg, wpm, lpm))

    of WM_MOUSELEAVE:
        if this.mIsMouseTracking:
            this.mIsMouseTracking = false
            this.mIsMouseEntered = false
        if this.onMouseLeave != nil: this.onMouseLeave(this, newEventArgs())

    of WM_SIZING:
        var sea = newSizeEventArgs(msg, lpm)
        this.mWidth = sea.mWinRect.right - sea.mWinRect.left
        this.mHeight = sea.mWinRect.bottom - sea.mWinRect.top
        if this.onSizing != nil:
            this.onSizing(this, sea)
            return 1
        return 0

    of WM_SIZE:
        if this.onSized != nil:
            this.onSized(this, newSizeEventArgs(msg, lpm))
            return 1

    of WM_MOVE:
        this.mXpos = getXFromLp(lpm)
        this.mYpos = getYFromLp(lpm)
        if this.onMoved != nil: this.onMoved(this, newEventArgs())
        return 0

    of WM_MOVING :
        var rct = cast[LPRECT](lpm)
        this.mXpos = rct.left
        this.mYpos = rct.top
        if this.onMoving != nil:
            this.onMoving(this, newEventArgs())
            return 1
        return 0

    of WM_KEYUP, WM_SYSKEYUP:
        if this.onKeyUp != nil: this.onKeyUp(this, newKeyEventArgs(wpm))

    of WM_KEYDOWN, WM_SYSKEYDOWN:
        if this.onKeyDown != nil: this.onKeyDown(this, newKeyEventArgs(wpm))

    of  WM_CHAR:
        if this.onKeyPress != nil: this.onKeyPress(this, newKeyPressEventArgs(wpm))

    of WM_NOTIFY:
        let nmh = cast[LPNMHDR](lpm)
        return SendMessageW(nmh.hwndFrom, MM_NOTIFY_REFLECT, wpm, lpm)

    of WM_CTLCOLOREDIT:
        let ctHwnd = cast[HWND](lpm)
        return SendMessageW(ctHwnd, MM_EDIT_COLOR, wpm, lpm)

    of WM_CTLCOLORSTATIC:
        let ctHwnd = cast[HWND](lpm)
        return SendMessageW(ctHwnd, MM_LABEL_COLOR, wpm, lpm)

    of WM_MEASUREITEM:
        var pmi = cast[LPMEASUREITEMSTRUCT](lpm)
        var mi = cast[MenuItem](cast[PVOID](pmi.itemData))
        if mi.mType == mtBaseMenu:
            var hdc = GetDC(hw)
            var size : SIZE
            GetTextExtentPoint32(hdc, mi.mText.toLPWSTR(), int32(len(mi.mText)), size.unsafeAddr)
            ReleaseDC(hw, hdc)
            pmi.itemWidth = UINT(size.cx) #+ 10
            pmi.itemHeight = UINT(size.cy)
        else:
            pmi.itemWidth = 100 #size.cx #+ 10
            pmi.itemHeight = 25
        return 1

    of WM_DRAWITEM:
        var dis = cast[LPDRAWITEMSTRUCT](lpm)
        var mi = cast[MenuItem](cast[PVOID](dis.itemData))
        var txtClrRef : COLORREF = mi.mFgColor.cref

        if dis.itemState == 320 or dis.itemState == 257:
            # var rc : RECT
            if mi.mIsEnabled:
                let rc = RECT(left: dis.rcItem.left + 4, top: dis.rcItem.top + 2,
                              right: dis.rcItem.right, bottom: dis.rcItem.bottom - 2)
                FillRect(dis.hDC, rc.unsafeAddr, this.mMenuHotBgBrush)
                FrameRect(dis.hDC, rc.unsafeAddr, this.mMenuFrameBrush)
                txtClrRef = 0x00000000
            else:
                FillRect(dis.hDC, dis.rcItem.unsafeAddr, this.mMenuGrayBrush)
                txtClrRef = this.mMenuGrayCref
        else:
            FillRect(dis.hDC, dis.rcItem.unsafeAddr, this.mMenuDefBgBrush)
            if not mi.mIsEnabled: txtClrRef = this.mMenuGrayCref

        SetBkMode(dis.hDC, 1)
        if mi.mType == mtBaseMenu:
            dis.rcItem.left += 10
        else:
            dis.rcItem.left += 25
        SelectObject(dis.hDC, this.mMenuFont.handle)
        SetTextColor(dis.hDC, txtClrRef)
        DrawTextW(dis.hDC, mi.mWideText, -1, dis.rcItem.unsafeAddr, DT_LEFT or DT_SINGLELINE or DT_VCENTER)
        return 0

    of MM_MENU_ADDED:
        # User added a sub menu to an existing menu. We need to keep this in our table.
        this.mMenuItemDict[int32(wpm)] = cast[MenuItem](cast[PVOID](lpm))
        return 0

    of WM_MENUSELECT:
        var pmenu = this.getMenuFromHmenu(cast[HMENU](lpm))
        let mid = int32(LOWORD(wpm)) # Could be an id of a child menu or index of a child menu
        let hwwpm = HIWORD(wpm)
        if pmenu != nil:
            var menu : MenuItem
            case hwwpm:
                of 33152: # A normal child menu. We can use mid ad menu id.
                    menu = this.mMenuItemDict[mid]
                of 33168: # A popup child menu. We can use mid as index.
                    menu = pmenu.getChildFromIndex(mid)
                else: discard

            if menu != nil and menu.onFocus != nil : menu.onFocus(menu, newEventArgs())

    of WM_INITMENUPOPUP:
        var menu = this.getMenuFromHmenu(cast[HMENU](wpm))
        if menu != nil and menu.onPopup != nil: menu.onPopup(menu, newEventArgs())

    of WM_UNINITMENUPOPUP:
        var menu = this.getMenuFromHmenu(cast[HMENU](wpm))
        if menu != nil and menu.onCloseup != nil : menu.onCloseup(menu, newEventArgs())

    of WM_COMMAND:
        case HIWORD(wpm)
        of 0:
            var menu = this.mMenuItemDict[int32(LOWORD(wpm))]
            if menu != nil and menu.onClick != nil: menu.onClick(menu, newEventArgs())
            return 0
        else: discard

    else: return DefWindowProcW(hw, msg, wpm, lpm)
    return DefWindowProcW(hw, msg, wpm, lpm)
