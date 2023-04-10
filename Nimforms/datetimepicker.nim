# datetimepicker module Created on 30-Mar-2023 12:22 PM

## DateTimePicker type
#     Constructor - newDateTimePicker*(parent: Form, x, y: int32 = 10, w, h: int32 = 10): DateTimePicker
#     Functions - createHandle - Create handle of the DateTimePicker control.
#     Properties - Getter & Setter available
#       Name            Type
        # font          Font
        # width         int32
        # height        int32
        # xpos          int32
        # ypos          int32
        # backColor     Color
        # foreColor     Color
        # value         DateAndTime
        # formatString  string
        # format        DTPFormat - Values {dfLongDate = 1, dfShortDate, dfTimeOnly = 4, dfCustom = 8}
        # rightAlign    bool
        # noToday       bool
        # showUpdown    bool
        # showWeekNumber    bool
        # noTodayCircle     bool
        # noTrailingDates   bool
        # shortDateNames    bool
        # fourDigitYear     bool

    # Events
    #     onMouseEnter*, onClick*, onMouseLeave*, onRightClick*, onDoubleClick*,
    #     onLostFocus*, onGotFocus*: EventHandler - proc(c: DateTimePicker, e: EventArgs)

    #     onMouseWheel*, onMouseHover*, onMouseMove*, onMouseDown*, onMouseUp*
    #     onRightMouseDown*, onRightMouseUp*: MouseEventHandler - - proc(c: DateTimePicker, e: MouseEventArgs)

    #     onKeyDown*, onKeyUp*: KeyEventHandler - proc(c: DateTimePicker, e: KeyEventArgs)
    #     onKeyPress*: KeyPressEventHandler - proc(c: DateTimePicker, e: KeyPressEventArgs)

    #     onValueChanged*, onCalendarOpened*, onCalendarClosed*: EventHandler
    #     onTextChanged*: DateTimeEventHandler - proc(c: Control, e: DateTimeEventArgs)

# Constants
const
    DTM_FIRST = 0x1000
    DTN_FIRST = cast[UINT](0-740)
    DTN_FIRST2 = cast[UINT](0-753)
    DTM_GETSYSTEMTIME = DTM_FIRST+1
    DTM_SETSYSTEMTIME = DTM_FIRST+2
    DTM_GETRANGE = DTM_FIRST+3
    DTM_SETRANGE = DTM_FIRST+4
    DTM_SETFORMATA = DTM_FIRST+5
    DTM_SETFORMATW = DTM_FIRST+50
    DTM_SETMCCOLOR = DTM_FIRST+6
    DTM_GETMCCOLOR = DTM_FIRST+7
    DTM_GETMONTHCAL = DTM_FIRST+8
    DTM_SETMCFONT = DTM_FIRST+9
    DTM_GETMCFONT = DTM_FIRST+10
    DTM_SETMCSTYLE = DTM_FIRST+11
    DTM_GETMCSTYLE = DTM_FIRST+12
    DTM_CLOSEMONTHCAL = DTM_FIRST+13
    DTM_GETDATETIMEPICKERINFO = DTM_FIRST+14
    DTM_GETIDEALSIZE = DTM_FIRST+15
    DTS_UPDOWN = 0x1
    DTS_SHOWNONE = 0x2
    DTS_SHORTDATEFORMAT = 0x0
    DTS_LONGDATEFORMAT = 0x4
    DTS_SHORTDATECENTURYFORMAT = 0xc
    DTS_TIMEFORMAT = 0x9
    DTS_APPCANPARSE = 0x10
    DTS_RIGHTALIGN = 0x20
    DTN_DATETIMECHANGE = DTN_FIRST2-6
    DTN_USERSTRINGA = DTN_FIRST2-5
    DTN_USERSTRINGW = DTN_FIRST-5
    DTN_WMKEYDOWNA = DTN_FIRST2-4
    DTN_WMKEYDOWNW = DTN_FIRST-4
    DTN_FORMATA = DTN_FIRST2-3
    DTN_FORMATW = DTN_FIRST-3
    DTN_FORMATQUERYA = DTN_FIRST2-2
    DTN_FORMATQUERYW = DTN_FIRST-2
    DTN_DROPDOWN = DTN_FIRST2-1
    DTN_CLOSEUP = DTN_FIRST2

var dtpCount = 1

# Forward declaration
proc dtpWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.}

