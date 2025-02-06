%define WINDOW_WIDTH 80
%define WINDOW_HEIGTH 24

%define MAX_SNAKE_LENGTH 90

%define DIRECTION_LEFT 0
%define DIRECTION_RIGHT 1
%define DIRECTION_UP 2
%define DIRECTION_BOTTOM 3

%assign MAP_NUMBER_OF_CHARS WINDOW_HEIGTH * WINDOW_WIDTH

extern getch, initscr, noecho, halfdelay

global main

section .bss
    map resb MAP_NUMBER_OF_CHARS
    snake_x resb MAX_SNAKE_LENGTH
    snake_y resb MAX_SNAKE_LENGTH
    timeval resq 2

section .data
    current_snake_length dd 0
    apple_x db 10
    apple_y db 10
    direction db DIRECTION_RIGHT

section .text
main:
    push rbp
    mov rbp, rsp
    sub rsp, 10h
    call initscr
    call noecho
    mov edi, 1
    call halfdelay
    call init_snake
    call spawn_apple

.loop:
    ; read user input and set snake direction
    ; TODO: disable moving to oposite side by one move
    call getch
    movzx dx, byte [direction]
    mov cx, DIRECTION_UP
    cmp rax, 119
    cmove dx, cx
    mov cx, DIRECTION_LEFT
    cmp rax, 97
    cmove dx, cx
    mov cx, DIRECTION_RIGHT
    cmp rax, 100
    cmove dx, cx
    mov cx, DIRECTION_BOTTOM
    cmp rax, 115
    cmove dx, cx
    mov [direction], dx
    ; set x and y shift depend on current direction
    mov dx, 0 ; x shift
    mov ax, 0 ; y shift
    mov cx, 1
    mov bl, byte [direction]

    cmp bl, DIRECTION_RIGHT
    cmove dx, cx
    cmp bl, DIRECTION_BOTTOM
    cmove ax, cx
    mov cx, -1
    cmp bl, DIRECTION_LEFT
    cmove dx, cx
    cmp bl, DIRECTION_UP
    cmove ax, cx

    movzx rbx, dx
    movzx rax, ax
    push rbx
    push rax
    call process_snake
    add rsp, 16
    call create_map
    call print_map
    jmp .loop
    
    mov eax, 0
    leave
    ret

process_snake:
    push rbp
    mov rbp, rsp
    sub rsp, 4
    ; check if the head is on apple
    mov al, byte [snake_x]
    cmp al, byte [apple_x]
    jne .not_on_apple

    mov al, byte [snake_y]
    cmp al, byte [apple_y]
    jne .not_on_apple

    call add_snake_part
    call spawn_apple
.not_on_apple:
    ; set x-shift and y-shift to rdx and rax
    mov rdx, [rbp + 24]
    mov rax, [rbp + 16]
    ; start changing snake position
    mov bx, [snake_x]
    mov word [rbp - 2], bx
    mov bx, [snake_y]
    mov word [rbp - 4], bx

    add [snake_x], dx ; head x
    add [snake_y], ax ; head y 

    mov dx, [rbp - 2]
    mov ax, [rbp - 4]

    mov ecx, 1
.lp:cmp ecx, dword [current_snake_length]
    jg .finish
    mov bx, [snake_x + ecx]
    mov word [rbp - 2], bx
    mov bx, [snake_y + ecx]
    mov word [rbp - 4], bx

    mov [snake_x + ecx], dx 
    mov [snake_y + ecx], ax
    
    mov dx, [rbp - 2]
    mov ax, [rbp - 4]

    inc ecx
    jmp .lp
.finish:
    mov rsp, rbp
    pop rbp
    ret

create_map:
    push rbp
    mov rbp, rsp
    sub rsp, 40

    mov ecx, 0
.lp:cmp ecx, MAP_NUMBER_OF_CHARS
    je .fnsh

    mov eax, ecx
    xor edx, edx
    mov ebx, WINDOW_WIDTH
    div ebx

    mov [rbp - 8], edx ; x coord
    mov [rbp - 16], eax ; y coord

    mov edx, 0
.snake_loop:
    cmp edx, dword [current_snake_length]
    jg .check_next_map_cell

    movzx eax, byte [snake_x + edx]
    cmp eax, [rbp - 8]
    jne .print_space

    movzx eax, byte [snake_y + edx]
    cmp eax, [rbp - 16]
    jne .print_space

    mov [map + ecx], byte '@'
    inc edx
    jmp .check_next_map_cell

.print_space
    mov [map + ecx], byte ' ' 
    inc edx
    jmp .snake_loop

.check_next_map_cell:
    movzx eax, byte [apple_x]
    cmp eax, [rbp - 8]
    jne .not_apple

    movzx eax, byte [apple_y]
    cmp eax, [rbp - 16]
    jne .not_apple

    mov [map + ecx], byte 'a'
.not_apple:
    inc ecx
    jmp .lp
.fnsh:
    mov rsp, rbp
    pop rbp
    ret

print_map:
    push rbp
    mov rbp, rsp

    mov rax, 1
    mov rdi, 1
    mov rsi, qword map
    mov rdx, qword MAP_NUMBER_OF_CHARS
    syscall

    mov rsp, rbp
    pop rbp
    ret

init_snake:
    push rbp
    mov rbp, rsp
    ; init head
    mov [snake_x], byte 8
    mov [snake_y], byte 8  
    ; add more snake parts
    call add_snake_part
    call add_snake_part
    call add_snake_part
    
    mov rsp, rbp
    pop rbp
    ret

spawn_apple:
    push rbp
    mov rbp, rsp
    ; TODO: write better solution for spawning apples
    mov rax, 96                 ; syscall: sys_gettimeofday
    mov rdi, timeval            ; pointer to struct
    xor rsi, rsi                ; NULL timezone
    syscall
    mov ecx, MAP_NUMBER_OF_CHARS
    mov eax, dword [timeval + 8]
    xor rdx, rdx
    div ecx
    xor rdx, rdx
    mov ecx, WINDOW_WIDTH
    div ecx

    mov [apple_x], byte dx
    mov [apple_y], byte ax

    mov rsp, rbp
    pop rbp
    ret

add_snake_part:
    push rbp
    mov rbp, rsp
    push rcx

    mov ecx, dword [current_snake_length]
    mov al, byte [snake_x + ecx]
    mov ah, byte [snake_y + ecx]
    dec al

    mov byte [snake_x + ecx + 1], al
    mov byte [snake_y + ecx + 1], ah
    inc ecx
    mov dword [current_snake_length], ecx

    pop rcx
    mov rsp, rbp
    pop rbp
    ret

