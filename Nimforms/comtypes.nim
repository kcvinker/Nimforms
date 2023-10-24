
# Created on : 2023-Oct18 11:22 PM
# Author : Vinod
# Description : Com helper for nimforms
const
    COINITBASE_MULTITHREADED* = 0x0
    COINIT_MULTITHREADED* = COINITBASE_MULTITHREADED

when compileOption("threads"):
    discard CoInitializeEx(nil, COINIT_MULTITHREADED)
else:
    discard CoInitialize(nil)

when defined(notrace):
    const hasTraceTable = false
else:
    const hasTraceTable = true

proc `&`*[T](x: var T): ptr T {.inline.} =
  ## Use `&` like it in C/C++ to get address for anything.
  result = x.addr

proc `&`*(x: object): ptr type(x) {.importc: "&", nodecl.}

type
    GUID* {.pure.} = object
        Data1: int32
        Data2: uint16
        Data3: uint16
        Data4: array[8, uint8]
    LPGUID = ptr GUID
    LPCGUID = ptr GUID

    IID = GUID
    REFIID = ptr IID
    REFGUID* = ptr GUID

    COMError = object of Exception
        hresult: HRESULT
    COMException = object of COMError
    VariantConversionError = object of ValueError
    SomeFloat = float | float32 | float64 # SomeReal is deprecated in devel



# make these const store in global scope to avoid repeat init in every proc
template DEFINE_GUID(data1: int32, data2: uint16, data3: uint16, data4: array[8, uint8]): GUID = GUID(Data1: data1, Data2: data2, Data3: data3, Data4: data4)

