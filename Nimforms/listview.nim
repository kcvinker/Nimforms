# listview module Created on 01-Apr-2023 11:22 PM

# Note: Improve some properties to respond at runtime
# Constants
const
    LVM_FIRST = 0x1000
    LVN_FIRST = cast[UINT](0-100)
    LVS_ICON = 0x0
    LVS_REPORT = 0x1
    LVS_SMALLICON = 0x2
    LVS_LIST = 0x3
    LVS_TYPEMASK = 0x3
    LVS_SINGLESEL = 0x4
    LVS_SHOWSELALWAYS = 0x8
    LVS_SORTASCENDING = 0x10
    LVS_SORTDESCENDING = 0x20
    LVS_SHAREIMAGELISTS = 0x40
    LVS_NOLABELWRAP = 0x80
    LVS_AUTOARRANGE = 0x100
    LVS_EDITLABELS = 0x200
    LVS_OWNERDATA = 0x1000
    LVS_NOSCROLL = 0x2000
    LVS_TYPESTYLEMASK = 0xfc00
    LVS_ALIGNTOP = 0x0
    LVS_ALIGNLEFT = 0x800
    LVS_ALIGNMASK = 0xc00
    LVS_NOCOLUMNHEADER = 0x4000
    LVS_NOSORTHEADER = 0x8000
    LVM_GETBKCOLOR = LVM_FIRST+0
    LVM_SETBKCOLOR = LVM_FIRST+1
    LVM_GETIMAGELIST = LVM_FIRST+2
    LVSIL_NORMAL = 0
    LVSIL_SMALL = 1
    LVSIL_STATE = 2
    LVSIL_GROUPHEADER = 3
    LVM_SETIMAGELIST = LVM_FIRST+3
    LVM_GETITEMCOUNT = LVM_FIRST+4
    LVIF_TEXT = 0x1
    LVIF_IMAGE = 0x2
    LVIF_PARAM = 0x4
    LVIF_STATE = 0x8
    LVIF_INDENT = 0x10
    LVIF_NORECOMPUTE = 0x800
    LVIF_GROUPID = 0x100
    LVIF_COLUMNS = 0x200
    LVIF_COLFMT = 0x10000
    LVIS_FOCUSED = 0x1
    LVIS_SELECTED = 0x2
    LVIS_CUT = 0x4
    LVIS_DROPHILITED = 0x8
    LVIS_GLOW = 0x10
    LVIS_ACTIVATING = 0x20
    LVIS_OVERLAYMASK = 0xf00
    LVIS_STATEIMAGEMASK = 0xF000
    LVM_GETITEMW = LVM_FIRST+75
    LVM_SETITEMW = LVM_FIRST+76
    LVM_INSERTITEMW = LVM_FIRST+77
    LVM_DELETEITEM = LVM_FIRST+8
    LVM_DELETEALLITEMS = LVM_FIRST+9
    LVM_GETCALLBACKMASK = LVM_FIRST+10
    LVM_SETCALLBACKMASK = LVM_FIRST+11
    LVNI_ALL = 0x0
    LVNI_FOCUSED = 0x1
    LVNI_SELECTED = 0x2
    LVNI_CUT = 0x4
    LVNI_DROPHILITED = 0x8
    LVNI_STATEMASK = LVNI_FOCUSED or LVNI_SELECTED or LVNI_CUT or LVNI_DROPHILITED
    LVNI_VISIBLEORDER = 0x10
    LVNI_PREVIOUS = 0x20
    LVNI_VISIBLEONLY = 0x40
    LVNI_SAMEGROUPONLY = 0x80
    LVNI_ABOVE = 0x100
    LVNI_BELOW = 0x200
    LVNI_TOLEFT = 0x400
    LVNI_TORIGHT = 0x800
    LVNI_DIRECTIONMASK = LVNI_ABOVE or LVNI_BELOW or LVNI_TOLEFT or LVNI_TORIGHT
    LVM_GETNEXTITEM = LVM_FIRST+12
    LVFI_PARAM = 0x1
    LVFI_STRING = 0x2
    LVFI_PARTIAL = 0x8
    LVFI_WRAP = 0x20
    LVFI_NEARESTXY = 0x40
    LVM_FINDITEMW = LVM_FIRST+83
    LVIR_BOUNDS = 0
    LVIR_ICON = 1
    LVIR_LABEL = 2
    LVIR_SELECTBOUNDS = 3
    LVM_GETITEMRECT = LVM_FIRST+14
    LVM_SETITEMPOSITION = LVM_FIRST+15
    LVM_GETITEMPOSITION = LVM_FIRST+16
    LVM_GETSTRINGWIDTHA = LVM_FIRST+17
    LVM_GETSTRINGWIDTHW = LVM_FIRST+87
    LVM_HITTEST = LVM_FIRST+18
    LVM_ENSUREVISIBLE = LVM_FIRST+19
    LVM_SCROLL = LVM_FIRST+20
    LVM_REDRAWITEMS = LVM_FIRST+21
    LVA_DEFAULT = 0x0
    LVA_ALIGNLEFT = 0x1
    LVA_ALIGNTOP = 0x2
    LVA_SNAPTOGRID = 0x5
    LVM_ARRANGE = LVM_FIRST+22
    LVM_EDITLABELA = LVM_FIRST+23
    LVM_EDITLABELW = LVM_FIRST+118
    LVM_GETEDITCONTROL = LVM_FIRST+24
    LVCF_FMT = 0x1
    LVCF_WIDTH = 0x2
    LVCF_TEXT = 0x4
    LVCF_SUBITEM = 0x8
    LVCF_IMAGE = 0x10
    LVCF_ORDER = 0x20
    LVCF_MINWIDTH = 0x40
    LVCF_DEFAULTWIDTH = 0x80
    LVCF_IDEALWIDTH = 0x100
    LVCFMT_LEFT = 0x0
    LVCFMT_RIGHT = 0x1
    LVCFMT_CENTER = 0x2
    LVCFMT_JUSTIFYMASK = 0x3
    LVCFMT_IMAGE = 0x800
    LVCFMT_BITMAP_ON_RIGHT = 0x1000
    LVCFMT_COL_HAS_IMAGES = 0x8000
    LVCFMT_FIXED_WIDTH = 0x100
    LVCFMT_NO_DPI_SCALE = 0x40000
    LVCFMT_FIXED_RATIO = 0x80000
    LVCFMT_LINE_BREAK = 0x100000
    LVCFMT_FILL = 0x200000
    LVCFMT_WRAP = 0x400000
    LVCFMT_NO_TITLE = 0x800000
    LVCFMT_SPLITBUTTON = 0x1000000
    LVCFMT_TILE_PLACEMENTMASK = LVCFMT_LINE_BREAK or LVCFMT_FILL
    LVM_GETCOLUMNW = LVM_FIRST+95
    LVM_SETCOLUMNW = LVM_FIRST+96
    LVM_INSERTCOLUMNW = LVM_FIRST+97
    LVM_DELETECOLUMN = LVM_FIRST+28
    LVM_GETCOLUMNWIDTH = LVM_FIRST+29
    LVSCW_AUTOSIZE = -1
    LVSCW_AUTOSIZE_USEHEADER = -2
    LVM_SETCOLUMNWIDTH = LVM_FIRST+30
    LVM_GETHEADER = LVM_FIRST+31
    LVM_CREATEDRAGIMAGE = LVM_FIRST+33
    LVM_GETVIEWRECT = LVM_FIRST+34
    LVM_GETTEXTCOLOR = LVM_FIRST+35
    LVM_SETTEXTCOLOR = LVM_FIRST+36
    LVM_GETTEXTBKCOLOR = LVM_FIRST+37
    LVM_SETTEXTBKCOLOR = LVM_FIRST+38
    LVM_GETTOPINDEX = LVM_FIRST+39
    LVM_GETCOUNTPERPAGE = LVM_FIRST+40
    LVM_GETORIGIN = LVM_FIRST+41
    LVM_UPDATE = LVM_FIRST+42
    LVM_SETITEMSTATE = LVM_FIRST+43
    LVM_GETITEMSTATE = LVM_FIRST+44
    LVM_GETITEMTEXTA = LVM_FIRST+45
    LVM_GETITEMTEXTW = LVM_FIRST+115
    LVM_SETITEMTEXTA = LVM_FIRST+46
    LVM_SETITEMTEXTW = LVM_FIRST+116
    LVSICF_NOINVALIDATEALL = 0x1
    LVSICF_NOSCROLL = 0x2
    LVM_SETITEMCOUNT = LVM_FIRST+47
    LVM_SORTITEMS = LVM_FIRST+48
    LVM_SETITEMPOSITION32 = LVM_FIRST+49
    LVM_GETSELECTEDCOUNT = LVM_FIRST+50
    LVM_GETITEMSPACING = LVM_FIRST+51
    LVM_GETISEARCHSTRINGA = LVM_FIRST+52
    LVM_GETISEARCHSTRINGW = LVM_FIRST+117
    LVM_SETICONSPACING = LVM_FIRST+53
    LVM_SETEXTENDEDLISTVIEWSTYLE = LVM_FIRST+54
    LVM_GETEXTENDEDLISTVIEWSTYLE = LVM_FIRST+55
    LVS_EX_GRIDLINES = 0x1
    LVS_EX_SUBITEMIMAGES = 0x2
    LVS_EX_CHECKBOXES = 0x4
    LVS_EX_TRACKSELECT = 0x8
    LVS_EX_HEADERDRAGDROP = 0x10
    LVS_EX_FULLROWSELECT = 0x20
    LVS_EX_ONECLICKACTIVATE = 0x40
    LVS_EX_TWOCLICKACTIVATE = 0x80
    LVS_EX_FLATSB = 0x100
    LVS_EX_REGIONAL = 0x200
    LVS_EX_INFOTIP = 0x400
    LVS_EX_UNDERLINEHOT = 0x800
    LVS_EX_UNDERLINECOLD = 0x1000
    LVS_EX_MULTIWORKAREAS = 0x2000
    LVS_EX_LABELTIP = 0x4000
    LVS_EX_BORDERSELECT = 0x8000
    LVS_EX_DOUBLEBUFFER = 0x10000
    LVS_EX_HIDELABELS = 0x20000
    LVS_EX_SINGLEROW = 0x40000
    LVS_EX_SNAPTOGRID = 0x80000
    LVS_EX_SIMPLESELECT = 0x100000
    LVS_EX_JUSTIFYCOLUMNS = 0x200000
    LVS_EX_TRANSPARENTBKGND = 0x400000
    LVS_EX_TRANSPARENTSHADOWTEXT = 0x800000
    LVS_EX_AUTOAUTOARRANGE = 0x1000000
    LVS_EX_HEADERINALLVIEWS = 0x2000000
    LVS_EX_AUTOCHECKSELECT = 0x8000000
    LVS_EX_AUTOSIZECOLUMNS = 0x10000000
    LVS_EX_COLUMNSNAPPOINTS = 0x40000000
    LVS_EX_COLUMNOVERFLOW = 0x80000000'i32
    LVM_GETSUBITEMRECT = LVM_FIRST+56
    LVM_SUBITEMHITTEST = LVM_FIRST+57
    LVM_SETCOLUMNORDERARRAY = LVM_FIRST+58
    LVM_GETCOLUMNORDERARRAY = LVM_FIRST+59
    LVM_SETHOTITEM = LVM_FIRST+60
    LVM_GETHOTITEM = LVM_FIRST+61
    LVM_SETHOTCURSOR = LVM_FIRST+62
    LVM_GETHOTCURSOR = LVM_FIRST+63
    LVM_APPROXIMATEVIEWRECT = LVM_FIRST+64
    LV_MAX_WORKAREAS = 16
    LVM_SETWORKAREAS = LVM_FIRST+65
    LVM_GETWORKAREAS = LVM_FIRST+70
    LVM_GETNUMBEROFWORKAREAS = LVM_FIRST+73
    LVM_GETSELECTIONMARK = LVM_FIRST+66
    LVM_SETSELECTIONMARK = LVM_FIRST+67
    LVM_SETHOVERTIME = LVM_FIRST+71
    LVM_GETHOVERTIME = LVM_FIRST+72
    LVM_SETTOOLTIPS = LVM_FIRST+74
    LVM_GETTOOLTIPS = LVM_FIRST+78
    LVM_SORTITEMSEX = LVM_FIRST+81
    LVBKIF_SOURCE_NONE = 0x0
    LVBKIF_SOURCE_HBITMAP = 0x1
    LVBKIF_SOURCE_URL = 0x2
    LVBKIF_SOURCE_MASK = 0x3
    LVBKIF_STYLE_NORMAL = 0x0
    LVBKIF_STYLE_TILE = 0x10
    LVBKIF_STYLE_MASK = 0x10
    LVBKIF_FLAG_TILEOFFSET = 0x100
    LVBKIF_TYPE_WATERMARK = 0x10000000
    LVBKIF_FLAG_ALPHABLEND = 0x20000000
    LVM_SETBKIMAGEA = LVM_FIRST+68
    LVM_SETBKIMAGEW = LVM_FIRST+138
    LVM_GETBKIMAGEA = LVM_FIRST+69
    LVM_GETBKIMAGEW = LVM_FIRST+139
    LVM_SETSELECTEDCOLUMN = LVM_FIRST+140
    LVM_SETTILEWIDTH = LVM_FIRST+141
    LV_VIEW_ICON = 0x0
    LV_VIEW_DETAILS = 0x1
    LV_VIEW_SMALLICON = 0x2
    LV_VIEW_LIST = 0x3
    LV_VIEW_TILE = 0x4
    LV_VIEW_MAX = 0x4
    LVM_SETVIEW = LVM_FIRST+142
    LVM_GETVIEW = LVM_FIRST+143
    LVM_INSERTGROUP = LVM_FIRST+145
    LVM_SETGROUPINFO = LVM_FIRST+147
    LVM_GETGROUPINFO = LVM_FIRST+149
    LVM_REMOVEGROUP = LVM_FIRST+150
    LVM_MOVEGROUP = LVM_FIRST+151
    LVM_GETGROUPCOUNT = LVM_FIRST+152
    LVM_GETGROUPINFOBYINDEX = LVM_FIRST+153
    LVM_MOVEITEMTOGROUP = LVM_FIRST+154
    LVGGR_GROUP = 0
    LVGGR_HEADER = 1
    LVGGR_LABEL = 2
    LVGGR_SUBSETLINK = 3
    LVM_GETGROUPRECT = LVM_FIRST+98
    LVGMF_NONE = 0x0
    LVGMF_BORDERSIZE = 0x1
    LVGMF_BORDERCOLOR = 0x2
    LVGMF_TEXTCOLOR = 0x4
    LVM_SETGROUPMETRICS = LVM_FIRST+155
    LVM_GETGROUPMETRICS = LVM_FIRST+156
    LVM_ENABLEGROUPVIEW = LVM_FIRST+157
    LVM_SORTGROUPS = LVM_FIRST+158
    LVM_INSERTGROUPSORTED = LVM_FIRST+159
    LVM_REMOVEALLGROUPS = LVM_FIRST+160
    LVM_HASGROUP = LVM_FIRST+161
    LVM_GETGROUPSTATE = LVM_FIRST+92
    LVM_GETFOCUSEDGROUP = LVM_FIRST+93
    LVM_SETTILEVIEWINFO = LVM_FIRST+162
    LVM_GETTILEVIEWINFO = LVM_FIRST+163
    LVM_SETTILEINFO = LVM_FIRST+164
    LVM_GETTILEINFO = LVM_FIRST+165
    LVIM_AFTER = 0x1
    LVM_SETINSERTMARK = LVM_FIRST+166
    LVM_GETINSERTMARK = LVM_FIRST+167
    LVM_INSERTMARKHITTEST = LVM_FIRST+168
    LVM_GETINSERTMARKRECT = LVM_FIRST+169
    LVM_SETINSERTMARKCOLOR = LVM_FIRST+170
    LVM_GETINSERTMARKCOLOR = LVM_FIRST+171
    LVM_SETINFOTIP = LVM_FIRST+173
    LVM_GETSELECTEDCOLUMN = LVM_FIRST+174
    LVM_ISGROUPVIEWENABLED = LVM_FIRST+175
    LVM_GETOUTLINECOLOR = LVM_FIRST+176
    LVM_SETOUTLINECOLOR = LVM_FIRST+177
    LVM_CANCELEDITLABEL = LVM_FIRST+179
    LVM_MAPINDEXTOID = LVM_FIRST+180
    LVM_MAPIDTOINDEX = LVM_FIRST+181
    LVM_ISITEMVISIBLE = LVM_FIRST+182
    LVM_GETEMPTYTEXT = LVM_FIRST+204
    LVM_GETFOOTERRECT = LVM_FIRST+205
    LVFF_ITEMCOUNT = 0x1
    LVM_GETFOOTERINFO = LVM_FIRST+206
    LVM_GETFOOTERITEMRECT = LVM_FIRST+207
    LVFIF_TEXT = 0x1
    LVFIF_STATE = 0x2
    LVFIS_FOCUSED = 0x1
    LVM_GETFOOTERITEM = LVM_FIRST+208
    LVM_GETITEMINDEXRECT = LVM_FIRST+209
    LVM_SETITEMINDEXSTATE = LVM_FIRST+210
    LVM_GETNEXTITEMINDEX = LVM_FIRST+211
    LVN_ITEMCHANGING = LVN_FIRST-0
    LVN_ITEMCHANGED = LVN_FIRST-1
    LVN_INSERTITEM = LVN_FIRST-2
    LVN_DELETEITEM = LVN_FIRST-3
    LVN_DELETEALLITEMS = LVN_FIRST-4
    LVN_BEGINLABELEDITW = LVN_FIRST-75
    LVN_ENDLABELEDITW = LVN_FIRST-76
    LVN_COLUMNCLICK = LVN_FIRST-8
    LVN_BEGINDRAG = LVN_FIRST-9
    LVN_BEGINRDRAG = LVN_FIRST-11
    LVN_ODCACHEHINT = LVN_FIRST-13
    LVN_ODFINDITEMW = LVN_FIRST-79
    LVN_ITEMACTIVATE = LVN_FIRST-14
    LVN_ODSTATECHANGED = LVN_FIRST-15
    LVN_HOTTRACK = LVN_FIRST-21
    LVN_GETDISPINFOW = LVN_FIRST-77
    LVN_SETDISPINFOW = LVN_FIRST-78
    LVIF_DI_SETITEM = 0x1000
    LVN_KEYDOWN = LVN_FIRST-55
    LVN_MARQUEEBEGIN = LVN_FIRST-56
    LVGIT_UNFOLDED = 0x1
    LVN_GETINFOTIPW = LVN_FIRST-58
    LVNSCH_DEFAULT = -1
    LVNSCH_ERROR = -2
    LVNSCH_IGNORE = -3
    LVN_INCREMENTALSEARCHW = LVN_FIRST-63
    LVN_COLUMNDROPDOWN = LVN_FIRST-64
    LVN_COLUMNOVERFLOWCLICK = LVN_FIRST-66
    LVN_BEGINSCROLL = LVN_FIRST-80
    LVN_ENDSCROLL = LVN_FIRST-81
    LVN_LINKCLICK = LVN_FIRST-84


