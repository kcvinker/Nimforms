# forms module Created on 23-Mar-2023 08:52 PM

 #[====================================================Form Docs===============================================
  Constructor - newForm()
  functions
        createHandle()      - Create the handle of form
        display()           - Show the form on screen
        close()             - Closes the form
        setGradientColor()  - Set gradient back color

    Properties - 
        Form is inheriting all Control type properties. See 'controls.nim'
      Name             Type
        startPos      FormPos
        formStyle     FormStyle
        formState     WindowState
        maximizeBox   bool
        minimizeBox   bool
        topMost       bool

    Events
        Form is inheriting all Control type events. See 'controls.nim'
        EventHandler type events - proc(c: Control, e: EventArgs)
            onLoad
            onActivate
            onDeActivate
            onMinimized
            onMoving
            onMoved
            onClosing
            onMaximized
            onRestored
        SizeEventHandler type events - proc(c: Control, e: SizeEventArgs)
            onSizing
            onSized
        ThreadMsgHandler type event - proc(wpm: WPARAM, lpm: LPARAM)
            onThreadMsg
============================================================================================================]#

# const menuTxtFlag : UINT =
import std/monotimes
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
    ZERO_HINST = cast[HINSTANCE](0)
    ZERO_HWND = cast[HWND](0)
    ZERO_HMENU = cast[HMENU](0)
    SC_MINIMIZE = 0xF020
    SC_MAXIMIZE = 0xF030
    SC_RESTORE = 0xF120
    TME_HOVER = 0x00000001
    TME_LEAVE = 0x00000002
    HOVER_DEFAULT = 0xFFFFFFFF'i32

# Window class name : 'Nimforms_Window'
let frmClsName : array[16, uint16] = [0x4E, 0x69, 0x6D, 0x66, 0x6F, 0x72, 0x6D, 0x73, 0x5F, 0x57, 0x69, 0x6E, 0x64, 0x6F, 0x77, 0]

proc mainWndProc( hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM): LRESULT {.stdcall.} # forward declaration



proc getSystemDPI() =
    var hdc: HDC = GetDC(nil)
    appdata.sysDPI = GetDeviceCaps(hdc, LOGPIXELSY)
    ReleaseDC(nil, hdc)     
    appdata.scaleF = float(appdata.sysDPI) / 96.0
    echo "scalf ", appData.scaleF
    

proc registerWinClass(this: Form) =
    appData.appStarted = true
    appData.screenWidth = GetSystemMetrics(0)
    appData.screenHeight = GetSystemMetrics(1)
    appData.scaleFactor = GetScaleFactorForDevice(0)
    appData.hInstance = GetModuleHandleW(nil)
    appData.sendMsgBuffer = newWideString(64)
    this.hInstance = appData.hInstance

    
    getSystemDPI()

    this.mClassName = cast[LPCWSTR](frmClsName[0].addr) #toWcharPtr("Nimforms_Window")
    this.mBackColor = newColor(0xF0F0F0)
    echo "Appdata scale factor ", appData.scaleFactor
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
    wcex.lpszClassName = this.mClassName
    var ret = RegisterClassExW(wcex.addr)
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
        if menu.mHandle == menuHandle: return menu
    return nil

proc setBkClrInternal(this: Form, hdc: HDC) : int32 =
    var rct : RECT
    GetClientRect(this.mHandle, rct.unsafeAddr)
    if this.mFdMode == FormDrawMode.fdmFlat:
        this.mBkBrush = CreateSolidBrush(this.mBackColor.cref)
    # elif this.mFdMode == FormDrawMode.fdmGradient:
    #     createGradientBrush(this.mGrad, hdc, rct, gmDefault)
    #     this.mBkBrush = this.mGrad.defBrush


    let ret = FillRect(hdc, rct.unsafeAddr, this.mBkBrush)
    return 1

proc setGradientInfo(this: Form, c1, c2: uint, rtl: bool) =
    this.mGrad.c1 = newColor(c1)
    this.mGrad.c2 = newColor(c2)
    this.mGrad.rtl = rtl


