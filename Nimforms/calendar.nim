
# calendar module Created on 29-Mar-2023 05:03 PM; Author kcvinker

#[=========================================Calendar Docs=======================================
    Constructor - newCalendar*(parent: Form, x: int32 = 10, y: int32 = 10): Calendar
    Functions
        createHandle
    
    Properties
        All props inherited from Control type 
        value          :    DateAndTime - See typemodule.nim
        viewMode       :    ViewMode    - An enum, see typemodule.nim
        oldViewMode    :    ViewMode    - Ad enum.
        noToday        :    bool
        shortDateNames :    bool
        showWeekNumber :    bool
        noTodayCircle  :    bool
        noTrailingDates:    bool

    Events
        All events inherited from Control type
        EventHandler - proc(c: Control, e: EventArgs)
            onSelectionCommitted
            onValueChanged
            onViewChanged
==========================================================================================================]#



# Constants
const
    MCM_FIRST = 0x1000
    MCN_FIRST = cast[UINT](0-746)
    MCM_GETCALENDARGRIDINFO = MCM_FIRST+24
    MCM_GETCALID = MCM_FIRST+27
    MCM_SETCALID = MCM_FIRST+28
    MCM_SIZERECTTOMIN = MCM_FIRST+29
    MCM_SETCALENDARBORDER = MCM_FIRST+30
    MCM_GETCALENDARBORDER = MCM_FIRST+31
    MCM_SETCURRENTVIEW = MCM_FIRST+32
    MCN_SELCHANGE = MCN_FIRST-3
    MCN_GETDAYSTATE = MCN_FIRST+3
    MCN_SELECT = MCN_FIRST
    MCN_VIEWCHANGE = MCN_FIRST-4
    MCS_DAYSTATE = 0x1
    MCS_MULTISELECT = 0x2
    MCS_WEEKNUMBERS = 0x4
    MCS_NOTODAYCIRCLE = 0x8
    MCS_NOTODAY = 0x10
    MCS_NOTRAILINGDATES = 0x40
    MCS_SHORTDAYSOFWEEK = 0x80
    MCS_NOSELCHANGEONNAV = 0x100
    MCM_GETMINREQRECT = MCM_FIRST+9
    MCM_GETCURSEL = MCM_FIRST+1
    MCM_SETCURSEL = MCM_FIRST+2

var calCount = 1
let calClsName : array[14, uint16] = [0x53, 0x79, 0x73, 0x4D, 0x6F, 0x6E, 0x74, 0x68, 0x43, 0x61, 0x6C, 0x33, 0x32, 0] 

# Forward declaration
proc calWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.}
proc createHandle*(this: Calendar)

proc newDateAndTime*(st: SYSTEMTIME): DateAndTime =
    result.year = int32(st.wYear)
    result.month = int32(st.wMonth)
    result.day = int32(st.wDay)
    result.hour = int32(st.wHour)
    result.minute = int32(st.wMinute)
    result.second = int32(st.wSecond)
    result.milliSecond = int32(st.wMilliseconds)
    result.dayOfWeek = cast[WeekDays](st.wDayOfWeek)

proc makeSystemTime(dt: DateAndTime): SYSTEMTIME =
    result.wYear = WORD(dt.year)
    result.wMonth = WORD(dt.month)
    result.wDay = WORD(dt.day)
    result.wHour = WORD(dt.hour)
    result.wMinute = WORD(dt.minute)
    result.wSecond = WORD(dt.second)
    result.wMilliseconds = WORD(dt.milliSecond)
    result.wDayOfWeek = WORD(dt.dayOfWeek)



# Calendar constructor
proc newCalendar*(parent: Form, x: int32 = 10, y: int32 = 10): Calendar =
    new(result)
    result.mKind = ctCalendar
    result.mClassName = cast[LPCWSTR](calClsName[0].addr)
    result.mName = "Calendar_" & $calCount
    result.mParent = parent
    result.mXpos = x
    result.mYpos = y
    result.mWidth = 10
    result.mHeight = 10
    result.mStyle = WS_CHILD or WS_TABSTOP or WS_VISIBLE
    result.mViewMode = vmMonthView
    calCount += 1
    parent.mControls.add(result)
    if parent.mCreateChilds: result.createHandle()

proc setCalStyle(this: Calendar) =
    if this.mShowWeekNum: this.mStyle = this.mStyle or MCS_WEEKNUMBERS
    if this.mNoTodayCircle: this.mStyle = this.mStyle or MCS_NOTODAYCIRCLE
    if this.mNoToday: this.mStyle = this.mStyle or MCS_NOTODAY
    if this.mNoTrailDates: this.mStyle = this.mStyle or MCS_NOTRAILINGDATES
    if this.mShortDateNames: this.mStyle = this.mStyle or MCS_SHORTDAYSOFWEEK

