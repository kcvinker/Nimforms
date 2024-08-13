# dialogs module Created on 17-May-2023 06:32


const
    MAX_PATH = 260
    MAX_PATH_NEW = 32768 + 256 * 100 + 1
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
        mTitle, mInitDir, mFilter, mSelPath : string
        mFileStart, mExtStart : int
        mAllowAllFiles: bool

    FileOpenDialog* = ref object of DialogBase
        mMultiSel, mShowHidden : bool
        mSelFiles : seq[string]

    FileSaveDialog* = ref object of DialogBase
        mDefExt : string

    FolderBrowserDialog* = ref object of DialogBase
        mNewFolBtn, mShowFiles : bool



proc GetOpenFileNameW(P1: LPOPENFILENAMEW): BOOL {.stdcall, dynlib: "comdlg32", importc.}
proc GetSaveFileNameW(P1: LPOPENFILENAMEW): BOOL {.stdcall, dynlib: "comdlg32", importc.}
proc SHBrowseForFolderW(lpbi: LPBROWSEINFOW): PIDLIST_ABSOLUTE {.stdcall, dynlib: "shell32", importc.}
proc SHGetPathFromIDListW(pidl: PCIDLIST_ABSOLUTE, pszPath: LPWSTR): BOOL {.stdcall, dynlib: "shell32", importc.}
proc CoTaskMemFree(pv: LPVOID): void {.stdcall, dynlib: "ole32", importc.}

proc initDialogBase(this: DialogBase, ttl: string, initDir: string) =
    this.mTitle = ttl
    this.mInitDir = initDir
    # this.mFilter = if filter == "": "All Files" & "\0" & "*.*" & "\0" else: filter

proc newFileOpenDialog*(title: string = "Open file", initDir: string = "", multisel : bool = false): FileOpenDialog =
    new(result)
    initDialogBase(result, title, initDir)
    # result.kind = DialogType.fileOpen
    result.mMultiSel = multisel

proc newFileSaveDialog*(title: string = "Save As", initDir: string = ""): FileSaveDialog =
    new(result)
    initDialogBase(result, title, initDir)
    # result.kind = DialogType.fileSave

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
# proc `filter=`*(this: DialogBase, value: string) = this.mFilter = value
proc `multiSelect=`*(this: FileOpenDialog, value: bool) = this.mMultiSel = value
proc `showHiddenFiles=`*(this: FileOpenDialog, value: bool) = this.mShowHidden = value
proc `newFolderButton=`*(this: FolderBrowserDialog, value: bool) = this.mNewFolBtn = value
proc `showFiles=`*(this: FolderBrowserDialog, value: bool) = this.mShowFiles = value
proc `allowAllFiles=`*(this: DialogBase, value: bool) = this.mAllowAllFiles = value




proc extractFileNames(this: FileOpenDialog, buff: wstring, startPos: int) =
    var offset : int = startPos
    let dirPath = toString(buff[0..startPos - 2]) # First item in buff is the directory path.
    for i in startPos .. MAX_PATH:
        let wc : WCHAR = buff[i]
        if ord(wc) == 0:
            var slice : wstring = buff[offset..i - 1]
            offset = i + 1
            this.mSelFiles.add(fmt"{dirPath}\{slice.toString}")
            if ord(buff[offset]) == 0: break
    this.mSelPath = fmt("{this.mSelFiles[0]}")




