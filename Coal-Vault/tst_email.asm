INCLUDE Irvine32.inc

EXTERN ValidateEmailFormat:PROC
EXTERN ValidateEmailDomain:PROC

.data
    ; valid email
    email1 BYTE "umar@niit.edu.pk", 0

    ; no @ sign
    email2 BYTE "umarnoemail.com", 0

    ; wrong domain
    email3 BYTE "umar@gmail.com", 0

    ; space inside
    email4 BYTE "um ar@niit.edu.pk", 0

    ; two @ signs
    email5 BYTE "umar@@niit.edu.pk", 0

    msgTest   BYTE "Testing: ", 0
    msgValid  BYTE "VALID", 0
    msgInvalid BYTE "INVALID", 0
    msgFmt    BYTE " | Format: ", 0
    msgDom    BYTE " | Domain: ", 0

.code

PrintResult PROC
    cmp eax, 1
    je  print_valid
    mov edx, OFFSET msgInvalid
    call WriteString
    ret
print_valid:
    mov edx, OFFSET msgValid
    call WriteString
    ret
PrintResult ENDP

main PROC

    ; Test 1 — valid email
    mov edx, OFFSET msgTest
    call WriteString
    mov edx, OFFSET email1
    call WriteString

    mov edx, OFFSET msgFmt
    call WriteString
    mov esi, OFFSET email1
    call ValidateEmailFormat
    call PrintResult

    mov edx, OFFSET msgDom
    call WriteString
    mov esi, OFFSET email1
    call ValidateEmailDomain
    call PrintResult
    call Crlf

    ; Test 2 — no @
    mov edx, OFFSET msgTest
    call WriteString
    mov edx, OFFSET email2
    call WriteString

    mov edx, OFFSET msgFmt
    call WriteString
    mov esi, OFFSET email2
    call ValidateEmailFormat
    call PrintResult

    mov edx, OFFSET msgDom
    call WriteString
    mov esi, OFFSET email2
    call ValidateEmailDomain
    call PrintResult
    call Crlf

    ; Test 3 — wrong domain
    mov edx, OFFSET msgTest
    call WriteString
    mov edx, OFFSET email3
    call WriteString

    mov edx, OFFSET msgFmt
    call WriteString
    mov esi, OFFSET email3
    call ValidateEmailFormat
    call PrintResult

    mov edx, OFFSET msgDom
    call WriteString
    mov esi, OFFSET email3
    call ValidateEmailDomain
    call PrintResult
    call Crlf

    ; Test 4 — space inside
    mov edx, OFFSET msgTest
    call WriteString
    mov edx, OFFSET email4
    call WriteString

    mov edx, OFFSET msgFmt
    call WriteString
    mov esi, OFFSET email4
    call ValidateEmailFormat
    call PrintResult

    mov edx, OFFSET msgDom
    call WriteString
    mov esi, OFFSET email4
    call ValidateEmailDomain
    call PrintResult
    call Crlf

    ; Test 5 — two @
    mov edx, OFFSET msgTest
    call WriteString
    mov edx, OFFSET email5
    call WriteString

    mov edx, OFFSET msgFmt
    call WriteString
    mov esi, OFFSET email5
    call ValidateEmailFormat
    call PrintResult

    mov edx, OFFSET msgDom
    call WriteString
    mov esi, OFFSET email5
    call ValidateEmailDomain
    call PrintResult
    call Crlf

    INVOKE ExitProcess, 0
main ENDP
END main