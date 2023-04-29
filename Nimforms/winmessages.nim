# winmessages module - Created on 26-Mar-2023 12:22 PM
# This module contains all the necessary windows messages.
const
    WM_NULL = 0x0000
    WM_CREATE = 0x0001
    WM_DESTROY = 0x0002
    WM_MOVE = 0x0003
    WM_SIZE = 0x0005
    WM_ACTIVATE = 0x0006
    WA_INACTIVE = 0
    WA_ACTIVE = 1
    WA_CLICKACTIVE = 2
    WM_SETFOCUS = 0x0007
    WM_KILLFOCUS = 0x0008
    WM_ENABLE = 0x000A
    WM_SETREDRAW = 0x000B
    WM_SETTEXT = 0x000C
    WM_GETTEXT = 0x000D
    WM_GETTEXTLENGTH = 0x000E
    WM_PAINT = 0x000F
    WM_CLOSE = 0x0010
    WM_QUERYENDSESSION = 0x0011
    WM_QUERYOPEN = 0x0013
    WM_ENDSESSION = 0x0016
    WM_QUIT = 0x0012
    WM_ERASEBKGND = 0x0014
    WM_SYSCOLORCHANGE = 0x0015
    WM_SHOWWINDOW = 0x0018
    WM_WININICHANGE = 0x001A
    WM_SETTINGCHANGE = WM_WININICHANGE
    WM_DEVMODECHANGE = 0x001B
    WM_ACTIVATEAPP = 0x001C
    WM_FONTCHANGE = 0x001D
    WM_TIMECHANGE = 0x001E
    WM_CANCELMODE = 0x001F
    WM_SETCURSOR = 0x0020
    WM_MOUSEACTIVATE = 0x0021
    WM_CHILDACTIVATE = 0x0022
    WM_QUEUESYNC = 0x0023
    WM_GETMINMAXINFO = 0x0024
    WM_PAINTICON = 0x0026
    WM_ICONERASEBKGND = 0x0027
    WM_NEXTDLGCTL = 0x0028
    WM_SPOOLERSTATUS = 0x002A
    WM_DRAWITEM = 0x002B
    WM_MEASUREITEM = 0x002C
    WM_DELETEITEM = 0x002D
    WM_VKEYTOITEM = 0x002E
    WM_CHARTOITEM = 0x002F
    WM_SETFONT = 0x0030
    WM_GETFONT = 0x0031
    WM_SETHOTKEY = 0x0032
    WM_GETHOTKEY = 0x0033
    WM_QUERYDRAGICON = 0x0037
    WM_COMPAREITEM = 0x0039
    WM_GETOBJECT = 0x003D
    WM_COMPACTING = 0x0041
    WM_COMMNOTIFY = 0x0044
    WM_WINDOWPOSCHANGING = 0x0046
    WM_WINDOWPOSCHANGED = 0x0047
    WM_POWER = 0x0048
    PWR_OK = 1
    PWR_FAIL = -1
    PWR_SUSPENDREQUEST = 1
    PWR_SUSPENDRESUME = 2
    PWR_CRITICALRESUME = 3
    WM_COPYDATA = 0x004A
    WM_CANCELJOURNAL = 0x004B
    WM_NOTIFY = 0x004E
    WM_INPUTLANGCHANGEREQUEST = 0x0050
    WM_INPUTLANGCHANGE = 0x0051
    WM_TCARD = 0x0052
    WM_HELP = 0x0053
    WM_USERCHANGED = 0x0054
    WM_NOTIFYFORMAT = 0x0055
    NFR_ANSI = 1
    NFR_UNICODE = 2
    NF_QUERY = 3
    NF_REQUERY = 4
    WM_CONTEXTMENU = 0x007B
    WM_STYLECHANGING = 0x007C
    WM_STYLECHANGED = 0x007D
    WM_DISPLAYCHANGE = 0x007E
    WM_GETICON = 0x007F
    WM_SETICON = 0x0080
    WM_NCCREATE = 0x0081
    WM_NCDESTROY = 0x0082
    WM_NCCALCSIZE = 0x0083
    WM_NCHITTEST = 0x0084
    WM_NCPAINT = 0x0085
    WM_NCACTIVATE = 0x0086
    WM_GETDLGCODE = 0x0087
    WM_SYNCPAINT = 0x0088
    WM_NCMOUSEMOVE = 0x00A0
    WM_NCLBUTTONDOWN = 0x00A1
    WM_NCLBUTTONUP = 0x00A2
    WM_NCLBUTTONDBLCLK = 0x00A3
    WM_NCRBUTTONDOWN = 0x00A4
    WM_NCRBUTTONUP = 0x00A5
    WM_NCRBUTTONDBLCLK = 0x00A6
    WM_NCMBUTTONDOWN = 0x00A7
    WM_NCMBUTTONUP = 0x00A8
    WM_NCMBUTTONDBLCLK = 0x00A9
    WM_NCXBUTTONDOWN = 0x00AB
    WM_NCXBUTTONUP = 0x00AC
    WM_NCXBUTTONDBLCLK = 0x00AD
    WM_INPUT_DEVICE_CHANGE = 0x00fe
    WM_INPUT = 0x00FF
    WM_KEYFIRST = 0x0100
    WM_KEYDOWN = 0x0100
    WM_KEYUP = 0x0101
    WM_CHAR = 0x0102
    WM_DEADCHAR = 0x0103
    WM_SYSKEYDOWN = 0x0104
    WM_SYSKEYUP = 0x0105
    WM_SYSCHAR = 0x0106
    WM_SYSDEADCHAR = 0x0107
    WM_UNICHAR = 0x0109
    WM_KEYLAST = 0x0109
    UNICODE_NOCHAR = 0xFFFF
    WM_IME_STARTCOMPOSITION = 0x010D
    WM_IME_ENDCOMPOSITION = 0x010E
    WM_IME_COMPOSITION = 0x010F
    WM_IME_KEYLAST = 0x010F
    WM_INITDIALOG = 0x0110
    WM_COMMAND = 0x0111
    WM_SYSCOMMAND = 0x0112
    WM_TIMER = 0x0113
    WM_HSCROLL = 0x0114
    WM_VSCROLL = 0x0115
    WM_INITMENU = 0x0116
    WM_INITMENUPOPUP = 0x0117
    WM_MENUSELECT = 0x011F
    WM_GESTURE = 0x0119
    WM_GESTURENOTIFY = 0x011A
    WM_MENUCHAR = 0x0120
    WM_ENTERIDLE = 0x0121
    WM_MENURBUTTONUP = 0x0122
    WM_MENUDRAG = 0x0123
    WM_MENUGETOBJECT = 0x0124
    WM_UNINITMENUPOPUP = 0x0125
    WM_MENUCOMMAND = 0x0126
    WM_CHANGEUISTATE = 0x0127
    WM_UPDATEUISTATE = 0x0128
    WM_QUERYUISTATE = 0x0129
    UIS_SET = 1
    UIS_CLEAR = 2
    UIS_INITIALIZE = 3
    UISF_HIDEFOCUS = 0x1
    UISF_HIDEACCEL = 0x2
    UISF_ACTIVE = 0x4
    WM_CTLCOLORMSGBOX = 0x0132
    WM_CTLCOLOREDIT = 0x0133
    WM_CTLCOLORLISTBOX = 0x0134
    WM_CTLCOLORBTN = 0x0135
    WM_CTLCOLORDLG = 0x0136
    WM_CTLCOLORSCROLLBAR = 0x0137
    WM_CTLCOLORSTATIC = 0x0138
    MN_GETHMENU = 0x01E1
    WM_MOUSEFIRST = 0x0200
    WM_MOUSEMOVE = 0x0200
    WM_LBUTTONDOWN = 0x0201
    WM_LBUTTONUP = 0x0202
    WM_LBUTTONDBLCLK = 0x0203
    WM_RBUTTONDOWN = 0x0204
    WM_RBUTTONUP = 0x0205
    WM_RBUTTONDBLCLK = 0x0206
    WM_MBUTTONDOWN = 0x0207
    WM_MBUTTONUP = 0x0208
    WM_MBUTTONDBLCLK = 0x0209
    WM_MOUSEWHEEL = 0x020A
    WM_XBUTTONDOWN = 0x020B
    WM_XBUTTONUP = 0x020C
    WM_XBUTTONDBLCLK = 0x020D
    WM_MOUSEHWHEEL = 0x020e
    WM_MOUSELAST = 0x020e
    WHEEL_DELTA = 120
    XBUTTON1 = 0x0001
    XBUTTON2 = 0x0002
    WM_PARENTNOTIFY = 0x0210
    WM_ENTERMENULOOP = 0x0211
    WM_EXITMENULOOP = 0x0212
    WM_NEXTMENU = 0x0213
    WM_SIZING = 0x0214
    WM_CAPTURECHANGED = 0x0215
    WM_MOVING = 0x0216
    WM_POWERBROADCAST = 0x0218
    PBT_APMQUERYSUSPEND = 0x0000
    PBT_APMQUERYSTANDBY = 0x0001
    PBT_APMQUERYSUSPENDFAILED = 0x0002
    PBT_APMQUERYSTANDBYFAILED = 0x0003
    PBT_APMSUSPEND = 0x0004
    PBT_APMSTANDBY = 0x0005
    PBT_APMRESUMECRITICAL = 0x0006
    PBT_APMRESUMESUSPEND = 0x0007
    PBT_APMRESUMESTANDBY = 0x0008
    PBTF_APMRESUMEFROMFAILURE = 0x00000001
    PBT_APMBATTERYLOW = 0x0009
    PBT_APMPOWERSTATUSCHANGE = 0x000A
    PBT_APMOEMEVENT = 0x000B
    PBT_APMRESUMEAUTOMATIC = 0x0012
    PBT_POWERSETTINGCHANGE = 32787
    WM_DEVICECHANGE = 0x0219
    WM_MDICREATE = 0x0220
    WM_MDIDESTROY = 0x0221
    WM_MDIACTIVATE = 0x0222
    WM_MDIRESTORE = 0x0223
    WM_MDINEXT = 0x0224
    WM_MDIMAXIMIZE = 0x0225
    WM_MDITILE = 0x0226
    WM_MDICASCADE = 0x0227
    WM_MDIICONARRANGE = 0x0228
    WM_MDIGETACTIVE = 0x0229
    WM_MDISETMENU = 0x0230
    WM_ENTERSIZEMOVE = 0x0231
    WM_EXITSIZEMOVE = 0x0232
    WM_DROPFILES = 0x0233
    WM_MDIREFRESHMENU = 0x0234
    WM_POINTERDEVICECHANGE = 0x238
    WM_POINTERDEVICEINRANGE = 0x239
    WM_POINTERDEVICEOUTOFRANGE = 0x23a
    WM_TOUCH = 0x0240
    WM_NCPOINTERUPDATE = 0x0241
    WM_NCPOINTERDOWN = 0x0242
    WM_NCPOINTERUP = 0x0243
    WM_POINTERUPDATE = 0x0245
    WM_POINTERDOWN = 0x0246
    WM_POINTERUP = 0x0247
    WM_POINTERENTER = 0x0249
    WM_POINTERLEAVE = 0x024a
    WM_POINTERACTIVATE = 0x024b
    WM_POINTERCAPTURECHANGED = 0x024c
    WM_TOUCHHITTESTING = 0x024d
    WM_POINTERWHEEL = 0x024e
    WM_POINTERHWHEEL = 0x024f
    WM_IME_SETCONTEXT = 0x0281
    WM_IME_NOTIFY = 0x0282
    WM_IME_CONTROL = 0x0283
    WM_IME_COMPOSITIONFULL = 0x0284
    WM_IME_SELECT = 0x0285
    WM_IME_CHAR = 0x0286
    WM_IME_REQUEST = 0x0288
    WM_IME_KEYDOWN = 0x0290
    WM_IME_KEYUP = 0x0291
    WM_MOUSEHOVER = 0x02A1
    WM_MOUSELEAVE = 0x02A3
    WM_NCMOUSEHOVER = 0x02A0
    WM_NCMOUSELEAVE = 0x02A2
    WM_WTSSESSION_CHANGE = 0x02B1
    WM_TABLET_FIRST = 0x02c0
    WM_TABLET_LAST = 0x02df
    WM_CUT = 0x0300
    WM_COPY = 0x0301
    WM_PASTE = 0x0302
    WM_CLEAR = 0x0303
    WM_UNDO = 0x0304
    WM_RENDERFORMAT = 0x0305
    WM_RENDERALLFORMATS = 0x0306
    WM_DESTROYCLIPBOARD = 0x0307
    WM_DRAWCLIPBOARD = 0x0308
    WM_PAINTCLIPBOARD = 0x0309
    WM_VSCROLLCLIPBOARD = 0x030A
    WM_SIZECLIPBOARD = 0x030B
    WM_ASKCBFORMATNAME = 0x030C
    WM_CHANGECBCHAIN = 0x030D
    WM_HSCROLLCLIPBOARD = 0x030E
    WM_QUERYNEWPALETTE = 0x030F
    WM_PALETTEISCHANGING = 0x0310
    WM_PALETTECHANGED = 0x0311
    WM_HOTKEY = 0x0312
    WM_PRINT = 0x0317
    WM_PRINTCLIENT = 0x0318
    WM_APPCOMMAND = 0x0319
    WM_THEMECHANGED = 0x031A
    WM_CLIPBOARDUPDATE = 0x031d
    WM_DWMCOMPOSITIONCHANGED = 0x031e
    WM_DWMNCRENDERINGCHANGED = 0x031f
    WM_DWMCOLORIZATIONCOLORCHANGED = 0x0320
    WM_DWMWINDOWMAXIMIZEDCHANGE = 0x0321
    WM_DWMSENDICONICTHUMBNAIL = 0x0323
    WM_DWMSENDICONICLIVEPREVIEWBITMAP = 0x0326
    WM_GETTITLEBARINFOEX = 0x033f
    WM_HANDHELDFIRST = 0x0358
    WM_HANDHELDLAST = 0x035F
    WM_AFXFIRST = 0x0360
    WM_AFXLAST = 0x037F
    WM_PENWINFIRST = 0x0380
    WM_PENWINLAST = 0x038F
    WM_APP = 0x8000
    WM_USER = 0x0400

