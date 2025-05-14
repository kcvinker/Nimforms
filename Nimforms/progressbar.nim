# progressbar module Created on 09-Apr-2023 01:42 AM; Author kcvinker
#[==============================================ProgressBar type==============================================
  Constructor - newProgressBar
  Functions:
        createHandle() - Create the handle of progressBar
        increment*()
        startMarquee*()
        stopMarquee*()

    Properties:
        All props inherited from Control type 
        value           : int32
        step            : int32
        style           : ProgressBarStyle - {pbsBlock, pbsMarquee}
        state           : ProgressBarState - {pbsNone, pbsNormal, pbsError, pbsPaused}
        marqueeSpeed    : int32
        showPercentage  : bool

    Events:
        EventHandler type - proc(c: Control, e: EventArgs)
            onProgressChanged
==========================================================================================================]#

# Constants
const
    PBS_SMOOTH = 0x01
    PBS_VERTICAL = 0x04
    PBS_MARQUEE = 0x08
    PBST_NORMAL = 0x0001
    PBST_ERROR = 0x0002
    PBST_PAUSED = 0x0003
    PBM_SETPOS = (WM_USER+2)
    PBM_SETSTEP = (WM_USER+4)
    PBM_STEPIT = (WM_USER+5)
    PBM_SETRANGE32 = (WM_USER+6)
    PBM_GETPOS = (WM_USER+8)
    PBM_SETMARQUEE = (WM_USER+10)
    PBM_SETSTATE  = (WM_USER+16)

var pbCount = 1
# let pgbClsName = toWcharPtr("msctls_progress32")
let pgbClsName : array[18, uint16] = [0x6D, 0x73, 0x63, 0x74, 0x6C, 0x73, 0x5F, 0x70, 0x72, 0x6F, 0x67, 0x72, 0x65, 0x73, 0x73, 0x33, 0x32, 0]


# Forward declaration
proc pbWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.}
proc createHandle*(this: ProgressBar)
# ProgressBar constructor
proc progressBarCtor(parent: Form, x, y, w, h: int32): ProgressBar =
    new(result)
    result.mKind = ctProgressBar
    result.mClassName = cast[LPCWSTR](pgbClsName[0].addr)
    result.mName = "ProgressBar_" & $pbCount
    result.mParent = parent
    result.mXpos = x
    result.mYpos = y
    result.mWidth = w
    result.mHeight = h
    result.mFont = parent.mFont
    result.mHasFont = true
    result.mBackColor = parent.mBackColor
    result.mForeColor = CLR_BLACK
    result.mStyle = WS_VISIBLE or WS_CHILD
    result.mExStyle = 0
    result.mMinValue = 0
    result.mMaxValue = 100
    result.mStep = 1
    result.mBarState = pbsNormal
    result.mBarStyle = pbsBlock
    result.mMarqueeSpeed = 30
    pbCount += 1
    parent.mControls.add(result)



proc newProgressBar*(parent: Form, x, y: int32, w: int32 = 200, h: int32 = 25, autoc = false, perc = false): ProgressBar =
    result = progressBarCtor(parent, x, y, w, h)
    result.mShowPerc = perc
    if parent.mCreateChilds: result.createHandle()


proc setPbStyle(this: ProgressBar) =
    if this.mBarStyle == pbsMarquee: this.mStyle = this.mStyle or PBS_MARQUEE
    if this.mVertical: this.mStyle = this.mStyle or PBS_VERTICAL
    # this.mBkBrush = CreateSolidBrush(this.mBackColor.cref)


# Create ProgressBar's hwnd
proc createHandle*(this: ProgressBar) =
    this.setPbStyle()
    this.createHandleInternal()
    if this.mHandle != nil:
        this.setSubclass(pbWndProc)
        this.setFontInternal()
        this.sendMsg(PBM_SETRANGE32, this.mMinValue, this.mMaxValue)
        this.sendMsg(PBM_SETSTEP, this.mStep, 0)

method autoCreate(this: ProgressBar) = this.createHandle()

# Increment progress bar value by step value
proc increment*(this: ProgressBar) =
    if this.mIsCreated:
        this.mValue = (if this.mValue == this.mMaxValue: this.mStep else: this.mValue + this.mStep)
        this.sendMsg(PBM_STEPIT, 0, 0)

# Start the marquee animation
proc startMarquee*(this: ProgressBar) =
    if this.mIsCreated and this.mBarStyle == pbsMarquee:
        this.sendMsg(PBM_SETMARQUEE, 1, this.mMarqueeSpeed)

# Stop the marquee animation
proc stopMarquee*(this: ProgressBar) =
    if this.mIsCreated and this.mBarStyle == pbsMarquee:
        this.sendMsg(PBM_SETMARQUEE, 0, this.mMarqueeSpeed)


