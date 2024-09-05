# menu module - Created on 14-Aug-2024 00:57
#[========================================TrayIcon Docs========================================
    Constructor: newTrayIcon
    Functions:
        showBalloon
        addContextMenu

    Properties:
        menuTrigger     : TrayMenuTrigger - enum [See typemodule.nim]
        tooltip         : string
        icon            : string

    Events:
        TrayIconEventHandler type - proc(c: TrayIcon, e: EventArgs)
            onBalloonShow
            onBalloonClose
            onBalloonClick
            onMouseMove
            onLeftMouseDown
            onLeftMouseUp
            onRightMouseDown
            onRightMouseUp
            onLeftClick
            onRightClick
            onLeftDoubleClick
===============================================================================================]#

# Class name - "Tray_Msg_Win"
let trayClsName : array[13, uint16] = [0x54, 0x72, 0x61, 0x79, 0x5F, 0x4D, 0x73, 0x67, 0x5F, 0x57, 0x69, 0x6E, 0]
const LIMG_FLAG = LR_DEFAULTCOLOR or LR_LOADFROMFILE
var trayWinRegistered : bool
proc createTrayMsgWindow(this: TrayIcon) # Forward declaration
proc trayWndProc( hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM): LRESULT {.stdcall.}

const 
    # Notify Icon messages
    NIM_ADD = 0x00000000
    NIM_MODIFY = 0x00000001
    NIM_DELETE = 0x00000002
    NIM_SETFOCUS = 0x00000003
    NIM_SETVERSION = 0x00000004

    # Notify Icon Notifications
    NIF_MESSAGE = 0x00000001
    NIF_ICON = 0x00000002
    NIF_TIP = 0x00000004
    NIF_STATE = 0x00000008
    NIF_INFO = 0x00000010
    NIF_GUID = 0x00000020
    NIF_REALTIME = 0x00000040
    NIF_SHOWTIP = 0x00000080

    # Notify Icon Constants
    NIS_HIDDEN = 0x00000001
    NIS_SHAREDICON = 0x00000002

    NIIF_NONE = 0x00000000
    NIIF_INFO = 0x00000001
    NIIF_WARNING = 0x00000002
    NIIF_ERROR = 0x00000003
    NIIF_USER = 0x00000004
    NIIF_NOSOUND = 0x00000010
    NIIF_LARGE_ICON = 0x00000020
    NIIF_RESPECT_QUIET_TIME = 0x00000080
    NIIF_ICON_MASK = 0x0000000F
    NIN_SELECT           =   (WM_USER + 0)
    NINF_KEY             =   0x1
    NIN_KEYSELECT        =   (NIN_SELECT or NINF_KEY)
    NIN_BALLOONSHOW      =   (WM_USER + 2)
    NIN_BALLOONHIDE      =   (WM_USER + 3)
    NIN_BALLOONTIMEOUT   =   (WM_USER + 4)
    NIN_BALLOONUSERCLICK =   (WM_USER + 5)
    NIN_POPUPOPEN        =   (WM_USER + 6)
    NIN_POPUPCLOSE       =   (WM_USER + 7)


proc newTrayIcon*(tooltip : string, iconpath : string = ""): TrayIcon =
    new(result)
    result.mTooltip = tooltip
    result.mIconpath = iconpath
    result.createTrayMsgWindow()
    if iconpath == "":
        result.mhTrayIcon = LoadIconW(nil, IDI_SHIELD)
        result.mIconpath = "Sys_Icon_Shield"
    else:
        result.mhTrayIcon =  LoadImageW(nil, toWcharPtr(iconpath), IMAGE_ICON, 0, 0, LIMG_FLAG)
        if result.mhTrayIcon == nil:
            result.mhTrayIcon = LoadIconW(nil, IDI_SHIELD)
            result.mIconpath = "Sys_Icon_Shield"
            echo "Can't create icon from ", iconpath
    #-----------------------------------------------
    let tipTxt = newWideCString(tooltip)
    result.mNid.cbSize =  cast[DWORD](sizeof(result.mNid))
    result.mNid.hWnd = result.mMsgHwnd
    result.mNid.uID = 1
    result.mNid.uVersionOrTimeout = 4
    result.mNid.uFlags = NIF_ICON or NIF_MESSAGE or NIF_TIP
    result.mNid.uCallbackMessage = MM_TRAY_MSG
    result.mNid.hIcon = result.mhTrayIcon  
    for i in 0..tipTxt.len: result.mNid.toolTipText[i] = tipTxt[i]    
    let x = Shell_NotifyIconW(NIM_ADD, &result.mNid) 


