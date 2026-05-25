# treeview module Created on 05-Apr-2023 12:51 AM; Author kcvinker
#[===========================================TreeView Docs===============================================
    Constructor - newTreeView
    Functions:
        createHandle      - Create the handle of treeView
        addNode             
        addNode
        addChildNode    
        addChildNode
        insertNode
        insertNode
        insertChildNode
        insertChildNode
        deleteSelNode
        expandAll

    Properties:
        All props inherited from Control type
        selectedNode      : TreeNode
        foreColor         : Color, For setter, uint is also acceptable
        noLine            : bool
        noButton          : bool
        hasCheckBox       : bool
        fullRowSelect     : bool
        isEditable        : bool
        showSelection     : bool
        hotTrack          : bool
        nodeCount         : int32
        uniqNodeID        : int32
        lineColor         : Color, For setter, uint is also acceptable
        nodes             : seq[TreeNode]

    Events:
        All events inherited from Control type 
        EventHandler type - proc(c: Control, e: EventArgs)
            onBeginEdit
            onEndEdit
            onNodeDeleted
        TreeEventHandler type - proc(c: Control, e: TreeEventArgs)
            onBeforeChecked
            onAfterChecked
            onBeforeSelected
            onAfterSelected
            onBeforeExpanded
            onAfterExpanded
            onBeforeCollapsed
            onAfterCollapsed
======================================================================================================
    TreeNode type
        Constructor - newTreeNode
        Functions:
            addChildNode
            addChildNode
            insertChildNode
            insertChildNode

        Properties:
            nodes                     seq[TreeNode] (Getter only)
            index                     int32 (Getter only)
            text                      string
            imageIndex                int32
            selectedImageIndex        int32
            childCount                int32
            nodeID                    int32
            checked                   bool
            foreColor                 Color, For setter, uint is also acceptable
======================================================================================================]#
# Constants



var tvCount = 1
# let tvClsName = toWcharPtr("SysTreeView32")
let tvClsName : array[14, uint16] = [0x53, 0x79, 0x73, 0x54, 0x72, 0x65, 0x65, 0x56, 0x69, 0x65, 0x77, 0x33, 0x32, 0]


let TVSTYLE : DWORD = WS_BORDER or WS_CHILD or WS_VISIBLE or TVS_HASLINES or TVS_HASBUTTONS or TVS_LINESATROOT or TVS_DISABLEDRAGDROP
# Forward declaration
proc tvWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.}
proc createTvHandle(ctl: Control)
proc addNode*(this: TreeView, nodeText: string) : TreeNode {.discardable.}
proc addNode*(this: TreeView, node: TreeNode)
proc addChildNode*(this: TreeView, nodeText: string, parent: TreeNode) : TreeNode {.discardable.}
proc addNodeInternal(this: TreeView, node: TreeNode, pnode: TreeNode = nil)

# TreeView constructor
proc treeViewCtor(parent: Control, x, y, w, h: int32): TreeView =
    new(result)
    result.mKind = ctTreeView
    controlBaseInit(result, parent, x, y, w, h, tvCount)
    result.mLineColor = CLR_BLACK
    result.mUniqNodeID = 100
    result.mCreateHwndProc = createTvHandle
    


proc newTreeView*(parent: Control, x, y: int32, w: int32 = 200, h: int32 = 150): TreeView =
    result = treeViewCtor(parent, x, y, w, h)


proc newTreeNode*(text: string, img: int32 = -1, selImg: int32 = -1): TreeNode =
    new(result)
    result.mImgIndex = img
    result.mSelImgIndex = selImg
    result.mForeColor = CLR_BLACK
    result.mBackColor = CLR_WHITE
    result.mText = text
    result.mIndex = -1

proc addTreeNodeWithChilds*(this: TreeView, nodeTxt: string, args: varargs[string, `$`]) =
    var node = newTreeNode(nodeTxt)
    this.addNode(node)
    for txt in args:
        this.addChildNode(txt, node)


proc tryAddNode(this: TreeView, node: TreeNode) =
    node.mNodeOp = NodeOps.noAddNode
    node.mInsertAfter = TVI_LAST 
    node.mIndex = this.mNodeCount
    node.mIsRoot = true
    this.mNodeCount += 1
    this.mNodes.add(node)
    node.mInList = true
    if (this.mIsCreated):
        this.addNodeInternal(node)