# DateTimePicker constructor
proc newDateTimePicker*(parent: Form, x, y: int32 = 10, w, h: int32 = 10): DateTimePicker =
    new(result)
    result.mKind = ctDateTimePicker
    result.mClassName = "SysDateTimePick32"
    result.mName = "DateTimePicker_" & $dtpCount
    result.mParent = parent
    result.mXpos = x
    result.mYpos = y
    result.mWidth = w
    result.mHeight = h
    result.mFont = parent.mFont
    result.mBackColor = CLR_WHITE
    result.mForeColor = CLR_BLACK
    result.mFormat = dfCustom
    result.mFmtStr = "dd-mm-yyyy"
    result.mAutoSize = true
    result.mStyle = WS_CHILD or WS_VISIBLE or WS_TABSTOP
    result.mExStyle = 0
    if appData.isDateInit:
        appData.isDateInit = true
        appData.iccEx.dwICC = ICC_DATE_CLASSES
        InitCommonControlsFunc(appData.iccEx.unsafeAddr)

    dtpCount += 1

proc setDTPStyles(this: DateTimePicker) =
    case this.mFormat
    of dfCustom: this.mStyle = this.mStyle or DTS_LONGDATEFORMAT or DTS_APPCANPARSE
    of dfLongDate: this.mStyle = this.mStyle or DTS_LONGDATEFORMAT
    of dfShortDate:
        if this.m4DYear:
            this.mStyle = this.mStyle or DTS_SHORTDATECENTURYFORMAT
        else:
            this.mStyle = this.mStyle or DTS_SHORTDATEFORMAT
    of dfTimeOnly: this.mStyle = this.mStyle or DTS_TIMEFORMAT

    if this.mShowWeekNum: this.mCalStyle = this.mCalStyle or  MCS_WEEKNUMBERS
    if this.mNoTodayCircle: this.mCalStyle = this.mCalStyle or  MCS_NOTODAYCIRCLE
    if this.mNoToday: this.mCalStyle = this.mCalStyle or  MCS_NOTODAY
    if this.mNoTrailDates: this.mCalStyle = this.mCalStyle or  MCS_NOTRAILINGDATES
    if this.mShortDateNames: this.mCalStyle = this.mCalStyle or  MCS_SHORTDAYSOFWEEK
    if this.mRightAlign: this.mStyle = this.mStyle or  DTS_RIGHTALIGN
    if this.mShowUpdown: this.mStyle = this.mStyle or  DTS_UPDOWN

proc setAutoSize(this: DateTimePicker) =
    # Although we are using 'W' based unicode functions & messages,
    # here we must use ANSI message. DTM_SETFORMATW won't work here for unknown reason.
    if this.mFormat == dfCustom: this.sendMsg(DTM_SETFORMATA, 0, this.mFmtStr[0].unsafeAddr)
    if this.mCalStyle > 0: this.sendMsg(DTM_SETMCSTYLE, 0, this.mCalStyle)
    if this.mAutoSize: # We don't need this user set the size
        var ss: SIZE
        this.sendMsg(DTM_GETIDEALSIZE, 0, ss.unsafeAddr)
        this.mWidth = ss.cx + 2
        this.mHeight = ss.cy + 5
        SetWindowPos(this.mHandle, nil, this.mXpos, this.mYpos, this.mWidth, this.mHeight, SWP_NOZORDER)


# Create DateTimePicker's hwnd
proc createHandle*(this: DateTimePicker) =
    this.setDTPStyles()
    this.createHandleInternal()
    if this.mHandle != nil:
        this.setSubclass(dtpWndProc)
        this.setFontInternal()
        this.setAutoSize()
        var st: SYSTEMTIME
        let res = this.sendMsg(DTM_GETSYSTEMTIME, 0, st.unsafeAddr)
        if res == 0: this.mValue = newDateAndTime(st)


# Property section
proc `value=`*(this: DateTimePicker, dateValue: DateAndTime) =
    this.mValue = dateValue
    let stime = makeSystemTime(this.mValue)
    if this.mIsCreated: this.sendMsg(DTM_SETSYSTEMTIME, 0, stime)

proc value*(this: DateTimePicker): DateAndTime {.inline.} = this.mValue

