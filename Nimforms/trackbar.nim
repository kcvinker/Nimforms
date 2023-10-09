# trackbar module Created on 04-Apr-2023 01:48 PM; Author kcvinker
# TrackBar type
#   Constructor - newTrackBar*(parent: Form, x, y: int32 = 10, w: int32 = 180, h: int32 = 45): TrackBar
#   Functions
        # createHandle() - Create the handle of trackBar

#     Properties - Getter & Setter available
#       Name            Type
        # font              Font
        # text              string
        # width             int32
        # height            int32
        # xpos              int32
        # ypos              int32
        # backColor         Color
        # foreColor         Color
        # channelStyle      Color, For setter, uint is also acceptable
        # ticPosition       int32
        # ticColor          Color, For setter, uint is also acceptable
        # channelColor      Color, For setter, uint is also acceptable
        # selectionColor    Color, For setter, uint is also acceptable
        # vertical          bool
        # reversed          bool
        # noTics            bool
        # showSelRange      bool
        # toolTip           bool
        # customDraw        bool
        # freeMove          bool
        # noThumb           bool
        # ticWidth          int32
        # minRange          int32
        # maxRange          int32
        # frequency         int32
        # pageSize          int32
        # lineSize          int32
        # ticLength         int32
        # value             int32
        # trackChange       TrackChange (Getter only) - {tcNone, tcArrowLow, tcArrowHigh, tcPageLow, tcPageHigh, tcMouseClick, tcMouseDrag}

    # Events
    #     onMouseEnter*, onClick*, onMouseLeave*, onRightClick*, onDoubleClick*,
    #     onLostFocus*, onGotFocus*: EventHandler - proc(c: Control, e: EventArgs)

    #     onMouseWheel*, onMouseHover*, onMouseMove*, onMouseDown*, onMouseUp*
    #     onRightMouseDown*, onRightMouseUp*: MouseEventHandler - - proc(c: Control, e: MouseEventArgs)
    #     onValueChanged*, onDragging*, onDragged*: EventHandler

# Constants
const
    TRBN_FIRST = cast[UINT](0-1501)
    TBS_AUTOTICKS = 0x1
    TBS_VERT = 0x2
    TBS_HORZ = 0x0
    TBS_TOP = 0x4
    TBS_BOTTOM = 0x0
    TBS_LEFT = 0x4
    TBS_RIGHT = 0x0
    TBS_BOTH = 0x8
    TBS_NOTICKS = 0x10
    TBS_ENABLESELRANGE = 0x20
    TBS_FIXEDLENGTH = 0x40
    TBS_NOTHUMB = 0x80
    TBS_TOOLTIPS = 0x100
    TBS_REVERSED = 0x200
    TBS_DOWNISLEFT = 0x400
    TBS_NOTIFYBEFOREMOVE = 0x800
    TBS_TRANSPARENTBKGND = 0x1000
    TBM_GETPOS = WM_USER
    TBM_GETRANGEMIN = WM_USER+1
    TBM_GETRANGEMAX = WM_USER+2
    TBM_GETTIC = WM_USER+3
    TBM_SETTIC = WM_USER+4
    TBM_SETPOS = WM_USER+5
    TBM_SETRANGE = WM_USER+6
    TBM_SETRANGEMIN = WM_USER+7
    TBM_SETRANGEMAX = WM_USER+8
    TBM_CLEARTICS = WM_USER+9
    TBM_SETSEL = WM_USER+10
    TBM_SETSELSTART = WM_USER+11
    TBM_SETSELEND = WM_USER+12
    TBM_GETPTICS = WM_USER+14
    TBM_GETTICPOS = WM_USER+15
    TBM_GETNUMTICS = WM_USER+16
    TBM_GETSELSTART = WM_USER+17
    TBM_GETSELEND = WM_USER+18
    TBM_CLEARSEL = WM_USER+19
    TBM_SETTICFREQ = WM_USER+20
    TBM_SETPAGESIZE = WM_USER+21
    TBM_GETPAGESIZE = WM_USER+22
    TBM_SETLINESIZE = WM_USER+23
    TBM_GETLINESIZE = WM_USER+24
    TBM_GETTHUMBRECT = WM_USER+25
    TBM_GETCHANNELRECT = WM_USER+26
    TBM_SETTHUMBLENGTH = WM_USER+27
    TBM_GETTHUMBLENGTH = WM_USER+28
    TBM_SETTOOLTIPS = WM_USER+29
    TBM_GETTOOLTIPS = WM_USER+30
    TBM_SETTIPSIDE = WM_USER+31
    TBTS_TOP = 0
    TBTS_LEFT = 1
    TBTS_BOTTOM = 2
    TBTS_RIGHT = 3
    TBM_SETBUDDY = WM_USER+32
    TBM_GETBUDDY = WM_USER+33
    TB_LINEUP = 0
    TB_LINEDOWN = 1
    TB_PAGEUP = 2
    TB_PAGEDOWN = 3
    TB_THUMBPOSITION = 4
    TB_THUMBTRACK = 5
    TB_TOP = 6
    TB_BOTTOM = 7
    TB_ENDTRACK = 8
    TBCD_TICS = 0x1
    TBCD_THUMB = 0x2
    TBCD_CHANNEL = 0x3
    TRBN_THUMBPOSCHANGING = TRBN_FIRST-1
    THUMB_LINE_LOW = 0
    THUMB_LINE_HIGH = 1
    THUMB_PAGE_LOW = 2
    THUMB_PAGE_HIGH = 3
    U16_MAX = 1 shl 16