proc setValueInternal(this: Calendar, st: SYSTEMTIME) =
    this.mValue = newDateAndTime(st)

# Create Calendar's hwnd
proc createHandle*(this: Calendar) =
    this.setCalStyle()
    this.createHandleInternal()
    if this.mHandle != nil:
        this.setSubclass(calWndProc)
        # this.setFontInternal()
        var rc: RECT
        this.sendMsg(MCM_GETMINREQRECT, 0, rc.unsafeAddr)
        SetWindowPos(this.mHandle, nil, this.mXpos, this.mYpos, rc.right, rc.bottom, SWP_NOZORDER)
        var st: SYSTEMTIME
        this.sendMsg(MCM_GETCURSEL, 0, st.unsafeAddr)
        this.setValueInternal(st)

method autoCreate(this: Calendar) = this.createHandle()

# Set the value property
proc `value=`*(this: Calendar, dateValue: DateAndTime) {.inline.} =
    this.mValue = dateValue
    let stime = makeSystemTime(this.mValue)
    if this.mIsCreated: this.sendMsg(MCM_SETCURSEL, 0, stime)

# Get the value property
proc value*(this: Calendar): DateAndTime = this.mValue

# Set the viewMode property
proc `viewMode=`*(this: Calendar, value: ViewMode) {.inline.} =
    this.mViewMode = value
    if this.mIsCreated: this.sendMsg(MCM_SETCURRENTVIEW, 0, int32(this.mViewMode))

# Get the viewMode property
proc viewMode*(this: Calendar): ViewMode = this.mViewMode

# Get the oldViewMode property
proc oldViewMode*(this: Calendar): ViewMode = this.mOldView

proc `showWeekNumber=`*(this: Calendar, value: bool) = this.mShowWeekNum = value
proc showWeekNumber*(this: Calendar): bool = this.mShowWeekNum

proc `noTodayCircle=`*(this: Calendar, value: bool) = this.mNoTodayCircle = value
proc noTodayCircle*(this: Calendar): bool = this.mNoTodayCircle

proc `noToday=`*(this: Calendar, value: bool) = this.mNoToday = value
proc noToday*(this: Calendar): bool = this.mNoToday

proc `noTrailingDates=`*(this: Calendar, value: bool) = this.mNoTrailDates = value
proc noTrailingDates*(this: Calendar): bool = this.mNoTrailDates

proc `shortDateNames=`*(this: Calendar, value: bool) = this.mShortDateNames = value
proc shortDateNames*(this: Calendar): bool = this.mShortDateNames


proc calWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.} =
    
    case msg
    of WM_DESTROY:
        RemoveWindowSubclass(hw, calWndProc, scID)
        var this = cast[Calendar](refData)
        this.destructor()
        

    of WM_LBUTTONDOWN:
        var this = cast[Calendar](refData)
        this.leftButtonDownHandler(msg, wpm, lpm)

    of WM_LBUTTONUP:
        var this = cast[Calendar](refData)
        this.leftButtonUpHandler(msg, wpm, lpm)

    of WM_RBUTTONDOWN:
        var this = cast[Calendar](refData)
        this.rightButtonDownHandler(msg, wpm, lpm)

    of WM_RBUTTONUP:
        var this = cast[Calendar](refData)
        this.rightButtonUpHandler(msg, wpm, lpm)

    of WM_MOUSEMOVE:
        var this = cast[Calendar](refData)
        this.mouseMoveHandler(msg, wpm, lpm)

    of WM_MOUSELEAVE:
        var this = cast[Calendar](refData)
        this.mouseLeaveHandler()

    of WM_CONTEXTMENU:
        var this = cast[Calendar](refData)
        if this.mContextMenu != nil: this.mContextMenu.showMenu(lpm)

    of MM_NOTIFY_REFLECT:
        var this = cast[Calendar](refData)
        let nmh = cast[LPNMHDR](lpm)
        case nmh.code
        of MCN_SELECT:
            let nms = cast[LPNMSELCHANGE](lpm)
            this.setValueInternal(nms.stSelStart)
            if this.onValueChanged != nil: this.onValueChanged(this, newEventArgs())
        of MCN_SELCHANGE:
            let nms = cast[LPNMSELCHANGE](lpm)
            this.setValueInternal(nms.stSelStart)
            if this.onSelectionCommitted != nil: this.onSelectionCommitted(this, newEventArgs())
        of MCN_VIEWCHANGE:
            let nmv = cast[LPNMVIEWCHANGE](lpm)
            this.mViewMode = cast[ViewMode](nmv.dwNewView)
            this.mOldView = cast[ViewMode](nmv.dwOldView)
            if this.onViewChanged != nil: this.onViewChanged(this, newEventArgs())
        else: discard
        return 0

    else: return DefSubclassProc(hw, msg, wpm, lpm)
    return DefSubclassProc(hw, msg, wpm, lpm)
