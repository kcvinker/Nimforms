# Type module
import tables
# import nimpy

type
    ControlType* {.pure.} = enum
        ctNone, ctButton, ctCalendar, ctCheckBox, ctComboBox, ctDateTimePicker, ctForm, ctGroupBox, ctLabel,
        ctListBox, ctListView, ctNumberPicker, ctProgressBar, ctRadioButton, ctTextBox, ctTrackBar, ctTreeView

    WArrayPtr = ptr UncheckedArray[Utf16Char]

    WideString* = object 
        mData : WArrayPtr
        mInputLen: int32 
        mWcLen*: int32
        mBytes: int
        mInputStr: cstring

    Graphics = object 
        mHdc: HDC
        mHwnd: HWND
        mFree: bool


    Color* = object
        red*, green*, blue*, value*: uint
        cref*: COLORREF

    FontWeight* {.pure.} = enum
        fwLight = 300, fwNormal = 400, fwMedium = 500, fwSemiBold = 600, fwBold = 700,
        fwExtraBold = 800, fwUltraBold = 900

    Font* = object
        name*: string
        size*: int32
        weight*: FontWeight
        italics*, underLine*, strikeOut*: bool
        handle: HFONT
        # wtext: WideString

    TextAlignment* {.pure.} = enum
        taLeft, taCenter, taRight

    EventArgs* = ref object of RootObj
        handled*: bool
        cancelled*: bool

    EventHandler* = proc(c: Control, e: EventArgs)

    ThreadMsgHandler* = proc(wpm: WPARAM, lpm: LPARAM)

    ContextMenuEventHandler* = proc(c: ContextMenu, e: EventArgs)

    MenuEventHandler* = proc(m: MenuItem, e: EventArgs)

    MouseButtons* {.pure.} = enum
        mbNone, mbLeft = 10_48_576, mbRight = 20_97_152, mbMiddle = 41_94_304,
        mbXButton1 = 83_88_608, mbXButton2 = 167_77_216

    MouseEventArgs* = ref object of EventArgs
        mx, my, mDelta: int32
        mShiftPressed, mCtrlPressed: bool
        mButton: MouseButtons

    MouseEventHandler* = proc(c: Control, e: MouseEventArgs)

    KeyEventArgs* = ref object of EventArgs
        mAltPressed, mCtrlPressed, mShiftPressed: bool
        mKeyValue: int32
        mKeyCode: Keys
        mModifier: Keys

    KeyEventHandler* = proc(c: Control, e: KeyEventArgs)

    KeyPressEventArgs* = ref object of EventArgs
        keyChar*: char

    KeyPressEventHandler* = proc(c: Control, e: KeyPressEventArgs)

    Area* = object
        width*, height*: int32

    SizeEventArgs* = ref object of EventArgs
        mWinRect: LPRECT
        mClientArea: Area

    SizeEventHandler* = proc(c: Control, e: SizeEventArgs)

    DateTimeEventArgs* = ref object of EventArgs
        mDateStr: string
        mDateStruct: LPSYSTEMTIME

    DateTimeEventHandler* = proc(c: Control, e: DateTimeEventArgs)

    TrayIconEventHandler* = proc(c: TrayIcon, e: EventArgs)

    TreeViewAction* {.pure.} = enum
        tvaUnknown, tvaByKeyboard, tvaByMouse, tvaCollapse, tvaExpand

    TreeEventArgs* = ref object of EventArgs
        mAction: TreeViewAction
        mNode, mOldNode: TreeNode
        mNewState, mOldState: UINT

    TreeEventHandler* = proc(c: Control, e: TreeEventArgs)
    CreateFnHandler = proc(c: Control) {.nimcall.}

    LVItemEventArgs* = ref object of EventArgs
        item: ListViewItem
        index: int32

    LVSelChangeEventArgs* = ref object of LVItemEventArgs
        isSelected: bool

    LVItemCheckEventArgs* = ref object of LVItemEventArgs
        isChecked: bool

    LVItemClickEventHandler* = proc(c: Control, e: LVItemEventArgs)
    LVSelChangeEventHandler* = proc(c: Control, e: LVSelChangeEventArgs)
    LVCheckChangeEventHandler* = proc(c: Control, e: LVItemCheckEventArgs)


    # TimerTickHandler = proc(f: Form, e: EventArgs)

    Timer* = ref object
        interval: uint32
        onTick: EventHandler
        mParentHwnd: HWND
        mIsEnabled: bool
        mIdNum: UINT_PTR

    Control* = ref object of RootObj # Base class for all controls
        mKind: ControlType
        mClassName: LPCWSTR
        mName, mText: string
        mHandle: HWND
        mBackColor: Color
        mForeColor: Color
        mContextMenu : ContextMenu
        mWidth, mHeight, mXpos, mYpos, mCtlID: int32
        mStyle, mExStyle: DWORD
        mDrawMode: uint32
        mIsCreated, mLbDown, mRbDown, mIsMouseEntered: bool 
        mHasFont, mHasText, mCemnuUsed: bool
        mBkBrush: HBRUSH
        mFont: Font
        mParent: Form
        mcRect: RECT
        mWtext: WideString
        #Events
        onMouseEnter*, onClick*, onMouseLeave*, onRightClick*, onDoubleClick*: EventHandler
        onLostFocus*, onGotFocus*: EventHandler
        onMouseWheel*, onMouseHover*, onMouseMove*, onMouseDown*, onMouseUp*: MouseEventHandler
        onRightMouseDown*, onRightMouseUp*: MouseEventHandler
        onKeyDown*, onKeyUp*: KeyEventHandler
        onKeyPress*: KeyPressEventHandler
        createFnPtr*: CreateFnHandler


    FormPos* {.pure.} = enum
        fpCenter, fpTopLeft, fpTopMid, fpTopRight, fpMidLeft, fpMidRight,
        fpBottomLeft, fpBottomMid, fpBottomRight, fpManual

    FormStyle* {.pure.} = enum
        fsNone, fsFixedSingle, fsFixed3D, fsFixedDialog, fsNormalWindow,
        fsFixedTool, fsSizableTool, fsHidden

    WindowState* {.pure.} = enum
        wsNormal, wsMaximized, wsMinimized

    FormDrawMode {.pure.} = enum
        fdmNormal, fdmFlat, fdmGradient

    FormGrad = object
        c1, c2 : Color
        rtl : bool

    Form* = ref object of Control
        hInstance: HINSTANCE
        mFormPos: FormPos
        mFormStyle: FormStyle
        mFormState: WindowState
        mFdMode: FormDrawMode
        mMaximizeBox, mMinimizeBox, mTopMost, mIsLoaded: bool
        mIsMouseTracking, mCreateChilds, mIsMenuUsed: bool
        mAppFont : bool = true
        mMenuGrayBrush, mMenuDefBgBrush, mMenuHotBgBrush, mMenuFrameBrush : HBRUSH
        # mMenuFont : Font
        mMenuGrayCref : COLORREF
        mGrad : FormGrad
        mMenubar: MenuBar
        mMenuItemDict : Table[uint32, MenuItem]
        mComboData: Table[HWND, HWND]
        mControls: seq[Control]
        mTimerTable: Table[UINT_PTR, Timer]
        mFormID: int32

        #Events
        onLoad*, onActivate*, onDeActivate*, onMinimized*: EventHandler
        onMoving*, onMoved*, onClosing*: EventHandler
        onMaximized*, onRestored*: EventHandler
        onSizing*, onSized*: SizeEventHandler
        onThreadMsg*: ThreadMsgHandler
        # onKeyDown*, onKeyUp*: KeyEventHandler
        # onKeyPress*: KeyPressEventHandler

    FlatDraw = object
        defBrush : HBRUSH
        hotBrush : HBRUSH
        defFrmBrush : HBRUSH
        hotFrmBrush : HBRUSH
        defPen: HPEN
        hotPen: HPEN
        isActive: bool

    GradColor = object
        c1: Color
        c2: Color

    GdrawMode = enum
        gmDefault, gmFocused, gmClicked

    GradDraw = object
        gcDef: GradColor
        gcHot: GradColor
        defPen: HPEN
        hotPen: HPEN
        defBrush : HBRUSH
        hotBrush : HBRUSH
        rtl, isActive: bool


    Button* = ref object of Control
        mTxtFlag: UINT
        mFDraw: FlatDraw
        mGDraw: GradDraw

    WeekDays* {.pure.} = enum
        wdSunday, wdMonday, wdTuesday, wdWednesday, wdThursday, wdFriday, wdSaturday


    DateAndTime* = object
        year*, month*, day*, hour*, minute*, second*, milliSecond*: int32
        dayOfWeek*: WeekDays

    ViewMode* {.pure.} = enum
        vmMonthView, vmYearView, vmDecadeView, vmCenturyView

    Calendar* = ref object of Control
        mValue: DateAndTime
        mShowWeekNum, mNoTodayCircle, mNoToday, mNoTrailDates, mShortDateNames: bool
        mViewMode, mOldView: ViewMode
        #Events
        onSelectionCommitted*, onValueChanged*, onViewChanged*: EventHandler

    CheckBox* = ref object of Control
        mAutoSize, mChecked, mRightAlign: bool
        mWideText: LPWSTR
        mTextStyle: UINT
        #Events
        onCheckedChanged*: EventHandler

    ComboBox* = ref object of Control
        mSelIndex, mOwnCtlID: int32
        mReEnabled, mHasInput: bool
        mItems: seq[string]
        #Events
        onSelectionChanged*, onTextChanged*, onTextUpdated*: EventHandler
        onListOpened*, onListClosed*, onSelectionCommitted*, onSelectionCancelled*: EventHandler

    DTPFormat* {.pure.} = enum
        dfLongDate = 1, dfShortDate, dfTimeOnly = 4, dfCustom = 8

    DateTimePicker* = ref object of Control
        mFormat: DTPFormat
        mFmtStr: string
        mRightAlign, m4DYear, mShowWeekNum, mNoTodayCircle, mNoToday, mAutoSize: bool
        mNoTrailDates, mShortDateNames, mShowUpdown: bool
        mValue: DateAndTime
        mDropDownCount: int
        mCalStyle: DWORD
        # Events
        onValueChanged*, onCalendarOpened*, onCalendarClosed*: EventHandler
        onTextChanged*: DateTimeEventHandler

    GroupBoxStyle* {.pure.} = enum 
        gbsSystem, gbsClassic, gbsOverride

    GroupBox* = ref object of Control
        mTextWidth: int32
        mDBFill: bool
        mGetWidth: bool
        mThemeOff: bool
        mPen: HPEN
        mRect: RECT
        mHdc: HDC
        mBmp: HBITMAP
        mGBStyle: GroupBoxStyle
        mControls: seq[Control]

    LabelBorder* {.pure.} = enum
        lbNone, lbSingle, lbSunken

    Label* = ref object of Control
        mAutoSize, mMultiLine: bool
        mTextAlign: TextAlignment
        mBorder: LabelBorder
        mAlignFlag: DWORD

    ListBox* = ref object of Control
        mHasSort, mNoSelection, mMultiColumn, mKeyPreview, mVertScroll, mHorizScroll, mMultiSel: bool
        mDummyIndex: int32
        mSelIndex: int32
        mSelIndices: seq[int32]
        mItems: seq[string]
        # Events
        onSelectionChanged*, onSelectionCancelled*: EventHandler

    ListViewItem* = ref object
        mText: string
        mIndex, mImgIndex: int32
        mBackColor, mForeColor: Color
        mChecked: bool
        mFont: Font
        mLvHandle: HWND
        mColCount: int
        mSubItems: seq[string]

    ListViewColumn* = ref object
        mText: string
        mWideText: LPWSTR
        mWidth, mIndex, mImgIndex, mOrder: int32
        mImgOnRight, mHasImage, mDrawNeeded, mIsHotItem: bool
        mTextAlign, mHdrTextAlign: TextAlignment
        mBackColor, mForeColor: Color
        mHdrTextFlag: UINT
        mpLvc: LPLVCOLUMNW

    ListViewStyle* {.pure.} = enum
        lvsLargeIcon, lvsReport, lvsSmallIcon, lvsList, lvsTile

    ListView* = ref object of Control
        mSelIndex, mSelSubIndex, mHdrHeight: int32
        mColIndex, mRowIndex, mItemIndex, mLayoutCount: int32
        mEditLabel, mHideSel, mMultiSel, mHasCheckBox, mFullRowSel: bool
        mShowGrid, mOneClickActivate, mHotTrackSel, mNoHeader: bool
        mHdrClickable, mCheckBoxLast, mChecked, mChangeHdrHeight: bool
        mHdrBackColor, mHdrForeColor: Color
        mHdrHotBrush, mHdrBkBrush: HBRUSH
        mHdrFont: Font
        mHdrPen: HPEN
        mHotHdrIndex: DWORD_PTR
        mHdrHandle: HWND
        mSelItem: ListViewItem
        mViewStyle: ListViewStyle
        mColumns: seq[ListViewColumn]
        mItems: seq[ListViewItem]
        mSelItems: seq[ListViewItem]

        #Events
        onItemClick*, onItemDoubleClick*: LVItemClickEventHandler
        onSelectionChanged*: LVSelChangeEventHandler
        onItemCheckChanged*: LVCheckChangeEventHandler
        onItemHover*, onItemActivate*: EventHandler

    MenuType* {.pure.} = enum
        mtBaseMenu, mtMenuItem, mtPopup, mtSeparator, mtMenubar, mtContextMenu, mtContextSep

    MenuBase = ref object of RootObj
        mHandle: HMENU
        mFont: Font
        mMenuCount: uint32
        mMenus: Table[string, MenuItem]

    MenuBar* = ref object of MenuBase # Implemented in commons.nim
        mFormPtr : Form
        mMenuGrayCref: COLORREF
        mMenuDefBgBrush: HBRUSH
        mMenuHotBgBrush: HBRUSH
        mMenuFrameBrush: HBRUSH
        mMenuGrayBrush : HBRUSH

    MenuItem* = ref object of MenuBase
        mIsCreated, mIsEnabled, mPopup, mFormMenu : bool
        mTxtSizeReady: bool
        mId, mIndex : uint32
        mWideText: WideString 
        mBgColor, mFgColor: Color
        mTxtSize : SIZE
        mParentHandle: HMENU
        mText : string
        mType : MenuType
        mFormHwnd : HWND
        mBar: MenuBar
        # Events
        onClick*, onPopup*, onCloseup*, onFocus* : MenuEventHandler

    ContextMenu* = ref object of MenuBase
        mWidth, mHeight : int32
        mRightClick, mMenuInserted, mTrayParent: bool
        mGrayCref : COLORREF
        mDummyHwnd : HWND
        mParent: Control
        mTray: TrayIcon
        mDefBgBrush, mHotBgBrush, mBorderBrush, mGrayBrush : HBRUSH
        # Events
        onMenuShown*, onMenuClose* : EventHandler
        onTrayMenuShown*, onTrayMenuClose*: TrayIconEventHandler

    NumberPicker* = ref object of Control
        mButtonLeft, mHasSeperator, mAutoRotate, mHideCaret: bool
        mValue, mMinRange, mMaxRange, mStep: float
        mTrackMLeave, mKeyPressed, mTrackMouseLeave, mIntStep: bool
        mBuddyStyle, mBuddyExStyle, mTxtFlag: DWORD
        mDeciPrec, mBuddyCID, mLineX: int32
        mBuddyRect, mUpdRect, mMyRect: RECT
        mTopEdgeFlag, mBotEdgeFlag: UINT
        mTxtPos: TextAlignment
        mBuddyHandle: HWND
        mPen: HPEN
        mBuddySCID: UINT_PTR
        mBuddyStr: string
        #Event
        onValueChanged*: EventHandler

    ProgressBarState* {.pure.} = enum
        pbsNone, pbsNormal, pbsError, pbsPaused

    ProgressBarStyle* {.pure.} = enum
        pbsBlock, pbsMarquee

    ProgressBar* = ref object of Control
        mBarState: ProgressBarState
        mBarStyle: ProgressBarStyle
        mVertical, mShowPerc: bool
        mMinValue, mMaxValue, mStep, mValue, mMarqueeSpeed: int32
        # Events
        onProgressChanged*: EventHandler

    PropertyGrid = ref object of Control
        mPropName, mPropValue: string
        mRegistered: bool
        mHInst: HINSTANCE
        mWClsNamePtr: LPCWSTR

    RadioButton* = ref object of Control
        mAutoSize, mChecked, mCheckOnClick, mRightAlign: bool
        mTxtFlag: UINT
        mWideText: LPWSTR
        onCheckedChanged*: EventHandler

    TextCase* {.pure.} = enum
        tcNormal, tcLowerCase, tcUpperCase

    TextType* {.pure.} = enum
        ttNormal, ttNumberOnly, ttPasswordChar

    TextBox* = ref object of Control
        mTextAlign: TextAlignment
        mTextCase: TextCase
        mTextType: TextType
        mCueBanner: string
        mMultiLine, mHideSel, mReadOnly: bool
        #Events
        onTextChanged*: EventHandler

    ChannelStyle* {.pure.} = enum
        csClassic, csOutline

    TrackChange* {.pure.} = enum
        tcNone, tcArrowLow, tcArrowHigh, tcPageLow, tcPageHigh, tcMouseClick, tcMouseDrag

    TicPosition* {.pure.} = enum
        tpDownSide, tpUpSide, tpLeftSide, tpRightSide, tpBothSide

    TicDrawMode {.pure.} = enum
        tdmVertical, tdmHorizUpper, tdmHorizDown

    TicData = object
        phyPoint: int32
        logPoint: int32

    TrackBar* = ref object of Control
        mVertical, mReversed, mNoTics, mSelRange, mDefTics: bool
        mToolTip, mCustDraw, mFreeMove, mNoThumb: bool
        mTicWidth, mMinRange, mMaxRange, mFrequency, mPageSize: int32
        mLineSize, mTicLen, mValue, mThumbHalf, mP1, mP2, mTcCount: int32
        mTicColor, mChanColor, mSelColor: Color
        mChanRect, mThumbRect, mMyRect: RECT
        mChanPen, mTicPen: HPEN
        mChanStyle: ChannelStyle
        mTrackChange: TrackChange
        mTicPos: TicPosition
        mSelBrush: HBRUSH
        mChanFlag: UINT
        mTicList: seq[TicData]
        #Events
        onValueChanged*, onDragging*, onDragged*: EventHandler

    TrayMenuTrigger* {.pure.} = enum 
        tmtNone, tmtLeftClick, tmtleftDoubleClick, tmtRightClick = 4, tmtAnyClick = 7

    BalloonIcon* {.pure.} = enum
        biNone, biInfo, biWarning, biError, biCustom

    TrayIcon* = ref object
        mResetIcon, mCmenuUsed, mRetainIcon: bool 
        mTrig: uint8
        mMenuTrigger : TrayMenuTrigger
        mhTrayIcon: HICON
        mMsgHwnd: HWND
        mCmenu: ContextMenu
        mTooltip, mIconpath: string
        userData: pointer
        mNid: NOTIFYICONDATA

        onBalloonShow, onBalloonClose, onBalloonClick: TrayIconEventHandler 
        onMouseMove, onLeftMouseDown, onLeftMouseUp: TrayIconEventHandler
        onRightMouseDown, onRightMouseUp, onLeftClick: TrayIconEventHandler
        onRightClick, onLeftDoubleClick: TrayIconEventHandler


    # NodeNotifyHandler = proc(tv: TreeView, parent: TreeNode, child: TreeNode, nop: NodeOps, pos: int32)
    TreeNode* = ref object
        mImgIndex, mSelImgIndex, mChildCount, mIndex, mNodeCount, mNodeID: int32
        mChecked, mIsCreated: bool
        mForeColor, mBackColor: Color
        mHandle: HTREEITEM
        mTreeHandle: HWND
        mParentNode: TreeNode
        mText: string
        # mNotifyHandler: NodeNotifyHandler
        mNodes: seq[TreeNode]

    NodeOps {.pure.} = enum
        noAddNode, noInsertNode, noAddChild, noInsertChild

    NodeNotify = ref object # Send data from a node to treeview
        node: TreeNode
        parent: TreeNode
        pos: int32
        nops: NodeOps

    NodeAction {.pure.} = enum
        naAddNode, naSetText, naForeColor, naBackColor

    TreeView* = ref object of Control
        mNoLine, mNoButton, mHasCheckBox, mFullRowSel: bool
        mEditable, mShowSel, mHotTrack, mNodeChecked: bool
        mNodeCount, mUniqNodeID: int32
        mLineColor: Color
        mSelNode: TreeNode
        mNodes: seq[TreeNode]
        # Events
        onBeginEdit, onEndEdit, onNodeDeleted : EventHandler
        onBeforeChecked, onAfterChecked, onBeforeSelected: TreeEventHandler
        onAfterSelected, onBeforeExpanded, onAfterExpanded: TreeEventHandler
        onBeforeCollapsed, onAfterCollapsed: TreeEventHandler

    # FormMap = object 
    #     key: HWND
    #     value: Form 


    AppData = object
        appStarted: bool
        loopStarted: bool
        screenWidth: int32
        screenHeight: int32
        formCount: int32
        mainHwnd: HWND
        trayHwnds: seq[HWND]
        hInstance: HINSTANCE
        isDateInit: bool
        iccEx: INITCOMMONCONTROLSEX
        logfont: LOGFONTW
        scaleFactor: cint
        sysDPI: int32
        scaleF: float
        sendMsgBuffer: WideString

proc finalize*(this: var WideString) 
proc appFinalize(this: var AppData) =
    if this.trayHwnds.len > 0: 
        for hwnd in this.trayHwnds:
            if IsWindow(hwnd) > 0: DestroyWindow(hwnd)

    this.sendMsgBuffer.finalize()
    echo "Nimforms is exiting..."

var appData : AppData # Global object to hold some app level info.



var ewca : array[1, WCHAR] # Empty Wchar Array
ewca[0] = cast[WCHAR](0)
let emptyWStrPtr = ewca[0].unsafeAddr