var lvCount = 1
let LVSTYLE: DWORD = WS_VISIBLE or WS_CHILD or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or LVS_REPORT or WS_BORDER or LVS_ALIGNLEFT or LVS_SINGLESEL
# Forward declaration
proc lvWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.}
proc hdrWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.}

# ListView constructor
proc newListView*(parent: Form, x, y: int32 = 10, w: int32 = 250, h: int32 = 200): ListView =
    new(result)
    result.mKind = ctListView
    result.mClassName = "SysListView32"
    result.mName = "ListView_" & $lvCount
    result.mParent = parent
    result.mXpos = x
    result.mYpos = y
    result.mWidth = w
    result.mHeight = h
    result.mFont = parent.mFont
    result.mBackColor = CLR_WHITE
    result.mForeColor = CLR_BLACK
    result.mStyle = LVSTYLE
    result.mExStyle = 0
    result.mViewStyle = lvsReport
    result.mShowGrid = true
    result.mFullRowSel = true
    result.mHideSel = true
    result.mOneClickActivate = true
    result.mHdrClickable = true
    result.mHdrHeight = 35
    result.mItemIndex = -1
    result.mHotHdrIndex = cast[DWORD_PTR](-1)
    result.mHdrBackColor = newColor(0xdce1de)
    result.mHdrForeColor = CLR_BLACK
    result.mHdrFont = result.mFont
    lvCount += 1

