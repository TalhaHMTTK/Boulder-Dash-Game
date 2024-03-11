[org 0x100]
jmp start
oldisr: dw 0,0
current_pos: dw 0
gamescore: dw 0
win: dw 0
win_pos: dw 0
quit_flag: dw 0
lost: dw 0


 umove:
   jmp check_up
   perform_up:
   push ax
   push di
   push es
   mov ax,0xb800
   mov es,ax
   mov di,[current_pos]
   mov word[es:di],0x0720
   sub di,160
   mov ah,143
   mov al,0x02
   mov [es:di],ax
   mov [current_pos],di
   pop es
   pop di
   pop ax
   
 jmp back5


kbisr:
 push ax
 push es

in al,0x60
cmp al,1
jne forward
mov word[quit_flag],1
jmp back5
forward:
cmp word[lost],1
je back5
cmp word[win],1
je back5
 in al,0x60
 cmp al,0x4B
 je lmove

 in al,0x60
 cmp al,0x4D
 je rmove

 in al,0x60
 cmp al,0x48
 je umove 

 in al,0x60
 cmp al,0x50
 je dmove

back5:
  pop es
  pop ax
  jmp far[cs:oldisr]


 dmove:
   jmp check_down
   perform_down:
   push ax
   push di
   push es
   mov ax,0xb800
   mov es,ax
   mov di,[current_pos]
   mov word[es:di],0x0720
   add di,160
   mov ah,143
   mov al,0x02
   mov [es:di],ax
   mov [current_pos],di
   pop es
   pop di
   pop ax
 jmp back5

 lmove:
   cmp word[lost],1
   je back5
   jmp check_left
   perform_left:
   push ax
   push di
   push es
   mov ax,0xb800
   mov es,ax
   mov di,[current_pos]
   mov word[es:di],0x0720
   sub di,2
   mov ah,143
   mov al,0x02
   mov [es:di],ax
   mov [current_pos],di
   pop es
   pop di
   pop ax
   
 jmp back5
 
 rmove:
   jmp check_right
   perform_right:
   push ax
   push di
   push es
   mov ax,0xb800
   mov es,ax
   mov di,[current_pos]
   mov word[es:di],0x0720
   add di,2
   mov ah,143
   mov al,0x02
   mov [es:di],ax
   mov [current_pos],di
   pop es
   pop di
   pop ax
 jmp back5


check_up:

   mov ax,0xb800
   mov es,ax
   mov di,[current_pos]
   sub di,160
   mov al,0xDB
   mov ah,86
   cmp ax,[es:di]
   je to_remove_error
   mov al,0x09
   mov ah,5
   cmp ax,[es:di]
   je to_remove_error


   mov al,0x04
   mov ah,14
   cmp ax,[es:di]
   jne score_up
   add word[gamescore],1
 score_up:  
jmp perform_up


check_down:

   mov ax,0xb800
   mov es,ax
   mov di,[current_pos]
   add di,160
   mov al,0xDB
   mov ah,86
   cmp ax,[es:di]
   je to_remove_error
   mov al,0x09
   mov ah,5
   cmp ax,[es:di]
   je to_remove_error
   mov al,0x04
   mov ah,14
   cmp ax,[es:di]
   jne score_down
   add word[gamescore],1
 score_down:
jmp perform_down

to_remove_error:
jmp beep_sound

check_left:

   mov ax,0xb800
   mov es,ax
   mov di,[current_pos]
   sub di,2
   mov al,0xDB
   mov ah,86
   cmp ax,[es:di]
   je beep_sound
   mov al,0x09
   mov ah,5
   cmp ax,[es:di]
   je beep_sound
   mov al,0x04
   mov ah,14
   cmp ax,[es:di]
   jne score_left
   add word[gamescore],1
 score_left:
jmp perform_left


