INCLUDE Irvine32.inc

PUBLIC ValidateEmailFormat
PUBLIC ValidateEmailDomain

.data
    allowedDomain BYTE "niit.edu.pk", 0

.code

; ─────────────────────────────────────────
; ValidateEmailFormat
; INPUT:  ESI = pointer to email string
; OUTPUT: EAX = 1 (valid), 0 (invalid)
; Checks: no spaces, exactly one @, dot after @
; ─────────────────────────────────────────
ValidateEmailFormat PROC
    push esi
    push ebx
    push ecx

    mov ebx, 0      ; atCount
    mov ecx, 0      ; dotAfterAt
    mov edx, 0      ; foundAt

scan_loop:
    mov al, [esi]
    cmp al, 0
    je  check_result

    cmp al, ' '
    je  invalid

    cmp al, '@'
    jne check_dot
    inc ebx         ; atCount++
    mov edx, 1      ; foundAt = 1

check_dot:
    cmp al, '.'
    jne next_char
    cmp edx, 1
    jne next_char
    mov ecx, 1      ; dotAfterAt = 1

next_char:
    inc esi
    jmp scan_loop

check_result:
    cmp ebx, 1
    jne invalid
    cmp ecx, 1
    jne invalid

    mov eax, 1
    jmp done

invalid:
    mov eax, 0

done:
    pop ecx
    pop ebx
    pop esi
    ret
ValidateEmailFormat ENDP

; ─────────────────────────────────────────
; ValidateEmailDomain
; INPUT:  ESI = pointer to email string
; OUTPUT: EAX = 1 (valid), 0 (invalid)
; Checks: domain must be niit.edu.pk
; ─────────────────────────────────────────
ValidateEmailDomain PROC
    push esi
    push edi
    push ebx

    ; find @ first
find_at:
    mov al, [esi]
    cmp al, 0
    je  invalid_domain
    cmp al, '@'
    je  found_at
    inc esi
    jmp find_at

found_at:
    inc esi         ; move past @

    ; compare with "niit.edu.pk"
    mov edi, OFFSET allowedDomain

compare_loop:
    mov al, [edi]
    cmp al, 0
    je  valid_domain        ; domain fully matched

    mov bl, [esi]
    cmp al, bl
    jne invalid_domain

    inc esi
    inc edi
    jmp compare_loop

valid_domain:
    mov eax, 1
    jmp done_domain

invalid_domain:
    mov eax, 0

done_domain:
    pop ebx
    pop edi
    pop esi
    ret
ValidateEmailDomain ENDP

END