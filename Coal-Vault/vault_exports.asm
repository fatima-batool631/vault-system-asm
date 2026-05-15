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
PUBLIC _ValidateEmailFormat
PUBLIC _ValidateEmailDomain
PUBLIC _RegisterAccount
PUBLIC _LoginEmail
PUBLIC _LoginPIN
PUBLIC _LoginBackup
PUBLIC _AddItem
PUBLIC _DeleteItem
PUBLIC _SearchItem
PUBLIC _AttachTxtFile
PUBLIC _ReadTxtFile
PUBLIC _SaveTxtFile
PUBLIC _EditTxtFile
PUBLIC _DeleteTxtFile
PUBLIC _SaveVault
PUBLIC _LoadVault
.code
END