check_right:

   mov ax,0xb800
   mov es,ax
   mov di,[current_pos]
   add di,2
   mov al,0xDB
   mov ah,86
   cmp ax,[es:di]
   je beep_sound
   mov al,0x09
   mov ah,5
   cmp ax,[es:di]
   je beep_sound
   mov al,0x04
   mov ah,14
   cmp ax,[es:di]
   jne score_right
   add word[gamescore],1
 score_right:
jmp perform_right


beep_sound:
   mov ah,2
   mov dl,07
   int 21h
jmp back5


printnum:
   push bp
   mov bp,sp
   push es
   push ax
   push bx
   push cx
   push dx
   push di

   mov ax,0xb800
   mov es,ax
   mov ax,[bp+4]
   mov bx,10
   mov cx,0
nextdigit:
   mov dx,0
   div bx
   add dl,0x30
   push dx
   inc cx
   cmp ax,0 
   jnz nextdigit

   mov di,3854

nextpos:
   pop dx
   mov dh,0x07
   mov [es:di],dx
   add di,2
   loop nextpos

   pop di
   pop dx
   pop cx
   pop bx
   pop ax
   pop es
   pop bp
   ret 2     

open_file:

	mov ah, 3dh        ; open file
  cmp word[level_3_flag],1
  je level_3_file_name
  cmp word[level_2_flag],1
  je level_2_file_name

  cmp byte[length_file_name],0
  jne user_entered_file_name
  mov dx,fname
  jmp file_address_has_moved
user_entered_file_name:
	mov dx, fname2
  jmp file_address_has_moved
level_2_file_name:
  mov dx, level2
  jmp file_address_has_moved
level_3_file_name:
  mov dx, level3
file_address_has_moved:
	mov al, 2
	int 21h
	mov [fhandle], ax
ret

read_file:
	  mov ah, 3fh        ; read from file
	  mov dx, buffer
	  mov cx, 1600        ; read up to 1600 bytes at a time
	  mov bx, [fhandle]
	  int 21h
ret


close_file:
  	mov ah, 3eh    ; close file
  	mov bx, [fhandle]
  	int 21h
ret



rearrange:
    push ax
    push bx
    push cx
    push dx
    push si
    push di



    mov si,0
    mov di,0

jmp rear1


compare_with_orignals:
cmp byte[buffer+si],78h
je restore_location
cmp byte[buffer+si],57h
je restore_location
cmp byte[buffer+si],42h
je restore_location
cmp byte[buffer+si],44h
je restore_location
cmp byte[buffer+si],54h
je ending_point_count
cmp byte[buffer+si],52h
je starting_point_count
mov word[invalid_data],1

jmp restore_location




rear1:
    mov ax,[buffer+si]
    mov [buffer2+di],ax
jmp compare_with_orignals
restore_location:    
    add si,1
    add di,1
    inc word[rear_count]
    cmp word[rear_count],78
    je increment_rear_count
back_rearrange:
     cmp si,1600
     jne rear1

     pop di
     pop si
     pop dx
     pop cx
     pop bx
     pop ax
ret

increment_rear_count:
     mov word[rear_count],0
     add si,2
jmp back_rearrange

starting_point_count:
add word[smile_face],1
jmp restore_location

ending_point_count:
add word[target_game],1
jmp restore_location

messgage_question1: db 'Enter valid file name or press Enter to use the default (cave1.txt) $'
messgage_question2: db ' File name: $'
message_file_open: db 'Opening file now... $'
message_invalid1: db 'Error: you entered invalid File name $'
message_invalid2: db 'Error: Incomplete or incorrect data in a file $' 
name_of_file: times 80 db 0
want_to_play: times 10 db 0
length_file_name: db 0
invalid_data: dw 0


welcome_message: db "!!!  WELCOME TO BOULDER DASH GAME   !!! $"
welcome_message2: db "***   Hope you will enjoy this alot   *** $"
welcome_message3: db "```   Initial Process is going to start   ``` $"
message_again_start: db 'Would you like to restart if yes press backspace with enter otherwise just enter $'

