INCLUDE Irvine32.inc

; Constants
EMAIL_SIZE      EQU 64
NAME_SIZE       EQU 64
NOTES_SIZE      EQU 128
PATH_SIZE       EQU 128
MAX_ITEMS       EQU 100
MAX_TXT_FILES   EQU 50

; Structures 
AccountHeader STRUCT
    email           BYTE EMAIL_SIZE  DUP(?)
    pin             DWORD ?
    backupCode      DWORD ?
    itemCount       DWORD ?
    txtCount        DWORD ?
    pinAttempts     DWORD ?
    backupAttempts  DWORD ?
    reserved        BYTE 16 DUP(?)
AccountHeader ENDS

Item STRUCT
    id          DWORD ?
    name        BYTE NAME_SIZE  DUP(?)
    quantity    DWORD ?
    notes       BYTE NOTES_SIZE DUP(?)
Item ENDS

TxtFile STRUCT
    fileID      DWORD ?
    filename    BYTE NAME_SIZE DUP(?)
    path        BYTE PATH_SIZE DUP(?)
    linkedID    DWORD ?
TxtFile ENDS

; Global Memory 
.DATA

PUBLIC header
header          AccountHeader <>

PUBLIC items
items           Item MAX_ITEMS DUP(<>)

PUBLIC txtFiles
txtFiles        TxtFile MAX_TXT_FILES DUP(<>)

PUBLIC dirtyFlag
dirtyFlag       DWORD 0

PUBLIC isAuthenticated
isAuthenticated DWORD 0

PUBLIC currentUser
currentUser     BYTE EMAIL_SIZE DUP(0)

.CODE
END