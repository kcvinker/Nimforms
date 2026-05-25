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
proc rbWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, 
                scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.}
proc createRbHandle(ctl: Control)
# RadioButton constructor
proc newRadioButton*(parent: Control, text: string, x: int32 = 10, y: int32 = 10, 
                        w: int32 = 0, h: int32 = 0): RadioButton =
    new(result)
    result.mKind = ctRadioButton
    controlBaseInit(result, parent, x, y, w, h, rbCount, text)
    result.mAutoSize = true
    result.mTxtFlag = DT_SINGLELINE or DT_VCENTER
    result.mCreateHwndProc = createRbHandle
    


proc setRBStyle(this: RadioButton) =
    if this.mRightAlign:
        this.mStyle = this.mStyle or BS_RIGHTBUTTON
        this.mTxtFlag = this.mTxtFlag or DT_RIGHT
    this.mBkBrush = CreateSolidBrush(this.mBackColor.cref)


# Create RadioButton's hwnd
proc createRbHandle(ctl: Control) =
    var this = cast[RadioButton](ctl)
    this.setRBStyle()
    this.createHandleInternal(this.mWidth, this.mHeight)
    if this.mHandle != nil:
        this.setSubclass(rbWndProc)
        this.setFontInternal()
        this.setIdealSize()
        if this.mChecked: this.sendMsg(BM_SETCHECK, 1, 0)


# # Set the checked property
proc `checked=`*(this: RadioButton, value: bool) {.inline.} =
    this.mChecked = value
    if this.mIsCreated: this.sendMsg(BM_SETCHECK, int32(value), 0)

# # Get the checked property
proc checked*(this: RadioButton): bool {.inline.} = this.mChecked


proc rbWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, 
            scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.} =

    var this = cast[RadioButton](refData)
    let res = this.commonMsgHandler(hw, msg, wpm, lpm)
    if res == MsgHandlerResult.mhrCallDefProc:
        return DefSubclassProc(hw, msg, wpm, lpm)
    elif res == MsgHandlerResult.mhrReturnZero or res == MsgHandlerResult.mhrReturnOne:
        return cast[LRESULT](res)
    case msg
    of WM_NCDESTROY:
        RemoveWindowSubclass(hw, rbWndProc, scID)
        this.controlBaseDtor()

    of MM_LABEL_COLOR:
        let hdc = cast[HDC](wpm)
        SetBkMode(hdc, 1)
        if (this.mDrawMode and 2) == 2: SetBkColor(hdc, this.mBackColor.cref)
        return cast[LRESULT](this.mBkBrush)

    of MM_CTL_COMMAND:
        this.mChecked = bool(this.sendMsg(BM_GETCHECK, 0, 0))
        if this.onCheckedChanged != nil: this.onCheckedChanged(this, newEventArgs())

    of MM_NOTIFY_REFLECT:
        # We use this message only to change the fore color.
        let nmcd = cast[LPNMCUSTOMDRAW](lpm)
        case nmcd.dwDrawStage
        of CDDS_PREERASE: return CDRF_NOTIFYPOSTERASE
        of CDDS_PREPAINT:
            if not this.mRightAlign:
                nmcd.rc.left += 18
            else:
                nmcd.rc.right -= 18

            # if (this.mDrawMode and 1) == 1: 
            SetTextColor(nmcd.hdc, this.mForeColor.cref)
            # SetBkMode(nmcd.hdc, 1)
            DrawTextW(nmcd.hdc, this.mWtext, -1, nmcd.rc.unsafeAddr, this.mTxtFlag)
            return CDRF_SKIPDEFAULT
        else: discard
        return 0

    else: return DefSubclassProc(hw, msg, wpm, lpm)
    return DefSubclassProc(hw, msg, wpm, lpm)
