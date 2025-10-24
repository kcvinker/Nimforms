# radiobutton module Created on 04-Apr-2023 02:34 AM; Author kcvinker
#[==========================================RadioButton Docs=========================================================
  Constructor - newRadioButton
  Functions:
        createHandle() - Create the handle of radioButton

    Properties:
        All props inherited from Control type 
        checked       bool

    Events:
        All events inherited from Control type 
        EventHandler type - proc(c: Control, e: EventArgs)        
            onCheckedChanged
=========================================================================================================]#

var rbCount = 1
# let rbClsName = toWcharPtr("Button")

# Forward declaration
proc rbWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.}
proc createHandle*(this: RadioButton)
# RadioButton constructor
proc newRadioButton*(parent: Form, text: string, x: int32 = 10, y: int32 = 10, w: int32 = 0, h: int32 = 0): RadioButton =
    new(result)
    result.mKind = ctRadioButton
    result.mClassName = cast[LPCWSTR](BtnClass[0].addr)
    result.mName = "RadioButton_" & $rbCount
    result.mParent = parent
    result.mXpos = x
    result.mYpos = y
    result.mWidth = w
    result.mHeight = h
    result.mText = text
    # result.mFont = parent.mFont
    result.cloneParentFont()
    result.mHasFont = true
    result.mBackColor = parent.mBackColor
    result.mWideText = text.toLPWSTR()
    result.mForeColor = CLR_BLACK
    result.mAutoSize = true
    result.mTxtFlag = DT_SINGLELINE or DT_VCENTER
    result.mStyle = WS_CHILD or WS_VISIBLE or WS_TABSTOP or BS_AUTORADIOBUTTON
    result.mExStyle = WS_EX_LTRREADING or WS_EX_LEFT
    # result.mTextStyle = DT_SINGLELINE or DT_VCENTER
    rbCount += 1
    parent.mControls.add(result)
    if parent.mCreateChilds: result.createHandle()

proc setRBStyle(this: RadioButton) =
    if this.mRightAlign:
        this.mStyle = this.mStyle or BS_RIGHTBUTTON
        this.mTxtFlag = this.mTxtFlag or DT_RIGHT
    this.mBkBrush = CreateSolidBrush(this.mBackColor.cref)


# Create RadioButton's hwnd
proc createHandle*(this: RadioButton) =
    this.setRBStyle()
    this.createHandleInternal()
    if this.mHandle != nil:
        this.setSubclass(rbWndProc)
        this.setFontInternal()
        this.setIdealSize()
        if this.mChecked: this.sendMsg(BM_SETCHECK, 1, 0)

method autoCreate(this: RadioButton) = this.createHandle()

# # Set the checked property
proc `checked=`*(this: RadioButton, value: bool) {.inline.} =
    this.mChecked = value
    if this.mIsCreated: this.sendMsg(BM_SETCHECK, int32(value), 0)

# # Get the checked property
proc checked*(this: RadioButton): bool {.inline.} = this.mChecked


proc rbWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.} =
    
    case msg
    of WM_DESTROY:
        RemoveWindowSubclass(hw, rbWndProc, scID)
        var this = cast[RadioButton](refData)
        this.destructor()

    of WM_LBUTTONDOWN:
        var this = cast[RadioButton](refData)
        this.leftButtonDownHandler(msg, wpm, lpm)

    of WM_LBUTTONUP:
        var this = cast[RadioButton](refData)
        this.leftButtonUpHandler(msg, wpm, lpm)

    of WM_RBUTTONDOWN:
        var this = cast[RadioButton](refData)
        this.rightButtonDownHandler(msg, wpm, lpm)

    of WM_RBUTTONUP:
        var this = cast[RadioButton](refData)
        this.rightButtonUpHandler(msg, wpm, lpm)

    of WM_MOUSEMOVE:
        var this = cast[RadioButton](refData)
        this.mouseMoveHandler(msg, wpm, lpm)

    of WM_MOUSELEAVE:
        var this = cast[RadioButton](refData)
        this.mouseLeaveHandler()
        
    of WM_CONTEXTMENU:
        var this = cast[RadioButton](refData)
        if this.mContextMenu != nil: this.mContextMenu.showMenu(lpm)

    of MM_LABEL_COLOR:
        var this = cast[RadioButton](refData)
        let hdc = cast[HDC](wpm)
        SetBkMode(hdc, 1)
        if (this.mDrawMode and 2) == 2: SetBkColor(hdc, this.mBackColor.cref)
        return cast[LRESULT](this.mBkBrush)

    of MM_CTL_COMMAND:
        var this = cast[RadioButton](refData)
        this.mChecked = bool(this.sendMsg(BM_GETCHECK, 0, 0))
        if this.onCheckedChanged != nil: this.onCheckedChanged(this, newEventArgs())

    of MM_NOTIFY_REFLECT:
        var this = cast[RadioButton](refData)
        # We use this message only to change the fore color.
        let nmcd = cast[LPNMCUSTOMDRAW](lpm)
        case nmcd.dwDrawStage
        of CDDS_PREERASE: return CDRF_NOTIFYPOSTERASE
        of CDDS_PREPAINT:
            if not this.mRightAlign:
                nmcd.rc.left += 18
            else:
                nmcd.rc.right -= 18

            if (this.mDrawMode and 1) == 1: SetTextColor(nmcd.hdc, this.mForeColor.cref)
            # SetBkMode(nmcd.hdc, 1)
            DrawTextW(nmcd.hdc, this.mWideText, -1, nmcd.rc.unsafeAddr, this.mTxtFlag)
            return CDRF_SKIPDEFAULT
        else: discard
        return 0

    of MM_FONT_CHANGED:
        var this = cast[RadioButton](refData)
        this.updateFontInternal()
        return 0

    else: return DefSubclassProc(hw, msg, wpm, lpm)
    return DefSubclassProc(hw, msg, wpm, lpm)