var tkbCount = 1
const UNKNOWN_MSG = cast[UINT](4294967280)


# Forward declaration
proc tkbWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.}
proc createHandle*(this: TrackBar)
# TrackBar constructor
proc newTrackBar*(parent: Form, x: int32 = 10, y: int32 = 10, w: int32 = 180, h: int32 = 45, rapid : bool = false): TrackBar =
    new(result)
    result.mKind = ctTrackBar
    result.mClassName = "msctls_trackbar32"
    result.mName = "TrackBar_" & $tkbCount
    result.mParent = parent
    result.mXpos = x
    result.mYpos = y
    result.mWidth = w
    result.mHeight = h
    result.mFont = parent.mFont
    result.mBackColor = parent.mBackColor
    result.mForeColor = CLR_BLACK
    result.mStyle = WS_CHILD or WS_VISIBLE or TBS_AUTOTICKS
    result.mExStyle = WS_EX_RIGHTSCROLLBAR or WS_EX_LTRREADING or WS_EX_LEFT
    result.mChanFlag = BF_RECT or BF_ADJUST
    result.mTicWidth = 1
    result.mTicLen = 4
    result.mLineSize = 1
    result.mMinRange = 0
    result.mMaxRange = 100
    result.mFrequency = 10
    result.mPageSize = 10
    result.mTicPos = tpDownSide
    result.mChanStyle = csClassic
    result.mTrackChange = tcNone
    result.mTicColor = newColor(0x3385ff)
    result.mChanColor = newColor(0xc2c2a3)
    result.mSelColor = newColor(0x99ff33)
    tkbCount += 1
    if rapid: result.createHandle()


proc setTKBStyle(this: TrackBar) =
    if this.mVertical:
        this.mStyle = this.mStyle or TBS_VERT
        case this.mTicPos
        of tpRightSide: this.mStyle = this.mStyle or TBS_RIGHT
        of tpLeftSide: this.mStyle = this.mStyle or TBS_LEFT
        of tpBothSide: this.mStyle = this.mStyle or TBS_BOTH
        else: discard
    else:
        case this.mTicPos
        of tpDownSide: this.mStyle = this.mStyle or TBS_BOTTOM
        of tpUpSide: this.mStyle = this.mStyle or TBS_TOP
        of tpBothSide: this.mStyle = this.mStyle or TBS_BOTH
        else: discard
    if this.mSelRange:
        this.mStyle = this.mStyle or TBS_ENABLESELRANGE
        this.mChanFlag = BF_RECT or BF_ADJUST or BF_FLAT
    if this.mReversed: this.mStyle = this.mStyle or TBS_REVERSED
    if this.mNoTics: this.mStyle = this.mStyle or TBS_NOTICKS
    if this.mNoThumb: this.mStyle = this.mStyle or TBS_NOTHUMB
    if this.mToolTip: this.mStyle = this.mStyle or TBS_TOOLTIPS
    this.mBkBrush = CreateSolidBrush(this.mBackColor.cref)

proc sendInitialMessages(this: TrackBar) =
    if this.mReversed:
        this.sendMsg(TBM_SETRANGEMIN, 1, (this.mMaxRange * -1))
        this.sendMsg(TBM_SETRANGEMAX, 1, this.mMinRange)
    else:
        this.sendMsg(TBM_SETRANGEMIN, 1, (this.mMinRange))
        this.sendMsg(TBM_SETRANGEMAX, 1, this.mMaxRange)

    this.sendMsg(TBM_SETTICFREQ, this.mFrequency, 0)
    this.sendMsg(TBM_SETPAGESIZE, 0, this.mPageSize)
    this.sendMsg(TBM_SETLINESIZE, 0, this.mLineSize)