# Window styles
const
    WS_POPUP = 0x80000000
    WS_CHILD = 0x40000000
    WS_MINIMIZE = 0x20000000
    WS_VISIBLE = 0x10000000
    WS_DISABLED = 0x08000000
    WS_CLIPSIBLINGS = 0x04000000
    WS_CLIPCHILDREN = 0x02000000
    WS_MAXIMIZE = 0x01000000
    WS_CAPTION = 0x00C00000
    WS_BORDER = 0x00800000
    WS_DLGFRAME = 0x00400000
    WS_VSCROLL = 0x00200000
    WS_HSCROLL = 0x00100000
    WS_SYSMENU = 0x00080000
    WS_THICKFRAME = 0x00040000
    WS_GROUP = 0x00020000
    WS_TABSTOP = 0x00010000
    WS_MINIMIZEBOX = 0x00020000
    WS_MAXIMIZEBOX = 0x00010000
    WS_OVERLAPPED = 0x00000000
    WS_TILED = WS_OVERLAPPED
    WS_ICONIC = WS_MINIMIZE
    WS_SIZEBOX = WS_THICKFRAME
    WS_OVERLAPPEDWINDOW = WS_OVERLAPPED or WS_CAPTION or WS_SYSMENU or WS_THICKFRAME or WS_MINIMIZEBOX or WS_MAXIMIZEBOX
    WS_TILEDWINDOW = WS_OVERLAPPEDWINDOW
    WS_POPUPWINDOW = WS_POPUP or WS_BORDER or WS_SYSMENU
    WS_CHILDWINDOW = WS_CHILD
    WS_EX_DLGMODALFRAME = 0x00000001
    WS_EX_NOPARENTNOTIFY = 0x00000004
    WS_EX_TOPMOST = 0x00000008
    WS_EX_ACCEPTFILES = 0x00000010
    WS_EX_TRANSPARENT = 0x00000020
    WS_EX_MDICHILD = 0x00000040
    WS_EX_TOOLWINDOW = 0x00000080
    WS_EX_WINDOWEDGE = 0x00000100
    WS_EX_CLIENTEDGE = 0x00000200
    WS_EX_CONTEXTHELP = 0x00000400
    WS_EX_RIGHT = 0x00001000
    WS_EX_LEFT = 0x00000000
    WS_EX_RTLREADING = 0x00002000
    WS_EX_LTRREADING = 0x00000000
    WS_EX_LEFTSCROLLBAR = 0x00004000
    WS_EX_RIGHTSCROLLBAR = 0x00000000
    WS_EX_CONTROLPARENT = 0x00010000
    WS_EX_STATICEDGE = 0x00020000
    WS_EX_APPWINDOW = 0x00040000
    WS_EX_OVERLAPPEDWINDOW = WS_EX_WINDOWEDGE or WS_EX_CLIENTEDGE
    WS_EX_PALETTEWINDOW = WS_EX_WINDOWEDGE or WS_EX_TOOLWINDOW or WS_EX_TOPMOST
    WS_EX_LAYERED = 0x00080000
    WS_EX_NOINHERITLAYOUT = 0x00100000
    WS_EX_NOREDIRECTIONBITMAP = 0x00200000
    WS_EX_LAYOUTRTL = 0x00400000
    WS_EX_COMPOSITED = 0x02000000
    WS_EX_NOACTIVATE = 0x08000000

