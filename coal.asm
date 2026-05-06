org 100h

jmp start

; ---------------- DATA ----------------
header db 13,10,"=== CAESAR CIPHER TOOL ===$"
menu   db 13,10,"1.Encrypt  2.Decrypt",13,10,"Choice: $"
msg1   db 13,10,"Enter text: $"
msg2   db 13,10,"Enter key (0-25): $"
msg3   db 13,10,"Result: $"
msg4   db 13,10,"Back to menu? (y/n): $"

buffer times 60 db '$'
keybuf times 5 db 0
key db 0
choice db 0

; ---------------- START ----------------
start:
    mov dx, header
    mov ah, 09h
    int 21h

main:
    mov dx, menu
    mov ah, 09h
    int 21h

    mov ah, 01h
    int 21h
    sub al, '0'
    mov [choice], al

; -------- TEXT INPUT --------
    mov dx, msg1
    mov ah, 09h
    int 21h

    mov si, buffer

read_text:
    mov ah, 01h
    int 21h
    cmp al, 13
    je get_key
    mov [si], al
    inc si
    jmp read_text

; -------- KEY INPUT --------
get_key:
    mov dx, msg2
    mov ah, 09h
    int 21h

    mov si, keybuf

read_key:
    mov ah, 01h
    int 21h
    cmp al, 13
    je convert_key
    mov [si], al
    inc si
    jmp read_key

convert_key:
    mov byte [si], 0
    mov si, keybuf
    xor ax, ax

key_loop:
    mov bl, [si]
    cmp bl, 0
    je done_key

    sub bl, '0'
    mov cx, 10
    mul cx
    add ax, bx

    inc si
    jmp key_loop

done_key:
    mov bl, 26
    div bl
    mov [key], ah

; -------- PROCESS TEXT (FIXED) --------
    mov si, buffer

process:
    mov al, [si]
    cmp al, '$'
    je show

    ; A-Z
    cmp al, 'A'
    jb skip
    cmp al, 'Z'
    jbe upper

    ; a-z
    cmp al, 'a'
    jb skip
    cmp al, 'z'
    jbe lower

    jmp skip

; -------- UPPERCASE --------
upper:
    sub al, 'A'
    mov bl, [key]

    cmp byte [choice], 1
    je up_encrypt

    ; decrypt
    sub al, bl
    add al, 26
    jmp up_mod

up_encrypt:
    add al, bl

up_mod:
    xor ah, ah
    mov dl, 26
    div dl
    mov al, ah
    add al, 'A'
    jmp store

; -------- LOWERCASE --------
lower:
    sub al, 'a'
    mov bl, [key]

    cmp byte [choice], 1
    je low_encrypt

    ; decrypt
    sub al, bl
    add al, 26
    jmp low_mod

low_encrypt:
    add al, bl

low_mod:
    xor ah, ah
    mov dl, 26
    div dl
    mov al, ah
    add al, 'a'

store:
    mov [si], al

skip:
    inc si
    jmp process

; -------- OUTPUT --------
show:
    mov dx, msg3
    mov ah, 09h
    int 21h

    mov dx, buffer
    mov ah, 09h
    int 21h

    mov dx, msg4
    mov ah, 09h
    int 21h

    mov ah, 01h
    int 21h

    cmp al, 'y'
    je main
    cmp al, 'Y'
    je main

    mov ah, 4Ch
    int 21h