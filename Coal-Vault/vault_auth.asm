INCLUDE Irvine32.inc

EXTERN ValidateEmailFormat:PROC
EXTERN ValidateEmailDomain:PROC

PUBLIC _RegisterAccount
PUBLIC _LoginEmail
PUBLIC _LoginPIN
PUBLIC _LoginBackup

; ─────────────────────────────────────────
; vault_auth.asm
; Handles registration and login logic
; ─────────────────────────────────────────

.data
    pinAttempts  DWORD 0
    backAttempts DWORD 0

.code

; ─────────────────────────────────────────
; _RegisterAccount
; INPUT:  ESI = email ptr, EDI = pin value, EBX = ptr to header
; OUTPUT: EAX = backupCode if success
;         EAX = 1 → invalid format
;         EAX = 2 → invalid domain
;         EAX = 3 → invalid PIN
; ─────────────────────────────────────────
_RegisterAccount PROC
    push esi
    push edi
    push ebx
    push ecx

    ; validate format
    call ValidateEmailFormat
    cmp  eax, 0
    jne  fmt_ok
    mov  eax, 1
    jmp  reg_done
fmt_ok:

    ; validate domain
    call ValidateEmailDomain
    cmp  eax, 0
    jne  dom_ok
    mov  eax, 2
    jmp  reg_done
dom_ok:

    ; validate PIN — count digits (4 to 6)
    mov  eax, edi           ; PIN value
    mov  ecx, 0             ; digit counter

count_digits:
    cmp  eax, 0
    je   digits_done
    mov  edx, 0
    mov  ebx, 10
    div  ebx               ; EAX = EAX/10, EDX = remainder
    inc  ecx
    jmp  count_digits

digits_done:
    cmp  ecx, 4
    jl   pin_invalid
    cmp  ecx, 6
    jg   pin_invalid
    jmp  pin_ok

pin_invalid:
    mov  eax, 3
    jmp  reg_done

pin_ok:
    ; generate backup code using RDTSC
    rdtsc
    mov  eax, eax           ; lower 32 bits = backup code

reg_done:
    pop  ecx
    pop  ebx
    pop  edi
    pop  esi
    ret
_RegisterAccount ENDP

; ─────────────────────────────────────────
; _LoginEmail
; INPUT:  ESI = input email, EDI = stored email
; OUTPUT: EAX = 1 match, 0 no match, -1 locked
; ─────────────────────────────────────────
_LoginEmail PROC
    push esi
    push edi
    push ecx

    ; check if locked
    cmp  pinAttempts, 3
    jge  email_locked

    ; compare email byte by byte
    mov  ecx, 64

compare_email:
    mov  al, [esi]
    mov  bl, [edi]
    cmp  al, bl
    jne  email_wrong
    cmp  al, 0
    je   email_match
    inc  esi
    inc  edi
    loop compare_email

email_match:
    mov  eax, 1
    jmp  email_done

email_wrong:
    inc  pinAttempts
    cmp  pinAttempts, 3
    jge  email_locked
    mov  eax, 0
    jmp  email_done

email_locked:
    mov  eax, -1

email_done:
    pop  ecx
    pop  edi
    pop  esi
    ret
_LoginEmail ENDP

; ─────────────────────────────────────────
; _LoginPIN
; INPUT:  EAX = input PIN, EBX = stored PIN
; OUTPUT: EAX = 1 match, 0 no match, -1 locked
; ─────────────────────────────────────────
_LoginPIN PROC
    push ebx
    push ecx

    ; check locked
    cmp  pinAttempts, 3
    jge  pin_locked

    cmp  eax, ebx
    je   pin_match

    inc  pinAttempts
    cmp  pinAttempts, 3
    jge  pin_locked
    mov  eax, 0
    jmp  pin_done

pin_match:
    mov  pinAttempts, 0     ; reset on success
    mov  eax, 1
    jmp  pin_done

pin_locked:
    mov  eax, -1

pin_done:
    pop  ecx
    pop  ebx
    ret
_LoginPIN ENDP

; ─────────────────────────────────────────
; _LoginBackup
; INPUT:  EAX = input backup code, EBX = stored backup code
; OUTPUT: EAX = 1 match, 0 no match
; ─────────────────────────────────────────
_LoginBackup PROC
    push ebx

    cmp  eax, ebx
    je   backup_match

    mov  eax, 0
    jmp  backup_done

backup_match:
    mov  pinAttempts, 0     ; reset all attempts
    mov  backAttempts, 0
    mov  eax, 1

backup_done:
    pop  ebx
    ret
_LoginBackup ENDP

END