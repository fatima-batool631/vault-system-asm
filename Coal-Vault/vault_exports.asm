.386
.model flat, stdcall
.stack 4096

INCLUDE Irvine32.inc

EXTERN _ValidateEmailFormat : PROC
EXTERN _ValidateEmailDomain : PROC
EXTERN _RegisterAccount     : PROC
EXTERN _LoginEmail          : PROC
EXTERN _LoginPIN            : PROC
EXTERN _LoginBackup         : PROC
EXTERN _AddItem             : PROC
EXTERN _DeleteItem          : PROC
EXTERN _SearchItem          : PROC
EXTERN _AttachTxtFile       : PROC
EXTERN _ReadTxtFile         : PROC
EXTERN _SaveTxtFile         : PROC
EXTERN _EditTxtFile         : PROC
EXTERN _DeleteTxtFile       : PROC
EXTERN _SaveVault           : PROC
EXTERN _LoadVault           : PROC

.code
END