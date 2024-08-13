# Controls module. Created on 27-Mar-2023 01:35 AM; Author kcvinker
## Control type - Base type for all other controls and Form.
#     Constructor - No constructor available. This is an astract type.
#     Functions - No public function in this type
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

    # Events
    #     onMouseEnter*, onClick*, onMouseLeave*, onRightClick*, onDoubleClick*,
    #     onLostFocus*, onGotFocus*: EventHandler - proc(c: Control, e: EventArgs)

    #     onMouseWheel*, onMouseHover*, onMouseMove*, onMouseDown*, onMouseUp*
    #     onRightMouseDown*, onRightMouseUp*: MouseEventHandler - - proc(c: Control, e: MouseEventArgs)

    #     onKeyDown*, onKeyUp*: KeyEventHandler - proc(c: Control, e: KeyEventArgs)
    #     onKeyPress*: KeyPressEventHandler - proc(c: Control, e: KeyPressEventArgs)


const
    BCM_FIRST = 0x1600
    BCM_GETIDEALSIZE = BCM_FIRST+0x1

    ES_NUMBER = 0x2000
    ES_LEFT = 0
    ES_CENTER = 1
    ES_RIGHT = 2
    EN_UPDATE = 0x0400
    EM_SETSEL = 0x00B1

# Control class names
let BtnClass : array[7, uint16] = [0x42, 0x75, 0x74, 0x74, 0x6F, 0x6E, 0]

# Package variables==================================================
var globalCtlID : int32 = 100
var globalSubClassID : UINT_PTR = 1000

# Control class's methods====================================================
proc setSubclass(this: Control, ctlWndProc: SUBCLASSPROC) =
    SetWindowSubclass(this.mHandle, ctlWndProc, globalSubClassID, cast[DWORD_PTR](cast[PVOID](this)))
    globalSubClassID += 1

proc cmenuDtor*(this: ContextMenu)
proc destructor(this: Control) =
    if this.mBkBrush != nil: DeleteObject(this.mBkBrush)
    if this.mCemnuUsed: this.mContextMenu.cmenuDtor()
    # if this.mFont.handle != nil: DeleteObject(this.mFont.handle)

proc sendMsg(this: Control, msg: UINT, wpm: auto, lpm: auto): LRESULT {.discardable, inline.} =
    return SendMessageW(this.mHandle, msg, cast[WPARAM](wpm), cast[LPARAM](lpm))

proc setFontInternal(this: Control) =
    if this.mIsCreated:
        if this.mFont.handle == nil: this.mFont.createHandle(this.mHandle)
        this.sendMsg(WM_SETFONT, this.mFont.handle, 1)

proc checkRedraw(this: Control) =
    if this.mIsCreated: InvalidateRect(this.mHandle, nil, 0)

proc getControlText(hw: HWND): string =
    let count = GetWindowTextLengthW(hw)
    var buffer = new_wstring(count + 1)
    GetWindowTextW(hw, buffer[0].unsafeAddr, count + 1)
    result = buffer.toString
    



proc mapParentPoints(this: Control) : RECT =
    var
        rc : RECT
        firstHwnd : HWND
    if this.mIsCreated:
        GetClientRect(this.mHandle, rc.unsafeAddr)
        firstHwnd = this.mHandle
    else:
        firstHwnd = this.mParent.mHandle
        rc = RECT(left: this.mXpos, top: this.mYpos,
                    right: (this.mXpos + this.mWidth), bottom: (this.mYpos + this.mHeight ))

    MapWindowPoints(firstHwnd, this.mParent.mHandle, cast[LPPOINT](rc.unsafeAddr), 2)
    # echo rc.repr
    result = rc

# Control class's properties==========================================
proc handle*(this: Control): HWND = this.mHandle

proc `font=`*(this: Control, value: Font) {.inline.} =
    this.mFont = value
    if this.mIsCreated: this.setFontInternal()

proc font*(this: Control): Font {.inline.} = return this.mFont

