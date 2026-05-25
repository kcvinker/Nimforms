# Controls module. Created on 27-Mar-2023 01:35 AM; Author kcvinker
#[ 
    Control type - Base type for all other controls and Form.
    Constructor - No constructor available. This is an astract type.
    
    Properties - Getter & Setter available
      Name            Type
        font          Font
        text          string
        width         int32
        height        int32
        xpos          int32
        ypos          int32
        backColor     Color
        foreColor     Color

    Functions:
        

    Events
        EventHandler - proc(c: Control, e: EventArgs)
            onMouseEnter, onClick, onMouseLeave, onRightClick, onDoubleClick,
            onLostFocus, onGotFocus

        MouseEventHandler - - proc(c: Control, e: MouseEventArgs)
            onMouseWheel, onMouseHover, onMouseMove, onMouseDown, onMouseUp
            onRightMouseDown, onRightMouseUp

        KeyEventHandler - proc(c: Control, e: KeyEventArgs)
            onKeyDown, onKeyUp

        KeyPressEventHandler - proc(c: Control, e: KeyPressEventArgs)            
            onKeyPress
====================================================================================================]#



# Control class names
let BtnClass : array[7, uint16] = [0x42, 0x75, 0x74, 0x74, 0x6F, 0x6E, 0]

# Package variables==================================================
var globalCtlID : int32 = 100
var globalSubClassID : UINT_PTR = 1000

#===================Forward Declarations===================================
proc getMappedRect(this: Control): RECT
proc cloneParentFont*(this: Control)
proc setFontInternal(this: Control) {.inline.}
proc cmenuDtor(this: ContextMenu)
proc ctlSetPos(this: Control) {.inline.}=
    SetWindowPos(this.mHandle, nil, this.mXpos, this.mYpos, this.mWidth, this.mHeight, SWP_NOZORDER)




proc controlBaseInit(this: Control, parent: Control, x, y, w, h: int32, 
                            ctlCounter: var int, txt: string = "") =
    this.mParent = parent
    this.mXpos = x
    this.mYpos = y
    this.mWidth = w
    this.mHeight = h
    this.mCtlID = globalCtlID

    let ctlMeta : ControlMeta = ControlData[this.mKind]
    globalCtlID += 1
    ctlCounter += 1
    this.mName = ctlMeta.prefix & $ctlCounter
    this.mStyle = ctlMeta.wstyle
    this.mExStyle = ctlMeta.wexStyle

    if ctlMeta.info.isTextable and len(txt) > 0: 
        this.mText = txt
        this.mWtext = newWideString(txt)
        this.mHasText = true

    this.mOwnerForm = if parent.mKind == ControlType.ctForm: cast[Form](parent) else: parent.mOwnerForm
    if this.mOwnerForm != nil: 
        if ctlMeta.info.hasFont: this.cloneParentFont()
        if ctlMeta.info.backColorMode == bcmInherit:
            this.mBackColor = parent.mBackColor
        elif ctlMeta.info.backColorMode == bcmWhite:
            this.mBackColor = newColor(0xFFFFFF) # Default white background for all controls

        if ctlMeta.info.blackFGC:            
            this.mForeColor = newColor(0x000000) # Default black foreground for all controls
        else:
            this.mForeColor = this.mOwnerForm.mForeColor
        
        this.mOwnerForm.mControls.add(this)


proc controlBaseDtor(this: Control) =
    if this.mBkBrush != nil: DeleteObject(this.mBkBrush)
    if this.mCemnuUsed: this.mContextMenu.cmenuDtor()
    if this.mHasFont: 
        this.mFont.finalize()

    if this.mHasText: 
        this.mWtext.finalize()


proc createHandleInternal(this: Control, width, height: int32) =
    if this.mHandle != nil: return
    let ctlMeta : ControlMeta = ControlData[this.mKind]
    let txtPtr : LPCWSTR = (if this.mHasText: &this.mWtext else: nil)  
    let lpm: PVOID = if this.mKind == ControlType.ctPictureBox: cast[PVOID](this) else: nil
    this.mHandle = CreateWindowExW( this.mExStyle,
                                    ctlMeta.clsName,
                                    txtPtr, this.mStyle, 
                                    this.mXpos, this.mYpos,
                                    width, height,
                                    this.mParent.mHandle, cast[HMENU](this.mCtlID),
                                    appData.hInstance, lpm)
    if this.mHandle != nil:        
        this.mIsCreated = true
        if this.mHasFont: this.setFontInternal()
            
    else:
        echo "Error while creating the hwnd of ", this.mName, ", Err.No - ", GetLastError()


# Control class's methods====================================================
proc cloneParentFont*(this: Control) =
    # this.mFont = copyNewFont(this.mParent.mFont)
    this.mFont = this.mOwnerForm.mFont    
    this.mFont.mOwnership = FontOwner.foUser
    this.mFont.tag = this.mName
    this.mHasFont = true

proc copyAppFont(this: Form) =
    this.mFont = appData.defFont     
    this.mFont.mOwnership = FontOwner.foUser
    

