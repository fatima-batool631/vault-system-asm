.386
.model flat, stdcall
.stack 4096

EXTERN _header:BYTE
EXTERN _txtFiles:BYTE
EXTERN _dirtyFlag:DWORD
EXTERN _isAuthenticated:DWORD

; Prototypes for kernel32 APIs used in this module
CreateDirectoryA PROTO :PTR, :PTR
CopyFileA       PROTO :PTR, :PTR, :DWORD
DeleteFileA     PROTO :PTR
CreateFileA     PROTO :PTR, :DWORD, :DWORD, :PTR, :DWORD, :DWORD, :PTR
ReadFile        PROTO :DWORD, :PTR, :DWORD, :PTR, :PTR
WriteFile       PROTO :DWORD, :PTR, :DWORD, :PTR, :PTR
CloseHandle     PROTO :DWORD

; Link against kernel32
INCLUDELIB kernel32.lib
TxtFile STRUCT
    fileID      DWORD ?
    filename    BYTE 64 DUP(?)
    path        BYTE 128 DUP(?)
    linkedID    DWORD ?
TxtFile ENDS

AccountHeader STRUCT
    email          BYTE 64 DUP(?)
    pin            DWORD ?
    backupCode     DWORD ?
    itemCount      DWORD ?
    txtCount       DWORD ?
    pinAttempts    DWORD ?
    backupAttempts DWORD ?
    reserved       BYTE 16 DUP(?)
AccountHeader ENDS

MAX_TXT_FILES  EQU 50
TxtFile_SIZE   EQU SIZE TxtFile

.data
    attachDir  BYTE "attachments", 0
    filePrefix BYTE "attachments\file_", 0
    dotTxt     BYTE ".txt", 0
    readBuf    BYTE 4096 DUP(0)
    tempPath   BYTE 200  DUP(0)
    numBuf     BYTE 12   DUP(0)
    bytesXfer  DWORD 0

.code

_IntToStr PROC
    push    ebp
    mov     ebp, esp
    push    eax
    push    ebx
    push    ecx
    push    edx
    push    edi
    mov     eax, [ebp+8]
    mov     edi, [ebp+12]
    xor     ecx, ecx
    mov     ebx, 10
@@div:
    xor     edx, edx
    div     ebx
    push    edx
    inc     ecx
    test    eax, eax
    jnz     @@div
@@store:
    pop     edx
    add     dl, '0'
    mov     [edi], dl
    inc     edi
    loop    @@store
    mov     BYTE PTR [edi], 0
    pop     edi
    pop     edx
    pop     ecx
    pop     ebx
    pop     eax
    pop     ebp
    ret     8
_IntToStr ENDP

_StrCopyN PROC
    push    ebp
    mov     ebp, esp
    push    esi
    push    edi
    push    ecx
    mov     edi, [ebp+8]
    mov     esi, [ebp+12]
    mov     ecx, [ebp+16]
    cld
@@lp:
    lodsb
    stosb
    test    al, al
    jz      @@done
    loop    @@lp
    mov     BYTE PTR [edi], 0
@@done:
    pop     ecx
    pop     edi
    pop     esi
    pop     ebp
    ret     12
_StrCopyN ENDP

_FindTxtByID PROC
    push    ebp
    mov     ebp, esp
    push    ecx
    push    edx
    mov     edx, [ebp+8]
    lea     esi, _txtFiles
    lea     eax, _header
    mov     ecx, (AccountHeader PTR [eax]).txtCount
    xor     eax, eax
@@loop:
    cmp     eax, ecx
    jge     @@miss
    cmp     (TxtFile PTR [esi]).fileID, edx
    je      @@hit
    add     esi, TxtFile_SIZE
    inc     eax
    jmp     @@loop
@@hit:
    mov     eax, esi
    jmp     @@done
@@miss:
    xor     eax, eax
@@done:
    pop     edx
    pop     ecx
    pop     ebp
    ret     4
_FindTxtByID ENDP

PUBLIC _AttachTxtFile
_AttachTxtFile PROC
    push    ebp
    mov     ebp, esp
    push    ebx
    push    esi
    push    edi
    push    ecx
    push    edx

    cmp     _isAuthenticated, 0
    je      @@fail

    lea     eax, _header
    mov     edx, (AccountHeader PTR [eax]).txtCount
    cmp     edx, MAX_TXT_FILES
    jge     @@fail

    invoke  CreateDirectoryA, OFFSET attachDir, 0

    lea     edi, tempPath
    mov     ecx, 200
    xor     al, al
    cld
    rep     stosb

    lea     edi, tempPath
    lea     esi, filePrefix
@@cpPfx:
    lodsb
    stosb
    test    al, al
    jnz     @@cpPfx
    dec     edi

    lea     eax, _header
    mov     edx, (AccountHeader PTR [eax]).txtCount
    push    edx
    push    OFFSET numBuf
    call    _IntToStr

    lea     esi, numBuf
@@cpNum:
    lodsb
    stosb
    test    al, al
    jnz     @@cpNum
    dec     edi

    lea     esi, dotTxt
@@cpExt:
    lodsb
    stosb
    test    al, al
    jnz     @@cpExt

    invoke  CopyFileA, [ebp+8], OFFSET tempPath, 0
    test    eax, eax
    jz      @@fail

    lea     eax, _header
    mov     edx, (AccountHeader PTR [eax]).txtCount
    mov     eax, TxtFile_SIZE
    mul     edx
    lea     esi, _txtFiles
    add     esi, eax

    lea     eax, _header
    mov     edx, (AccountHeader PTR [eax]).txtCount
    inc     edx
    mov     (TxtFile PTR [esi]).fileID, edx

    push    64
    push    [ebp+12]
    lea     eax, (TxtFile PTR [esi]).filename
    push    eax
    call    _StrCopyN

    push    200
    push    OFFSET tempPath
    lea     eax, (TxtFile PTR [esi]).path
    push    eax
    call    _StrCopyN

    mov     eax, [ebp+16]
    mov     (TxtFile PTR [esi]).linkedID, eax

    lea     eax, _header
    mov     edx, (AccountHeader PTR [eax]).txtCount
    inc     edx
    mov     (AccountHeader PTR [eax]).txtCount, edx

    mov     _dirtyFlag, 1
    mov     eax, 1
    jmp     @@done
