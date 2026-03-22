# Created on: 22-Mar-2026 02:27 AM
# Purpose: 


var isPboxReg : bool = false
var pboxCount : int = 1
let posFlag : UINT = SWP_NOMOVE or SWP_NOZORDER or SWP_NOACTIVATE
let pboxClsName : array[20, uint16] = [78, 105, 109, 102, 111, 114, 109, 115, 95, 80, 105, 99, 116, 117, 114, 101, 66, 111, 120, 0]
 
# forward declarations
proc pBoxWndProc( hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM): LRESULT {.stdcall.} 
proc createHandle*(this: PictureBox) 
proc registerPboxClass(pbxClass: LPCWSTR, hinst: HINSTANCE)
proc setImageInternal(this: PictureBox, filePath: string, setPath: bool = true) 
proc updateClientRect(this: PictureBox)
proc adjustSizeToImage(this: PictureBox)
proc computeDestRect(this: PictureBox)



proc newPictureBox*(parent: Form, x, y, w, h: int32, imgPath: string = "", 
                    sizeMode: PictureSizeMode = PictureSizeMode.psmStretch) : PictureBox =
    new(result)
    result.mClassName = cast[LPCWSTR](pboxClsName[0].addr)     
    result.mKind = ctPictureBox
    result.mName = "PictureBox_" & $pboxCount
    result.mParent = parent
    result.mXpos = x
    result.mYpos = y
    result.mWidth = w
    result.mHeight = h    
    result.mStyle = WS_CHILD or WS_TABSTOP or WS_VISIBLE
    result.mSizeMode = sizeMode
    if not isPboxReg: registerPboxClass(result.mClassName, result.mParent.hInstance)
    if len(imgPath) > 0: result.mImgPath = imgPath
    parent.mControls.add(result)
    pboxCount += 1
    # if evtFn != nil: result.onClick = evtFn
    if parent.mCreateChilds: result.createHandle()


proc createHandle*(this: PictureBox) =
    this.mSize = SIZE(cx: this.mWidth.int32, cy: this.mHeight.int32)
    if this.mImgPath.len > 0: this.setImageInternal(this.mImgPath, false)
    this.createHandleInternal()
    if this.mHandle != nil:
        GetClientRect(this.mHandle, &this.mRect)
        SetWindowLongPtrW(this.mHandle, GWLP_USERDATA, cast[LONG_PTR](cast[PVOID](this)))
        

method autoCreate(this: PictureBox) = this.createHandle()

proc setImage*(this: PictureBox, filePath: string) =
    this.mImage.finalize() 
    this.mImage = newImage(filePath)
    this.mImgPath = filePath
    if this.mSizeMode == PictureSizeMode.psmAutoSize:
        this.mSize = this.mImage.size

    if this.mHandle != nil: this.updateClientRect()

proc clearImage*(this: PictureBox) =
    this.mImage.finalize()
    this.mImgPath = ""
    if this.mHandle != nil: InvalidateRect(this.mHandle, nil, 1)

proc image*(this: PictureBox) : Image = this.mImage
proc `image=`*(this: PictureBox, value : Image) =
    this.mImage.finalize()
    this.mImage = value
    if this.mHandle != nil:
        if this.mSizeMode == PictureSizeMode.psmAutoSize:
            this.adjustSizeToImage()
        else:
            this.updateClientRect()

proc sizeMode*(this: PictureBox) : PictureSizeMode = this.mSizeMode
proc `sizeMode=`*(this: PictureBox, mode: PictureSizeMode) =
    if this.mSizeMode == mode: return
    this.mSizeMode = mode
    if mode == PictureSizeMode.psmAutoSize and this.mImage != nil:
        this.adjustSizeToImage()
    else:
        this.updateClientRect()

proc size*(this: PictureBox): SIZE = this.mSize
proc `size=`*(this: PictureBox, value: SIZE) =
    if this.mHandle == nil: return 
    SetWindowPos(this.mHandle, nil, 0, 0, value.cx, value.cy, posFlag)
    this.mSize = value

# Overriding base class's width property
proc `width=`*(this: PictureBox, value: int32) =
    this.mWidth = value 
    if this.mIsCreated: this.updateClientRect()

# Overriding base class's width property
proc `height=`*(this: PictureBox, value: int32) =
    this.mHeight = value
    if this.mIsCreated: this.updateClientRect()


