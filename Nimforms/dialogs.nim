# dialogs module Created on 17-May-2023 06:32

import std/strformat
const
    MAX_PATH = 260
    OFN_ALLOWMULTISELECT = 0x200
    OFN_PATHMUSTEXIST = 0x800
    OFN_FILEMUSTEXIST = 0x1000
    OFN_FORCESHOWHIDDEN = 0x10000000
    OFN_OVERWRITEPROMPT = 0x2
    BIF_RETURNONLYFSDIRS = 0x00000001
    BIF_NEWDIALOGSTYLE = 0x00000040
    BIF_EDITBOX = 0x00000010
    BIF_NONEWFOLDERBUTTON = 0x00000200
    BIF_BROWSEINCLUDEFILES = 0x00004000
    OFN_EXPLORER = 0x00080000

type
    DialogBase = ref object of RootObj
        kind : DialogType
        mTitle, mInitDir, mFilter, mSelPath : string
        mFileStart, mExtStart : int

    FileOpenDialog* = ref object of DialogBase
        mMultiSel, mShowHidden : bool
        mSelFiles : seq[string]

    FileSaveDialog* = ref object of DialogBase
        mDefExt : string

    FolderBrowserDialog* = ref object of DialogBase
        mNewFolBtn, mShowFiles : bool

    DialogType = enum
        fileOpen, fileSave

    OFNHOOKPROC = proc(hwnd: HWND, msg: uint, wpm: WPARAM, lpm: LPARAM): UINT_PTR {.stdcall.}
    BROWSECBPROC = proc(hwnd: HWND, msg: uint, lpm1: LPARAM, lpm2: LPARAM): INT {.stdcall.}


    OPENFILENAMEW {.pure.} = object
        lStructSize: DWORD
        hwndOwner: HWND
        hInstance: HINSTANCE
        lpstrFilter: LPCWSTR
        lpstrCustomFilter: LPWSTR
        nMaxCustFilter: DWORD
        nFilterIndex: DWORD
        lpstrFile: LPWSTR
        nMaxFile: DWORD
        lpstrFileTitle: LPWSTR
        nMaxFileTitle: DWORD
        lpstrInitialDir: LPCWSTR
        lpstrTitle: LPCWSTR
        Flags: DWORD
        nFileOffset: WORD
        nFileExtension: WORD
        lpstrDefExt: LPCWSTR
        lCustData: LPARAM
        lpfnHook: OFNHOOKPROC
        lpTemplateName: LPCWSTR
        pvReserved: pointer
        dwReserved: DWORD
        FlagsEx: DWORD
    LPOPENFILENAMEW = ptr OPENFILENAMEW

    SHITEMID {.pure.} = object
        cb: USHORT
        abID: array[1, BYTE]
    LPSHITEMID* = ptr SHITEMID

    ITEMIDLIST {.pure, packed.} = object
        mkid: SHITEMID
    ITEMIDLIST_RELATIVE = ITEMIDLIST
    ITEMID_CHILD = ITEMIDLIST
    ITEMIDLIST_ABSOLUTE = ITEMIDLIST
    LPITEMIDLIST = ptr ITEMIDLIST
    LPCITEMIDLIST = ptr ITEMIDLIST
    PIDLIST_ABSOLUTE = ptr ITEMIDLIST_ABSOLUTE
    PCIDLIST_ABSOLUTE = ptr ITEMIDLIST_ABSOLUTE

    BROWSEINFOW {.pure.} = object
        hwndOwner: HWND
        pidlRoot: PCIDLIST_ABSOLUTE
        pszDisplayName: LPWSTR
        lpszTitle: LPCWSTR
        ulFlags: UINT
        lpfn: BROWSECBPROC
        lParam: LPARAM
        iImage: int32
    LPBROWSEINFOW = ptr BROWSEINFOW

proc GetOpenFileNameW(P1: LPOPENFILENAMEW): BOOL {.stdcall, dynlib: "comdlg32", importc.}
proc GetSaveFileNameW(P1: LPOPENFILENAMEW): BOOL {.stdcall, dynlib: "comdlg32", importc.}
proc SHBrowseForFolderW(lpbi: LPBROWSEINFOW): PIDLIST_ABSOLUTE {.stdcall, dynlib: "shell32", importc.}
proc SHGetPathFromIDListW(pidl: PCIDLIST_ABSOLUTE, pszPath: LPWSTR): BOOL {.stdcall, dynlib: "shell32", importc.}
proc CoTaskMemFree(pv: LPVOID): void {.stdcall, dynlib: "ole32", importc.}

proc initDialogBase(this: DialogBase, ttl: string, initDir: string, filter: string = "") =
    this.mTitle = ttl
    this.mInitDir = initDir
    this.mFilter = if filter == "": "All Files" & "\0" & "*.*" & "\0" else: filter

proc newFileOpenDialog*(title: string = "Open file", initDir: string = "", filter: string = ""): FileOpenDialog =
    new(result)
    initDialogBase(result, title, initDir, filter)
    result.kind = DialogType.fileOpen

proc newFileSaveDialog*(title: string = "Save As", initDir: string = "", filter: string = ""): FileSaveDialog =
    new(result)
    initDialogBase(result, title, initDir, filter)
    result.kind = DialogType.fileSave

proc newFolderBrowserDialog*(title: string = "Save As", initDir: string = ""): FolderBrowserDialog =
    new(result)
    initDialogBase(result, title, initDir)