proc newListViewColumn*(text: string, width: int32, imgIndex: int32 = -1) : ListViewColumn =
    new(result)
    result.mText = text
    result.mWidth = width
    result.mImgIndex = imgIndex
    result.mImgOnRight = false
    result.mTextAlign = taLeft
    result.mIndex = -1
    result.mHdrTextAlign = taCenter
    result.mHdrTextFlag = DT_SINGLELINE or DT_VCENTER or DT_CENTER or DT_NOPREFIX


proc newListViewItem*(text: string, bgColor: uint = 0xFFFFFF, fgColor: uint = 0x000000, imgIndex: int32 = -1): ListViewItem =
    new(result)
    result.mText = text
    result.mBackColor = newColor(bgColor)
    result.mForeColor = newColor(fgColor)
    result.mIndex = -1
    result.mImgIndex = imgIndex


proc setLVStyle(this: ListView) =
    case this.mViewStyle
    of lvsLargeIcon: this.mStyle = this.mStyle or LVS_ICON
    of lvsReport: this.mStyle = this.mStyle or LVS_REPORT
    of lvsSmallIcon: this.mStyle = this.mStyle or LVS_SMALLICON
    of lvsList: this.mStyle = this.mStyle or LVS_LIST
    else: discard

    if this.mEditLabel: this.mStyle = this.mStyle or LVS_EDITLABELS
    if this.mNoHeader: this.mStyle = this.mStyle or LVS_NOCOLUMNHEADER
    if this.mHideSel: this.mStyle = this.mStyle xor LVS_SHOWSELALWAYS
    if this.mMultiSel: this.mStyle = this.mStyle xor LVS_SINGLESEL
    # Set some brushes & pen
    this.mHdrBkBrush = CreateSolidBrush(this.mHdrBackColor.cref)
    this.mHdrHotBrush = this.mHdrBackColor.getHotBrush(0.9)
    this.mHdrPen = CreatePen(PS_SOLID, 1, 0x00FFFFFF) # A white pen


