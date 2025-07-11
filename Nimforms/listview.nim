# listview module Created on 01-Apr-2023 11:22 PM; Author kcvinker
#[============================================ListView Docs================================================
    constructor - newListView
    Functions:
         createHandle
         addColumn
         addColumns
         addColumns
         addItem 
         addItem
         addItems
         addItems
         addRow
         addSubItem
         addSubItems

    Properties:
        All props inherited from Control type 
        font              Font
        text              string
        width             int32
        height            int32
        xpos              int32
        ypos              int32
        backColor         Color
        foreColor         Color
        headerHeight      int32
        editLabel         bool
        hideSelection     bool
        multiSelection    bool
        hasCheckBox       bool
        fullRowSelection  bool
        showGrid          bool
        oneClickActivate  bool
        hotTrackSelection bool
        headerClickable   bool
        checkBoxLast      bool
        headerBackColor   Getter - Color, Setter - [Color, uint]
        headerForeColor   Getter - Color, Setter - [Color, uint]
        headerFont        Font
        selectedItem      ListViewItem
        viewStyle         ListViewStyle {lvsLargeIcon, lvsReport, lvsSmallIcon, lvsList, lvsTile}

        Getter only------------
            selectedIndex         int32
            selectedSubIndex      int32
            checked               bool
            columns               seq[ListViewColumn]
            items                 seq[ListViewItem]

     Events:
        All events inherited from Control type 
        EventHandler type - proc(c: Control, e: EventArgs)
            onCheckedChanged
            onSelectionChanged
            onItemDoubleClicked
            onItemClicked
            onItemHover
#---------------------------------------------------------------------------------------

ListViewColumn type
    constructor - newListViewColumn
    Properties:    
        index                 int32
        text                  string
        width                 int32
        imageIndex            int32
        imageOnRight          bool
        hasImage              bool
        textAlign             TextAlignment - {taLeft, taCenter, taRight}
        headerTextAlign       TextAlignment
        backColor             Color (Use uint also for setter)
        foreColor             Color (Use uint also for setter)
#-------------------------------------------------------------------------------------------

ListViewItem type
    Constructor - newListViewItem
    Properties:
        index             int32 (Getter only)
        subItems          seq[string (Getter only)
        text              string
        imageIndex        int32
        backColor         Color (Use uint also for setter)
        foreColor         Color (Use uint also for setter)
        font              Font
=====================================================================================================]#
# Note: Improve some properties to respond at runtime
# Constants
const

    LVN_FIRST = cast[UINT](0-100)
    LVN_BEGINLABELEDIT = LVN_FIRST-75
    LVS_ICON = 0x0000
    LVS_REPORT = 0x0001
    LVS_SMALLICON = 0x0002
    LVS_LIST = 0x0003
    LVS_SHOWSELALWAYS = 0x0008
    LVS_EDITLABELS = 512 #0x0200
    LVS_ALIGNLEFT = 0x0800
    LVS_NOCOLUMNHEADER = 0x4000
    LVS_SINGLESEL = 0x0004
    LVS_EX_GRIDLINES = 0x00000001
    LVS_EX_CHECKBOXES = 0x00000004
    LVS_EX_TRACKSELECT = 0x00000008
    LVS_EX_FULLROWSELECT = 0x00000020
    LVS_EX_ONECLICKACTIVATE = 0x00000040
    LV_VIEW_ICON = 0x0000
    LV_VIEW_DETAILS  = 0x0001
    LV_VIEW_SMALLICON = 0x0002
    LV_VIEW_LIST = 0x0003
    LV_VIEW_TILE = 0x0004
    LV_VIEW_MAX = 0x0004
    LVCF_FMT = 1
    LVCF_WIDTH = 2
    LVCF_TEXT = 4
    LVCF_SUBITEM = 8
    LVCF_IMAGE = 16
    LVCF_ORDER = 32
    LVCFMT_LEFT = 0
    LVCFMT_RIGHT = 1
    LVCFMT_CENTER = 2
    LVCFMT_JUSTIFYMASK = 3
    LVCFMT_IMAGE = 2048
    LVCFMT_BITMAP_ON_RIGHT = 4096
    LVCFMT_COL_HAS_IMAGES = 32768
    LVIF_TEXT = 1
    LVIF_IMAGE = 2
    LVIF_PARAM = 4
    LVIF_STATE = 8

    LVM_GETHEADER = (LVM_FIRST + 31)
    LVM_SETEXTENDEDLISTVIEWSTYLE = (LVM_FIRST + 54)
    LVM_SETCOLUMNORDERARRAY = (LVM_FIRST + 58)
    LVM_INSERTITEMW = (LVM_FIRST + 77)
    LVM_INSERTCOLUMNW = (LVM_FIRST + 97)
    LVM_SETITEMTEXTW = (LVM_FIRST + 116)
    LVN_ITEMCHANGED = (LVN_FIRST-1)
    LVN_ITEMACTIVATE = (LVN_FIRST-14)
    LVIS_SELECTED = 2
    LVIS_STATEIMAGEMASK = 61440