proc showDialog*(this: FileOpenDialog, hwnd: HWND = nil): bool {.discardable.} =
    if this.mFilter.len == 0:
        this.mFilter = "All files\0*.*\0"
    else:
        if this.mAllowAllFiles:
            this.mFilter = fmt("{this.mFilter}All files\0*.*\0")
    var ofn: OPENFILENAMEW
    var buffer: wstring = new_wstring(MAX_PATH_NEW)    
    ofn.hwndOwner = hwnd
    ofn.lStructSize = cast[DWORD](sizeof(ofn))
    ofn.lpstrFilter = this.mFilter.toLPWSTR()
    ofn.lpstrFile = &buffer   
    ofn.lpstrInitialDir = (if len(this.mInitDir) > 0: this.mInitDir.toLPWSTR() else: nil)
    ofn.lpstrTitle = this.mTitle.toLPWSTR()
    ofn.nMaxFile = MAX_PATH_NEW
    ofn.nMaxFileTitle = MAX_PATH
    ofn.Flags = OFN_PATHMUSTEXIST or OFN_FILEMUSTEXIST
    if this.mMultiSel: ofn.Flags = ofn.Flags or OFN_ALLOWMULTISELECT or OFN_EXPLORER
    if this.mShowHidden: ofn.Flags = ofn.Flags or OFN_FORCESHOWHIDDEN
    let ret = GetOpenFileNameW(ofn.unsafeAddr)
    if ret > 0:
        if this.mMultiSel:
            this.extractFileNames(buffer, cast[int](ofn.nFileOffset))
            result = true
        else:
           this.mSelPath = buffer.toString
           result = true


proc showDialog*(this: FileSaveDialog, hwnd: HWND = nil): bool =
    var ofn: OPENFILENAMEW
    var buffer: wstring = new_wstring(MAX_PATH)
    ofn.hwndOwner = hwnd
    ofn.lStructSize = cast[DWORD](sizeof(ofn))
    ofn.lpstrFilter = this.mFilter.toLPWSTR()
    ofn.lpstrFile = &buffer
    ofn.lpstrInitialDir = (if len(this.mInitDir) > 0: this.mInitDir.toLPWSTR() else: nil)
    ofn.lpstrTitle = this.mTitle.toLPWSTR()
    ofn.nMaxFile = MAX_PATH
    ofn.nMaxFileTitle = MAX_PATH
    ofn.Flags = OFN_PATHMUSTEXIST or OFN_OVERWRITEPROMPT
    let ret = GetSaveFileNameW(ofn.unsafeAddr)
    if ret != 0:
        this.mFileStart = cast[int](ofn.nFileOffset)
        this.mExtStart = cast[int](ofn.nFileExtension)
        this.mSelPath = buffer.toString
        result = true


proc showDialog*(this: FolderBrowserDialog, hwnd: HWND = nil): bool {.discardable.} =
    var buffer: wstring = new_wstring(MAX_PATH)
    var bi: BROWSEINFOW
    bi.hwndOwner = hwnd;
    bi.lpszTitle = this.mTitle.toLPWSTR()
    bi.ulFlags = BIF_RETURNONLYFSDIRS or BIF_NEWDIALOGSTYLE
    if this.mNewFolBtn: bi.ulFlags = bi.ulFlags or BIF_NONEWFOLDERBUTTON
    if this.mShowFiles: bi.ulFlags = bi.ulFlags or BIF_BROWSEINCLUDEFILES
    var pidl : LPITEMIDLIST = SHBrowseForFolderW(bi.unsafeAddr)
    if pidl != nil:
        if SHGetPathFromIDListW(pidl, &buffer) != 0:
            CoTaskMemFree(pidl)
            this.mSelPath = buffer.toString
            result = true
        else:
            CoTaskMemFree(pidl)



proc setFilter*(this: DialogBase, filterName, ext: string) =
    if this.mFilter.len > 0:
        this.mFilter = fmt("{this.mFilter}{filterName}\0*{ext}\0");
    else:
        this.mFilter = fmt("{filterName}\0*{ext}\0")


proc setFilters*(this: DialogBase, description: string, extSeq: seq[string]) =
    # Adding multiple filters with single discription
    var filterSeq : seq[string]
    filterSeq.add(fmt("{description}\0"))
    let fillCount = extSeq.len - 1
    for i, ext in extSeq:
        if i == fillCount: # It's tha last extension
            filterSeq.add(fmt("*{ext}\0\0"))
        else:
            filterSeq.add(fmt("*{ext};"))

    this.mFilter = filterSeq.join("")