proc setLVExStyles(this: ListView) =
    var lvExStyle: DWORD = 0x0000
    if this.mShowGrid: lvExStyle = lvExStyle or LVS_EX_GRIDLINES
    if this.mHasCheckBox: lvExStyle = lvExStyle or LVS_EX_CHECKBOXES
    if this.mFullRowSel: lvExStyle = lvExStyle or LVS_EX_FULLROWSELECT
    if this.mOneClickActivate: lvExStyle = lvExStyle or LVS_EX_ONECLICKACTIVATE
    if this.mHotTrackSel: lvExStyle = lvExStyle or LVS_EX_TRACKSELECT
    # if (this.viewStyle == ListViewStyle.TileView: SendMessageW(this.handle, LVM_SETVIEW, 0x0004, 0)
    this.sendMsg(LVM_SETEXTENDEDLISTVIEWSTYLE, 0, lvExStyle)

proc setHeaderSubclass(this: ListView) {.inline.} =
    this.mHdrHandle = cast[HWND](this.sendMsg(LVM_GETHEADER, 0, 0))
    SetWindowSubclass(this.mHdrHandle, hdrWndProc, globalSubClassID, cast[DWORD_PTR](cast[PVOID](this)))
    globalSubClassID += 1

proc postCreationTasks(this: ListView) =
    if this.mBackColor.value != CLR_WHITE.value: this.sendMsg(LVM_SETBKCOLOR, 0, this.mBackColor.cref)
    if this.mCheckBoxLast:
        var iSeq: seq[int32] = newSeq[int32](this.mColumns.len)
        for col in this.mColumns:
            if col.mIndex > 0: iSeq.add(col.mIndex)
        iSeq.add(0)
        this.sendMsg(LVM_SETCOLUMNORDERARRAY, int32(iSeq.len), iSeq[0].unsafeAddr)