var lvCount = 1
# let lvClsName = toWcharPtr("SysListView32")
let lvClsName : array[14, uint16] = [0x53, 0x79, 0x73, 0x4C, 0x69, 0x73, 0x74, 0x56, 0x69, 0x65, 0x77, 0x33, 0x32, 0]


let LVSTYLE: DWORD = WS_VISIBLE or WS_CHILD or WS_CLIPCHILDREN or
                        WS_CLIPSIBLINGS or LVS_REPORT or WS_BORDER or LVS_ALIGNLEFT or LVS_SINGLESEL
# Forward declaration
proc lvWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.}
proc hdrWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.}
proc createHandle*(this: ListView)
proc newListViewColumn*(text: string, width: int32, imgIndex: int32 = -1) : ListViewColumn
proc addColumns(this: ListView, colnames: varargs[string, `$`]) : seq[ListViewColumn] {.discardable.}
proc addColumnInternal(this: ListView, lvCol: ListViewColumn)


# ListView constructor
proc listViewCtor(parent: Form, x, y, w, h: int32): ListView =
    new(result)
    result.mKind = ctListView
    result.mClassName = cast[LPCWSTR](lvClsName[0].addr)
    result.mName = "ListView_" & $lvCount
    result.mParent = parent
    result.mXpos = x
    result.mYpos = y
    result.mWidth = w
    result.mHeight = h
    # result.mFont = parent.mFont
    result.cloneParentFont()
    result.mHasFont = true
    result.mBackColor = CLR_WHITE
    result.mForeColor = CLR_BLACK
    result.mStyle = LVSTYLE
    result.mExStyle = 0
    result.mViewStyle = lvsReport
    result.mShowGrid = true
    result.mFullRowSel = true
    result.mHideSel = true
    # result.mOneClickActivate = true
    result.mHdrClickable = true
    result.mHdrHeight = 35
    result.mItemIndex = -1
    result.mHotHdrIndex = cast[DWORD_PTR](-1)
    result.mHdrBackColor = newColor(0xdce1de)
    result.mHdrForeColor = CLR_BLACK
    result.mEditLabel = true
    result.mHdrFont = result.mFont
    lvCount += 1
    parent.mControls.add(result)

proc newListView*(parent: Form, x: int32 = 10, y: int32 = 10, w: int32 = 250, h: int32 = 200): ListView =
    result = listViewCtor(parent, x, y, w, h)
    if parent.mCreateChilds: result.createHandle()

proc newListView*(parent: Form, x, y: int32, colnames: varargs[string, `$`] ): ListView =
    result = listViewCtor(parent, x, y, 100, 150)
    result.createHandle()
    if colnames.len > 0: result.addColumns(colnames)
    result.`width=`result.getAccumulatedColWidth()

proc newListView*(parent: Form, x, y: int32, cols_widths: tuple or object): ListView =
    result = listViewCtor(parent, x, y, 100, 150)
    result.createHandle()
    var colnames : seq[string]
    var widths : seq[int32]
    for f in fields(cols_widths):
        when f is int:
            widths.add(int32(f))
        elif f is string:
            colnames.add(f)

    if colnames.len == widths.len:
        for i in 0..<colnames.len:
            var col = newListViewColumn(colnames[i], widths[i])
            result.addColumnInternal(col)

        result.`width=`result.getAccumulatedColWidth()