# My messages
const
    MM_NUMBER : UINT = 9000
    MM_MOUSE_LB_CLICK: UINT = MM_NUMBER + 1
    MM_MOUSE_RB_CLICK: UINT = MM_NUMBER + 2
    MM_NOTIFY_REFLECT: UINT = MM_NUMBER + 3
    MM_EDIT_COLOR: UINT = MM_NUMBER + 4
    MM_LABEL_COLOR: UINT = MM_NUMBER + 5
    MM_CTL_COMMAND: UINT = MM_NUMBER + 6
    MM_LIST_COLOR: UINT = MM_NUMBER + 7
    MM_BUDDY_RESIZE: UINT = MM_NUMBER + 8
    MM_HSCROLL: UINT = MM_NUMBER + 9
    MM_VSCROLL: UINT = MM_NUMBER + 10
    MM_MENU_EVENT: UINT = MM_NUMBER + 11
    MM_NODE_NOTIFY: UINT = MM_NUMBER + 12
    MM_MENU_ADDED: UINT = MM_NUMBER + 13


type # Key enum to represent all the keyboard keys
    Keys = enum
        keyModifier = -65536
        keyNone = 0,
        keyLButton, keyRButton, keyCancel, keyMButton, keyXButtonOne, keyXButtonTwo,
        keyBbackspace = 8,
        keyTab, keyLineFeed,
        keyClear = 12,
        keyEnter,
        keyShift = 16,
        keyCtrl, keyAlt, keyPause, keyCapsLock,
        keyEscape = 27,
        keySpace = 32,
        keyPageUp, keyPageDown, keyEnd, keyHome, keyLeftArrow, keyUpArrow, keyRightArrow, keyDownArrow,
        keySelect, keyPrint, keyExecute, keyPrintScreen, keyInsert, keyDelete, keyHelp,
        keyD0, keyD1, keyD2, keyD3, keyD4, keyD5, keyD6, keyD7, keyD8, keyD9,
        keyA = 65,
        keyB, keyC, keyD, keyE, keyF, keyG, keyH, keyI, keyJ, keyK, keyL, keyM, keyN,
        keyO, keyP, keyQ, keyR, keyS, keyT, keyU, keyV, keyW, keyX, keyY, keyZ,
        keyLeftWin, keyRightWin, keyApps,
        keySleep = 95,
        keyNumPad0, keyNumPad1, keyNumPad2, keyNumPad3, keyNumPad4, keyNumPad5,
        keyNumPad6, keyNumPad7, keyNumPad8, keyNumPad9,
        keyMultiply, keyAdd, keySeperator, keySubtract, keyDecimal, keyDivide,
        keyF1, keyF2, keyF3, keyF4, keyF5, keyF6, keyF7, keyF8, keyF9, keyF10,
        keyF11, keyF12, keyF13, keyF14, keyF15, keyF16, keyF17, keyF18, keyF19, keyF20,
        keyF21, keyF22, keyF23, keyF24,
        keyNumLock = 144,
        keyScroll,
        keyLeftShift = 160,
        keyRightShift, keyLeftCtrl, keyRightCtrl, keyLeftMenu, keyRightmenu,
        keyBrowserBack, keyBrowserForward, keyBrowerRefresh, keyBrowserStop,
        keyBrowserSearch, keyBrowserFavorites, keyBrowserHome,
        keyVolumeMute, keyVolumeDown, keyVolumeUp,
        keyMediaNextTrack, keyMediaPrevTrack, keyMediaStop, keyMediaPlayPause, launchMail, selectMedia,
        keyLaunchApp1, keyLaunchApp2,
        keyOEM1 = 186,
        keyOEMPlus, keyOEMComma, keyOEMMinus, keyOEMPeriod, keyOEMQuestion, keyOEMTilde,
        keyOEMOpenBracket = 219,
        keyOEMPipe, keyOEMCloseBracket, keyOEMQuotes, keyOEM8,
        keyOEMBackSlash = 226,
        keyProcess = 229,
        keyPacket = 231,
        keyAttn = 246,
        keyCrSel, keyExSel, keyEraseEof, keyPlay, keyZoom, keyNoName, keyPa1, keyOEMClear,  # start from 400
        keyKeyCode = 65535,
        keyShiftModifier = 65536,
        keyCtrlModifier = 131072,
        keyAltModifier = 262144,