proc newForm*(title: string = "", width: int32 = 550, height: int32 = 400): Form =
    new(result)
    if not appData.appStarted: result.registerWinClass()
    
    appData.formCount += 1
    result.mFormID = appData.formCount
    result.mKind = ctForm
    result.mWidth = adjDpi(width)
    result.mHeight = adjDpi(height)
    result.mXpos = 100
    result.mYpos = 100
    result.mFont = newFont("Tahoma", 11)
    result.mHasFont = true
    result.mFormStyle = fsNormalWindow
    result.mFdMode = fdmNormal
    result.mFormPos = fpCenter
    result.mMaximizeBox = true
    result.mMinimizeBox = true
    result.mText = (if title == "": "Form_" & $appData.formCount else: title)

# proc setFormFont(this: Form) =
#     this.mFont.createPrimaryHandle()


proc createHandle*(this: Form, create_childs: bool = false) =
    this.setFormStyles()
    this.setFormPosition()
    this.mCreateChilds = create_childs
    this.mHandle = CreateWindowExW( this.mExStyle,
                                    this.mClassName,
                                    toWcharPtr(this.mText),
                                    this.mStyle, this.mXpos, this.mYpos,
                                    this.mWidth, this.mHeight,
                                    nil, nil, this.hInstance, nil)
    if this.mHandle != nil:
        appData.sysDPI = cast[int32](GetDpiForWindow(this.mHandle))
        # appData.forms.add(FormMap(key: this.mHandle, value: this))
        this.mIsCreated = true
        SetWindowLongPtrW(this.mHandle, GWLP_USERDATA, cast[LONG_PTR](cast[PVOID](this)))
        # this.setFontInternal()
        this.mFont.createPrimaryHandle()
        # echo "ex : ", this.mExStyle, ", style : ", this.mStyle
        echo "GetDpiForWindows ", GetDpiForWindow(this.mHandle)
    else:
        echo "window creation error : ", GetLastError()
    

proc addMenubar*(this: Form, args: varargs[string, `$`]) : MenuBar =
    this.mMenubar = newMenuBar(this)
    if len(args) > 0:
        this.mMenubar.addItems(args)

    result = this.mMenubar

proc addTimer*(this: Form, interval: uint32 = 100, tickHandler: EventHandler = nil): Timer =
    new(result)
    result.interval = interval
    result.onTick = tickHandler
    result.mParentHwnd = this.mHandle
    result.mIdNum = cast[UINT_PTR](result)
    this.mTimerTable[result.mIdNum] = result

proc start*(this: Timer) =
    this.mIsEnabled = true
    SetTimer(this.mParentHwnd, this.mIdNum, this.interval, nil)

proc stop*(this: Timer) =
    KillTimer(this.mParentHwnd, this.mIdNum)
    this.mIsEnabled = false

proc timer_dtor(this: Timer) =
    if this.mIsEnabled:
        KillTimer(this.mParentHwnd, this.mIdNum)




# Private function
proc createChildHandles(self: Form) =
    if self.mIsMenuUsed: self.mMenubar.createHandle()
    for ctl in self.mControls:
        if ctl.mHandle == nil: ctl.autoCreate()

proc mainLoop() =
    var uMsg : MSG
    while GetMessageW(uMsg.unsafeAddr, nil, 0, 0) != 0 :
        TranslateMessage(uMsg.unsafeAddr)
        DispatchMessageW(uMsg.unsafeAddr)

proc display*(self: Form) =
    self.createChildHandles()
    ShowWindow(self.mHandle, 5)
    UpdateWindow(self.mHandle)
    if not appData.loopStarted:
        appData.loopStarted = true
        appData.mainHwnd = self.mHandle
        mainLoop()
        appData.appFinalize()

proc close*(this: Form) = DestroyWindow(this.mHandle)