# proc newListView*(parent: Form, x, y, w, h: int32, colnames: varargs[string, `$`] ): ListView =
#     result = listViewCtor(parent, x, y, w, h)
#     result.createHandle()
#     if colnames.len > 0: result.addColumns(colnames)


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
    result.mWideText = toLPWSTR(text)

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
    lvc.pszText = lvCol.mWideText
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
    appData.sendMsgBuffer.updateBuffer(item.mText)
    var lvi: LVITEMW
    lvi.mask = LVIF_TEXT or LVIF_PARAM or LVIF_STATE
    if item.mImgIndex != -1: lvi.mask = lvi.mask or LVIF_IMAGE
    lvi.state = 0
    lvi.stateMask = 0
    lvi.iItem = item.mIndex
    lvi.iSubItem = 0
    lvi.iImage = item.mImgIndex
    lvi.pszText = &appData.sendMsgBuffer #item.mText.toLPWSTR()
    lvi.cchTextMax = appData.sendMsgBuffer.mWcLen  #int32(item.mText.len)
    lvi.lParam = cast[LPARAM](cast[PVOID](item))
    this.sendMsg(LVM_INSERTITEMW, 0, lvi.unsafeAddr)
    this.mItems.add(item)
    this.mRowIndex += 1

proc addSubItemInternal(this: ListView, subItmTxt: string, itemIndex: int32, subIndx: int32, imgIndex: int32 = -1) =
    appData.sendMsgBuffer.updateBuffer(subItmTxt)
    var lw: LVITEMW
    lw.iSubItem = subIndx
    lw.pszText = &appData.sendMsgBuffer  #.toLPWSTR()
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
    DrawTextW(nmcd.hdc, col.mWideText, int32(-1), nmcd.rc.unsafeAddr, col.mHdrTextFlag)
    result = CDRF_SKIPDEFAULT

proc wmNotifyHandler(this: ListView, lpm: LPARAM): LRESULT =
    let nmh = cast[LPNMHDR](lpm)
    case nmh.code
    of NM_CUSTOMDRAW_NM:
        var lvcd = cast[LPNMLVCUSTOMDRAW](lpm)
        case lvcd.nmcd.dwDrawStage
        of CDDS_PREPAINT: return CDRF_NOTIFYITEMDRAW
        of CDDS_ITEMPREPAINT:
            lvcd.clrTextBk = this.mBackColor.cref
            lvcd.clrText = this.mForeColor.cref
            return CDRF_NEWFONT or CDRF_DODEFAULT
        else: return CDRF_DODEFAULT

    of LVN_ITEMCHANGED:
        var nmlv = cast[LPNMLISTVIEW](lpm)
        if (nmlv.uChanged and LVIF_STATE) > 0:
            let nowSelected = (nmlv.uNewState and LVIS_SELECTED)
            let wasSelected = (nmlv.uOldState and LVIS_SELECTED)
            if nowSelected > 0 and wasSelected == 0:
                var pitem: ListViewItem = this.mItems[nmlv.iItem]
                if this.mMultiSel:
                    this.mSelItems.add(pitem)
                else:
                    this.mSelItem = pitem

                if this.onSelectionChanged != nil: 
                    var lsea = LVSelChangeEventArgs(item: pitem, 
                                                     index:nmlv. iItem, 
                                                     isSelected: cast[bool](nowSelected))
                    this.onSelectionChanged(this, lsea)
            elif nowSelected == 0 and wasSelected > 0:
                let sitem = this.mItems[nmlv.iItem]
                if this.mMultiSel:
                    this.mSelItems.delete(this.mSelItems.find(sitem))                                
                    if this.onSelectionChanged != nil: 
                        var lsea = LVSelChangeEventArgs(item: sitem, 
                                                         index: nmlv.iItem, 
                                                         isSelected: cast[bool](nowSelected))
                        this.onSelectionChanged(this, lsea)

            # ✅ Check for checkbox state change
            let state_index = (nmlv.uNewState and LVIS_STATEIMAGEMASK) shr 12
            let old_state_index = (nmlv.uOldState and LVIS_STATEIMAGEMASK) shr 12
            if state_index != old_state_index: # Item checkbox changed
                let is_checked = (state_index == 2)  # 2 = checked, 1 = unchecked
                if this.mItems.len > 0:                               
                    var sitem = this.mItems[nmlv.iItem]
                    sitem.mChecked = is_checked  
                    if this.onItemCheckChanged != nil:
                        var licea = LVItemCheckEventArgs(item: sitem, 
                                                         index: nmlv.iItem, 
                                                         isChecked: cast[bool](is_checked))
                        this.onItemCheckChanged(this, licea)

    of NM_DBLCLK, NM_CLICK:
        if (this.onItemClick != nil or this.onItemDoubleClick != nil) and this.mItems.len > 0:
            var nmia = cast[LPNMITEMACTIVATE](lpm)
            var sitem = this.mItems[nmia.iItem]
            var lviea = LVItemEventArgs(item: sitem, index: nmia.iItem)
            if this.onItemDoubleClick != nil: 
                this.onItemDoubleClick(this, lviea)
            elif this.onItemClick != nil: 
                this.onItemClick(this, lviea)

    of LVN_ITEMACTIVATE:
        if this.onItemActivate != nil: 
            this.onItemActivate(this, GEA)
        

    # of NM_HOVER:
    #     if this.onItemHover != nil: this.onItemHover(this, newEventArgs())

    # of LVN_BEGINLABELEDIT:
    #     echo "591 ok"
    else: discard
    return CDRF_DODEFAULT