proc calculateTics(this: TrackBar) =
    # Calculating logical & physical positions for tics.
    var twidth, numTics, stPos, enPos, channelLen : int32
    var pFactor, fRange, tic : float

    #1. Collecting required rects
    GetClientRect(this.mHandle, this.mMyRect.unsafeAddr) # Get Trackbar rect
    this.sendMsg(TBM_GETTHUMBRECT, 0, this.mThumbRect.unsafeAddr) # Get the thumb rect
    this.sendMsg(TBM_GETCHANNELRECT, 0, this.mChanRect.unsafeAddr) # Get the channel rect

    #2. Calculate thumb offset
    if this.mVertical:
        twidth = this.mThumbRect.bottom - this.mThumbRect.top
    else:
        twidth = this.mThumbRect.right - this.mThumbRect.left
    this.mThumbHalf = int32(twidth / 2)

    # Now calculate required variables
    fRange = float(this.mMaxRange - this.mMinRange)
    numTics = int32(fRange / float(this.mFrequency))
    if (int32(fRange) mod this.mFrequency) == 0: numTics -= 1
    stPos = this.mChanRect.left + this.mThumbHalf
    enPos = this.mChanRect.right - this.mThumbHalf - 1
    channelLen = enPos - stPos
    pFactor = float(channelLen) / fRange

    tic = float(this.mMinRange + this.mFrequency)
    this.mTicList.add(TicData(phyPoint: stPos, logPoint: 0)) # Very first tic
    for i in 0..<numTics:
        this.mTicList.add(TicData(phyPoint: (int32(tic * pFactor) + stPos), logPoint: int32(tic))) # Middle tics
        tic += float(this.mFrequency)

    this.mTicList.add(TicData(phyPoint: enPos, logPoint: int32(fRange))) # Last tic

    # Now, set up single point (x/y) for tics.
    if this.mVertical:
        case this.mTicPos
        of tpLeftSide: this.mP1 = this.mThumbRect.left - 5
        of tpRightSide: this.mP1 = this.mThumbRect.right + 2
        of tpBothSide:
            this.mP1 = this.mThumbRect.right + 2
            this.mP2 = this.mThumbRect.left - 5
        else: discard
    else:
        case this.mTicPos
        of tpDownSide: this.mP1 = this.mThumbRect.bottom + 1
        of tpUpSide: this.mP1 = this.mThumbRect.top - 4
        of tpBothSide:
            this.mP1 = this.mThumbRect.bottom + 1
            this.mP2 = this.mThumbRect.top - 3
        else: discard

proc drawTics(this: TrackBar, drMode: TicDrawMode, hdc: HDC, px, py: int32) =
    var xp, yp: int32
    case drMode
    of tdmVertical:
        xp = px + this.mTicLen
        yp = py
    of tdmHorizDown:
        xp = px
        yp = py + this.mTicLen
    of tdmHorizUpper:
        xp = px
        yp = py - this.mTicLen
    MoveToEx(hdc, px, py, nil)
    LineTo(hdc, xp, yp)

proc implementTickDraw(this: TrackBar, hdc: HDC) =
    SelectObject(hdc, this.mTicPen)
    if this.mVertical:
        case this.mTicPos
        of tpRightSide, tpLeftSide:
            for p in this.mTicList: this.drawTics(tdmVertical, hdc, this.mP1, p.phyPoint)
        of tpBothSide:
            for p in this.mTicList:
                this.drawTics(tdmVertical, hdc, this.mP1, p.phyPoint)
                this.drawTics(tdmVertical, hdc, this.mP2, p.phyPoint)
        else: discard
    else:
        case this.mTicPos
        of tpUpSide, tpDownSide:
            for p in this.mTicList: this.drawTics(tdmHorizDown, hdc, p.phyPoint, this.mP1)
        of tpBothSide:
            for p in this.mTicList:
                this.drawTics(tdmHorizDown, hdc, p.phyPoint, this.mP1)
                this.drawTics(tdmHorizUpper, hdc, p.phyPoint, this.mP2)
        else: discard