proc setGradientBackColor*(this: Form, clr1, clr2 : uint, rtl: bool = false) =
    this.mFdMode = fdmGradient
    this.setGradientInfo(clr1, clr2, rtl )
    if this.mIsCreated: InvalidateRect(this.mHandle, nil, 1)

# Properties
proc `font=`*(this: Form, value: Font) =
    this.mFont = value
    this.mAppFont = false
    this.setUserFont()


proc `backColor=`*(this: Form, value: uint) =
    this.mFdMode = fdmFlat
    this.mBackColor = newColor(value)
    if this.mIsCreated: InvalidateRect(this.mHandle, nil, 1)

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

proc `createChilds=`*(this: Form, value: bool) = this.mCreateChilds = value

proc printPointProc(ctl: Control, e: MouseEventArgs) =
    echo "[X]: ", e.x, "  [Y]: ", e.y

proc printPoint*(this: Form) = this.onMouseUp = printPointProc

proc trackMouseMove(hw: HWND) =
    var tme: TRACKMOUSEEVENT
    tme.cbSize = cast[DWORD](tme.sizeof)
    tme.dwFlags = TME_HOVER or TME_LEAVE
    tme.dwHoverTime = HOVER_DEFAULT
    tme.hwndTrack = hw
    TrackMouseEventFunc(tme.unsafeAddr)

proc form_timer_handler(this: Form, wpm: WPARAM) =
    let key = cast[UINT_PTR](wpm)
    let timer : Timer = this.mTimerTable.getOrDefault(key)
    if timer != nil and timer.onTick != nil:
        timer.onTick(this, newEventArgs())

# proc menuBarDtor(this: MenuBar) # Forward declaration

proc form_dtor(this: Form, hw: HWND) =
    if this.mTimerTable.len > 0:
        for key, tmr in this.mTimerTable:
            tmr.timer_dtor()
            # echo "Timer freed"

    this.destructor() # Call the base destructor.
    if this.mFont.handle != nil: DeleteObject(this.mFont.handle)
    if this.mMenubar != nil: this.mMenubar.menuBarDtor()
    if hw == appData.mainHwnd: PostQuitMessage(0)