proc destroyResources(this: ListView) =
    if this.mHdrHotBrush != nil: DeleteObject(this.mHdrHotBrush)
    if this.mHdrBkBrush != nil: DeleteObject(this.mHdrBkBrush)
    if this.mHdrFont.handle != nil: DeleteObject(this.mHdrFont.handle)
    if this.mHdrPen != nil: DeleteObject(this.mHdrPen)
    this.destructor()

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

method autoCreate(this: ListView) = this.createHandle()
#---------------------Add Column variants----------------------------------------------------

proc addColumn*(this: ListView, text: string, width: int32, imgIndex: int32 = -1): ListViewColumn {.discardable.} =
    result = newListViewColumn(text, width, imgIndex)
    this.addColumnInternal(result)

proc addColumns*(this: ListView, colNames: seq[string], colWidths: seq[int]): seq[ListViewColumn] {.discardable.} =
    if colNames.len != colWidths.len: raise newException(Exception, "Column namse are not equal to widths")
    for (name, width) in zip(colNames, colWidths):
        var col = newListViewColumn(name, int32(width))
        this.addColumnInternal(col)
        result.add(col)

proc addColumns*(this: ListView, colCount: int, nameAndWidth: varargs[string, `$`]): seq[ListViewColumn] {.discardable.} =
    # Example usage - lv.addColumns(3, "Names", "Jobs", "Salaries", 100, 60, 110)
    echo "line 386"
    if nameAndWidth.len != (colCount * 2): raise newException(Exception, "Column namse are not equal to widths")
    for i in 0..<colCount:
        var col = newListViewColumn(nameAndWidth[i], int32(parseInt(nameAndWidth[i + colCount])))
        this.addColumnInternal(col)
        result.add(col)

proc addColumns*(this: ListView, colsAndWidths: tuple or object): seq[ListViewColumn] {.discardable.} =
    echo "line 393"
    var colnames : seq[string]
    var widths : seq[int]
    for f in fields(colsAndWidths):
        when f is int:
            widths.add(f)
        elif f is string:
            colnames.add(f)

    if colnames.len == widths.len:
        for i in 0..<colnames.len:
            var col = newListViewColumn(colnames[i], widths[i])
            this.addColumnInternal(col)
            result.add(col)