proc getThumbRect(this: TrackBar): RECT =
    discard this.sendMsg(TBM_GETTHUMBRECT, 0, result.unsafeAddr)

proc fillChannelRect(this: TrackBar, nm: LPNMCUSTOMDRAW, trc: RECT): bool =
    # If show_selection property is enabled in this trackbar,
    # we need to show the area between thumb and channel starting in diff color.
    # But we need to check if the trackbar is reversed or not.
    # NOTE: If we change the drawing flags for DrawEdge function in channel drawing area,
    # We need to reduce the rect size 1 point. Because, current flags working perfectly...
    # Without adsting rect. So change it carefully.
    var rct: RECT
    if this.mVertical:
        rct.left = nm.rc.left
        rct.right = nm.rc.right
        if this.mReversed:
            rct.top = trc.bottom
            rct.bottom = nm.rc.bottom
        else:
            rct.top = nm.rc.top
            rct.bottom = trc.top
    else:
        rct.top = nm.rc.top
        rct.bottom = nm.rc.bottom
        if this.mReversed:
            rct.left = trc.right
            rct.right = nm.rc.right
        else:
            rct.left = nm.rc.left
            rct.right = trc.left
    result = bool(FillRect(nm.hdc, rct.unsafeAddr, this.mSelBrush))

proc setupValueInternal(this: TrackBar, iValue: int32) =
    if this.mReversed:
        this.mValue = U16_MAX - iValue
    else:
        this.mValue = iValue

proc destroyResources(this: TrackBar) =
    if this.mChanPen != nil: DeleteObject(this.mChanPen)
    if this.mTicPen != nil: DeleteObject(this.mTicPen)
    if this.mSelBrush != nil: DeleteObject(this.mSelBrush)
    this.destructor()




# Create TrackBar's hwnd
proc createHandle*(this: TrackBar) =
    this.setTKBStyle()
    this.createHandleInternal()
    if this.mHandle != nil:
        this.setSubclass(tkbWndProc)
        # this.setFontInternal()
        this.sendInitialMessages()
        if this.mCustDraw:
            this.mChanPen = CreatePen(PS_SOLID, 1, this.mChanColor.cref)
            this.mTicPen = CreatePen(PS_SOLID, this.mTicWidth, this.mTicColor.cref)
            this.calculateTics()
        if this.mSelRange: this.mSelBrush = CreateSolidBrush(this.mSelColor.cref)



# Properties--------------------------------------------------------------------------

proc trackChange*(this: TrackBar): TrackChange {.inline.} = this.mTrackChange

proc `channelStyle=`*(this: TrackBar, value: ChannelStyle) {.inline.} = this.mChanStyle = value
proc channelStyle*(this: TrackBar): ChannelStyle {.inline.} = this.mChanStyle

proc `ticPosition=`*(this: TrackBar, value: TicPosition) {.inline.} = this.mTicPos = value
proc ticPosition*(this: TrackBar): TicPosition {.inline.} = this.mTicPos

proc `ticColor=`*(this: TrackBar, value: Color) {.inline.} = this.mTicColor = value
proc `ticColor=`*(this: TrackBar, value: uint) {.inline.} = this.mTicColor = newColor(value)
proc ticColor*(this: TrackBar): Color {.inline.} = this.mTicColor

proc `channelColor=`*(this: TrackBar, value: Color) {.inline.} = this.mChanColor = value
proc `channelColor=`*(this: TrackBar, value: uint) {.inline.} = this.mChanColor = newColor(value)
proc channelColor*(this: TrackBar): Color {.inline.} = this.mChanColor

proc `selectionColor=`*(this: TrackBar, value: Color) {.inline.} = this.mSelColor = value
proc `selectionColor=`*(this: TrackBar, value: uint) {.inline.} = this.mSelColor = newColor(value)
proc selectionColor*(this: TrackBar): Color {.inline.} = this.mSelColor

proc `vertical=`*(this: TrackBar, value: bool) {.inline.} =
    this.mVertical = value
    if this.mTicPos == tpDownSide or this.mTicPos == tpUpSide: this.mTicPos = tpRightSide

proc vertical*(this: TrackBar): bool {.inline.} = this.mVertical

proc `reversed=`*(this: TrackBar, value: bool) {.inline.} = this.mReversed = value
proc reversed*(this: TrackBar): bool {.inline.} = this.mReversed

proc `noTics=`*(this: TrackBar, value: bool) {.inline.} = this.mNoTics = value
proc noTics*(this: TrackBar): bool {.inline.} = this.mNoTics

