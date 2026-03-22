# Created on: 21-Mar-2026 10:08 PM
# Purpose: Image type using Gdi+ flat api.

# Create new Image class with loading an image from file.
proc newImage*(filePath: string): Image =
    initGdiPlus(appData)
    new(result)
    let st = GdipLoadImageFromFile(filePath.toWcharPtr, &result.mImage);
    if st != Status.okay: 
        raise newException(OSError, "GDI+ Error:Can't load Image fromF file, status: " & $st)

# Destroy an Image class. Call this when you finished using an Image.
proc finalize*(this: Image) =
    if this.mImage != nil:
        let x = GdipDisposeImage(this.mImage)
        this.mImage = nil   
        # echo "Gdip Disp Image: ", x 

proc width*(this: Image): uint32 = 
    if this.mImage == nil: return 0
    GdipGetImageWidth(this.mImage, &this.mWidth)
    result = this.mWidth

proc height*(this: Image): uint32 = 
    if this.mImage == nil: return 0
    GdipGetImageHeight(this.mImage, &this.mHeight)
    result = this.mHeight

proc handle*(this: Image): ptr GpImage = this.mImage

proc size*(this: Image): SIZE =
    result.cx = this.width.int32
    result.cy = this.height.int32

proc draw(this: Image, hdc: HDC, x, y, w, h: LONG) =
    if this.mImage == nil: return # No image loaded, nothing to draw.            
    var gp: ptr GpGraphics
    var st: Status = GdipCreateFromHDC(hdc, gp.addr)
    if st != Status.okay:
        raise newException(OsError, "Failed to create GDI+ graphics context, Status: " & $st)

    try:
        st = GdipDrawImageRect(gp, this.mImage,
                            x.float32, y.float32,
                            w.float32, h.float32)
        # st = GdipDrawImageRect(gp, this.mImage,0.0f32, 0.0f32, 100.0f32, 100.0f32)
        
        if st != Status.okay:
            raise newException(OsError, "Failed to draw image, Status: " & $st)
    finally:
        GdipDeleteGraphics(gp)