proc tryAddChildNode(this: TreeView, parent: TreeNode, child: TreeNode ) =
    if not parent.mInList:
        # We don't allow new nodes here.
        echo "Error: %s node is not added already!", parent.mText
        return
 
    child.mNodeOp = NodeOps.noAddChild
    child.mInsertAfter = TVI_LAST
    child.mIndex = parent.mChildCount
    parent.mChildCount += 1
    parent.mNodes.add(child)
    child.mInList = true     
    if this.mIsCreated: this.addNodeInternal(child, parent)


proc insertAllNodes(this: TreeView, node: TreeNode, pnode: TreeNode = nil) =
    this.addNodeInternal(node, pnode)
    if node.mNodes.len > 0:
        for tn in node.mNodes:
            this.insertAllNodes(tn, node)


proc setTVStyle(this: TreeView) =
    if this.mNoLine: this.mStyle = this.mStyle xor TVS_HASLINES
    if this.mNoButton: this.mStyle = this.mStyle xor TVS_HASBUTTONS
    if this.mHasCheckBox: this.mStyle = this.mStyle or TVS_CHECKBOXES
    if this.mFullRowSel: this.mStyle = this.mStyle or TVS_FULLROWSELECT
    if this.mEditable: this.mStyle = this.mStyle or TVS_EDITLABELS
    if this.mShowSel: this.mStyle = this.mStyle or TVS_SHOWSELALWAYS
    if this.mHotTrack: this.mStyle = this.mStyle or TVS_TRACKSELECT
    if this.mNoButton and this.mNoLine: this.mStyle = this.mStyle xor TVS_LINESATROOT
    this.mBkBrush = CreateSolidBrush(this.mBackColor.cref)

proc sendInitialMessages(this: TreeView) =
    if this.mBackColor.value != 0xFFFFFF: this.sendMsg(TVM_SETBKCOLOR, 0, this.mBackColor.cref)
    if this.mForeColor.value != 0x000000: this.sendMsg(TVM_SETTEXTCOLOR, 0, this.mForeColor.cref)
    if this.mLineColor.value != 0x000000: this.sendMsg(TVM_SETLINECOLOR, 0, this.mLineColor.cref)

proc addNodeInternal(this: TreeView, node: TreeNode, pnode: TreeNode = nil) =
    node.mIsCreated = true
    node.mTreeHandle = this.mHandle
    node.mNodeID = this.mUniqNodeID # We can identify any node

    var tvi: TVITEMEXW
    tvi.mask = TVIF_TEXT or TVIF_PARAM
    tvi.pszText = toLPWSTR(node.mText)
    tvi.cchTextMax = int32(node.mText.len)
    tvi.iImage = node.mImgIndex
    tvi.iSelectedImage = node.mSelImgIndex
    tvi.stateMask = TVIS_USERMASK
    if node.mImgIndex > -1: tvi.mask = tvi.mask or TVIF_IMAGE
    if node.mSelImgIndex > -1: tvi.mask = tvi.mask or TVIF_SELECTEDIMAGE

    var tis: TVINSERTSTRUCTW
    tis.itemex = tvi
    tis.itemex.lParam = cast[LPARAM](cast[PVOID](node))
    tis.hInsertAfter = node.mInsertAfter
    var isRootNode = false
    var errMsg = "Can't Add"

    case node.mNodeOp:
    of noAddNode:
        tis.hParent = TVI_ROOT
        
    of noInsertNode:
        tis.hParent = TVI_ROOT
        errMsg = "Can't Insert"

    of noAddChild:
        tis.hParent = pnode.mHandle
        node.mParentNode = pnode
        errMsg = "Can't Add Child"

    of noInsertChild:
        tis.hParent = pnode.mHandle
        node.mParentNode = pnode
        errMsg = "Can't Insert Child"

    let hItem =  cast[HTREEITEM](this.sendMsg(TVM_INSERTITEMW, 0, tis.unsafeAddr))
    if hItem != nil:
        node.mHandle = hItem
        this.mUniqNodeID += 1
    else:
        let errNo = GetLastError()
        echo(errMsg & " node!, Error - " & $errNo )


proc insertNodeGeneric[T: TreeView | TreeNode](this: TreeView, container: T, 
                                                node: TreeNode, 
                                                position: int32, op: NodeOps) =
    if position < 0 or position >= container.mNodes.len: 
            raise newException(IndexDefect, "Index is out of range!")

    when T is TreeView:
        node.mIndex = this.mNodeCount
        this.mNodeCount += 1
    else: # T is TreeNode
        node.mIndex = container.mChildCount
        container.mChildCount += 1

    node.mInsertPos = position        
    node.mNodeOp = op
    node.mInsertAfter = if position == 0: TVI_FIRST 
                        else: container.mNodes[position - 1].mHandle

    # Update counts and append to the specific container
    
    container.mNodes.add(node)
    node.mInList = true

    # Finalize the underlying Win32/internal tree structure
    if this.mIsCreated:
        when T is TreeView:
            this.addNodeInternal(node)
        else:
            this.addNodeInternal(node, container)