proc addColumnInternal(this: ListView, lvCol: ListViewColumn) =
    lvCol.mIndex = this.mColIndex
    var lvc: LVCOLUMNW
    lvc.mask = LVCF_FMT or LVCF_TEXT  or LVCF_WIDTH  or LVCF_SUBITEM #-or LVCF_ORDER
    lvc.fmt = int32(lvCol.mTextAlign)
    lvc.cx = lvCol.mWidth
    lvc.pszText = lvCol.mText.toLPWSTR()
    if lvCol.mHasImage:
        lvc.mask = lvc.mask or LVCF_IMAGE
        lvc.fmt = lvc.fmt or LVCFMT_COL_HAS_IMAGES or LVCFMT_IMAGE
        lvc.iImage = lvCol.mImgIndex
        if lvCol.mImgOnRight: lvc.fmt = lvc.fmt or LVCFMT_BITMAP_ON_RIGHT

    lvCol.mpLvc = lvc.unsafeAddr
    if this.mIsCreated:
        this.sendMsg(LVM_INSERTCOLUMNW, lvCol.mIndex, lvc.unsafeAddr)
        # We need this to do the painting in wm notify.
       # if (!this.mDrawColumns && lvCol.mDrawNeeded) this.mDrawColumns = true
    this.mColumns.add(lvCol)
    this.mColIndex += 1