const
    IID_IEnumVARIANT = DEFINE_GUID(0x00020404'i32, 0x0000, 0x0000, [0xc0'u8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x46])
    IID_IClassFactory = DEFINE_GUID(0x00000001'i32, 0x0000, 0x0000, [0xc0'u8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x46])
    IID_IDispatch = DEFINE_GUID(0x00020400'i32, 0x0000, 0x0000, [0xc0'u8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x46])
    IID_ITypeInfo = DEFINE_GUID(0x00020401'i32, 0x0000, 0x0000, [0xc0'u8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x46])

    GUID_NULL = DEFINE_GUID(0x00000000'i32, 0x0000, 0x0000, [0x00'u8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
    IID_NULL = GUID_NULL
    CLSID_NULL = GUID_NULL


discard &IID_NULL
discard &IID_IEnumVARIANT
discard &IID_IClassFactory
discard &IID_IDispatch
discard &IID_ITypeInfo

type
    LCID = ULONG
    DISPID* = LONG
    MEMBERID* = DISPID
    OLECHAR* = WCHAR
    LPOLESTR* = ptr OLECHAR
    LPCOLESTR* = ptr OLECHAR
    TYPEKIND* = int32
    HREFTYPE* = DWORD
    VARTYPE* = uint16
    DESCKIND* = int32
    SCODE* = LONG
    LONGLONG* = int64
    FLOAT* = float32
    DOUBLE* = float64
    VARIANT_BOOL* = int16
    DATE* = float64
    BSTR* = distinct ptr OLECHAR
    CHAR* = char
    ULONGLONG* = uint64
    CALLCONV* = int32
    FUNCKIND* = int32
    INVOKEKIND* = int32
    VARKIND* = int32
    SYSKIND* = int32


    SAFEARRAYBOUND* {.pure.} = object
        cElements*: ULONG
        lLbound*: LONG
    LPSAFEARRAYBOUND* = ptr SAFEARRAYBOUND

    ARRAYDESC* {.pure.} = object
        tdescElem*: TYPEDESC
        cDims*: USHORT
        rgbounds*: array[1, SAFEARRAYBOUND]

    TYPEDESC_UNION1* {.pure, union.} = object
        lptdesc*: ptr TYPEDESC
        lpadesc*: ptr ARRAYDESC
        hreftype*: HREFTYPE

    TYPEDESC* {.pure.} = object
        union1*: TYPEDESC_UNION1
        vt*: VARTYPE

    IDLDESC* {.pure.} = object
        dwReserved*: ULONG_PTR
        wIDLFlags*: USHORT

    TYPEATTR* {.pure.} = object
        guid*: GUID
        lcid*: LCID
        dwReserved*: DWORD
        memidConstructor*: MEMBERID
        memidDestructor*: MEMBERID
        lpstrSchema*: LPOLESTR
        cbSizeInstance*: ULONG
        typekind*: TYPEKIND
        cFuncs*: WORD
        cVars*: WORD
        cImplTypes*: WORD
        cbSizeVft*: WORD
        cbAlignment*: WORD
        wTypeFlags*: WORD
        wMajorVerNum*: WORD
        wMinorVerNum*: WORD
        tdescAlias*: TYPEDESC
        idldescType*: IDLDESC

    IUnknown* {.pure.} = object
        lpVtbl*: ptr IUnknownVtbl

    IUnknownVtbl* {.pure, inheritable.} = object
        QueryInterface*: proc(self: ptr IUnknown, riid: REFIID, ppvObject: ptr pointer): HRESULT {.stdcall.}
        AddRef*: proc(self: ptr IUnknown): ULONG {.stdcall.}
        Release*: proc(self: ptr IUnknown): ULONG {.stdcall.}
    LPUNKNOWN* = ptr IUnknown

    IRecordInfo* {.pure.} = object
        lpVtbl*: ptr IRecordInfoVtbl

    IRecordInfoVtbl* {.pure, inheritable.} = object of IUnknownVtbl
        RecordInit*: proc(self: ptr IRecordInfo, pvNew: PVOID): HRESULT {.stdcall.}
        RecordClear*: proc(self: ptr IRecordInfo, pvExisting: PVOID): HRESULT {.stdcall.}
        RecordCopy*: proc(self: ptr IRecordInfo, pvExisting: PVOID, pvNew: PVOID): HRESULT {.stdcall.}
        GetGuid*: proc(self: ptr IRecordInfo, pguid: ptr GUID): HRESULT {.stdcall.}
        GetName*: proc(self: ptr IRecordInfo, pbstrName: ptr BSTR): HRESULT {.stdcall.}
        GetSize*: proc(self: ptr IRecordInfo, pcbSize: ptr ULONG): HRESULT {.stdcall.}
        GetTypeInfo*: proc(self: ptr IRecordInfo, ppTypeInfo: ptr ptr ITypeInfo): HRESULT {.stdcall.}
        GetField*: proc(self: ptr IRecordInfo, pvData: PVOID, szFieldName: LPCOLESTR, pvarField: ptr VARIANT): HRESULT {.stdcall.}
        GetFieldNoCopy*: proc(self: ptr IRecordInfo, pvData: PVOID, szFieldName: LPCOLESTR, pvarField: ptr VARIANT, ppvDataCArray: ptr PVOID): HRESULT {.stdcall.}
        PutField*: proc(self: ptr IRecordInfo, wFlags: ULONG, pvData: PVOID, szFieldName: LPCOLESTR, pvarField: ptr VARIANT): HRESULT {.stdcall.}
        PutFieldNoCopy*: proc(self: ptr IRecordInfo, wFlags: ULONG, pvData: PVOID, szFieldName: LPCOLESTR, pvarField: ptr VARIANT): HRESULT {.stdcall.}
        GetFieldNames*: proc(self: ptr IRecordInfo, pcNames: ptr ULONG, rgBstrNames: ptr BSTR): HRESULT {.stdcall.}
        IsMatchingType*: proc(self: ptr IRecordInfo, pRecordInfo: ptr IRecordInfo): BOOL {.stdcall.}
        RecordCreate*: proc(self: ptr IRecordInfo): PVOID {.stdcall.}
        RecordCreateCopy*: proc(self: ptr IRecordInfo, pvSource: PVOID, ppvDest: ptr PVOID): HRESULT {.stdcall.}
        RecordDestroy*: proc(self: ptr IRecordInfo, pvRecord: PVOID): HRESULT {.stdcall.}

    ITypeInfo* {.pure.} = object
        lpVtbl*: ptr ITypeInfoVtbl

    CY_STRUCT1* {.pure.} = object
        Lo*: int32
        Hi*: int32

    CY* {.pure, union.} = object
        struct1*: CY_STRUCT1
        int64*: LONGLONG
    LPCY* = ptr CY

    SAFEARRAY* {.pure.} = object
        cDims*: USHORT
        fFeatures*: USHORT
        cbElements*: ULONG
        cLocks*: ULONG
        pvData*: PVOID
        rgsabound*: array[1, SAFEARRAYBOUND]

    DECIMAL_UNION1_STRUCT1* {.pure.} = object
        scale*: BYTE
        sign*: BYTE

    DECIMAL_UNION1* {.pure, union.} = object
        struct1*: DECIMAL_UNION1_STRUCT1
        signscale*: USHORT

    DECIMAL_UNION2_STRUCT1* {.pure.} = object
        Lo32*: ULONG
        Mid32*: ULONG

    DECIMAL_UNION2* {.pure, union.} = object
        struct1*: DECIMAL_UNION2_STRUCT1
        Lo64*: ULONGLONG

    DECIMAL* {.pure.} = object
        wReserved*: USHORT
        union1*: DECIMAL_UNION1
        Hi32*: ULONG
        union2*: DECIMAL_UNION2
    LPDECIMAL* = ptr DECIMAL

    VARIANT_UNION1_STRUCT1_UNION1_STRUCT1* {.pure.} = object
        pvRecord*: PVOID
        pRecInfo*: ptr IRecordInfo

    VARIANT_UNION1_STRUCT1_UNION1* {.pure, union.} = object
        llVal*: LONGLONG
        lVal*: LONG
        bVal*: BYTE
        iVal*: SHORT
        fltVal*: FLOAT
        dblVal*: DOUBLE
        boolVal*: VARIANT_BOOL
        scode*: SCODE
        cyVal*: CY
        date*: DATE
        bstrVal*: BSTR
        punkVal*: ptr IUnknown
        pdispVal*: ptr IDispatch
        parray*: ptr SAFEARRAY
        pbVal*: ptr BYTE
        piVal*: ptr SHORT
        plVal*: ptr LONG
        pllVal*: ptr LONGLONG
        pfltVal*: ptr FLOAT
        pdblVal*: ptr DOUBLE
        pboolVal*: ptr VARIANT_BOOL
        pscode*: ptr SCODE
        pcyVal*: ptr CY
        pdate*: ptr DATE
        pbstrVal*: ptr BSTR
        ppunkVal*: ptr ptr IUnknown
        ppdispVal*: ptr ptr IDispatch
        pparray*: ptr ptr SAFEARRAY
        pvarVal*: ptr VARIANT
        byref*: PVOID
        cVal*: CHAR
        uiVal*: USHORT
        ulVal*: ULONG
        ullVal*: ULONGLONG
        intVal*: INT
        uintVal*: UINT
        pdecVal*: ptr DECIMAL
        pcVal*: cstring
        puiVal*: ptr USHORT
        pulVal*: ptr ULONG
        pullVal*: ptr ULONGLONG
        pintVal*: ptr INT
        puintVal*: ptr UINT
        struct1*: VARIANT_UNION1_STRUCT1_UNION1_STRUCT1

    VARIANT_UNION1_STRUCT1* {.pure.} = object
        vt*: VARTYPE
        wReserved1*: WORD
        wReserved2*: WORD
        wReserved3*: WORD
        union1*: VARIANT_UNION1_STRUCT1_UNION1

    VARIANT_UNION1* {.pure, union.} = object
        struct1*: VARIANT_UNION1_STRUCT1
        decVal*: DECIMAL

    VARIANT* {.pure.} = object
        union1*: VARIANT_UNION1

    VARIANTARG* = VARIANT

    PARAMDESCEX* {.pure.} = object
        cBytes*: ULONG
        varDefaultValue*: VARIANTARG
    LPPARAMDESCEX* = ptr PARAMDESCEX

    PARAMDESC* {.pure.} = object
        pparamdescex*: LPPARAMDESCEX
        wParamFlags*: USHORT

    ELEMDESC_UNION1* {.pure, union.} = object
        idldesc*: IDLDESC
        paramdesc*: PARAMDESC

    ELEMDESC* {.pure.} = object
        tdesc*: TYPEDESC
        union1*: ELEMDESC_UNION1

    FUNCDESC* {.pure.} = object
        memid*: MEMBERID
        lprgscode*: ptr SCODE
        lprgelemdescParam*: ptr ELEMDESC
        funckind*: FUNCKIND
        invkind*: INVOKEKIND
        callconv*: CALLCONV
        cParams*: SHORT
        cParamsOpt*: SHORT
        oVft*: SHORT
        cScodes*: SHORT
        elemdescFunc*: ELEMDESC
        wFuncFlags*: WORD

    VARDESC_UNION1* {.pure, union.} = object
        oInst*: ULONG
        lpvarValue*: ptr VARIANT

    VARDESC* {.pure.} = object
        memid*: MEMBERID
        lpstrSchema*: LPOLESTR
        union1*: VARDESC_UNION1
        elemdescVar*: ELEMDESC
        wVarFlags*: WORD
        varkind*: VARKIND

    BINDPTR* {.pure, union.} = object
        lpfuncdesc*: ptr FUNCDESC
        lpvardesc*: ptr VARDESC
        lptcomp*: ptr ITypeComp

    ITypeComp* {.pure.} = object
        lpVtbl*: ptr ITypeCompVtbl

    ITypeCompVtbl* {.pure, inheritable.} = object of IUnknownVtbl
        Bind*: proc(self: ptr ITypeComp, szName: LPOLESTR, lHashVal: ULONG, wFlags: WORD, ppTInfo: ptr ptr ITypeInfo, pDescKind: ptr DESCKIND, pBindPtr: ptr BINDPTR): HRESULT {.stdcall.}
        BindType*: proc(self: ptr ITypeComp, szName: LPOLESTR, lHashVal: ULONG, ppTInfo: ptr ptr ITypeInfo, ppTComp: ptr ptr ITypeComp): HRESULT {.stdcall.}

    DISPPARAMS* {.pure.} = object
        rgvarg*: ptr VARIANTARG
        rgdispidNamedArgs*: ptr DISPID
        cArgs*: UINT
        cNamedArgs*: UINT

    EXCEPINFO* {.pure.} = object
        wCode*: WORD
        wReserved*: WORD
        bstrSource*: BSTR
        bstrDescription*: BSTR
        bstrHelpFile*: BSTR
        dwHelpContext*: DWORD
        pvReserved*: PVOID
        pfnDeferredFillIn*: proc(P1: ptr EXCEPINFO): HRESULT {.stdcall.}
        scode*: SCODE

    ITypeLib* {.pure.} = object
        lpVtbl*: ptr ITypeLibVtbl

    TLIBATTR* {.pure.} = object
        guid*: GUID
        lcid*: LCID
        syskind*: SYSKIND
        wMajorVerNum*: WORD
        wMinorVerNum*: WORD
        wLibFlags*: WORD

    ITypeLibVtbl* {.pure, inheritable.} = object of IUnknownVtbl
        GetTypeInfoCount*: proc(self: ptr ITypeLib): UINT {.stdcall.}
        GetTypeInfo*: proc(self: ptr ITypeLib, index: UINT, ppTInfo: ptr ptr ITypeInfo): HRESULT {.stdcall.}
        GetTypeInfoType*: proc(self: ptr ITypeLib, index: UINT, pTKind: ptr TYPEKIND): HRESULT {.stdcall.}
        GetTypeInfoOfGuid*: proc(self: ptr ITypeLib, guid: REFGUID, ppTinfo: ptr ptr ITypeInfo): HRESULT {.stdcall.}
        GetLibAttr*: proc(self: ptr ITypeLib, ppTLibAttr: ptr ptr TLIBATTR): HRESULT {.stdcall.}
        GetTypeComp*: proc(self: ptr ITypeLib, ppTComp: ptr ptr ITypeComp): HRESULT {.stdcall.}
        GetDocumentation*: proc(self: ptr ITypeLib, index: INT, pBstrName: ptr BSTR, pBstrDocString: ptr BSTR, pdwHelpContext: ptr DWORD, pBstrHelpFile: ptr BSTR): HRESULT {.stdcall.}
        IsName*: proc(self: ptr ITypeLib, szNameBuf: LPOLESTR, lHashVal: ULONG, pfName: ptr BOOL): HRESULT {.stdcall.}
        FindName*: proc(self: ptr ITypeLib, szNameBuf: LPOLESTR, lHashVal: ULONG, ppTInfo: ptr ptr ITypeInfo, rgMemId: ptr MEMBERID, pcFound: ptr USHORT): HRESULT {.stdcall.}
        ReleaseTLibAttr*: proc(self: ptr ITypeLib, pTLibAttr: ptr TLIBATTR): void {.stdcall.}

    ITypeInfoVtbl* {.pure, inheritable.} = object of IUnknownVtbl
        GetTypeAttr*: proc(self: ptr ITypeInfo, ppTypeAttr: ptr ptr TYPEATTR): HRESULT {.stdcall.}
        GetTypeComp*: proc(self: ptr ITypeInfo, ppTComp: ptr ptr ITypeComp): HRESULT {.stdcall.}
        GetFuncDesc*: proc(self: ptr ITypeInfo, index: UINT, ppFuncDesc: ptr ptr FUNCDESC): HRESULT {.stdcall.}
        GetVarDesc*: proc(self: ptr ITypeInfo, index: UINT, ppVarDesc: ptr ptr VARDESC): HRESULT {.stdcall.}
        GetNames*: proc(self: ptr ITypeInfo, memid: MEMBERID, rgBstrNames: ptr BSTR, cMaxNames: UINT, pcNames: ptr UINT): HRESULT {.stdcall.}
        GetRefTypeOfImplType*: proc(self: ptr ITypeInfo, index: UINT, pRefType: ptr HREFTYPE): HRESULT {.stdcall.}
        GetImplTypeFlags*: proc(self: ptr ITypeInfo, index: UINT, pImplTypeFlags: ptr INT): HRESULT {.stdcall.}
        GetIDsOfNames*: proc(self: ptr ITypeInfo, rgszNames: ptr LPOLESTR, cNames: UINT, pMemId: ptr MEMBERID): HRESULT {.stdcall.}
        Invoke*: proc(self: ptr ITypeInfo, pvInstance: PVOID, memid: MEMBERID, wFlags: WORD, pDispParams: ptr DISPPARAMS, pVarResult: ptr VARIANT, pExcepInfo: ptr EXCEPINFO, puArgErr: ptr UINT): HRESULT {.stdcall.}
        GetDocumentation*: proc(self: ptr ITypeInfo, memid: MEMBERID, pBstrName: ptr BSTR, pBstrDocString: ptr BSTR, pdwHelpContext: ptr DWORD, pBstrHelpFile: ptr BSTR): HRESULT {.stdcall.}
        GetDllEntry*: proc(self: ptr ITypeInfo, memid: MEMBERID, invKind: INVOKEKIND, pBstrDllName: ptr BSTR, pBstrName: ptr BSTR, pwOrdinal: ptr WORD): HRESULT {.stdcall.}
        GetRefTypeInfo*: proc(self: ptr ITypeInfo, hRefType: HREFTYPE, ppTInfo: ptr ptr ITypeInfo): HRESULT {.stdcall.}
        AddressOfMember*: proc(self: ptr ITypeInfo, memid: MEMBERID, invKind: INVOKEKIND, ppv: ptr PVOID): HRESULT {.stdcall.}
        CreateInstance*: proc(self: ptr ITypeInfo, pUnkOuter: ptr IUnknown, riid: REFIID, ppvObj: ptr PVOID): HRESULT {.stdcall.}
        GetMops*: proc(self: ptr ITypeInfo, memid: MEMBERID, pBstrMops: ptr BSTR): HRESULT {.stdcall.}
        GetContainingTypeLib*: proc(self: ptr ITypeInfo, ppTLib: ptr ptr ITypeLib, pIndex: ptr UINT): HRESULT {.stdcall.}
        ReleaseTypeAttr*: proc(self: ptr ITypeInfo, pTypeAttr: ptr TYPEATTR): void {.stdcall.}
        ReleaseFuncDesc*: proc(self: ptr ITypeInfo, pFuncDesc: ptr FUNCDESC): void {.stdcall.}
        ReleaseVarDesc*: proc(self: ptr ITypeInfo, pVarDesc: ptr VARDESC): void {.stdcall.}

    IDispatch* {.pure.} = object
        lpVtbl*: ptr IDispatchVtbl

    IDispatchVtbl* {.pure, inheritable.} = object of IUnknownVtbl
        GetTypeInfoCount*: proc(self: ptr IDispatch, pctinfo: ptr UINT): HRESULT {.stdcall.}
        GetTypeInfo*: proc(self: ptr IDispatch, iTInfo: UINT, lcid: LCID, ppTInfo: ptr ptr ITypeInfo): HRESULT {.stdcall.}
        GetIDsOfNames*: proc(self: ptr IDispatch, riid: REFIID, rgszNames: ptr LPOLESTR, cNames: UINT, lcid: LCID, rgDispId: ptr DISPID): HRESULT {.stdcall.}
        Invoke*: proc(self: ptr IDispatch, dispIdMember: DISPID, riid: REFIID, lcid: LCID, wFlags: WORD, pDispParams: ptr DISPPARAMS, pVarResult: ptr VARIANT, pExcepInfo: ptr EXCEPINFO, puArgErr: ptr UINT): HRESULT {.stdcall.}

    com = ref object
        disp: ptr IDispatch

    variant = ref object
        raw: VARIANT

    COMArray = seq[variant]
    COMArray1D = seq[variant]
    COMArray2D = seq[seq[variant]]
    COMArray3D = seq[seq[seq[variant]]]

    PWstring* = ptr object
        size: uint32
        data: UncheckedArray[WCHAR]

    Wstring* = ref object
        size: uint32
        data: UncheckedArray[WCHAR]


#====================================================PROCS==============================
proc FormatMessageW*(dwFlags: DWORD, lpSource: LPCVOID, dwMessageId: DWORD, dwLanguageId: DWORD,
                        lpBuffer: LPWSTR, nSize: DWORD, Arguments: ptr va_list):
                                DWORD {.stdcall, dynlib: "kernel32", importc.}

proc length(x: Wstring|PWstring): int {.inline.} =
    result = (x[].size shr 1).int

proc `length=`(x: Wstring|PWstring, L: Natural) {.inline.} =
    x[].size = L.uint32 shl 1

proc wstringBuffer(L: Natural, alloc: bool): pointer =
    # make sure there are extra null after wstring
    let size = L * 2 + sizeof(int32) + 4
    if alloc:
        result = alloc0(size)
    else:
        var ws: Wstring
        unsafeNew(ws, size)
        result = cast[pointer](ws)

    cast[Wstring](result).length = L

proc allocWString*(s: cstring|string|Wstring): PWstring =
    ## Create a wstring buffer, need to be dealloc.
    ## Exists only for optimization purposes.
    when s is cstring|string:
        result = cast[PWstring](`UTF8->wstring`(&s, s.len, alloc=true))
    elif s is Wstring:
        result = cast[PWstring](`UNICODE->wstring`(&s, s.len, alloc=true))
    # elif s is mstring:
    #     result = cast[PWstring](`ANSI->wstring`(&s, s.len, alloc=true))

proc allocWString*(L: Natural): PWstring =
    ## Create a wstring buffer, need to be dealloc.
    ## Exists only for optimization purposes.
    result = cast[PWstring](wstringBuffer(L, alloc=true))

proc notNil[T](x: T): bool =
  when T is BSTR: not cast[pointer](x).isNil
  else: not x.isNil

proc free(x: pointer) =
  if not x.isNil:
    system.dealloc(x)

when hasTraceTable:
  import tables

  var
    comTrace {.threadvar.}: TableRef[pointer, bool]
    varTrace {.threadvar.}: TableRef[pointer, bool]

var hresult {.threadvar.}: HRESULT

template ERR(x: HRESULT): bool =
    hresult = x
    hresult.FAILED()

template OK(x: HRESULT): bool =
    hresult = x
    hresult.SUCCEEDED()

proc newCOMError(msg: string, hr: HRESULT = hresult): ref COMError =
    result = newException(COMError, msg)
    result.hresult = hr

proc newCOMException(msg: string, hr: HRESULT = hresult): ref COMException =
    result = newException(COMException, msg)
    result.hresult = hr

proc getCurrentCOMError*(): ref COMError {.inline.} =
    result = (ref COMError)(getCurrentException())

template MAKELANGID*(p: untyped, s: untyped): WORD = s.WORD shl 10 or p.WORD

proc desc*(e: ref COMError): string =
    var buffer = allocWString(4096)
    defer: dealloc(buffer)

    discard FormatMessageW(FORMAT_MESSAGE_FROM_SYSTEM or FORMAT_MESSAGE_IGNORE_INSERTS,
                nil,
                DWORD e.hresult,
                DWORD MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
                cast[LPWSTR](&buffer.data[0]), 4096, nil)
    result = wcharArrayToString(&buffer.data[0])

# proc del*(x: com) =
#     when hasTraceTable:
#         comTrace.del(cast[pointer](x))

#     if x.notNil and x.disp.notNil:
#         x.disp.Release()
#         x.disp = nil

template init(x): untyped =
    new(x, del)

    when hasTraceTable:
        if comTrace.isNil: comTrace = newTable[pointer, bool]()
        if varTrace.isNil: varTrace = newTable[pointer, bool]()

        when x.type is variant:
            varTrace[cast[pointer](x)] = true

        elif x.type is com:
            comTrace[cast[pointer](x)] = true

when hasTraceTable:
    proc COM_FullRelease*() =
        ## Clean up all COM objects and variants.
        ##
        ## Usually, we let garbage collector to release the objects.
        ## However, sometimes the garbage collector can't release all the object even we call GC_fullCollect().
        ## Some object will create a endless process in this situation. (for example: Excel.Application).
        ## So we need this function.
        ##
        ## Use -d:notrace to disable this function.

        for k, v in varTrace: del cast[variant](k)
        for k, v in comTrace: del cast[com](k)
        varTrace.clear
        comTrace.clear