proc setNodeText(this: TreeView, node: TreeNode) = # Implement this
    echo node.mText

proc sendMsg(this: TreeNode, uMsg: UINT, wpm, lpm: auto) : LRESULT {.discardable.} =
    return SendMessageW(this.mTreeHandle, uMsg, cast[WPARAM](wpm), cast[LPARAM](lpm))

# We need this function to recurseively traverse all the nodes and expand them.
proc expandNode(this: TreeNode) =
    this.sendMsg(TVM_EXPAND, TVE_EXPAND, this.mHandle)
    if this.mChildCount > 0:
        for node in this.mNodes: node.expandNode()


# Create TreeView's hwnd
proc createTvHandle(ctl: Control) =
    var this = cast[TreeView](ctl)
    this.setTVStyle()
    this.createHandleInternal(this.mWidth, this.mHeight)
    if this.mHandle != nil:
        this.setSubclass(tvWndProc)
        this.sendInitialMessages()
        if this.mNodes.len > 0:
            for node in this.mNodes:
                this.insertAllNodes(node)

# method autoCreate(this: TreeView) = this.createHandle()


proc addNode*(this: TreeView, nodeText: string) : TreeNode {.discardable.} =
    result = newTreeNode(nodeText)
    this.tryAddNode(result)


proc addNode*(this: TreeView, node: TreeNode) = this.tryAddNode(node)


proc addChildNode*(this: TreeView, nodeText: string, parent: TreeNode) : TreeNode {.discardable.} =
    result = newTreeNode(nodeText)
    this.tryAddChildNode(parent, result)


proc addChildNode*(this: TreeView, node: TreeNode, parent: TreeNode) = 
    this.tryAddChildNode(parent, node)

proc insertNode*(this: TreeView, node: TreeNode, position: int32) =
    # Uses the exact mNodes field from your TreeView definition
    node.mIsRoot = true
    this.insertNodeGeneric(this, node, position, NodeOps.noInsertNode)


proc insertNode*(this: TreeView, nodeText: string, position: int32) : TreeNode {.discardable.} =
    result = newTreeNode(nodeText)    
    this.insertNode(result, position)
    

proc insertChildNode*(this: TreeView, node: TreeNode, parent: TreeNode, position: int32) =
    this.insertNodeGeneric(parent, node, position, NodeOps.noInsertChild)


proc insertChildNode*(this: TreeView, nodeText: string, parent: TreeNode, position: int32) : TreeNode {.discardable.} =
    result = newTreeNode(nodeText)
    this.insertChildNode(result, parent, position)


proc deleteSelNode*(this: TreeView, index: int32): bool =
    let selItem = cast[HTREEITEM](this.sendMsg(TVM_GETNEXTITEM, TVGN_CARET, 0))
    if selItem != nil:
        result = bool(this.sendMsg(TVM_DELETEITEM, 0, selItem))

# Expand all nodes in this tree view
proc expandAll*(this: TreeView) =
    if this.mIsCreated:
        for node in this.mNodes: node.expandNode()




# TreeNode functions------------------------------------------------------------
proc newNodeNotify(nod: TreeNode, pnode: TreeNode, nop: NodeOps, p: int32 = -1) : NodeNotify =
    new(result)
    result.node = nod
    result.parent = pnode
    result.nops = nop
    result.pos = p

proc nnDataToLparm(nnData: NodeNotify): LPARAM = cast[LPARAM](cast[PVOID](nnData))
proc nodeToWparm(node: TreeNode): WPARAM = cast[WPARAM](cast[PVOID](node))
proc nodeToLparm(node: TreeNode): LPARAM = cast[LPARAM](cast[PVOID](node))

proc addChildNode*(this: TreeNode, nodeText: string) : TreeNode {.discardable.} =
    result = newTreeNode(nodeText)
    let nnData = newNodeNotify(result, this, noAddChild)
    this.sendMsg(MM_NODE_NOTIFY, naAddNode, cast[PVOID](nnData))


proc addChildNode*(this: TreeNode, chNode: TreeNode) =
    let nnData = newNodeNotify(chNode, this, noAddChild)
    this.sendMsg(MM_NODE_NOTIFY, naAddNode, cast[PVOID](nnData))