proc right*(this: Control, value: int32 = 10): int32 =
    if this.mIsCreated:
        this.getMappedRect().right + value
    else:
        this.mXpos + this.mWidth + value

proc bottom*(this: Control, value: int32 = 10): int32 = 
    if this.mIsCreated:
        this.getMappedRect().bottom + value
    else:
        this.mYpos + this.mHeight + value

proc `->`*(this: Control, value: int32 = 10) : int32 = 
    if this.mIsCreated:
        this.getMappedRect().right + value
    else:
        this.mXpos + this.mWidth + value

proc `>>`*(this: Control, value: int32 = 10): int32 = 
    if this.mIsCreated:
        this.getMappedRect().bottom + value
    else:
        this.mYpos + this.mHeight + value

# Control class's properties==========================================
proc handle*(this: Control): HWND = this.mHandle

proc name*(this: Control): string {.inline.} = return this.mName

proc `font=`*(this: Control, value: Font) {.inline.} =
    this.mFont.finalize()
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
    if this.mIsCreated: this.ctlSetPos()
        # SetWindowPos(this.mHandle, nil, this.mXpos, this.mYpos, this.mWidth, this.mHeight, SWP_NOZORDER)

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

proc `onMouseEnter=`*(this: Control, evtProc: EventHandler) =
    this.mMouseEvents.incl(mouseEnterEvent)
    this.mTmeFlags.incl(tmeMLeave)
    this.mOnMouseEnter = evtProc

proc `onMouseLeave=`*(this: Control, evtProc: EventHandler) =
    this.mMouseEvents.incl(mouseLeaveEvent)
    this.mTmeFlags.incl(tmeMLeave)
    this.mOnMouseLeave = evtProc

method `onMouseHover=`*(this: Control, evtProc: EventHandler) {. base .} =
    this.mMouseEvents.incl(mouseHoverEvent)
    this.mTmeFlags.incl(tmeMHover)
    this.mTmeFlags.incl(tmeMLeave)
    this.mOnMouseHover = evtProc



# proc left*(this: Control): int32 = int32(this.mcRect.left)
# proc top*(this: Control): int32 = int32(this.mcRect.top)

# ============================================Private functions====================================

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

proc printControlRect*(this: Control) =
    var rct : RECT
    GetClientRect(this.mHandle, rct.unsafeAddr)
    echo "left: ", rct.left, ", top: ", rct.top, ", right: ", rct.right, ", bottom: ", rct.bottom

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
    result = rc

    

proc sendMsg(this: Control, msg: UINT, wpm: auto, lpm: auto): LRESULT {.discardable, inline.} =
    return SendMessageW(this.mHandle, msg, cast[WPARAM](wpm), cast[LPARAM](lpm))

proc setFontInternal(this: Control) {.inline.} =
    if this.mFont.handle == nil: 
        this.mFont.createHandle()
    let x = this.sendMsg(WM_SETFONT, this.mFont.handle, 1)


proc updateFontInternal(this: Control) =
    if this.mFont.handle != nil:
        if this.mFont.mOwnership == FontOwner.foOwner:
            DeleteObject(this.mFont.handle)
        else:
            this.mFont.handle = nil

        this.mFont.createHandle()
        this.sendMsg(WM_SETFONT, this.mFont.handle, 1)


proc setUserFont(this: Control) {.inline.} =
    if this.mFont.handle == nil:
        this.mFont.createHandle()
    if this.mIsCreated: 
        this.sendMsg(WM_SETFONT, this.mFont.handle, 1)
        


proc checkRedraw(this: Control) =
    if this.mIsCreated: InvalidateRect(this.mHandle, nil, 0)

proc getControlText(hw: HWND): string =
    let count = GetWindowTextLengthW(hw)
    var buffer = new_wstring(count + 1)
    GetWindowTextW(hw, buffer[0].unsafeAddr, count + 1)
    result = buffer.toString

proc setSubclass(this: Control, ctlWndProc: SUBCLASSPROC) =
    SetWindowSubclass(this.mHandle, ctlWndProc, globalSubClassID, cast[DWORD_PTR](cast[PVOID](this)))
    globalSubClassID += 1


proc isMouseOnMe(this: Control, lpm: LPARAM) : bool {. inline .} =
    let pt = POINT(x: getXFromLp(lpm), y: getYFromLP(lpm))
    return PtInRect(&this.mcRect, pt) != 0    


proc keyDownHandler(this: Control, wp: WPARAM) =
    if this.onKeyDown != nil: this.onKeyDown(this, newKeyEventArgs(wp))

proc keyUpHandler(this: Control, wp: WPARAM) =
    if this.onKeyUp != nil: this.onKeyUp(this, newKeyEventArgs(wp))

proc keyPressHandler(this: Control, wp: WPARAM) =
    if this.onKeyPress != nil: this.onKeyPress(this, newKeyPressEventArgs(wp))


#======================================================================================================
# Here we are including contextmenu module. Because, contextmenu should be available for all controls.
include contextmenu
#=====================================================================================================


proc contextMenu*(this: Control): ContextMenu = this.mContextMenu