proc addItemInternal(this: ListView, item: ListViewItem) =
    item.mIndex = this.mRowIndex
    item.mLvHandle = this.mHandle
    item.mColCount = this.mColumns.len
    var lvi: LVITEMW
    lvi.mask = LVIF_TEXT or LVIF_PARAM or LVIF_STATE
    if item.mImgIndex != -1: lvi.mask = lvi.mask or LVIF_IMAGE
    lvi.state = 0
    lvi.stateMask = 0
    lvi.iItem = item.mIndex
    lvi.iSubItem = 0
    lvi.iImage = item.mImgIndex
    lvi.pszText = item.mText.toLPWSTR()
    lvi.cchTextMax = int32(item.mText.len)
    lvi.lParam = cast[LPARAM](cast[PVOID](item))
    this.sendMsg(LVM_INSERTITEMW, 0, lvi.unsafeAddr)
    this.mItems.add(item)
    this.mRowIndex += 1

proc addSubItemInternal(this: ListView, subItmTxt: string, itemIndex: int32, subIndx: int32, imgIndex: int32 = -1) =
    var lw: LVITEMW
    lw.iSubItem = subIndx
    lw.pszText = subItmTxt.toLPWSTR()
    lw.iImage = imgIndex
    this.sendMsg(LVM_SETITEMTEXTW, itemIndex, lw.unsafeAddr)
    this.mItems[itemIndex].mSubItems.add(subItmTxt)

proc headerCustomDraw(this: ListView, nmcd: LPNMCUSTOMDRAW): LRESULT =
    # When Windows paints the listview header, it sends us a notification.
    # So we can use that notification and draw our headers.
    let col = this.mColumns[nmcd.dwItemSpec]
    SetBkMode(nmcd.hdc, 1)
    if col.mIndex > 0: nmcd.rc.left = nmcd.rc.left + 1
    if this.mHdrClickable:
        if (nmcd.uItemState and CDIS_SELECTED) == CDIS_SELECTED:
            # Header is clicked. So we will change the back color.
            FillRect(nmcd.hdc, nmcd.rc.unsafeAddr, this.mHdrBkBrush)
        else:
            if nmcd.dwItemSpec == this.mHotHdrIndex:
                # Mouse pointer is on header. So we will change the back color.
                FillRect(nmcd.hdc, nmcd.rc.unsafeAddr, this.mHdrHotBrush)
            else:
                FillRect(nmcd.hdc, nmcd.rc.unsafeAddr, this.mHdrBkBrush)

        if (nmcd.uItemState and CDIS_SELECTED) == CDIS_SELECTED:
            # Mimicing dot net's technique. Adjusting rect to get the feel of clicked button.
            nmcd.rc.left = nmcd.rc.left + 2
            nmcd.rc.top = nmcd.rc.top + 2

    else:
        FillRect(nmcd.hdc, nmcd.rc.unsafeAddr, this.mHdrBkBrush)

    # Draw a white line on ther right side of the hdr
    SelectObject(nmcd.hdc, this.mHdrPen)
    MoveToEx(nmcd.hdc, nmcd.rc.right, nmcd.rc.top, nil)
    LineTo(nmcd.hdc, nmcd.rc.right, nmcd.rc.bottom)
    SelectObject(nmcd.hdc, this.mHdrFont.handle)
    SetTextColor(nmcd.hdc, this.mHdrForeColor.cref)
    DrawTextW(nmcd.hdc, col.mText.toWcharPtr, int32(-1), nmcd.rc.unsafeAddr, col.mHdrTextFlag)
    result = CDRF_SKIPDEFAULT


# Create ListView's hwnd
proc createHandle*(this: ListView) =
    this.setLVStyle()
    this.createHandleInternal()
    if this.mHandle != nil:
        this.setLVExStyles()
        this.setSubclass(lvWndProc)
        this.setHeaderSubclass()
        this.setFontInternal()
        this.postCreationTasks()

#---------------------Add Column variants----------------------------------------------------

proc addColumn*(this: ListView, text: string, width: int32, imgIndex: int32 = -1): ListViewColumn {.discardable.} =
    result = newListViewColumn(text, width, imgIndex)
    this.addColumnInternal(result)

proc addColumns*(this: ListView, colNames: seq[string], colWidths: seq[auto]): seq[ListViewColumn] {.discardable.} =
    if colNames.len != colWidths.len: raise newException(Exception, "Column namse are not equal to widths")
    for (name, width) in zip(colNames, colWidths):
        var col = newListViewColumn(name, int32(width))
        this.addColumnInternal(col)
        result.add(col)

proc addColumns*(this: ListView, colCount: int, nameAndWidth: varargs[string, `$`]): seq[ListViewColumn] {.discardable.} =
    # Example usage - lv.addColumns(3, "Names", "Jobs", "Salaries", 100, 60, 110)
    if nameAndWidth.len != (colCount * 2): raise newException(Exception, "Column namse are not equal to widths")
    for i in 0..<colCount:
        var col = newListViewColumn(nameAndWidth[i], int32(parseInt(nameAndWidth[i + colCount])))
        this.addColumnInternal(col)
        result.add(col)

#-------------Add Item variants------------------------------------------------------

proc addItem*(this: ListView, itemTxt: auto, bgColor: uint = 0xFFFFFF, fgColor: uint = 0x000000, imgIndex: int32 = -1) : ListViewItem {.discardable.} =
    let sitem : string = (if itemTxt is string: itemTxt else: $itemTxt)
    result = newListViewItem(sitem, bgColor, fgColor, imgIndex)
    this.addItemInternal(result)