proc insertChildNode*(this: TreeNode, nodeText: string, position: int32) : TreeNode {.discardable.} =
    result = newTreeNode(nodeText)
    let nnData = newNodeNotify(result, this, noInsertChild, position)
    this.sendMsg(MM_NODE_NOTIFY, naAddNode, cast[PVOID](nnData))

proc insertChildNode*(this: TreeNode, node: TreeNode, position: int32) =
    let nnData = newNodeNotify(node, this, noInsertChild, position)
    this.sendMsg(MM_NODE_NOTIFY, naAddNode, cast[PVOID](nnData))





#TreeView Properties------------------------------------------------------------------------
proc nodes*(this: TreeView) : seq[TreeNode] = this.mNodes
proc selectedNode*(this: TreeView): TreeNode = this.mSelNode

proc foreColor*(this: TreeView): Color = this.mForeColor
proc `foreColor=`*(this: TreeView, value: uint) =
    this.mForeColor = newColor(value)
    this.sendMsg(TVM_SETTEXTCOLOR, 0, this.mForeColor.cref)
    this.checkRedraw()

proc noLine*(this: TreeView): bool = this.mNoLine
proc `noLine=`*(this: TreeView, value: bool) = this.mNoLine = value

proc noButton*(this: TreeView): bool = this.mNoButton
proc `noButton=`*(this: TreeView, value: bool) = this.mNoButton = value

proc hasCheckBox*(this: TreeView): bool = this.mHasCheckBox
proc `hasCheckBox=`*(this: TreeView, value: bool) = this.mHasCheckBox = value

proc fullRowSelect*(this: TreeView): bool = this.mFullRowSel
proc `fullRowSelect=`*(this: TreeView, value: bool) = this.mFullRowSel = value

proc isEditable*(this: TreeView): bool = this.mEditable
proc `isEditable=`*(this: TreeView, value: bool) = this.mEditable = value

proc showSelection*(this: TreeView): bool = this.mShowSel
proc `showSelection=`*(this: TreeView, value: bool)= this.mShowSel = value

proc hotTrack*(this: TreeView): bool = this.mHotTrack
proc `hotTrack=`*(this: TreeView, value: bool) = this.mHotTrack = value

proc nodeCount*(this: TreeView): int32 = this.mNodeCount
proc `nodeCount=`*(this: TreeView, value: int32) = this.mNodeCount = value

proc uniqNodeID*(this: TreeView): int32 = this.mUniqNodeID
proc `uniqNodeID=`*(this: TreeView, value: int32) = this.mUniqNodeID = value

proc lineColor*(this: TreeView): Color = this.mLineColor
proc `lineColor=`*(this: TreeView, value: uint) = this.mLineColor =  newColor(value)




# TreeNode properties-------------------------------------------------------
proc nodes*(this: TreeNode) : seq[TreeNode] = this.mNodes
proc index*(this: TreeNode): int32 = this.mIndex
proc text*(this: TreeNode): string = this.mText
proc `text=`*(this: TreeNode, value: string) =
    this.mText = value
    if this.mIsCreated:
        this.sendMsg(MM_NODE_NOTIFY, naSetText, cast[PVOID](this))

proc imageIndex*(this: TreeNode): int32 = this.mImgIndex
proc selectedImageIndex*(this: TreeNode): int32 = this.mSelImgIndex
proc childCount*(this: TreeNode): int32 = this.mChildCount
# proc childCount*(this: TreeNode): int32 = this.mChildCount
proc nodeID*(this: TreeNode): int32 = this.mNodeID
proc checked*(this: TreeNode): bool = this.mChecked
proc foreColor*(this: TreeNode): Color = this.mForeColor
proc `foreColor=`*(this: TreeNode, value: uint) =
    this.mForeColor = newColor(value)
    if this.mIsCreated: InvalidateRect(this.mTreeHandle, nil, 0)


# proc baackColor*(this: TreeNode): Color = this.mBackColor
# proc `baackColor=`*(this: TreeNode, value: uint) =
#     this.mBackColor = newColor(value)
#     if this.mIsCreated: InvalidateRect(this.mTreeHandle, nil, 0)

proc parentNode*(this: TreeNode): TreeNode = this.mParentNode



# proc `selectedItem=`*(this: TreeView, value: int32) =






# # Set the checked property
# proc `checked=`*(this: TreeView, value: bool) {.inline.} =
#     this.mChecked = value
#     if this.mIsCreated: this.sendMsg(BM_SETCHECK, int32(value), 0)

# # # Get the checked property
# proc checked*(this: TreeView): bool {.inline.} = this.mChecked