proc `contextMenu=`*(this: Control, value: ContextMenu) =
    this.mContextMenu = value
    this.mCemnuUsed = true

proc setContextMenu*(parent: Control, menuNames: varargs[string, `$`]) : ContextMenu {.discardable.} =
    result = newContextMenu(parent, menuNames)
    parent.mContextMenu = result
    parent.mCemnuUsed = true


# Package level functions====================================================
proc setControlRect(this: Control) =
    var lprct = this.mcRect.unsafeAddr
    GetClientRect(this.mHandle, lprct);
    MapWindowPoints(this.mHandle, this.mParent.mHandle, cast[LPPOINT](lprct), 2);

        

# Only used CheckBox & RadioButton
proc setIdealSize(this: Control) =
    var ss: SIZE
    this.sendMsg(BCM_GETIDEALSIZE, 0, ss.unsafeAddr)
    this.mWidth = ss.cx
    this.mHeight = ss.cy
    MoveWindow(this.mHandle, this.mXpos, this.mYpos, ss.cx, ss.cy, 1)


proc trackMouseMove(hw: HWND, flags: set[TMEFlags] = {}) : bool =
    var tme: TRACKMOUSEEVENT
    tme.cbSize = cast[DWORD](tme.sizeof)
    tme.dwFlags = cast[DWORD](flags)
    tme.dwHoverTime = HOVER_DEFAULT
    tme.hwndTrack = hw
    result = cast[bool](TrackMouseEventFunc(tme.unsafeAddr))

method shouldTrackMouse(this: Control, hw: HWND) : bool {. base .} =
    return not this.mIsMouseTracking

method mouseMoveHandler(this: Control, hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM) : MsgHandlerResult {. base .} =
    result = MsgHandlerResult.mhrCallDefProc
    # if this.mtid == 2: print("mouse move")
    if this.onMouseMove != nil:
        var mea = newMouseEventArgs(msg, wpm, lpm)
        this.onMouseMove(this, mea)
    
    if this.mTmeFlags != {}:
        if not this.mIsMouseTracking:
            this.mIsMouseTracking = (trackMouseMove(this.mHandle, this.mTmeFlags))  
            if mouseEnterEvent in this.mMouseEvents and not this.mMouseEntered: 
                this.mMouseEntered = true
                this.mOnMouseEnter(this, newEventArgs())
                result = MsgHandlerResult.mhrReturnZero

        
method mouseLeaveHandler(this: Control) : MsgHandlerResult {. base .} =
    result = MsgHandlerResult.mhrCallDefProc
    this.mMouseEntered = false

    if this.mIsMouseTracking:               
        this.mIsMouseTracking = false
        if this.mOnMouseLeave != nil: 
            this.mOnMouseLeave(this, newEventArgs())
            result = MsgHandlerResult.mhrReturnZero



proc commonMsgHandler(this: Control, hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM) : MsgHandlerResult =
    result = MsgHandlerResult.mhrCallDefProc
    case msg
    of WM_LBUTTONDOWN:
        this.mLbDown = true
        if this.onMouseDown != nil: 
            this.onMouseDown(this, newMouseEventArgs(msg, wpm, lpm))

    of WM_LBUTTONUP:
        if this.onMouseUp != nil: 
            this.onMouseUp(this, newMouseEventArgs(msg, wpm, lpm))
    
        if this.onClick != nil and this.mLbDown: 
            if this.isMouseOnMe(lpm):
                this.onClick(this, newEventArgs())

        this.mLbDown = false

    of WM_RBUTTONDOWN:
        this.mRbDown = true
        if this.onRightMouseDown != nil: 
            this.onRightMouseDown(this, newMouseEventArgs(msg, wpm, lpm))

    of WM_RBUTTONUP:
        if this.onRightMouseUp != nil: 
            this.onRightMouseUp(this, newMouseEventArgs(msg, wpm, lpm))

        if this.onRightClick != nil and this.mRbDown: 
            if this.isMouseOnMe(lpm):
                this.onRightClick(this, newEventArgs())

        this.mRbDown = false

    of WM_MOUSEWHEEL:
        if this.onMouseWheel != nil: 
            this.onMouseWheel(this, newMouseEventArgs(msg, wpm, lpm))

    of WM_MOUSEMOVE:
        return this.mouseMoveHandler(hw, msg, wpm, lpm)

    of WM_MOUSEHOVER:
        if not this.mHoverFired and this.mOnMouseHover != nil:
            this.mOnMouseHover(this, newMouseEventArgs(msg, wpm, lpm))

    of WM_MOUSELEAVE:
        return this.mouseLeaveHandler()
    
    of WM_CONTEXTMENU:
        if this.mContextMenu != nil: this.mContextMenu.showMenu(lpm)

    of MM_FONT_CHANGED:
        this.updateFontInternal()
        return MsgHandlerResult.mhrReturnZero

    of WM_KEYDOWN:
        this.keyDownHandler(wpm)

    of WM_KEYUP:
        this.keyUpHandler(wpm)

    of WM_CHAR:
        this.keyPressHandler(wpm)
    else: return MsgHandlerResult.mhrContinue