proc addColumns(this: ListView, colAndWidth: OrderedTable[string, int32]) : seq[ListViewColumn] {.discardable.} =
    for key, value in colAndWidth:
        var col = newListViewColumn(key, value)
        this.addColumnInternal(col)
        result.add(col)

proc addColumns(this: ListView, colnames: varargs[string, `$`]) : seq[ListViewColumn] {.discardable.} =
    echo "line 416"
    let colAndWidth = this.getWidthOfColumnNames(colnames) # This will return a Table[string, int]
    result = this.addColumns(colAndWidth)



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
    appData.sendMsgBuffer.updateBuffer(sitem)
    var lw: LVITEMW
    lw.iSubItem = subIndx
    lw.pszText = &appData.sendMsgBuffer  #.toLPWSTR()
    lw.iImage = imgIndex
    SendMessageW(this.mLvHandle, LVM_SETITEMTEXTW, WPARAM(this.mIndex), cast[LPARAM](lw.unsafeAddr))
    this.mSubItems.add(sitem)

proc addSubItems*(this: ListViewItem, subitems: varargs[string, `$`]) =
    if (subitems.len + 1) != this.mColCount: raise newException(Exception, "Column count is not matching to sub item count")
    for index, subitem in subitems:
        let sitem : string = (if subitem is string: subitem else: $subitem)
        appData.sendMsgBuffer.updateBuffer(sitem)
        var lw: LVITEMW
        lw.iSubItem = int32(index + 1)
        lw.pszText = &appData.sendMsgBuffer #sitem.toLPWSTR()
        lw.iImage = -1
        SendMessageW(this.mLvHandle, LVM_SETITEMTEXTW, WPARAM(this.mIndex), cast[LPARAM](lw.unsafeAddr))
        this.mSubItems.add(sitem)


# Properties---------------------------------------------------------------------------
proc selectedIndex*(this: ListView): int32 {.inline.} = this.mSelIndex
proc selectedSubIndex*(this: ListView): int32 {.inline.} = this.mSelSubIndex
proc checked*(this: ListView): bool {.inline.} = this.mChecked
proc columns*(this: ListView): seq[ListViewColumn] {.inline.} = this.mColumns
proc items*(this: ListView): seq[ListViewItem] {.inline.} = this.mItems

proc `headerHeight=`*(this: ListView, value : int) {.inline.} = this.mHdrHeight = int32(value)
proc headerHeight*(this: ListView): int {.inline.} = int(this.mHdrHeight)

proc `editLabel=`*(this: ListView, value: bool) {.inline.} = this.mEditLabel = value
proc editLabel*(this: ListView): bool {.inline.} = this.mEditLabel

proc `hideSelection=`*(this: ListView, value: bool) {.inline.} = this.mHideSel = value
proc hideSelection*(this: ListView): bool {.inline.} = this.mHideSel

proc `multiSelection=`*(this: ListView, value: bool) {.inline.} = this.mMultiSel = value
proc multiSelection*(this: ListView): bool {.inline.} = this.mMultiSel

proc `hasCheckBox=`*(this: ListView, value: bool) {.inline.} = this.mHasCheckBox = value
proc hasCheckBox*(this: ListView): bool {.inline.} = this.mHasCheckBox

proc `fullRowSelection=`*(this: ListView, value: bool) {.inline.} = this.mFullRowSel = value
proc fullRowSelection*(this: ListView): bool {.inline.} = this.mFullRowSel

proc `showGrid=`*(this: ListView, value: bool) {.inline.} = this.mShowGrid = value
proc showGrid*(this: ListView): bool {.inline.} = this.mShowGrid

proc `oneClickActivate=`*(this: ListView, value: bool) {.inline.} = this.mOneClickActivate = value
proc oneClickActivate*(this: ListView): bool {.inline.} = this.mOneClickActivate

proc `hotTrackSelection=`*(this: ListView, value: bool) {.inline.} = this.mHotTrackSel = value
proc hotTrackSelection*(this: ListView): bool {.inline.} = this.mHotTrackSel

proc `headerClickable=`*(this: ListView, value: bool) {.inline.} = this.mHdrClickable = value
proc headerClickable*(this: ListView): bool {.inline.} = this.mHdrClickable