blink_rock:
push ax
push es
push di
mov ax,0xb800
mov es,ax
mov di,[current_pos]
sub di,160
mov al,0x09
mov ah,133
mov [es:di],ax
pop di
pop es
pop ax
jmp rock_blink_back

  start:




mov word[win],0
mov word[lost],0
mov word[win_pos],0

call cls

    mov dh,9h           ;ROW SET
    mov dl,18           ;Col SET
    mov ah,2h           ;Set cursor position
    int 10h

	  mov ah, 9  			; display prompt for file name
	  mov dx, welcome_message
	  int 21h

    mov dh,0x0C           ;ROW SET
    mov dl,18           ;Col SET
    mov ah,2h           ;Set cursor position
    int 10h

	  mov ah, 9  			; display prompt for file name
	  mov dx, welcome_message2
	  int 21h

    mov dh,0x0F           ;ROW SET
    mov dl,18           ;Col SET
    mov ah,2h           ;Set cursor position
    int 10h

	  mov ah, 9  			; display prompt for file name
	  mov dx, welcome_message3
	  int 21h

call print_welcome


call delay
call delay
call delay
call delay
call delay
call delay
call delay
call delay
call delay

call cls
    




    mov dh,0h           
    mov dl,0            
    mov ah,2h           
    int 10h

	MOV AH, 9  			; display prompt for file name
	MOV DX, messgage_question1
	INT 21h

    mov dh,1h           ;ROW SET
    mov dl,0            ;Col SET
    mov ah,2h           ;Set cursor position
    int 10h

	MOV AH, 9  			; display prompt for file name
	MOV DX, messgage_question2
	INT 21h

 mov byte[name_of_file],18
    mov byte[name_of_file+1],0
	MOV AH, 0Ah  ; read file name from user
	MOV DX, name_of_file  ; set DX to the address of file_name buffer
	INT 21h
    mov ax,0
    mov al,[name_of_file+1]
    mov [length_file_name],al

    mov dh,2h           ;ROW SET
    mov dl,0            ;Col SET
    mov ah,2h           ;Set cursor position
    int 10h

	  mov ah, 9  			; display prompt for file name
	  mov dx, message_file_open
	  int 21h

    mov cx,0
    mov cl,[length_file_name]
    cmp cx,0
    je user_press_enter

    mov si,2
    mov ax,0
    mov di,0
loop_for_file_name:
    mov al,[name_of_file+si]
    mov [fname2+di],al
    inc si
    inc di
    loop loop_for_file_name


user_press_enter:

jmp after
before1:
    mov dh,3h           ;ROW SET
    mov dl,0            ;Col SET
    mov ah,2h           ;Set cursor position
    int 10h

	MOV ah, 9  			; display prompt for file name
	MOV dx, message_invalid1
	INT 21h
  jmp going_to_terminate
before2:
    mov dh,3h           ;ROW SET
    mov dl,0            ;Col SET
    mov ah,2h           ;Set cursor position
    int 10h

	MOV ah, 9  			; display prompt for file name
	MOV dx, message_invalid2
	INT 21h
going_to_terminate:
mov ax,0x4c00
int 21h
after:

here_another_levels_starts:
mov word[win],0
mov word[quit_flag],0
call open_file

jc before1

call read_file

call close_file

call rearrange

cmp word[invalid_data],1
je before2

cmp word[smile_face],1
jne before2

cmp word[target_game],1
jne before2
mov word[smile_face],0
mov word[target_game],0

mov ah,0
int 0x16
call cls