#----ProgressBar properties--------------------------------------------------------------

proc `value=`*(this: ProgressBar, value: int32) {.inline.} =
    if value >= this.mMinValue and value <= this.mMaxValue:
        this.mValue = value
        if this.mIsCreated: this.sendMsg(PBM_SETPOS, value, 0)
    else:
        raise newException(Exception, "value is not in between minValue & maxValue")

proc value*(this: ProgressBar): int32 {.inline.} = this.mValue

proc `style=`*(this: ProgressBar, value: ProgressBarStyle) =
    if this.mIsCreated and this.mBarStyle != value:
        this.mValue = 0
        if value == pbsBlock:
            this.mStyle = this.mStyle xor PBS_MARQUEE
            this.mStyle = this.mStyle or PBS_SMOOTH
        else:
            this.mStyle = this.mStyle xor PBS_SMOOTH
            this.mStyle = this.mStyle or PBS_MARQUEE
    SetWindowLongPtr(this.mHandle, GWL_STYLE, cast[LONG_PTR](this.mStyle))
    if value == pbsMarquee: this.sendMsg(PBM_SETMARQUEE, 1, this.mMarqueeSpeed)
    this.mBarStyle = value

proc style*(this: ProgressBar): ProgressBarStyle {.inline.} = this.mBarStyle

proc `marqueeSpeed=`*(this: ProgressBar, value: int32) {.inline.} = this.mMarqueeSpeed = value
proc marqueeSpeed*(this: ProgressBar): int32 {.inline.} = this.mMarqueeSpeed

proc `step=`*(this: ProgressBar, value: int32) =
    if value >= this.mMinValue and value <= this.mMaxValue:
        this.mStep = value
        if this.mIsCreated: this.sendMsg(PBM_SETSTEP, this.mStep, 0)
    else:
        raise newException(Exception, "value is not in between minValue & maxValue")

proc step*(this: ProgressBar): int32 {.inline.} = this.mStep

proc `state=`*(this: ProgressBar, value: ProgressBarState) {.inline.} =
    this.mBarState = value
    if this.mIsCreated: this.sendMsg(PBM_SETSTATE, value, 0)

proc state*(this: ProgressBar): ProgressBarState {.inline.} = this.mBarState

proc `showPercentage=`*(this: ProgressBar, value: bool) {.inline.} = this.mShowPerc = value
proc showPercentage*(this: ProgressBar): bool {.inline.} = this.mShowPerc




proc pbWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.} =
    
    case msg
    of WM_DESTROY:
        RemoveWindowSubclass(hw, pbWndProc, scID)
        var this = cast[ProgressBar](refData)
        this.destructor()

    of WM_LBUTTONDOWN:
        var this = cast[ProgressBar](refData)
        this.leftButtonDownHandler(msg, wpm, lpm)
    of WM_LBUTTONUP:
        var this = cast[ProgressBar](refData)
        this.leftButtonUpHandler(msg, wpm, lpm)
    of WM_RBUTTONDOWN:
        var this = cast[ProgressBar](refData)
        this.rightButtonDownHandler(msg, wpm, lpm)
    of WM_RBUTTONUP:
        var this = cast[ProgressBar](refData)
        this.rightButtonUpHandler(msg, wpm, lpm)
    of WM_MOUSEMOVE:
        var this = cast[ProgressBar](refData)
        this.mouseMoveHandler(msg, wpm, lpm)
    of WM_MOUSELEAVE:
        var this = cast[ProgressBar](refData)
        this.mouseLeaveHandler()
    of WM_CONTEXTMENU:
        var this = cast[ProgressBar](refData)
        if this.mContextMenu != nil: this.mContextMenu.showMenu(lpm)

    of WM_PAINT:
        var this = cast[ProgressBar](refData)
        if this.mShowPerc and this.mBarStyle == pbsBlock:
            discard DefSubclassProc(hw, msg, wpm, lpm)
            var ss: SIZE
            let vtext = $this.mValue & "%"
            let wtext = vtext.toWcharPtr()
            var hdc: HDC = GetDC(hw)
            SelectObject(hdc, this.mFont.handle)
            GetTextExtentPoint32(hdc, wtext, int32(vtext.len), ss.unsafeAddr)
            let x = int32((this.width - ss.cx) / 2)
            let y = int32((this.height - ss.cy) / 2)
            SetBkMode(hdc, 1)
            SetTextColor(hdc, this.mForeColor.cref)
            TextOut(hdc, x, y, wtext, int32(vtext.len))
            ReleaseDC(hw, hdc)
            return 0
        else:
            return DefSubclassProc(hw, msg, wpm, lpm)

    else: return DefSubclassProc(hw, msg, wpm, lpm)
    return DefSubclassProc(hw, msg, wpm, lpm)