proc `checkBoxLast=`*(this: ListView, value: bool) {.inline.} = this.mCheckBoxLast = value
proc checkBoxLast*(this: ListView): bool {.inline.} = this.mCheckBoxLast

proc `headerBackColor=`*(this: ListView, value: uint) {.inline.} = this.mHdrBackColor = newColor(value)
proc `headerBackColor=`*(this: ListView, value: Color) {.inline.} = this.mHdrBackColor = value
proc headerBackColor*(this: ListView): Color {.inline.} = this.mHdrBackColor

proc `headerForeColor=`*(this: ListView, value: uint) {.inline.} = this.mHdrForeColor = newColor(value)
proc `headerForeColor=`*(this: ListView, value: Color) {.inline.} = this.mHdrForeColor = value
proc headerForeColor*(this: ListView): Color {.inline.} = this.mHdrForeColor

proc `headerFont=`*(this: ListView, value: Font) {.inline.} = this.mHdrFont = value
proc headerFont*(this: ListView): Font {.inline.} = this.mHdrFont

proc `selectedItem=`*(this: ListView, value: ListViewItem) {.inline.} = this.mSelItem = value
proc selectedItem*(this: ListView): ListViewItem {.inline.} = this.mSelItem

proc `viewStyle=`*(this: ListView, value: ListViewStyle) {.inline.} = this.mViewStyle = value
proc viewStyle*(this: ListView): ListViewStyle {.inline.} = this.mViewStyle

#-----------ListViewColumn properties------------------------------------

proc index*(this: ListViewColumn): int32 {.inline.} = this.mIndex

proc `text=`*(this: ListViewColumn, value: string) {.inline.} = this.mText = value
proc text*(this: ListViewColumn): string {.inline.} = this.mText

proc `width=`*(this: ListViewColumn, value: int32) {.inline.} = this.mWidth = value
proc width*(this: ListViewColumn): int32 {.inline.} = this.mWidth

proc `imageIndex=`*(this: ListViewColumn, value: int32) {.inline.} = this.mImgIndex = value
proc imageIndex*(this: ListViewColumn): int32 {.inline.} = this.mImgIndex

proc `imageOnRight=`*(this: ListViewColumn, value: bool) {.inline.} = this.mImgOnRight = value
proc imageOnRight*(this: ListViewColumn): bool {.inline.} = this.mImgOnRight

proc `hasImage=`*(this: ListViewColumn, value: bool) {.inline.} = this.mHasImage = value
proc hasImage*(this: ListViewColumn): bool {.inline.} = this.mHasImage

proc `textAlign=`*(this: ListViewColumn, value: TextAlignment) {.inline.} = this.mTextAlign = value
proc textAlign*(this: ListViewColumn): TextAlignment {.inline.} = this.mTextAlign

proc `headerTextAlign=`*(this: ListViewColumn, value: TextAlignment) {.inline.} = this.mHdrTextAlign = value
proc headerTextAlign*(this: ListViewColumn): TextAlignment {.inline.} = this.mHdrTextAlign

proc `backColor=`*(this: ListViewColumn, value: uint) {.inline.} = this.mBackColor = newColor(value)
proc `backColor=`*(this: ListViewColumn, value: Color) {.inline.} = this.mBackColor = value
proc backColor*(this: ListViewColumn): Color {.inline.} = this.mBackColor

proc `foreColor=`*(this: ListViewColumn, value: uint) {.inline.} = this.mForeColor = newColor(value)
proc `foreColor=`*(this: ListViewColumn, value: Color) {.inline.} = this.mForeColor = value
proc foreColor*(this: ListViewColumn): Color {.inline.} = this.mForeColor

#------ListViewItem properties------------------------------------------------------------

proc index*(this: ListViewItem): int32 {.inline.} = this.mIndex
proc subItems*(this: ListViewItem): seq[string] {.inline.} = this.mSubItems

proc `text=`*(this: ListViewItem, value: string) {.inline.} = this.mText = value
proc text*(this: ListViewItem): string {.inline.} = this.mText