mov byte[buffer2+1560],'_'
cmp word[level_2_flag],1
jne i_am_level1
mov ax,-1
jmp here_i_am_going_to_start_again
i_am_level1:
mov ax, 1
here_i_am_going_to_start_again:
push ax
mov ax, 3
push ax
mov ax, 7
push ax
mov ax, buffer2
push ax
call print
  
  mov ax,1
  push ax
  mov ax, 0
  push ax
  mov ax, 7
  push ax
  mov ax,string2
  push ax
  call print1

  mov ax,1
  push ax
  mov ax, 1
  push ax
  mov ax, 7
  push ax
  mov ax,string5
  push ax
  call print1

  mov ax,1
  push ax
  mov ax, 24
  push ax
  mov ax, 7
  push ax
  cmp word[level_3_flag],1
  je move_level3
  cmp word[level_2_flag],1
  je move_level2
  mov ax,string3
  jmp last_point 
move_level2:
mov ax,strinl2
jmp last_point
move_level3:
mov ax,strinl3
last_point:  
  push ax
  call print1
jmp find_start

bbback:
    xor ax,ax
    mov es,ax
    mov ax,[es:9*4]
    mov [oldisr],ax
    mov ax,[es:9*4+2]
    mov [oldisr+2],ax
    cli
    mov word[es:9*4],kbisr
    mov [es:9*4+2],cs
    sti 

  ll1:
    call check_win_or_not
    cmp word[win],1
    je end_of_game_before
    call check_die_or_not
    cmp word[lost],1
    je has_the_life_finished
    mov ax,[gamescore]
    push ax
    call printnum

    int 0x16
    cmp al,27
    jne ll1
    mov word[quit_flag],1
    jmp end_of_game_lost
has_the_life_finished:
jmp check_rockfold_lifes

end_of_game_lost:
    mov word[life_of_rockfold],0
    cmp word[lost],1
    je blink_rock
rock_blink_back: 
jmp end_of_game
end_of_game_before:
  mov ax,1
  push ax
  mov ax, 1
  push ax
  mov ax, 7
  push ax
  cmp word[level_3_flag],1
  je push_level3
  cmp word[level_2_flag],1
  je push_level2
  mov ax,strcom1
  jmp here_after_push
push_level3:
  mov ax,strcom3
  jmp here_after_push
push_level2:
  mov ax,strcom2
here_after_push:
  push ax  
  call print1

end_of_game:
    cmp word[quit_flag],1
    jne end_of_game
    mov ax,[oldisr]
    mov bx,[oldisr+2]
    cli
    mov [es:9*4],ax
    mov [es:9*4+2],bx
    sti 

call cls
cmp word[win],1
jne termination_of_game
cmp word[level_2_flag],1
jne jump_on_level2
mov word[level_3_flag],1
jump_on_level2:
mov word[level_2_flag],1
jmp here_another_levels_starts

termination_of_game:
cmp word[lost],1
jne dont_want

mov bx,0
    
    mov dh,0h           
    mov dl,0            
    mov ah,2h           
    int 10h

	  mov ah, 9  			; display prompt for file name
	  mov dx, message_again_start
	  int 21h

    mov byte[want_to_play],2
    mov byte[want_to_play+1],0
	  MOV AH, 0Ah  ; read file name from user
	  MOV DX, want_to_play  ; set DX to the address of file_name buffer
	  INT 21h
    cmp byte[want_to_play+1],0
    jne dont_want
    mov word[gamescore],0
    mov word[lost],0
    mov word[quit_flag],0
    call cls
    mov dh,2h           ;ROW SET
    mov dl,0            ;Col SET
    mov ah,2h           ;Set cursor position
    int 10h

    mov ax, -1
    jmp here_i_am_going_to_start_again
    dont_want:
mov ax, 0x4c00
int 21h

check_rockfold_lifes:

    add word[life_of_rockfold],1
    cmp word[life_of_rockfold],2
    je end_of_game_lost
    push ax 
    push es
    push di 
    mov word[lost],0
    mov ax,0xb800
    mov es,ax
    mov di,[current_pos]
    mov word[es:di],0x0720
    mov di,[start_pos]
    mov al,0x02
    mov ah,15
    mov word[es:di],ax
    mov ax,[start_pos]
    mov [current_pos],ax
    pop di
    pop es
    pop ax
    jmp ll1