@@fail:
    xor     eax, eax
@@done:
    pop     edx
    pop     ecx
    pop     edi
    pop     esi
    pop     ebx
    pop     ebp
    ret     12
_AttachTxtFile ENDP

PUBLIC _ReadTxtFile
_ReadTxtFile PROC
    push    ebp
    mov     ebp, esp
    push    ebx

    cmp     _isAuthenticated, 0
    je      @@fail

    push    [ebp+8]
    call    _FindTxtByID
    test    eax, eax
    jz      @@fail
    mov     esi, eax

    lea     eax, (TxtFile PTR [esi]).path
    invoke  CreateFileA, eax, 80000000h, 0, 0, 3, 80h, 0
    mov     ebx, eax
    cmp     ebx, 0FFFFFFFFh
    je      @@fail

    invoke  ReadFile, ebx, OFFSET readBuf, 4096, OFFSET bytesXfer, 0
    invoke  CloseHandle, ebx
    mov     eax, OFFSET readBuf
    jmp     @@done
@@fail:
    xor     eax, eax
@@done:
    pop     ebx
    pop     ebp
    ret     4
_ReadTxtFile ENDP

PUBLIC _SaveTxtFile
_SaveTxtFile PROC
    push    ebp
    mov     ebp, esp
    push    ebx
    push    ecx
    push    edi

    cmp     _isAuthenticated, 0
    je      @@fail

    push    [ebp+8]
    call    _FindTxtByID
    test    eax, eax
    jz      @@fail
    mov     esi, eax

    mov     edi, [ebp+12]
    xor     ecx, ecx
@@len:
    cmp     BYTE PTR [edi], 0
    je      @@lenDone
    inc     edi
    inc     ecx
    jmp     @@len
@@lenDone:

    lea     eax, (TxtFile PTR [esi]).path
    invoke  CreateFileA, eax, 40000000h, 0, 0, 2, 80h, 0
    mov     ebx, eax
    cmp     ebx, 0FFFFFFFFh
    je      @@fail

    invoke  WriteFile, ebx, [ebp+12], ecx, OFFSET bytesXfer, 0
    invoke  CloseHandle, ebx
    mov     _dirtyFlag, 1
    mov     eax, 1
    jmp     @@done
@@fail:
    xor     eax, eax
@@done:
    pop     edi
    pop     ecx
    pop     ebx
    pop     ebp
    ret     8
_SaveTxtFile ENDP

PUBLIC _EditTxtFile
_EditTxtFile PROC
    push    ebp
    mov     ebp, esp
    push    ebx
    push    ecx

    cmp     _isAuthenticated, 0
    je      @@fail

    push    [ebp+8]
    call    _FindTxtByID
    test    eax, eax
    jz      @@fail
    mov     esi, eax

    mov     edx, [ebp+12]
    test    edx, edx
    jz      @@skipName
    push    64
    push    edx
    lea     eax, (TxtFile PTR [esi]).filename
    push    eax
    call    _StrCopyN
@@skipName:

    mov     edx, [ebp+16]
    test    edx, edx
    jz      @@skipPath
    invoke  CopyFileA, edx, OFFSET tempPath, 0
    test    eax, eax
    jz      @@fail
    push    200
    push    OFFSET tempPath
    lea     eax, (TxtFile PTR [esi]).path
    push    eax
    call    _StrCopyN
@@skipPath:

    mov     eax, [ebp+20]
    test    eax, eax
    jz      @@skipLink
    mov     (TxtFile PTR [esi]).linkedID, eax
@@skipLink:

    mov     _dirtyFlag, 1
    mov     eax, 1
    jmp     @@done
@@fail:
    xor     eax, eax
@@done:
    pop     ecx
    pop     ebx
    pop     ebp
    ret     16
_EditTxtFile ENDP

PUBLIC _DeleteTxtFile
_DeleteTxtFile PROC
    push    ebp
    mov     ebp, esp
    push    ebx
    push    ecx
    push    edx

    cmp     _isAuthenticated, 0
    je      @@fail

    push    [ebp+8]
    call    _FindTxtByID
    test    eax, eax
    jz      @@fail
    mov     esi, eax

    lea     eax, (TxtFile PTR [esi]).path
    invoke  DeleteFileA, eax

    lea     edx, _txtFiles
    mov     eax, esi
    sub     eax, edx
    xor     edx, edx
    mov     ebx, TxtFile_SIZE
    div     ebx
    mov     edx, eax

    lea     eax, _header
    mov     ecx, (AccountHeader PTR [eax]).txtCount
    dec     ecx
    sub     ecx, edx
    jz      @@skip

    mov     edi, esi
    lea     esi, [edi + TxtFile_SIZE]
    mov     eax, ecx
    mov     ecx, TxtFile_SIZE
    mul     ecx
    mov     ecx, eax
    cld
    rep     movsb

@@skip:
    lea     eax, _header
    dec     (AccountHeader PTR [eax]).txtCount
    mov     _dirtyFlag, 1
    mov     eax, 1
    jmp     @@done
@@fail:
    xor     eax, eax
@@done:
    pop     edx
    pop     ecx
    pop     ebx
    pop     ebp
    ret     4
_DeleteTxtFile ENDP

END