proc trayIconDtor(this: TrayIcon) =
    DestroyWindow(this.mMsgHwnd)

# Properties------------------------------------------

proc menuTrigger*(this: TrayIcon): TrayMenuTrigger = this.mMenuTrigger

proc `menuTrigger=`*(this: TrayIcon, value: TrayMenuTrigger) =
    this.mMenuTrigger = value
    this.mTrig = cast[uint8](value)

proc tooltip*(this: TrayIcon): string = this.mToolTip

proc `tooltip=`*(this: TrayIcon, value: string) =
    this.mToolTip = value
    this.mNid.uFlags = NIF_ICON or NIF_MESSAGE or NIF_TIP
    let tipTxt = newWideCString(value)
    for i in 0..tipTxt.len: this.mNid.toolTipText[i] = tipTxt[i]
    let x = Shell_NotifyIconW(NIM_MODIFY, &this.mNid)


proc icon*(this: TrayIcon): string = this.mIconpath

proc `icon=`*(this: TrayIcon, value: string) =
    this.mIconpath = value
    this.mhTrayIcon =  LoadImageW(nil, toWcharPtr(value), IMAGE_ICON, 0, 0, LIMG_FLAG)
    if this.mhTrayIcon == nil:
            this.mhTrayIcon = LoadIconW(nil, IDI_SHIELD)
            echo "Can't create icon from ", value
    
    this.mNid.uFlags = NIF_ICON or NIF_MESSAGE or NIF_TIP
    this.mNid.hIcon = this.mhTrayIcon
    let x = Shell_NotifyIconW(NIM_MODIFY, &this.mNid)

proc contextMenu*(this: TrayIcon): ContextMenu = this.mCmenu
# Methods---------------------------------------------------

proc showBalloon*(this: TrayIcon, title, message: string, # Balloon title & Balloon text
                timeout: uint32, noSound: bool = false,  # Balloon timeout in ms, Do you want to play system sound?
                icon: BalloonIcon = BalloonIcon.biInfo,  # System defined icons, but you can choose custom icon.
                iconpath: string = "") =                 # If you choose custom icon, pass an icon path here.

    let bTitle = newWideCString(title)
    let bMsg = newWideCString(message)
    this.mNid.uFlags = NIF_ICON or NIF_MESSAGE or NIF_TIP or NIF_INFO
    for i in 0..bTitle.len: this.mNid.balloonTitle[i] = bTitle[i]
    for i in 0..bMsg.len: this.mNid.balloonText[i] = bMsg[i]
    if icon == BalloonIcon.biCustom and iconpath != "":
        this.mNid.hIcon =  LoadImageW(nil, toWcharPtr(iconpath), IMAGE_ICON, 0, 0, LIMG_FLAG)
        if this.mNid.hIcon == nil: 
            this.mNid.hIcon = this.mhTrayIcon
        else:
            # We successfully created an icon handle from 'iconpath' parameter.
            # So, for this balloon, we will show this icon. But We need to... 
            # ...reset the old icon after this balloon vanished. 
            # Otherwise, from now on we need to use this icon in Balloons and tray.
            this.mResetIcon = true
        #------------------------
    #----------------------------
    this.mNid.dwInfoFlags = cast[DWORD](icon)
    this.mNid.uVersionOrTimeout = timeout
    if noSound: this.mNid.dwInfoFlags = this.mNid.dwInfoFlags or NIIF_NOSOUND
    Shell_NotifyIconW(NIM_MODIFY, &this.mNid)
    this.mNid.dwInfoFlags = 0
    this.mNid.uFlags = 0


proc addContextMenu*(this: TrayIcon, trigger: TrayMenuTrigger, 
                        menuNames: varargs[string, `$`]) : ContextMenu {.discardable.} =
    result = newContextMenu(this, menuNames)
    this.mCmenu = result 
    this.mCmenuUsed = true
    this.mMenuTrigger = trigger
    this.mTrig = cast[uint8](trigger)



proc resetIconInternal(this: TrayIcon) =
    this.mNid.uFlags = NIF_ICON or NIF_MESSAGE or NIF_TIP
    this.mNid.hIcon = this.mhTrayIcon
    Shell_NotifyIconW(NIM_MODIFY, &this.mNid)
    this.mResetIcon = false # Revert to the default state