check_win_or_not:
    push di

    mov di,[current_pos] 
    cmp di,[win_pos]
    jne skip_win
    mov word[win],1
 skip_win:
    pop di
    ret 

check_die_or_not:
    push ax
    push es
    push di

    mov ax,0xb800
    mov es,ax
    mov al,0x09
    mov ah,5
    mov di,[current_pos]
    sub di,160
    cmp [es:di],ax
    jne skipup
    mov word[lost],1
 skipup: 
    pop di
    pop es
    pop ax
ret


cls:
push es
push ax
push cx
push di

mov ax, 0xb800
mov es, ax
xor di, di
mov ax, 0x0720
mov cx, 2000
cld
rep stosw
pop di
pop cx
pop ax
pop es
ret
delay:
push cx
push ax
push dx
mov dx, 65535
mov cx, 65535
del:cmp dx, 0
je end
mov ax, 0
sub dx, 1
loop del
end: pop dx
pop ax
pop cx
ret


print1:
  push bp

  mov bp, sp
  push es
  push ax

 push cx
 push si
 push di
 push ds
 pop es
 mov di, [bp+4]
 mov cx, 0xffff
 mov al, [null]
 repne scasb
 mov ax, 0xffff
 sub ax, cx
 dec ax
 jz exit1
 mov cx, ax
 mov ax, 0xb800
 mov es, ax
 mov al, 80
 mul byte [bp+8]
 add ax, [bp+10]
 shl ax, 1
 mov di,ax
 mov si, [bp+4]
 mov ah, [bp+6]
cld
nextchar1: lodsb

 stosw
 loop nextchar1
exit1: pop di
 pop si
 pop cx
 pop ax
 pop es
 pop bp
 ret 8


print_welcome:

mov ax,0xb800
mov es,ax

mov al,80
mov bl,5
mul bl
add ax,14
shl ax,1
mov di,ax
mov al,0xDB
mov ah,43

wl1:
 mov [es:di],ax
 add di,2
 inc word[welccome_count]
 cmp word[welccome_count],50
 jne wl1


mov al,80
mov bl,7
mul bl
add ax,14
shl ax,1
mov di,ax
mov al,0xDB
mov ah,43
mov word[welccome_count],0
wl2:
 mov [es:di],ax
 add di,2
 inc word[welccome_count]
 cmp word[welccome_count],50
 jne wl2

mov al,80
mov bl,21
mul bl
add ax,14
shl ax,1
mov di,ax
mov al,0xDB
mov ah,43
mov word[welccome_count],0

wl3:
 mov [es:di],ax
 add di,2
 inc word[welccome_count]
 cmp word[welccome_count],50
 jne wl3

mov al,80
mov bl,23
mul bl
add ax,14
shl ax,1
mov di,ax
mov al,0xDB
mov ah,43
mov word[welccome_count],0

wl4:
 mov [es:di],ax
 add di,2
 inc word[welccome_count]
 cmp word[welccome_count],50
 jne wl4

mov al,80
mov bl,8
mul bl
add ax,12
shl ax,1
mov di,ax
mov al,0xDB
mov ah,37
mov word[welccome_count],0

wl5:
 mov [es:di],ax
 add di,160
 inc word[welccome_count]
 cmp word[welccome_count],13
 jne wl5

mov al,80
mov bl,8
mul bl
add ax,10
shl ax,1
mov di,ax
mov al,0xDB
mov ah,37
mov word[welccome_count],0

wl6:
 mov [es:di],ax
 add di,160
 inc word[welccome_count]
 cmp word[welccome_count],13
 jne wl6


mov al,80
mov bl,8
mul bl
add ax,65
shl ax,1
mov di,ax
mov al,0xDB
mov ah,37
mov word[welccome_count],0

wl7:
 mov [es:di],ax
 add di,160
 inc word[welccome_count]
 cmp word[welccome_count],13
 jne wl7

 mov al,80