proc `formatString=`*(this: DateTimePicker, value: string) =
    this.mFmtStr = value
    this.mFormat = dfCustom
    if this.mIsCreated: this.sendMsg(DTM_SETFORMATA, 0, this.mFmtStr.toWcharPtr)

proc `formatString=`*(this: DateTimePicker) : string {.inline.} = this.mFmtStr

# If set to true, text in date time picker is right aligned.
proc `rightAlign=`*(this: DateTimePicker, value: bool) {.inline.} = this.mRightAlign = value
proc rightAlign*(this: DateTimePicker): bool {.inline.} = this.mRightAlign

proc `format=`*(this: DateTimePicker, value: DTPFormat) {.inline.} = this.mFormat = value
proc format*(this: DateTimePicker) : DTPFormat {.inline.} = this.mFormat

proc `showWeekNumber=`*(this: DateTimePicker, value: bool) {.inline.} = this.mShowWeekNum = value
proc showWeekNumber*(this: DateTimePicker): bool {.inline.} = this.mShowWeekNum

proc `noTodayCircle=`*(this: DateTimePicker, value: bool) {.inline.} = this.mNoTodayCircle = value
proc noTodayCircle*(this: DateTimePicker): bool {.inline.} = this.mNoTodayCircle

proc `noToday=`*(this: DateTimePicker, value: bool) {.inline.} = this.mNoToday = value
proc noToday*(this: DateTimePicker): bool {.inline.} = this.mNoToday

proc `noTrailingDates=`*(this: DateTimePicker, value: bool) {.inline.} = this.mNoTrailDates = value
proc noTrailingDates*(this: DateTimePicker): bool {.inline.} = this.mNoTrailDates

proc `shortDateNames=`*(this: DateTimePicker, value: bool) {.inline.} = this.mShortDateNames = value
proc shortDateNames*(this: DateTimePicker): bool {.inline.} = this.mShortDateNames

proc `showUpdown=`*(this: DateTimePicker, value: bool) {.inline.} = this.mShowUpdown = value
proc showUpdown*(this: DateTimePicker): bool {.inline.} = this.mShowUpdown

proc `fourDigitYear=`*(this: DateTimePicker, value: bool) {.inline.} = this.m4DYear = value
proc fourDigitYear*(this: DateTimePicker): bool {.inline.} = this.m4DYear




proc dtpWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.} =
    var this = cast[DateTimePicker](refData)
    case msg
    of WM_DESTROY:
        this.destructor()
        RemoveWindowSubclass(hw, dtpWndProc, scID)
    of WM_LBUTTONDOWN: this.leftButtonDownHandler(msg, wpm, lpm)
    of WM_LBUTTONUP: this.leftButtonUpHandler(msg, wpm, lpm)
    of WM_RBUTTONDOWN: this.rightButtonDownHandler(msg, wpm, lpm)
    of WM_RBUTTONUP: this.rightButtonUpHandler(msg, wpm, lpm)
    of WM_MOUSEMOVE: this.mouseMoveHandler(msg, wpm, lpm)
    of WM_MOUSELEAVE: this.mouseLeaveHandler()
    of MM_NOTIFY_REFLECT:
        let nm = cast[LPNMHDR](lpm)
        case nm.code
        of DTN_USERSTRINGW:
            if this.onTextChanged != nil:
                let dts = cast[LPNMDATETIMESTRINGW](lpm)
                var dtea = newDateTimeEventArgs(dts.pszUserString)
                this.onTextChanged(this, dtea)
                if dtea.handled: this.sendMsg(DTM_SETSYSTEMTIME, 0, dtea.mDateStruct)

        of DTN_DROPDOWN:
            if this.onCalendarOpened != nil: this.onCalendarOpened(this, newEventArgs())

        of DTN_DATETIMECHANGE:
            if this.mDropDownCount == 0:
                this.mDropDownCount = 1
                let nmd = cast[LPNMDATETIMECHANGE](lpm)
                this.mValue = newDateAndTime(nmd.st)
                if this.onValueChanged != nil: this.onValueChanged(this, newEventArgs())

            elif this.mDropDownCount == 1:
                this.mDropDownCount = 0
                return 0

        of DTN_CLOSEUP:
            if this.onCalendarClosed != nil: this.onCalendarClosed(this, newEventArgs())
        else: discard
        return 0

    else: return DefSubclassProc(hw, msg, wpm, lpm)
    return DefSubclassProc(hw, msg, wpm, lpm)