proc `showSelRange=`*(this: TrackBar, value: bool) {.inline.} = this.mSelRange = value
proc showSelRange*(this: TrackBar): bool {.inline.} = this.mSelRange

proc `toolTip=`*(this: TrackBar, value: bool) {.inline.} = this.mToolTip = value
proc toolTip*(this: TrackBar): bool {.inline.} = this.mToolTip

proc `customDraw=`*(this: TrackBar, value: bool) {.inline.} = this.mCustDraw = value
proc customDraw*(this: TrackBar): bool {.inline.} = this.mCustDraw

proc `freeMove=`*(this: TrackBar, value: bool) {.inline.} = this.mFreeMove = value
proc freeMove*(this: TrackBar): bool {.inline.} = this.mFreeMove

proc `noThumb=`*(this: TrackBar, value: bool) {.inline.} = this.mNoThumb = value
proc noThumb*(this: TrackBar): bool {.inline.} = this.mNoThumb

proc `ticWidth=`*(this: TrackBar, value: int32) {.inline.} = this.mTicWidth = value
proc ticWidth*(this: TrackBar): int32 {.inline.} = this.mTicWidth

proc `minRange=`*(this: TrackBar, value: int32) {.inline.} = this.mMinRange = value
proc minRange*(this: TrackBar): int32 {.inline.} = this.mMinRange

proc `maxRange=`*(this: TrackBar, value: int32) {.inline.} = this.mMaxRange = value
proc maxRange*(this: TrackBar): int32 {.inline.} = this.mMaxRange

proc `frequency=`*(this: TrackBar, value: int32) {.inline.} = this.mFrequency = value
proc frequency*(this: TrackBar): int32 {.inline.} = this.mFrequency

proc `pageSize=`*(this: TrackBar, value: int32) {.inline.} = this.mPageSize = value
proc pageSize*(this: TrackBar): int32 {.inline.} = this.mPageSize

proc `lineSize=`*(this: TrackBar, value: int32) {.inline.} = this.mLineSize = value
proc lineSize*(this: TrackBar): int32 {.inline.} = this.mLineSize

proc `ticLength=`*(this: TrackBar, value: int32) {.inline.} = this.mTicLen = value
proc ticLength*(this: TrackBar): int32 {.inline.} = this.mTicLen

proc `value=`*(this: TrackBar, value: int32) {.inline.} =
    this.mValue = value
    if this.mIsCreated: this.sendMsg(TBM_SETPOS, 1, value)

proc value*(this: TrackBar): int32 {.inline.} = this.mValue

proc `backColor=`*(this: TrackBar, value: uint) {.inline.} =
    this.mBackColor = newColor(value)
    if (this.mDrawMode and 2) != 2 : this.mDrawMode += 2
    if this.mIsCreated:
        this.mBkBrush = this.mBackColor.makeHBRUSH

        # We need this to immediate redraw. This is the only reason we are overriding this prop
        this.sendMsg(TBM_SETRANGEMAX, 1, this.mMaxRange)
        InvalidateRect(this.mHandle, nil, 0)

proc `backColor=`*(this: TrackBar, value: Color) {.inline.} =
    this.mBackColor = value
    if (this.mDrawMode and 2) != 2 : this.mDrawMode += 2
    if this.mIsCreated:
        this.mBkBrush = this.mBackColor.makeHBRUSH
        this.sendMsg(TBM_SETRANGEMAX, 1, this.mMaxRange)
        InvalidateRect(this.mHandle, nil, 0)




