# Type module

type
    ControlType* {.pure.} = enum
        ctNone, ctButton, ctCalendar, ctCheckBox, ctComboBox, ctDateTimePicker, ctGroupBox, ctLabel,
        ctListBox, ctListView, ctNumberPicker, ctProgressBar, ctRadioButton, ctTextBox, ctTrackBar, ctTreeView

    Color* = ref object
        red*, green*, blue*, value*: uint
        cref*: COLORREF

    FontWeight* {.pure.} = enum
        fwLight = 300, fwNormal = 400, fwMedium = 500, fwSemiBold = 600, fwBold = 700,
        fwExtraBold = 800, fwUltraBold = 900

    Font* = ref object
        name*: string
        size*: int32
        weight*: FontWeight
        italics*, underLine*, strikeOut*: bool
        handle: HFONT

    EventArgs* = ref object of RootObj
        handled*: bool
        cancelled*: bool

    EventHandler* = proc(c: Control, e: EventArgs)

    MouseButton* {.pure.} = enum
        mbNone, mbLeft = 10_48_576, mbRight = 20_97_152, mbMiddle = 41_94_304,
        mbXButton1 = 83_88_608, mbXButton2 = 167_77_216

    MouseEventArgs* = ref object of EventArgs
        mx, my, mDelta: int32
        mShiftPressed, mCtrlPressed: bool
        mButton: MouseButton

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


    Control* = ref object of RootObj # Base class for all controls
        mKind: ControlType
        mName, mClassName, mText: string
        mHandle: HWND
        mBackColor: Color
        mForeColor: Color
        mWidth, mHeight, mXpos, mYpos, mCtlID: int32
        mStyle, mExStyle: DWORD
        mDrawMode: uint32
        mIsCreated, mLbDown, mRbDown, mIsMouseEntered, mHasText: bool
        mBkBrush: HBRUSH
        mFont: Font
        mParent: Form
        #Events
        onMouseEnter*, onClick*, onMouseLeave*, onRightClick*, onDoubleClick*: EventHandler
        onMouseWheel*, onMouseHover*, onMouseMove*, onMouseDown*, onMouseUp*: MouseEventHandler
        onRightMouseDown*, onRightMouseUp*: MouseEventHandler
        onKeyDown*, onKeyUp*: KeyEventHandler
        onKeyPress*: KeyPressEventHandler


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

    Form* = ref object of Control
        hInstance: HINSTANCE
        mFormPos: FormPos
        mFormStyle: FormStyle
        mFormState: WindowState
        drawMode: FormDrawMode
        mMaximizeBox, mMinimizeBox, mTopMost, mIsLoaded: bool
        mIsMouseTracking: bool

        #Events
        onLoad*, onActivate*, onDeActivate*, onMinimized*: EventHandler
        onMoving*, onMoved*, onClosing*: EventHandler
        onMaximized*, onRestored*: EventHandler
        onSizing*, onSized*: SizeEventHandler
        # onKeyDown*, onKeyUp*: KeyEventHandler
        # onKeyPress*: KeyPressEventHandler

    FlatDraw = ref object
        defBrush : HBRUSH
        hotBrush : HBRUSH
        defFrmBrush : HBRUSH
        hotFrmBrush : HBRUSH
        defPen: HPEN
        hotPen: HPEN
        isActive: bool

    GradColor = ref object
        c1: Color
        c2: Color

    GradDraw = ref object
        gcDef: GradColor
        gcHot: GradColor
        defPen: HPEN
        hotPen: HPEN
        rtl, isActive: bool


    Button* = ref object of Control
        mTxtFlag: UINT
        mFDraw: FlatDraw
        mGDraw: GradDraw









