
# button module Created on 27-Mar-2023 01:56 PM

#[========================================Button Docs========================================
    constructor - newButton(): Button
    Properties
        All props inherited from Control type
   
   Functions
         createHandle - Create the handle of button
         setGradientColor - Set gradient back color     

    Events
        All events inherited from Control type.

======================================================================================================]#

# Constants
const
    BS_PUSHBUTTON = 0x00000000
    BS_DEFPUSHBUTTON = 0x00000001
    BS_CHECKBOX = 0x00000002
    BS_AUTOCHECKBOX = 0x00000003
    BS_RADIOBUTTON = 0x00000004
    BS_3STATE = 0x00000005
    BS_AUTO3STATE = 0x00000006
    BS_GROUPBOX = 0x00000007
    BS_USERBUTTON = 0x00000008
    BS_AUTORADIOBUTTON = 0x00000009
    BS_PUSHBOX = 0x0000000A
    BS_OWNERDRAW = 0x0000000B
    BS_TYPEMASK = 0x0000000F
    BS_LEFTTEXT = 0x00000020
    BS_TEXT = 0x00000000
    BS_ICON = 0x00000040
    BS_BITMAP = 0x00000080
    BS_LEFT = 0x00000100
    BS_RIGHT = 0x00000200
    BS_CENTER = 0x00000300
    BS_TOP = 0x00000400
    BS_BOTTOM = 0x00000800
    BS_VCENTER = 0x00000C00
    BS_PUSHLIKE = 0x00001000
    BS_MULTILINE = 0x00002000
    BS_NOTIFY = 0x00004000
    BS_FLAT = 0x00008000
    BS_RIGHTBUTTON = BS_LEFTTEXT
    BN_CLICKED = 0
    BN_PAINT = 1
    BN_HILITE = 2
    BN_UNHILITE = 3
    BN_DISABLE = 4
    BN_DOUBLECLICKED = 5
    BN_PUSHED = BN_HILITE
    BN_UNPUSHED = BN_UNHILITE
    BN_DBLCLK = BN_DOUBLECLICKED
    BN_SETFOCUS = 6
    BN_KILLFOCUS = 7
    BM_GETCHECK = 0x00F0
    BM_SETCHECK = 0x00F1
    BM_GETSTATE = 0x00F2
    BM_SETSTATE = 0x00F3
    BM_SETSTYLE = 0x00F4
    BM_CLICK = 0x00F5
    BM_GETIMAGE = 0x00F6
    BM_SETIMAGE = 0x00F7
    BM_SETDONTCLICK = 0x00f8
    MOUSECLICKFLAG = 0b1
    MOUSEOVERFLAG = 0b1000000
    ROUND_CURVE = 5

var btnCount = 1

# Forward declaration
proc btnWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.}
proc createHandle*(this: Button)

# Button constructor
proc newButton*(parent: Form, txt: string = "", x: int32 = 10, y: int32 = 10, 
                w: int32 = 110, h: int32 = 34, evtFn: EventHandler = nil): Button =
    new(result)
    result.mKind = ctButton
    result.mClassName = cast[LPCWSTR](BtnClass[0].addr)
    result.mName = "Button_" & $btnCount
    result.mParent = parent
    result.mXpos = x
    result.mYpos = y
    result.mWidth = w
    result.mHeight = h
    result.mFont = parent.mFont
    result.mHasFont = true
    result.mHasText = true
    result.mStyle = WS_CHILD or BS_NOTIFY or WS_TABSTOP or WS_VISIBLE or BS_PUSHBUTTON
    result.mText = (if txt == "": "Button_" & $btnCount else: txt)
    result.mWtext = newWideString(result.mText)
    parent.mControls.add(result)
    btnCount += 1
    if evtFn != nil: result.onClick = evtFn
    if parent.mCreateChilds: result.createHandle()


# Create button's hwnd
proc createHandle*(this: Button) =
    this.createHandleInternal()
    if this.mHandle != nil:
        this.setSubclass(btnWndProc)
        this.setFontInternal()

method autoCreate(this: Button) = this.createHandle()


# Set necessery data for a flat colored button
proc flatDrawSetData(this: var FlatDraw, clr: Color) =
    let adj : float = (if clr.isDark: 1.5 else: 1.15)
    this.defBrush = CreateSolidBrush(clr.cref)
    this.hotBrush = CreateSolidBrush(clr.getChangedColorRef(adj))
    this.defPen = CreatePen(PS_SOLID, 1, clr.getChangedColorRef(0.6))
    this.hotPen = CreatePen(PS_SOLID, 1, clr.getChangedColorRef(0.3))
    this.isActive = true