proc `text=`*(this: Control, value: string) {.inline.} =
    this.mText = value
    if this.mIsCreated:
        SetWindowTextW(this.mHandle, this.mText.toWcharPtr);

proc text*(this: Control): string {.inline.} = return this.mText

proc `width=`*(this: Control, value: int32) {.inline.} =
    this.mWidth = value
    if this.mIsCreated:
        SetWindowPos(this.mHandle, nil, this.mXpos, this.mYpos, this.mWidth, this.mHeight, SWP_NOZORDER)

proc width*(this: Control): int32 {.inline.} = return this.mWidth

proc `height=`*(this: Control, value: int32) {.inline.} =
    this.mHeight = value
    if this.mIsCreated: discard

proc height*(this: Control): int32 {.inline.} = return this.mHeight

proc `xpos=`*(this: Control, value: int32) {.inline.} =
    this.mXpos = value
    if this.mIsCreated: discard

proc xpos*(this: Control): int32 {.inline.} = return this.mXpos

proc `ypos=`*(this: Control, value: int32) {.inline.} =
    this.mYpos = value
    if this.mIsCreated: discard

proc ypos*(this: Control): int32 {.inline.} = return this.mYpos

proc `backColor=`*(this: Control, value: uint) {.inline.} =
    this.mBackColor = newColor(value)
    if (this.mDrawMode and 2) != 2 : this.mDrawMode += 2
    if this.mIsCreated:
        this.mBkBrush = this.mBackColor.makeHBRUSH
        InvalidateRect(this.mHandle, nil, 0)

proc `backColor=`*(this: Control, value: Color) {.inline.} =
    this.mBackColor = value
    if (this.mDrawMode and 2) != 2 : this.mDrawMode += 2
    if this.mIsCreated:
        this.mBkBrush = this.mBackColor.makeHBRUSH
        InvalidateRect(this.mHandle, nil, 0)

proc backColor*(this: Control): Color {.inline.} = return this.mBackColor

proc `foreColor=`*(this: Control, value: uint) {.inline.} =
    this.mForeColor = newColor(value)
    if (this.mDrawMode and 1) != 1 : this.mDrawMode += 1
    # this.mBkBrush = this.mForeColor.makeHBRUSH ------Delete later
    if this.mIsCreated: InvalidateRect(this.mHandle, nil, 0)

proc foreColor*(this: Control): Color {.inline.} = return this.mForeColor

# proc left*(this: Control): int32 = int32(this.mcRect.left)
# proc top*(this: Control): int32 = int32(this.mcRect.top)

# private function
proc getMappedRect(this: Control): RECT =
    var fhwnd : HWND
    var rct : RECT
    if this.mIsCreated:
        GetClientRect(this.mHandle, rct.unsafeAddr)
        fhwnd = this.mHandle
    else:
        rct = RECT(left: this.mXpos, top: this.mYpos, right: (this.mXpos + this.mWidth), bottom: (this.mYpos + this.mHeight))
        fhwnd = this.mParent.handle

    MapWindowPoints(fhwnd, this.mParent.handle, cast[LPPOINT](rct.unsafeAddr), 2)
    result = rct


proc right*(this: Control, value: int32): int32 = this.getMappedRect().right + value
proc bottom*(this: Control, value: int32): int32 = this.getMappedRect().bottom + value

proc `->`*(this: Control, value: int32) : int32 = this.getMappedRect().right + value
proc `>>`*(this: Control, value: int32): int32 = this.getMappedRect().bottom + value






# Event handlers for Control======================================================
proc leftButtonDownHandler(this: Control, msg: UINT, wp: WPARAM, lp: LPARAM) =
    if this.onMouseDown != nil: this.onMouseDown(this, newMouseEventArgs(msg, wp, lp))

proc leftButtonUpHandler(this: Control, msg: UINT, wp: WPARAM, lp: LPARAM) =
    if this.onMouseUp != nil: this.onMouseUp(this, newMouseEventArgs(msg, wp, lp))
    if this.onClick != nil: this.onClick(this, newEventArgs())

