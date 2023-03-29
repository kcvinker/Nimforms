# forms module Created on 23-Mar-2023 08:52 PM

# import std/strutils
template MAKEINTRESOURCE*(i: untyped): untyped = cast[LPTSTR](i and 0xffff)


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


proc newForm*(title: string = ""): Form =
    new(result)
    if not appData.appStarted: result.registerWinClass()
    appData.formCount += 1
    result.mWidth = 550
    result.mHeight = 400
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
        if hw == appData.mainHwnd:
            PostQuitMessage(0)
            quit(0)

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
        var nmh = cast[LPNMHDR](lpm)
        return SendMessageW(nmh.hwndFrom, MM_NOTIFY_REFLECT, wpm, lpm)


    else: return DefWindowProcW(hw, msg, wpm, lpm)
    return DefWindowProcW(hw, msg, wpm, lpm)
