# PropertyGrid module [WIP!!!] 
# Created on 01-Jun-2023 08:36 AM; Author kcvinker

var pgridCount = 1
proc pGridWndProc( hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM): LRESULT {.stdcall.}
proc registerPGClass(this: PropertyGrid) =
    var wcex : WNDCLASSEXW
    wcex.cbSize = cast[UINT](sizeof(wcex))
    wcex.style = CS_HREDRAW or CS_VREDRAW or CS_DBLCLKS
    wcex.lpfnWndProc = pGridWndProc
    wcex.cbClsExtra = 0
    wcex.cbWndExtra = 0
    wcex.hInstance = this.mHInst
    wcex.hCursor = LoadCursorW(ZERO_HINST, cast[LPCWSTR](IDC_ARROW))
    wcex.hbrBackground = CreateSolidBrush(this.mBackColor.cref)         #
    wcex.lpszClassName = this.mWClsNamePtr
    var ret = RegisterClassEx(wcex.unsafeAddr)
    this.mRegistered = true


proc newPropertyGrid(parent: Form, x, y: int32 = 25, w: int32 = 150, h: int32 = 300) : PropertyGrid =
    new(result)
    result.mClassName = "Nimforms_PropertyGrid"
    result.mHInst = parent.hInstance
    this.mBackColor = newColor(0xFFFFFF)
    this.mWClsNamePtr = toWcharPtr(this.mClassName)
    if not this.mRegistered: this.registerPGClass()
    result.mName = "PropertyGrid_" & $pgridCount
    result.mParent = parent
    result.mXpos = x
    result.mYpos = y
    result.mWidth = w
    result.mHeight = h
    result.mFont = parent.mFont
    pgridCount += 1

proc destroyPropGrid(this: PropertyGrid) =
    pgridCount -= 1
    this.destructor() # Call base destructor
    DestroyWindow(this.mHandle)
    if pgridCount == 0:
        UnregisterClass(this.mWClsNamePtr, this.mHInst)



proc mainWndProc( hw: HWND, msg: UINT, wpm: WPARAM, lpm: LPARAM): LRESULT =
    var this  = cast[PropertyGrid](GetWindowLongPtrW(hw, GWLP_USERDATA))
    case msg
    of WM_DESTROY:
        this.destroyPropGrid()
        # PostQuitMessage(0)


    else: return DefWindowProcW(hw, msg, wpm, lpm)
    return DefWindowProcW(hw, msg, wpm, lpm)