# Overriding Control's property because, button class needs a different treatment
proc `backColor=`*(this: Button, clr: uint) =
    this.mBackColor = newColor(clr)
    this.mFDraw.flatDrawSetData(this.mBackColor)
    if (this.mDrawMode and 2) != 2: this.mDrawMode += 2
    this.checkRedraw()

# Set necessery data for a gradient colored button.
proc gradDrawSetData(this: var GradDraw, c1, c2: uint) =
    this.isActive = true
    this.gcDef.c1 = newColor(c1)
    this.gcDef.c2 = newColor(c2)
    let hotAdj1 = (if this.gcDef.c1.isDark(): 1.5 else : 1.2)
    let hotAdj2 = (if this.gcDef.c2.isDark(): 1.5 else: 1.2)
    this.gcHot.c1 = this.gcDef.c1.getChangedColor(hotAdj1)
    this.gcHot.c2 = this.gcDef.c2.getChangedColor(hotAdj2)
    this.defPen = CreatePen(PS_SOLID, 1, this.gcDef.c1.getChangedColorRef(0.6))
    this.hotPen = CreatePen(PS_SOLID, 1, this.gcHot.c1.getChangedColorRef(0.3))
    if this.defBrush != nil:
         this.defBrush = nil
    if this.hotBrush != nil:
         this.hotBrush = nil

# Set gradient colors for this button.
proc setGradientColor*(this: Button, clr1, clr2: uint) =
    this.mGDraw.gradDrawSetData(clr1, clr2)
    if (this.mDrawMode and 4) != 4: this.mDrawMode += 4
    this.checkRedraw()

# Helper function for drawing a flat color button.
proc paintFlatBtnRoundRect(dc: HDC, rc: RECT, hbr: HBRUSH, pen: HPEN): LRESULT =
    SelectObject(dc, pen);
    SelectObject(dc, hbr);
    RoundRect(dc, rc.left, rc.top, rc.right, rc.bottom, ROUND_CURVE, ROUND_CURVE);
    FillPath(dc);
    result = CDRF_NOTIFYPOSTPAINT

# Helper function for drawing text on a button.
proc drawTextColor(this: Button, ncd: LPNMCUSTOMDRAW): LRESULT =
    SetTextColor(ncd.hdc, this.mForeColor.cref)
    SetBkMode(ncd.hdc, 1)
    DrawTextW(ncd.hdc, &this.mWtext, this.mWtext.wcLen, ncd.rc.unsafeAddr, this.mTxtFlag )
    return CDRF_NOTIFYPOSTPAINT

# Helper function dealing wm_notify message in a button's wndproc.
proc drawBackColor(this: Button, ncd: LPNMCUSTOMDRAW): LRESULT =
    case ncd.dwDrawStage
    of CDDS_PREERASE: # This happens when the paint starts
        return CDRF_NOTIFYPOSTERASE # Telling the program to inform us after erase
    of CDDS_PREPAINT: # We get the notification after erase happened.
        if (ncd.uItemState and MOUSECLICKFLAG) == MOUSECLICKFLAG:
            return paintFlatBtnRoundRect(ncd.hdc, ncd.rc, this.mFDraw.defBrush, this.mFDraw.hotPen)
        elif (ncd.uItemState and MOUSEOVERFLAG) == MOUSEOVERFLAG:
           return paintFlatBtnRoundRect(ncd.hdc, ncd.rc, this.mFDraw.hotBrush, this.mFDraw.hotPen)
        else:
            return paintFlatBtnRoundRect(ncd.hdc, ncd.rc, this.mFDraw.defBrush, this.mFDraw.defPen)
    else: discard
    return CDRF_DODEFAULT

# Helper function for drawing a gradient color button.
proc paintGradientRound(nm: LPNMCUSTOMDRAW, gBrush: HBRUSH, pen: HPEN): LRESULT =
    # var gBrush = createGradientBrush(dc, rc, gc.c1, gc.c2)
    SelectObject(nm.hdc, pen)
    SelectObject(nm.hdc, gBrush)
    RoundRect(nm.hdc, nm.rc.left, nm.rc.top, nm.rc.right, nm.rc.bottom, 5, 5)
    FillPath(nm.hdc)
    # DeleteObject(gBrush)
    result = CDRF_DODEFAULT