# proc showContextMenu(this: TrayIcon) =
#     var pt : POINT    
#     if not this.mCmenu.mMenuInserted: this.mCmenu.cmenuCreateHandle()
#     GetCursorPos(&pt)
#     TrackPopupMenu(this.mCmenu.mHandle, 2, pt.x, pt.y, 0, this.mCmenu.mDummyHwnd, nil)


proc createTrayMsgWindow(this: TrayIcon) =
    let clsname = cast[LPCWSTR](trayClsName[0].addr)
    if not trayWinRegistered:
        registerMessageWindowClass(clsname, trayWndProc)
        trayWinRegistered = true

    this.mMsgHwnd = CreateWindowExW(0, clsname, nil, 0, 0, 0, 0, 0, 
                                        HWND_MESSAGE, nil, appData.hInstance, nil)
    if this.mMsgHwnd != nil:
        SetWindowLongPtrW(this.mMsgHwnd, GWLP_USERDATA, cast[LONG_PTR](cast[PVOID](this)))
        appData.trayHwnd = this.mMsgHwnd
    else:
        echo "Cannot create dummy window for tray icon, Error: ", GetLastError()
    


proc trayWndProc( hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM): LRESULT {.stdcall.} =
    case msg
    of WM_DESTROY:
        var this  = cast[TrayIcon](GetWindowLongPtrW(hw, GWLP_USERDATA))
        Shell_NotifyIconW(NIM_DELETE, &this.mNid)
        if this.mhTrayIcon != nil: DestroyIcon(this.mhTrayIcon)
        if this.mCmenu != nil: this.mCmenu.cmenuDtor()
        appData.trayHwnd = nil
    
    of MM_TRAY_MSG:
        case lpm
        of NIN_BALLOONSHOW:
            var this  = cast[TrayIcon](GetWindowLongPtrW(hw, GWLP_USERDATA))
            if this.onBalloonShow != nil: this.onBalloonShow(this, newEventArgs())

        of NIN_BALLOONTIMEOUT:
            var this  = cast[TrayIcon](GetWindowLongPtrW(hw, GWLP_USERDATA))
            if this.onBalloonClose != nil: this.onBalloonClose(this, newEventArgs())
            if this.mResetIcon: this.resetIconInternal()

        of NIN_BALLOONUSERCLICK:
            var this  = cast[TrayIcon](GetWindowLongPtrW(hw, GWLP_USERDATA))
            if this.onBalloonClick != nil: this.onBalloonClick(this, newEventArgs())
            if this.mResetIcon: this.resetIconInternal()

        of WM_LBUTTONDOWN:
            var this  = cast[TrayIcon](GetWindowLongPtrW(hw, GWLP_USERDATA))
            if this.onLeftMouseDown != nil: this.onLeftMouseDown(this, newEventArgs())

        of WM_LBUTTONUP:
            var this  = cast[TrayIcon](GetWindowLongPtrW(hw, GWLP_USERDATA))
            if this.onLeftMouseUp != nil: this.onLeftMouseUp(this, newEventArgs())
            if this.onLeftClick != nil: this.onLeftClick(this, newEventArgs())
            if this.mCmenuUsed and (this.mTrig and 1) == 1 : 
                this.mCmenu.showMenu(0)

        of WM_LBUTTONDBLCLK:
            var this  = cast[TrayIcon](GetWindowLongPtrW(hw, GWLP_USERDATA))
            if this.onLeftDoubleClick != nil: this.onLeftDoubleClick(this, newEventArgs())
            if this.mCmenuUsed and (this.mTrig and 2) == 2:
                this.mCmenu.showMenu(0)

        of WM_RBUTTONDOWN:
            var this  = cast[TrayIcon](GetWindowLongPtrW(hw, GWLP_USERDATA))
            if this.onRightMouseDown != nil: this.onRightMouseDown(this, newEventArgs())

        of WM_RBUTTONUP:
            var this  = cast[TrayIcon](GetWindowLongPtrW(hw, GWLP_USERDATA))
            if this.onRightMouseUp != nil: this.onRightMouseUp(this, newEventArgs())
            if this.onRightClick != nil: this.onRightClick(this, newEventArgs())
            if this.mCmenuUsed and (this.mTrig and 4) == 4:
                this.mCmenu.showMenu(0)

        of WM_MOUSEMOVE:
            var this  = cast[TrayIcon](GetWindowLongPtrW(hw, GWLP_USERDATA))
            if this.onMouseMove != nil: this.onMouseMove(this, newEventArgs())

        else: return DefWindowProcW(hw, msg, wpm, lpm)


    else: return DefWindowProcW(hw, msg, wpm, lpm)
    return DefWindowProcW(hw, msg, wpm, lpm)