proc tkbWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.} =
    var this = cast[TrackBar](refData)
    case msg
    of WM_DESTROY:
        this.destroyResources()
        RemoveWindowSubclass(hw, tkbWndProc, scID)
    of WM_LBUTTONDOWN: this.leftButtonDownHandler(msg, wpm, lpm)
    of WM_LBUTTONUP: this.leftButtonUpHandler(msg, wpm, lpm)
    of WM_RBUTTONDOWN: this.rightButtonDownHandler(msg, wpm, lpm)
    of WM_RBUTTONUP: this.rightButtonUpHandler(msg, wpm, lpm)
    of WM_MOUSEMOVE: this.mouseMoveHandler(msg, wpm, lpm)
    of WM_MOUSELEAVE: this.mouseLeaveHandler()
    of WM_CONTEXTMENU:
        if this.mContextMenu != nil: this.mContextMenu.showMenu(lpm)

    of MM_HSCROLL, MM_VSCROLL:
        let lwp = LOWORD(wpm)
        case lwp
        of TB_THUMBPOSITION:
            this.setupValueInternal(int32(HIWORD(wpm)))
            if not this.mFreeMove:
                var pos: int32 = this.mValue
                let half = int32(this.mFrequency / 2)
                let diff = pos mod this.mFrequency
                if diff >= half:
                    pos = (this.mFrequency - diff) + this.mValue
                elif diff < half:
                    pos =  this.mValue - diff
                let lpmVal = (if this.mReversed: pos * -1 else: pos)
                this.sendMsg(TBM_SETPOS, 1, lpmVal)
                this.mValue = pos

            # We need to refresh then Trackbar in order to display our new drawings.
            InvalidateRect(hw, this.mChanRect.unsafeAddr, 0)
            this.mTrackChange = tcMouseDrag
            if this.onDragged != nil: this.onDragged(this, newEventArgs())
            if this.onValueChanged != nil: this.onValueChanged(this, newEventArgs())

        of THUMB_LINE_HIGH:
            this.setupValueInternal(int32(this.sendMsg(TBM_GETPOS, 0, 0)))
            this.mTrackChange = tcArrowHigh
            if this.onValueChanged != nil: this.onValueChanged(this, newEventArgs())

        of THUMB_LINE_LOW:
            this.setupValueInternal(int32(this.sendMsg(TBM_GETPOS, 0, 0)))
            this.mTrackChange = tcArrowLow
            if this.onValueChanged != nil: this.onValueChanged(this, newEventArgs())

        of THUMB_PAGE_HIGH:
            this.setupValueInternal(int32(this.sendMsg(TBM_GETPOS, 0, 0)))
            this.mTrackChange = tcPageHigh
            if this.onValueChanged != nil: this.onValueChanged(this, newEventArgs())

        of THUMB_PAGE_LOW:
            this.setupValueInternal(int32(this.sendMsg(TBM_GETPOS, 0, 0)))
            this.mTrackChange = tcPageLow
            if this.onValueChanged != nil: this.onValueChanged(this, newEventArgs())

        of TB_THUMBTRACK:
            this.setupValueInternal(int32(this.sendMsg(TBM_GETPOS, 0, 0)))
            if this.onDragging != nil: this.onDragging(this, newEventArgs())
        else: discard

    of MM_NOTIFY_REFLECT:
        let nmh = cast[LPNMHDR](lpm)
        case nmh.code
        of NM_CUSTOMDRAW_NM:
            if this.mCustDraw:
                var nmcd = cast[LPNMCUSTOMDRAW](lpm)
                if nmcd.dwDrawStage == CDDS_PREPAINT: return CDRF_NOTIFYITEMDRAW
                if nmcd.dwDrawStage ==  CDDS_ITEMPREPAINT:
                    if nmcd.dwItemSpec == TBCD_TICS:
                        if not this.mNoTics:
                            this.implementTickDraw(nmcd.hdc)
                            return CDRF_SKIPDEFAULT

                    if nmcd.dwItemSpec == TBCD_CHANNEL:
                        # In Python we are using EDGE_SUNKEN style without BF_FLAT.
                        # But D gives a strange outline in those flags. So I decided to use...
                        # these flags. But in this case, we don't need to reduce 1 point from...
                        # the coloring rect. It looks perfect without changing rect boundaries.
                        if this.mChanStyle == csClassic:
                            DrawEdge(nmcd.hdc, nmcd.rc.unsafeAddr, BDR_SUNKENOUTER, this.mChanFlag)
                        else:
                            SelectObject(nmcd.hdc, this.mChanPen)
                            Rectangle(nmcd.hdc, nmcd.rc.left, nmcd.rc.top, nmcd.rc.right, nmcd.rc.bottom)

                        if this.mSelRange: # Fill the selection range
                            var rc = this.getThumbRect()
                            if this.fillChannelRect(nmcd, rc): InvalidateRect(hw, nmcd.rc.unsafeAddr, 0)
                        return CDRF_SKIPDEFAULT
            else:
                return CDRF_DODEFAULT
        of UNKNOWN_MSG: # con.TRBN_THUMBPOSCHANGING:
            this.mTrackChange = tcMouseClick
        else: discard

    of MM_LABEL_COLOR:
        return cast[LRESULT](this.mBkBrush)

    else: return DefSubclassProc(hw, msg, wpm, lpm)
    return DefSubclassProc(hw, msg, wpm, lpm)