# Helper function dealing wm_notify message in a button's wndproc.
proc drawGradientBackColor(this: Button, ncd: LPNMCUSTOMDRAW): LRESULT =
    case ncd.dwDrawStage
    of CDDS_PREERASE: return  CDRF_NOTIFYPOSTERASE
    of CDDS_PREPAINT:
        if (ncd.uItemState and MOUSECLICKFLAG) == MOUSECLICKFLAG:
            if this.mGDraw.defBrush == nil:
                this.mGDraw.createGradientBrush(ncd.hdc, ncd.rc, gmClicked)
            return paintGradientRound(ncd, this.mGDraw.defBrush, this.mGDraw.hotPen)
        elif (ncd.uItemState and MOUSEOVERFLAG) == MOUSEOVERFLAG:
            if this.mGDraw.hotBrush == nil:
                this.mGDraw.createGradientBrush(ncd.hdc, ncd.rc, gmFocused)
            return paintGradientRound(ncd, this.mGDraw.hotBrush, this.mGDraw.hotPen)
        else:
            if this.mGDraw.defBrush == nil:
                this.mGDraw.createGradientBrush(ncd.hdc, ncd.rc, gmDefault)
            return paintGradientRound(ncd, this.mGDraw.defBrush, this.mGDraw.defPen)
    else: discard

proc flatDrawFinalize(this: var FlatDraw) =
    DeleteObject(this.defBrush)
    DeleteObject(this.hotBrush)
    DeleteObject(this.defPen)
    DeleteObject(this.hotPen)
    echo "flat draw finished"

proc gradDrowFinalize(this: var GradDraw) =
    DeleteObject(this.defBrush)
    DeleteObject(this.hotBrush)
    DeleteObject(this.defPen)
    DeleteObject(this.hotPen)
    echo "grad draw finished"

# Deleting certain resources for this button.
proc btnDtor(this: Button) =
    if this.mFDraw.isActive:
        this.mFDraw.flatDrawFinalize()
    
    if this.mGDraw.isActive:
        this.mGDraw.gradDrowFinalize() 



proc btnWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, 
                        scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.} =  
    case msg
    of WM_DESTROY:
        var this = cast[Button](refData)
        this.btnDtor()
        this.destructor()
        RemoveWindowSubclass(hw, btnWndProc, scID)

    of WM_LBUTTONDOWN:
        var this = cast[Button](refData)
        this.leftButtonDownHandler(msg, wpm, lpm)

    of WM_LBUTTONUP:
        var this = cast[Button](refData)
        this.leftButtonUpHandler(msg, wpm, lpm)

    of WM_RBUTTONDOWN:
        var this = cast[Button](refData)
        this.rightButtonDownHandler(msg, wpm, lpm)

    of WM_RBUTTONUP:
        var this = cast[Button](refData)
        this.rightButtonUpHandler(msg, wpm, lpm)

    of WM_MOUSEMOVE:
        var this = cast[Button](refData)
        this.mouseMoveHandler(msg, wpm, lpm)
        
    of WM_MOUSELEAVE:
        var this = cast[Button](refData)
        this.mouseLeaveHandler()
        
    of WM_CONTEXTMENU:
        var this = cast[Button](refData)
        if this.mContextMenu != nil: this.mContextMenu.showMenu(lpm)

    of MM_NOTIFY_REFLECT:
        var this = cast[Button](refData)
        var ret : LRESULT= CDRF_DODEFAULT
        if this.mDrawMode > 0:
            var nmcd = cast[LPNMCUSTOMDRAW](lpm)
            case this.mDrawMode
            of 1: ret = this.drawTextColor(nmcd) # ForeColor only
            of 2: ret = this.drawBackColor(nmcd) # BackColor only
            of 3:
                discard this.drawBackColor(nmcd) # Back & Fore colors
                ret = this.drawTextColor(nmcd)
            of 4: ret = this.drawGradientBackColor(nmcd) # Gradient only
            of 5: #------------------------------------------------Gradient & fore colors
                discard this.drawGradientBackColor(nmcd)
                ret = this.drawTextColor(nmcd)
            else: discard
        return ret

    else: return DefSubclassProc(hw, msg, wpm, lpm)
    return DefSubclassProc(hw, msg, wpm, lpm)