mov bl,8
mul bl
add ax,67
shl ax,1
mov di,ax
mov al,0xDB
mov ah,37
mov word[welccome_count],0

wl8:
 mov [es:di],ax
 add di,160
 inc word[welccome_count]
 cmp word[welccome_count],13
 jne wl8

ret





print:
push bp

mov bp, sp
push es
push ax

push cx
push si
push di
push ds
pop es
mov di, [bp+4]
mov cx, 0xffff
mov al, [null]
repne scasb
mov ax, 0xffff
sub ax, cx
dec ax
jz exit
mov cx, ax
mov ax, 0xb800
mov es, ax
mov al, 80
mul byte [bp+8]
add ax, [bp+10]
shl ax, 1
mov di,ax
mov si, [bp+4]
mov ah, [bp+6]
cld
nextchar: lodsb


cmp al,78h
jz change1
cmp al,57h
jz change2
cmp al,42h
jz change3
cmp al,44h
jz change4
cmp al,54h
jz change5
cmp al,52h
jz change6
back:

inc word[count]
cmp word[count],79
jz next_line

back2:
stosw
loop nextchar
jmp print_border
back3:
exit: pop di
pop si
pop cx
pop ax
pop es
pop bp
ret 8
ret

change1:
mov al,0xB1
mov ah,8
jmp back

change2:
mov al,0xDB
mov ah,86
jmp back

change3:
mov al,0x09
mov ah,5
jmp back

change4:
mov al,0x04
mov ah,14
jmp back

change5:
mov al,0x7F
mov ah,14
mov [win_pos],di
jmp back

change6:
mov al,0x02
mov ah,15
jmp back

next_line:
add di,4
mov word[count],1
jmp back2

find_start:
  mov ax,0xb800
  mov es,ax
  mov di,0 
  mov al,0x02
  mov ah,15
  mov cx,2000
  cld
  repne scasw

  sub di,2
  mov ah,143
  mov [es:di],ax
  mov [current_pos],di
  mov [start_pos],di
  jmp bbback
  
  






print_border:
mov al,80
mov bl,2
mul bl
add ax,0
shl ax,1
mov di,ax
mov al,0xDB
mov ah,86
mov word[count2],0
lp1:
mov [es:di],ax
add di,2
inc word[count2]
cmp word[count2],80
jnz lp1

mov al,80
mov bl,3
mul bl
add ax,0
shl ax,1
mov di,ax
mov al,0xDB
mov ah,86
mov word[count2],0
lp2:
mov [es:di],ax
add di,160
inc word[count2]
cmp word[count2],20
jnz lp2

mov word[count2],0
lp3:
mov [es:di],ax
add di,2
inc word[count2]
cmp word[count2],79
jnz lp3

mov word[count2],0
lp4:
mov [es:di],ax
sub di,160
inc word[count2]
cmp word[count2],21
jnz lp4


jmp back3


null: db "_"
string2: db "                     BOULDER DASH Talha's EDITION_"
string5: db "Arrow Keys: move                                                     Esc: quit_"
strcom1: db "Level 1 Completed _"
strcom2: db "Level 2 Completed _"
strcom3: db "Level 3 Completed _"
string3: db "SCORE:                                                                Level: 1_"
strinl2: db "SCORE:                                                                Level: 2_"
strinl3: db "SCORE:                                                                Level: 3_"
space_string: db " _"
count2: dw 0
count: dw 0
rear_count: dw 0
fname: db 'cave1.txt', 0
level2: db 'level2.txt', 0
level3: db 'level3.txt', 0
fname2: times 20 db 0
fhandle: dw 0
buffer: times 1600 db 0  
buffer2: times 1600 db 0
welccome_count: dw 0
buffer3: times 1600 db 0
buffer4: times 1600 db 0
level_2_flag: dw 0
level_3_flag: dw 0
smile_face: dw 0
target_game: dw 0
life_of_rockfold: dw 0
start_pos: dw 0