# Private functions
proc registerPboxClass(pbxClass: LPCWSTR, hinst: HINSTANCE) =
    var wcex : WNDCLASSEXW
    wcex.cbSize = cast[UINT](sizeof(wcex))
    wcex.style = CS_HREDRAW or CS_VREDRAW
    wcex.lpfnWndProc = pBoxWndProc
    wcex.cbClsExtra = 0
    wcex.cbWndExtra = 0
    wcex.hInstance = hInst
    wcex.hIcon = nil
    wcex.hCursor = LoadCursorW(ZERO_HINST, cast[LPCWSTR](IDC_ARROW))
    wcex.hbrBackground = nil         #
    wcex.lpszMenuName = nil
    wcex.lpszClassName = pbxClass
    var ret = RegisterClassExW(wcex.addr)
    if ret > 0: isPboxReg = true
        
proc setImageInternal(this: PictureBox, filePath: string, setPath: bool = true) =
    this.mImage = newImage(filePath)
    if setPath: this.mImgPath = filePath
    if this.mSizeMode == PictureSizeMode.psmAutoSize:
        this.mSize = this.mImage.size
    
    if this.mHandle != nil: this.updateClientRect()

proc updateClientRect(this: PictureBox) =
    this.computeDestRect()
    if this.mHandle != nil: InvalidateRect(this.mHandle, nil, 1)

proc computeDestRect(this: PictureBox) =
    # Use the Control's Client Area size
    let cw = this.mWidth  # Use the width/height of the PictureBox control
    let ch = this.mHeight
    
    if this.mImage == nil: 
        this.mRect = RECT(left:0, top:0, right:0, bottom:0)
        return

    let imgW = this.mImage.width.int32
    let imgH = this.mImage.height.int32

    case this.mSizeMode:
        of PictureSizeMode.psmNormal:
            this.mRect = RECT(left:0, top:0, right: imgW, bottom: imgH)       

        of PictureSizeMode.psmCenter: 
            let x = (cw - imgW) div 2
            let y = (ch - imgH) div 2
            this.mRect = RECT(left: x, top: y, right: x + imgW, bottom: y + imgH)        

        of PictureSizeMode.psmStretch:
            this.mRect = RECT(left:0, top:0, right: cw, bottom: ch)        

        of PictureSizeMode.psmZoom: 
            let ratioImg = imgW.float32 / imgH.float32
            let ratioCtl = cw.float32 / ch.float32
            var w, h : int32
            if ratioImg > ratioCtl:
                w = cw
                h = (cw.float32 / ratioImg).int32
            else:
                h = ch
                w = (ch.float32 * ratioImg).int32

            let x = (cw - w) div 2
            let y = (ch - h) div 2
            this.mRect = RECT(left: x, top: y, right: x + w, bottom: y + h)        

        of PictureSizeMode.psmAutoSize:
            this.mRect = RECT(left:0, top:0, right: imgW, bottom: imgH)
       

proc adjustSizeToImage(this: PictureBox) =
    if (this.mImage == nil or this.mHandle == nil): return
    let sz = this.mImage.size
    SetWindowPos(this.mHandle, nil, 0, 0, sz.cx, sz.cy, posFlag)
    this.mRect = RECT(left:0, top:0, right:sz.cx, bottom:sz.cy)
    if this.mHandle != nil: InvalidateRect(this.mHandle, nil, 1)



proc pBoxWndProc( hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM): LRESULT {.stdcall.} =
    case msg
    of WM_DESTROY: 
        var this  = cast[PictureBox](GetWindowLongPtrW(hw, GWLP_USERDATA))
        if this.mImage != nil: this.mImage.finalize()
        

    of WM_PAINT:
        var ps : PAINTSTRUCT
        var this  = cast[PictureBox](GetWindowLongPtrW(hw, GWLP_USERDATA))
        var hdc = BeginPaint(hw, ps.addr) 
        try:
            if this.mImage != nil:                
                this.mImage.draw(hdc, this.mRect.left, this.mRect.top, 
                                    this.mRect.right - this.mRect.left, 
                                    this.mRect.bottom - this.mRect.top)
            else:
                # If no image, fill with background color
                # print("No image to draw, filling with background color");
                let hbr : HBRUSH = CreateSolidBrush(this.mBackColor.cref)
                FillRect(hdc, &ps.rcPaint, hbr)
                DeleteObject(hbr)
        finally:
            EndPaint(hw, &ps)
        return 0

    of WM_ERASEBKGND:
        return 1

    of WM_SIZE:
        var this  = cast[PictureBox](GetWindowLongPtrW(hw, GWLP_USERDATA))
        if this != nil and this.mSizeMode != PictureSizeMode.psmAutoSize:
                InvalidateRect(this.mHandle, nil, 1)

    else: return DefWindowProcW(hw, msg, wpm, lpm)
    return DefWindowProcW(hw, msg, wpm, lpm)