proc tvWndProc(hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM, scID: UINT_PTR, refData: DWORD_PTR): LRESULT {.stdcall.} =
    var this = cast[TreeView](refData)
    let res = this.commonMsgHandler(hw, msg, wpm, lpm)
    if res == MsgHandlerResult.mhrCallDefProc:
        return DefSubclassProc(hw, msg, wpm, lpm)
    elif res == MsgHandlerResult.mhrReturnZero or res == MsgHandlerResult.mhrReturnOne:
        return cast[LRESULT](res)
    case msg
    of WM_NCDESTROY:
        RemoveWindowSubclass(hw, tvWndProc, scID)
        this.controlBaseDtor()

    # of MM_NODE_NOTIFY: # Received when a node wants to add a child node
    #     var action = cast[NodeAction](wpm)
    #     case action
    #     of naAddNode:
    #         var nnd = cast[NodeNotify](cast[PVOID](lpm))
    #         this.addNodeInternal(nnd.node, nnd.nops, nnd.parent)
    #     of naSetText: this.setNodeText(cast[TreeNode]([cast[PVOID](lpm)]))
    #     else: discard

    of MM_NOTIFY_REFLECT:
        let nmh = cast[LPNMHDR](lpm)
        case nmh.code
        of NM_DBLCLK:echo "MM_NOTIFY_REFLECT TREEVIEW"
        of NM_CUSTOMDRAW_NM:
            var nmtv = cast[LPNMTVCUSTOMDRAW](lpm)
            case nmtv.nmcd.dwDrawStage:
            of CDDS_PREPAINT: return CDRF_NOTIFYITEMDRAW
            of CDDS_ITEMPREPAINT:
                var node = cast[TreeNode](cast[PVOID](nmtv.nmcd.lItemlParam))
                # nmtv.clrText = node.mForeColor.cref
                # nmtv.clrTextBk = node.mBackColor.cref
                return CDRF_DODEFAULT
            else: discard

        of TVN_DELETEITEMW:
            if this.onNodeDeleted != nil: this.onNodeDeleted(this, newEventArgs())

        of TVN_SELCHANGINGW:
            if this.onBeforeSelected != nil:
                var nmtv = cast[LPNMTREEVIEWW](lpm)
                this.onBeforeSelected(this, newTreeEventArgs(nmtv))

        of TVN_SELCHANGEDW:
            let nmtv = cast[LPNMTREEVIEWW](lpm)
            var tea = newTreeEventArgs(nmtv)
            this.mSelNode = tea.mNode
            if this.onAfterSelected != nil: this.onAfterSelected(this, tea)

        of TVN_ITEMEXPANDINGW :
            let nmtv = cast[LPNMTREEVIEWW](lpm)
            if nmtv.action == 1:
                if this.onBeforeCollapsed != nil:
                    var tea = newTreeEventArgs(nmtv)
                    this.onBeforeCollapsed(this, tea)
            elif nmtv.action == 2:
                if this.onBeforeExpanded != nil:
                    var tea = newTreeEventArgs(nmtv)
                    this.onBeforeExpanded(this, tea)

        of TVN_ITEMEXPANDEDW:
            let nmtv = cast[LPNMTREEVIEWW](lpm)
            if nmtv.action == 1:
                if this.onAfterCollapsed != nil:
                    var tea = newTreeEventArgs(nmtv)
                    this.onAfterCollapsed(this, tea)
            elif nmtv.action == 2:
                if this.onAfterExpanded != nil:
                    var tea = newTreeEventArgs(nmtv)
                    this.onAfterExpanded(this, tea)

        of NM_TVSTATEIMAGECHANGING_NM:
            let tvsic = cast[LPNMTVSTATEIMAGECHANGING](lpm)
            if tvsic.iOldStateImageIndex == 1:
                this.mNodeChecked = true
            elif tvsic.iOldStateImageIndex == 2:
                this.mNodeChecked = false

        of TVN_ITEMCHANGINGW:
            if this.onBeforeChecked != nil:
                let tvic = cast[LPNMTVITEMCHANGE](lpm)
                var tea = newTreeEventArgs(tvic)
                tea.mNode.mChecked = this.mNodeChecked
                this.onBeforeChecked(this, tea)

        of TVN_ITEMCHANGEDW:
            if this.onAfterChecked != nil:
                let tvic = cast[LPNMTVITEMCHANGE](lpm)
                var tea = newTreeEventArgs(tvic)
                tea.mNode.mChecked = this.mNodeChecked
                this.onAfterChecked(this, tea)

        else: discard
        return 0

    else: return DefSubclassProc(hw, msg, wpm, lpm)
    return DefSubclassProc(hw, msg, wpm, lpm)