proc rightButtonDownHandler(this: Control, msg: UINT, wp: WPARAM, lp: LPARAM) =
    if this.onRightMouseDown != nil: this.onRightMouseDown(this, newMouseEventArgs(msg, wp, lp))

proc rightButtonUpHandler(this: Control, msg: UINT, wp: WPARAM, lp: LPARAM) =
    if this.onRightMouseUp != nil: this.onRightMouseUp(this, newMouseEventArgs(msg, wp, lp))
    if this.onRightClick != nil: this.onRightClick(this, newEventArgs())

proc mouseWheelHandler(this: Control, msg: UINT, wp: WPARAM, lp: LPARAM) =
    if this.onMouseWheel != nil: this.onMouseWheel(this, newMouseEventArgs(msg, wp, lp))

proc mouseMoveHandler(this: Control, msg: UINT, wp: WPARAM, lp: LPARAM) =
    if this.mIsMouseEntered:
        if this.onMouseMove != nil: this.onMouseMove(this, newMouseEventArgs(msg, wp, lp))
    else:
        this.mIsMouseEntered = true
        if this.onMouseEnter != nil: this.onMouseEnter(this, newEventArgs())

proc mouseLeaveHandler(this: Control) =
    this.mIsMouseEntered = false
    if this.onMouseLeave != nil: this.onMouseLeave(this, newEventArgs())

proc keyDownHandler(this: Control, wp: WPARAM) =
    if this.onKeyDown != nil: this.onKeyDown(this, newKeyEventArgs(wp))

proc keyUpHandler(this: Control, wp: WPARAM) =
    if this.onKeyUp != nil: this.onKeyUp(this, newKeyEventArgs(wp))

proc keyPressHandler(this: Control, wp: WPARAM) =
    if this.onKeyPress != nil: this.onKeyPress(this, newKeyPressEventArgs(wp))



# Package level functions====================================================
proc setControlRect(this: Control) =
    var lprct = this.mcRect.unsafeAddr
    GetClientRect(this.mHandle, lprct);
    MapWindowPoints(this.mHandle, this.mParent.mHandle, cast[LPPOINT](lprct), 2);
    # echo this.mKind, " Set rect"

proc createHandleInternal(this: Control, specialCtl: bool = false) =
    if not specialCtl:
        this.mCtlID = globalCtlID
        globalCtlID += 1
    # echo "creation started ", this.mKind
    this.mHandle = CreateWindowExW( this.mExStyle,
                                    this.mClassName,
                                    toWcharPtr(this.mText),
                                    this.mStyle, this.mXpos, this.mYpos,
                                    this.mWidth, this.mHeight,
                                    this.mParent.mHandle, cast[HMENU](this.mCtlID),
                                    this.mParent.hInstance, nil)
    if this.mHandle != nil:
        # echo "creation finished ", this.mKind
        this.mIsCreated = true
        # this.setControlRect()

# Only used CheckBox & RadioButton
proc setIdealSize(this: Control) =
    var ss: SIZE
    this.sendMsg(BCM_GETIDEALSIZE, 0, ss.unsafeAddr)
    this.mWidth = ss.cx
    this.mHeight = ss.cy
    MoveWindow(this.mHandle, this.mXpos, this.mYpos, ss.cx, ss.cy, 1)

method autoCreate(c: Control) {.base.} =
    quit "Childs are responsible for this"



# Here we are including contextmenu module. Because, contextmenu should be available for all controls.
include contextmenu

# proc setContextMenuInternal(this: Control)

proc contextMenu*(this: Control): ContextMenu = this.mContextMenu

proc `contextMenu=`*(this: Control, value: ContextMenu) =
    this.mContextMenu = value
    this.mCemnuUsed = true

proc setContextMenu*(parent: Control, menuNames: varargs[string, `$`]) : ContextMenu {.discardable.} =
    result = newContextMenu(parent, menuNames)
    parent.mContextMenu = result
    parent.mCemnuUsed = true