proc addItem*(this: ListView, item: ListViewItem) = this.addItemInternal(item)

proc addItems*(this: ListView, items: varargs[ListViewItem]) =
    for item in items: this.addItemInternal(item)

proc addItems*(this: ListView, itemTextList: varargs[string, `$`]) : seq[ListViewItem] {.discardable.} =
    for txt in itemTextList:
        var item = newListViewItem(txt)
        this.addItemInternal(item)
        result.add(item)

proc addRow*(this: ListView, items: varargs[string, `$`]) : ListViewItem {.discardable.} =
    if this.mViewStyle != lvsReport: raise newException(Exception, "Only works for Report view style.")
    if items.len != this.mColumns.len: raise newException(Exception, "Item count is not matching to column count.")
    result = newListViewItem(items[0])
    this.addItemInternal(result)
    for i in 1..<items.len: this.addSubItemInternal(items[i], result.mIndex, int32(i))

#--------------Add SubItems variants---------------------------------------------------------------------

proc addSubItem*(this: ListViewItem, subitem: auto, subIndx: int32, imgIndex: int32 = -1) =
    let sitem : string = (if subitem is string: subitem else: $subitem)
    var lw: LVITEMW
    lw.iSubItem = subIndx
    lw.pszText = sitem.toLPWSTR()
    lw.iImage = imgIndex
    SendMessageW(this.mLvHandle, LVM_SETITEMTEXTW, WPARAM(this.mIndex), cast[LPARAM](lw.unsafeAddr))
    this.mSubItems.add(sitem)

proc addSubItems*(this: ListViewItem, subitems: varargs[string, `$`]) =
    if (subitems.len + 1) != this.mColCount: raise newException(Exception, "Column count is not matching to sub item count")
    for index, subitem in subitems:
        let sitem : string = (if subitem is string: subitem else: $subitem)
        var lw: LVITEMW
        lw.iSubItem = int32(index + 1)
        lw.pszText = sitem.toLPWSTR()
        lw.iImage = -1
        SendMessageW(this.mLvHandle, LVM_SETITEMTEXTW, WPARAM(this.mIndex), cast[LPARAM](lw.unsafeAddr))
        this.mSubItems.add(sitem)


# Properties---------------------------------------------------------------------------
proc selectedIndex*(this: ListView): int32 = this.mSelIndex
proc selectedSubIndex*(this: ListView): int32 = this.mSelSubIndex
proc checked*(this: ListView): bool = this.mChecked
proc columns*(this: ListView): seq[ListViewColumn] = this.mColumns
proc items*(this: ListView): seq[ListViewItem] = this.mItems

proc `headerHeight=`*(this: ListView, value : int) = this.mHdrHeight = int32(value)
proc headerHeight*(this: ListView): int = int(this.mHdrHeight)

proc `editLabel=`*(this: ListView, value: bool) = this.mEditLabel = value
proc editLabel*(this: ListView): bool = this.mEditLabel

proc `hideSelection=`*(this: ListView, value: bool) = this.mHideSel = value
proc hideSelection*(this: ListView): bool = this.mHideSel

proc `multiSelection=`*(this: ListView, value: bool) = this.mMultiSel = value
proc multiSelection*(this: ListView): bool = this.mMultiSel

proc `hasCheckBox=`*(this: ListView, value: bool) = this.mHasCheckBox = value
proc hasCheckBox*(this: ListView): bool = this.mHasCheckBox

proc `fullRowSelection=`*(this: ListView, value: bool) = this.mFullRowSel = value
proc fullRowSelection*(this: ListView): bool = this.mFullRowSel

proc `showGrid=`*(this: ListView, value: bool) = this.mShowGrid = value
proc showGrid*(this: ListView): bool = this.mShowGrid

proc `oneClickActivate=`*(this: ListView, value: bool) = this.mOneClickActivate = value
proc oneClickActivate*(this: ListView): bool = this.mOneClickActivate

proc `hotTrackSelection=`*(this: ListView, value: bool) = this.mHotTrackSel = value
proc hotTrackSelection*(this: ListView): bool = this.mHotTrackSel

proc `headerClickable=`*(this: ListView, value: bool) = this.mHdrClickable = value
proc headerClickable*(this: ListView): bool = this.mHdrClickable

proc `checkBoxLast=`*(this: ListView, value: bool) = this.mCheckBoxLast = value
proc checkBoxLast*(this: ListView): bool = this.mCheckBoxLast

proc `headerBackColor=`*(this: ListView, value: uint) = this.mHdrBackColor = newColor(value)
proc `headerBackColor=`*(this: ListView, value: Color) = this.mHdrBackColor = value
proc headerBackColor*(this: ListView): Color = this.mHdrBackColor

proc `headerForeColor=`*(this: ListView, value: uint) = this.mHdrForeColor = newColor(value)
proc `headerForeColor=`*(this: ListView, value: Color) = this.mHdrForeColor = value
proc headerForeColor*(this: ListView): Color = this.mHdrForeColor

proc `headerFont=`*(this: ListView, value: Font) = this.mHdrFont = value
proc headerFont*(this: ListView): Font = this.mHdrFont