proc mainWndProc( hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM): LRESULT {.stdcall.} =
    case msg
    of WM_DESTROY: 
        var this  = cast[Form](GetWindowLongPtrW(hw, GWLP_USERDATA))
        this.form_dtor(hw)

    of WM_TIMER: 
        var this  = cast[Form](GetWindowLongPtrW(hw, GWLP_USERDATA))
        this.form_timer_handler(wpm)

    of MM_THREAD_MSG:
        var this  = cast[Form](GetWindowLongPtrW(hw, GWLP_USERDATA))
        if this.onThreadMsg != nil: this.onThreadMsg(wpm, lpm)

    of WM_CLOSE:
        var this  = cast[Form](GetWindowLongPtrW(hw, GWLP_USERDATA))
        if this.onClosing != nil: this.onClosing(this, newEventArgs())

    of WM_SHOWWINDOW:
        # echo "wm show window"
        var this  = cast[Form](GetWindowLongPtrW(hw, GWLP_USERDATA))
        if not this.mIsLoaded:
            this.mIsLoaded = true
            if this.onLoad != nil: this.onLoad(this, newEventArgs())

    of WM_ACTIVATEAPP:
        var this  = cast[Form](GetWindowLongPtrW(hw, GWLP_USERDATA))
        if (this.onActivate != nil) or (this.onDeActivate != nil):
            var ea = newEventArgs()
            let flag = cast[bool](wpm)
            if not flag:
                if this.onDeActivate != nil: this.onDeActivate(this, ea)
                return 0 ;
            else:
                if this.onActivate != nil: this.onActivate(this, ea)

    of WM_SYSCOMMAND :
        var this  = cast[Form](GetWindowLongPtrW(hw, GWLP_USERDATA))
        let uMsg = cast[UINT](wpm and 0xFFF0)
        case uMsg
        of SC_MINIMIZE:
            if this.onMinimized != nil: this.onMinimized(this, newEventArgs())
        of SC_MAXIMIZE:
            if this.onMaximized != nil: this.onMaximized(this, newEventArgs())
        of SC_RESTORE:
            if this.onRestored != nil: this.onRestored(this, newEventArgs())
        else: discard

    of WM_HSCROLL: 
        var this  = cast[Form](GetWindowLongPtrW(hw, GWLP_USERDATA))
        return SendMessageW(cast[HWND](lpm), MM_HSCROLL, wpm, lpm)

    of WM_VSCROLL: 
        var this  = cast[Form](GetWindowLongPtrW(hw, GWLP_USERDATA))
        return SendMessageW(cast[HWND](lpm), MM_VSCROLL, wpm, lpm)

    of WM_LBUTTONDOWN:
        # let a = getMonoTime()
        var this  = cast[Form](GetWindowLongPtrW(hw, GWLP_USERDATA))
        # var this = getForm(hw)
        # let b = getMonoTime()
        # echo "time for getting form : ", b - a
        this.leftButtonDownHandler(msg, wpm, lpm)
    of WM_LBUTTONUP:
        var this  = cast[Form](GetWindowLongPtrW(hw, GWLP_USERDATA))
        this.leftButtonUpHandler(msg, wpm, lpm)
    of WM_RBUTTONDOWN:
        var this  = cast[Form](GetWindowLongPtrW(hw, GWLP_USERDATA))
        this.rightButtonDownHandler(msg, wpm, lpm)
    of WM_RBUTTONUP:
        var this  = cast[Form](GetWindowLongPtrW(hw, GWLP_USERDATA))
        this.rightButtonUpHandler(msg, wpm, lpm)
    of WM_MOUSEWHEEL:
        var this  = cast[Form](GetWindowLongPtrW(hw, GWLP_USERDATA))
        this.mouseWheelHandler(msg, wpm, lpm)
    of WM_MOUSEMOVE:
        var this  = cast[Form](GetWindowLongPtrW(hw, GWLP_USERDATA))
        if not this.mIsMouseTracking:
            this.mIsMouseTracking = true
            trackMouseMove(hw)
            if not this.mIsMouseEntered:
                if this.onMouseEnter != nil:
                    this.mIsMouseEntered = true
                    this.onMouseEnter(this, newEventArgs())
        if this.onMouseMove != nil: this.onMouseMove(this, newMouseEventArgs(msg, wpm, lpm))

    of WM_MOUSEHOVER:
        var this  = cast[Form](GetWindowLongPtrW(hw, GWLP_USERDATA))
        if this.mIsMouseTracking: this.mIsMouseTracking = false
        if this.onMouseHover != nil: this.onMouseHover(this, newMouseEventArgs(msg, wpm, lpm))

    of WM_MOUSELEAVE:
        var this  = cast[Form](GetWindowLongPtrW(hw, GWLP_USERDATA))
        if this.mIsMouseTracking:
            this.mIsMouseTracking = false
            this.mIsMouseEntered = false
        if this.onMouseLeave != nil: this.onMouseLeave(this, newEventArgs())

    of WM_SIZING:
        var this  = cast[Form](GetWindowLongPtrW(hw, GWLP_USERDATA))
        var sea = newSizeEventArgs(msg, lpm)
        this.mWidth = sea.mWinRect.right - sea.mWinRect.left
        this.mHeight = sea.mWinRect.bottom - sea.mWinRect.top
        if this.onSizing != nil:
            this.onSizing(this, sea)
            return 1
        return 0

    of WM_SIZE:
        var this  = cast[Form](GetWindowLongPtrW(hw, GWLP_USERDATA))
        if this.onSized != nil:
            this.onSized(this, newSizeEventArgs(msg, lpm))
            return 1

    of WM_MOVE:
        var this  = cast[Form](GetWindowLongPtrW(hw, GWLP_USERDATA))
        this.mXpos = getXFromLp(lpm)
        this.mYpos = getYFromLp(lpm)
        if this.onMoved != nil: this.onMoved(this, newEventArgs())
        return 0

    of WM_MOVING:
        var this  = cast[Form](GetWindowLongPtrW(hw, GWLP_USERDATA))
        var rct = cast[LPRECT](lpm)
        this.mXpos = rct.left
        this.mYpos = rct.top
        if this.onMoving != nil:
            this.onMoving(this, newEventArgs())
            return 1
        return 0

    of WM_KEYUP, WM_SYSKEYUP:
        var this  = cast[Form](GetWindowLongPtrW(hw, GWLP_USERDATA))
        if this.onKeyUp != nil: this.onKeyUp(this, newKeyEventArgs(wpm))

    of WM_KEYDOWN, WM_SYSKEYDOWN:
        var this  = cast[Form](GetWindowLongPtrW(hw, GWLP_USERDATA))
        if this.onKeyDown != nil: this.onKeyDown(this, newKeyEventArgs(wpm))

    of  WM_CHAR:
        var this  = cast[Form](GetWindowLongPtrW(hw, GWLP_USERDATA))
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

    of WM_ERASEBKGND:
        var this  = cast[Form](GetWindowLongPtrW(hw, GWLP_USERDATA))
        if this.mFdMode != fdmNormal: return this.setBkClrInternal(cast[HDC](wpm))

    of WM_MEASUREITEM:
        # echo "wm measure item msg"
        var pmi = cast[LPMEASUREITEMSTRUCT](lpm)
        var mi = cast[MenuItem](cast[PVOID](pmi.itemData))
        return mi.handleWMMeasureItem(pmi, hw)

    of WM_DRAWITEM:
        var this  = cast[Form](GetWindowLongPtrW(hw, GWLP_USERDATA))
        return this.mMenuBar.handleWmDrawItem(lpm)

    of WM_MENUSELECT:
        var this  = cast[Form](GetWindowLongPtrW(hw, GWLP_USERDATA))
        var pmenu = this.getMenuFromHmenu(cast[HMENU](lpm))
        let mid = uint32(LOWORD(wpm)) # Could be an id of a child menu or index of a child menu
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
        var this  = cast[Form](GetWindowLongPtrW(hw, GWLP_USERDATA))
        var menu = this.getMenuFromHmenu(cast[HMENU](wpm))
        if menu != nil and menu.onPopup != nil: menu.onPopup(menu, newEventArgs())

    of WM_UNINITMENUPOPUP:
        var this  = cast[Form](GetWindowLongPtrW(hw, GWLP_USERDATA))
        var menu = this.getMenuFromHmenu(cast[HMENU](wpm))
        if menu != nil and menu.onCloseup != nil : menu.onCloseup(menu, newEventArgs())

    of WM_COMMAND:
        var this  = cast[Form](GetWindowLongPtrW(hw, GWLP_USERDATA))
        # echo "HIWORD(wpm) ", HIWORD(wpm), ", Lparam ", lpm, ", LOWORD(wpm) ", LOWORD(wpm)
        let hwpm = HIWORD(wpm)
        if hwpm == 0 and lpm == 0:
            # It's menu message
            case hwpm
            of 0:
                if len(this.mMenuItemDict) > 0:
                    var menu = this.mMenuItemDict[uint32(LOWORD(wpm))]
                    if menu != nil and menu.onClick != nil: menu.onClick(menu, newEventArgs())
                    return 0
            else:
                discard
        else:
            let ctHwnd = cast[HWND](lpm)
            return SendMessageW(ctHwnd, MM_CTL_COMMAND, wpm, lpm)
        
        
            

    of WM_CONTEXTMENU:
        var this  = cast[Form](GetWindowLongPtrW(hw, GWLP_USERDATA))
        if this.mContextMenu != nil: this.mContextMenu.showMenu(lpm)

    else: return DefWindowProcW(hw, msg, wpm, lpm)
    return DefWindowProcW(hw, msg, wpm, lpm)