# Getter functions
proc selectedPath*(this: DialogBase): string = this.mSelPath
proc nameStartPos*(this: DialogBase): int = this.mFileStart
proc extStartPos*(this: DialogBase): int = this.mExtStart
proc title*(this: DialogBase): string = this.mTitle
proc initialFolder*(this: DialogBase): string = this.mInitDir
proc filter*(this: DialogBase): string = this.mFilter
proc multiSelect*(this: FileOpenDialog): bool = this.mMultiSel
proc showHiddenFiles*(this: FileOpenDialog): bool = this.mShowHidden
proc newFolderButton*(this: FolderBrowserDialog): bool = this.mNewFolBtn
proc showFiles*(this: FolderBrowserDialog): bool = this.mShowFiles
proc fileNames*(this: FileOpenDialog): seq[string] = this.mSelFiles

# Setter functions
proc `title=`*(this: DialogBase, value: string) = this.mTitle = value
proc `initialFolder=`*(this: DialogBase, value: string) = this.mInitDir = value
proc `filter=`*(this: DialogBase, value: string) = this.mFilter = value
proc `multiSelect=`*(this: FileOpenDialog, value: bool) = this.mMultiSel = value
proc `showHiddenFiles=`*(this: FileOpenDialog, value: bool) = this.mShowHidden = value
proc `newFolderButton=`*(this: FolderBrowserDialog, value: bool) = this.mNewFolBtn = value
proc `showFiles=`*(this: FolderBrowserDialog, value: bool) = this.mShowFiles = value




proc extractFileNames(this: FileOpenDialog, buff: seq[WCHAR], startPos: int) =
    var offset : int = startPos
    let dirPath = toUtf8String(buff[0..startPos - 2]) # First item in buff is the directory path.
    for i in startPos .. MAX_PATH:
        let wc : WCHAR = buff[i]
        if ord(wc) == 0:
            var slice : seq[WCHAR] = buff[offset..i - 1]
            offset = i + 1
            this.mSelFiles.add(fmt"{dirPath}\{toUtf8String(slice)}")
            if ord(buff[offset]) == 0: break


proc showDialogHelper(obj: DialogBase, hwnd: HWND = nil): bool =
    var ofn: OPENFILENAMEW
    var buffer: seq[WCHAR] = newSeq[WCHAR](MAX_PATH)
    ofn.hwndOwner = hwnd
    ofn.lStructSize = cast[DWORD](sizeof(ofn))
    ofn.lpstrFilter = obj.mFilter.toLPWSTR()
    ofn.lpstrFile = buffer[0].unsafeAddr
    ofn.lpstrInitialDir = obj.mInitDir.toLPWSTR()
    ofn.lpstrTitle = obj.mTitle.toLPWSTR()
    ofn.nMaxFile = MAX_PATH
    var ret : BOOL

    if obj.kind == DialogType.fileOpen:
        let fod = cast[FileOpenDialog](obj)
        ofn.Flags = OFN_PATHMUSTEXIST or OFN_FILEMUSTEXIST
        if fod.mMultiSel: ofn.Flags = ofn.Flags or OFN_ALLOWMULTISELECT or OFN_EXPLORER
        if fod.mShowHidden: ofn.Flags = ofn.Flags or OFN_FORCESHOWHIDDEN
        ret = GetOpenFileNameW(ofn.unsafeAddr)
        if ret > 0 and fod.mMultiSel: fod.extractFileNames(buffer, cast[int](ofn.nFileOffset))
    else:
        let fsd = cast[FileSaveDialog](obj)
        ofn.Flags = OFN_PATHMUSTEXIST or OFN_OVERWRITEPROMPT
        ret = GetSaveFileNameW(ofn.unsafeAddr)

    if ret != 0:
        obj.mFileStart = cast[int](ofn.nFileOffset)
        obj.mExtStart = cast[int](ofn.nFileExtension)
        obj.mSelPath = toUtf8String(buffer)
        result = true


proc showDialog*(this: FileOpenDialog, hwnd: HWND = nil): bool {.discardable.} = showDialogHelper(this, hwnd)
proc showDialog*(this: FileSaveDialog, hwnd: HWND = nil): bool {.discardable.} = showDialogHelper(this, hwnd)

proc showDialog*(this: FolderBrowserDialog, hwnd: HWND = nil): bool {.discardable.} =
    var buffer: seq[WCHAR] = newSeq[WCHAR](MAX_PATH)
    var bi: BROWSEINFOW
    bi.hwndOwner = hwnd;
    bi.lpszTitle = this.mTitle.toLPWSTR()
    bi.ulFlags = BIF_RETURNONLYFSDIRS or BIF_NEWDIALOGSTYLE
    if this.mNewFolBtn: bi.ulFlags = bi.ulFlags or BIF_NONEWFOLDERBUTTON
    if this.mShowFiles: bi.ulFlags = bi.ulFlags or BIF_BROWSEINCLUDEFILES
    var pidl : LPITEMIDLIST = SHBrowseForFolderW(bi.unsafeAddr)
    if pidl != nil:
        if SHGetPathFromIDListW(pidl, buffer[0].unsafeAddr) != 0:
            CoTaskMemFree(pidl)
            this.mSelPath = toUtf8String(buffer)
            result = true
        else:
            CoTaskMemFree(pidl)