proc `selectedItem=`*(this: ListView, value: ListViewItem) = this.mSelItem = value
proc selectedItem*(this: ListView): ListViewItem = this.mSelItem

proc `viewStyle=`*(this: ListView, value: ListViewStyle) = this.mViewStyle = value
proc viewStyle*(this: ListView): ListViewStyle = this.mViewStyle




proc lvWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.} =
    var this = cast[ListView](refData)
    case msg
    of WM_DESTROY:
        RemoveWindowSubclass(hw, lvWndProc, scID)
    of WM_LBUTTONDOWN: this.leftButtonDownHandler(msg, wpm, lpm)
    of WM_LBUTTONUP: this.leftButtonUpHandler(msg, wpm, lpm)
    of WM_RBUTTONDOWN: this.rightButtonDownHandler(msg, wpm, lpm)
    of WM_RBUTTONUP: this.rightButtonUpHandler(msg, wpm, lpm)
    of WM_MOUSEMOVE: this.mouseMoveHandler(msg, wpm, lpm)
    of WM_MOUSELEAVE: this.mouseLeaveHandler()

    of WM_NOTIFY: # This is from header.
        let nmh = cast[LPNMHDR](lpm)
        if nmh.code == NM_CUSTOMDRAW_NM:  # Let's draw header back & fore colors
            var nmcd = cast[LPNMCUSTOMDRAW](lpm)
            case nmcd.dwDrawStage # NM_CUSTOMDRAW is always -12 when item painting
            of CDDS_PREPAINT: return CDRF_NOTIFYITEMDRAW
            of CDDS_ITEMPREPAINT:
                # We are drawing our headers.
                return this.headerCustomDraw(nmcd)
            else: discard

    of MM_NOTIFY_REFLECT:
        let nmh = cast[LPNMHDR](lpm)
        case nmh.code
        of NM_CUSTOMDRAW_NM:
            var nmLvcd = cast[LPNMLVCUSTOMDRAW](lpm)
            case nmLvcd.nmcd.dwDrawStage
            of CDDS_PREPAINT: return CDRF_NOTIFYITEMDRAW
            of CDDS_ITEMPREPAINT:
                nmLvcd.clrTextBk = this.mBackColor.cref
                return CDRF_NEWFONT or CDRF_DODEFAULT
            else: discard

        of LVN_ITEMCHANGED:
            var nmlv = cast[LPNMLISTVIEW](lpm)
            if nmlv.uNewState == 8192 or nmlv.uNewState == 4096:
                this.mChecked = (if nmlv.uNewState == 8192: true else: false)
                if this.onCheckedChanged != nil: this.onCheckedChanged(this, newEventArgs())
            else:
                if nmlv.uNewState == 3:
                    this.mSelIndex = nmlv.iItem
                    this.mSelSubIndex = nmlv.iSubItem
                    if this.onSelectionChanged != nil: this.onSelectionChanged(this, newEventArgs())

        of NM_DBLCLK:
            if this.onItemDoubleClicked != nil: this.onItemDoubleClicked(this, newEventArgs())

        of NM_CLICK:
            let nmia = cast[LPNMITEMACTIVATE](lpm)
            if this.onItemClicked != nil: this.onItemClicked(this, newEventArgs())

        of NM_HOVER:
            if this.onItemHover != nil: this.onItemHover(this, newEventArgs())
        else: discard

    else: return DefSubclassProc(hw, msg, wpm, lpm)
    return DefSubclassProc(hw, msg, wpm, lpm)


proc hdrWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.} =
    var this = cast[ListView](refData)
    case msg
    of WM_DESTROY:
        RemoveWindowSubclass(hw, hdrWndProc, scID)

    of WM_MOUSEMOVE:
        var hinfo: HDHITTESTINFO
        hinfo.pt = getMousePos(lpm)
        this.mHotHdrIndex = cast[DWORD_PTR](SendMessageW(hw, HDM_HITTEST, 0, cast[LPARAM](hinfo.unsafeAddr)))

    of WM_MOUSELEAVE: this.mHotHdrIndex = cast[DWORD_PTR](-1)

    of HDM_LAYOUT:
        if this.mChangeHdrHeight:
            var pHl = cast[LPHDLAYOUT](lpm)
            pHl.pwpos.hwnd = hw
            pHl.pwpos.flags = SWP_FRAMECHANGED
            pHl.pwpos.x = pHl.prc.left
            pHl.pwpos.y = 0
            pHl.pwpos.cx = (pHl.prc.right - pHl.prc.left)
            pHl.pwpos.cy = this.mHdrHeight
            pHl.prc.top = this.mHdrHeight
            return 1

    of WM_PAINT:
        discard DefSubclassProc(hw, msg, wpm, lpm)
        var hrc: RECT
        SendMessageW(hw, HDM_GETITEMRECT, cast[WPARAM](int32(this.mColumns.len - 1)), cast[LPARAM](hrc.unsafeAddr))
        var rc = RECT(left: hrc.right + 1, top: hrc.top, right: this.width, bottom: hrc.bottom)
        var hdc: HDC = GetDC(hw)
        FillRect(hdc, rc.unsafeAddr, this.mHdrBkBrush)
        ReleaseDC(hw, hdc)
        return 0

    else: return DefSubclassProc(hw, msg, wpm, lpm)
    return DefSubclassProc(hw, msg, wpm, lpm)