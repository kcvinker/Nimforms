# checkbox module Created on 29-Mar-2023 11:23 PM; Author kcvinker
#[============================================CheckBox Docs======================================
    Constructor - newCheckBox
    Functions:
        createHandle 
    Properties:
        All props inherited from Control type 
        checked     : bool

     Events
        EventHandler type - proc(c: Control, e: EventArgs)
            onCheckedChanged
==========================================================================================================]#

# Constants
# const

var cbCount = 1



# Forward declaration
proc cbWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.}
proc createCbHandle(ctl: Control)

# CheckBox constructor
proc newCheckBox*(parent: Control, text: string, x: int32 = 10, y: int32 = 10, w: int32 = 0, h: int32 = 0): CheckBox =
    new(result)
    result.mKind = ctCheckBox
    controlBaseInit(result, parent, x, y, w, h, cbCount, text)
    result.mAutoSize = true
    result.mCreateHwndProc = createCbHandle
    result.mTextStyle = DT_SINGLELINE or DT_VCENTER
    

proc setCbStyle(this: CheckBox) =
    if this.mRightAlign:
        this.mStyle = this.mStyle or BS_RIGHTBUTTON
        this.mTextStyle = this.mTextStyle or DT_RIGHT
    this.mBkBrush = CreateSolidBrush(this.mBackColor.cref)


# Create CheckBox's hwnd
proc createCbHandle(ctl: Control) =
    var this = cast[CheckBox](ctl)
    this.setCbStyle()
    this.createHandleInternal(this.mWidth, this.mHeight)
    if this.mHandle != nil:
        this.setSubclass(cbWndProc)
        this.setIdealSize()
        if this.mChecked: this.sendMsg(BM_SETCHECK, 1, 0)

# method autoCreate(this: CheckBox) = this.createHandle()

# # Set the checked property
proc `checked=`*(this: CheckBox, value: bool) {.inline.} =
    this.mChecked = value
    if this.mIsCreated: this.sendMsg(BM_SETCHECK, int32(value), 0)

# # Get the checked property
proc checked*(this: CheckBox): bool = this.mChecked


proc cbWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.} =
    var this = cast[CheckBox](refData)
    let res = this.commonMsgHandler(hw, msg, wpm, lpm)
    if res == MsgHandlerResult.mhrCallDefProc:
        return DefSubclassProc(hw, msg, wpm, lpm)
    elif res == MsgHandlerResult.mhrReturnZero or res == MsgHandlerResult.mhrReturnOne:
        return cast[LRESULT](res)
    case msg
    of WM_NCDESTROY:
        RemoveWindowSubclass(hw, cbWndProc, scID)
        this.controlBaseDtor()

    of MM_LABEL_COLOR:
        let hdc = cast[HDC](wpm)
        SetBkColor(hdc, this.mBackColor.cref)
        return cast[LRESULT](this.mBkBrush)

    of MM_CTL_COMMAND:
        this.mChecked = bool(this.sendMsg(BM_GETCHECK, 0, 0))
        if this.onCheckedChanged != nil: this.onCheckedChanged(this, newEventArgs())

    of MM_NOTIFY_REFLECT:
        let nmcd = cast[LPNMCUSTOMDRAW](lpm)
        case nmcd.dwDrawStage
        # of CDDS_PREERASE: return CDRF_NOTIFYPOSTERASE
        of CDDS_PREPAINT:
            if not this.mRightAlign:
                nmcd.rc.left += 18
            else:
                nmcd.rc.right -= 18

            # echo "this.forecolor: ", this.mForeColor, " this.mOwner.mForeColor: ", this.mOwnerForm.mForeColor
            # if (this.mDrawMode and 1) == 1: 
            SetTextColor(nmcd.hdc, this.mForeColor.cref)
            DrawTextW(nmcd.hdc, &this.mWtext, this.mWtext.wcLen, nmcd.rc.addr, this.mTextStyle)
            return CDRF_SKIPDEFAULT
        else: discard
        return 0

    else: return DefSubclassProc(hw, msg, wpm, lpm)
    return DefSubclassProc(hw, msg, wpm, lpm)