proc `imageIndex=`*(this: ListViewItem, value: int32) {.inline.} = this.mImgIndex = value
proc imageIndex*(this: ListViewItem): int32 {.inline.} = this.mImgIndex

proc `backColor=`*(this: ListViewItem, value: uint) {.inline.} = this.mBackColor = newColor(value)
proc `backColor=`*(this: ListViewItem, value: Color) {.inline.} = this.mBackColor = value
proc backColor*(this: ListViewItem): Color {.inline.} = this.mBackColor

proc `foreColor=`*(this: ListViewItem, value: uint) {.inline.} = this.mForeColor = newColor(value)
proc `foreColor=`*(this: ListViewItem, value: Color) {.inline.} = this.mForeColor = value
proc foreColor*(this: ListViewItem): Color {.inline.} = this.mForeColor

proc `font=`*(this: ListViewItem, value: Font) {.inline.} = this.mFont = value
proc font*(this: ListViewItem): Font {.inline.} = this.mFont





proc lvWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.} =
    
    # echo "533 ok ", $msg
    case msg
    of WM_DESTROY:
        RemoveWindowSubclass(hw, lvWndProc, scID)
        var this = cast[ListView](refData)
        this.destroyResources()

    of WM_LBUTTONDOWN:
        var this = cast[ListView](refData)
        this.leftButtonDownHandler(msg, wpm, lpm)
    of WM_LBUTTONUP:
        var this = cast[ListView](refData)
        this.leftButtonUpHandler(msg, wpm, lpm)
    of WM_RBUTTONDOWN:
        var this = cast[ListView](refData)
        this.rightButtonDownHandler(msg, wpm, lpm)
    of WM_RBUTTONUP:
        var this = cast[ListView](refData)
        this.rightButtonUpHandler(msg, wpm, lpm)
    of WM_MOUSEMOVE:
        var this = cast[ListView](refData)
        this.mouseMoveHandler(msg, wpm, lpm)
    of WM_MOUSELEAVE:
        var this = cast[ListView](refData)
        this.mouseLeaveHandler()

    of WM_CONTEXTMENU:
        var this = cast[ListView](refData)
        if this.mContextMenu != nil: this.mContextMenu.showMenu(lpm)

    of WM_NOTIFY: # This is from header.
        var this = cast[ListView](refData)
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
        var this = cast[ListView](refData)
        return this.wmNotifyHandler(lpm)

    else: return DefSubclassProc(hw, msg, wpm, lpm)
    return DefSubclassProc(hw, msg, wpm, lpm)


proc hdrWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.} =
    
    case msg
    of WM_DESTROY:
        # var this = cast[ListView](refData)
        RemoveWindowSubclass(hw, hdrWndProc, scID)

    of WM_MOUSEMOVE:
        var this = cast[ListView](refData)
        var hinfo: HDHITTESTINFO
        hinfo.pt = getMousePos(lpm)
        this.mHotHdrIndex = cast[DWORD_PTR](
            SendMessageW(hw, HDM_HITTEST, 0, cast[LPARAM](hinfo.unsafeAddr)))

    of WM_MOUSELEAVE: 
        var this = cast[ListView](refData)
        this.mHotHdrIndex = cast[DWORD_PTR](-1)

    of HDM_LAYOUT:
        var this = cast[ListView](refData)
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
        var this = cast[ListView](refData)
        discard DefSubclassProc(hw, msg, wpm, lpm)
        var hrc: RECT
        SendMessageW(hw, HDM_GETITEMRECT, 
                        cast[WPARAM](int32(this.mColumns.len - 1)), 
                        cast[LPARAM](hrc.unsafeAddr))
        var rc = RECT(left: hrc.right + 1, top: hrc.top, 
                        right: this.width, bottom: hrc.bottom)
        var hdc: HDC = GetDC(hw)
        FillRect(hdc, rc.unsafeAddr, this.mHdrBkBrush)
        ReleaseDC(hw, hdc)
        return 0

    else: return DefSubclassProc(hw, msg, wpm, lpm)
    return DefSubclassProc(hw, msg, wpm, lpm)