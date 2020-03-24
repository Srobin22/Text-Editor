
;;CSC 210
;;TEXT EDITOR
.model small
.386
.stack 200h

.data
buffer dw 10000 dup(?)
file_name db "file.txt",0
instruction db "INS.TXT",0
handle dw ?
file_size dw ?
x_count dw ?
x_count_2 db ?
x_pos db 0
x_pos_8 dw 0
y_pos db 0
index dw ?
file_size1 dw ?
file_size2 db ?
file_size3 db ?
tab_shift dw ?
temp_bx dw ?
temp_cx dw ?
temp_ax dw ?
temp_dx dw ?
handle_instruction dw  ?
codes db ?
y db 25 dup(0)
y_size db 0
current_y db ?
.code

QUIT PROC
   call ClearScreen

   call close
    mov ax, 4c00h
	int 21h 
    ret
    QUIT ENDP
ClearScreen proc
    mov ax,0b800h
    mov es,ax
    mov cx, 4000
    sub bx,bx
    mov ax,0f20h
    L:
        mov word ptr es:[bx], ax
        add bx, 2
    loop L
    ret
clearScreen endp

save PROC
call reset_seek
mov ah,40h
mov bx,handle
mov dx,offset buffer
mov cx,file_size
int 21h
jmp user
ret
save ENDP
user PROC
call ClearScreen
call write
    mov si,offset buffer
    add si,index
    mov ah,02h
    mov dl,x_pos
    mov dh,y_pos
    mov bh,0
    int 10h
     mov ah, 00h 
	int 16h 
    cmp ax, 011bh ;escape
	je QUIT 
    cmp al,9
    je tab
    
    cmp ah,1ch
    je ent
    cmp al,02
    je ent
    cmp ax,1f13h
    je save
    cmp ah, 48h 
	je UP 
    cmp ah,4Bh
    je Left
    cmp ah,4Dh
    je Right
    cmp al,39h
    je ws
    cmp al,8
    je bs
    cmp ah,53h
    je dell
    cmp ah,1ch
    mov codes,al
    mov bx,file_size
    mov file_size1,bx
    mov cx,1
    call shift_right_cx
    mov si,offset buffer
    add si,index
    mov al,codes
    mov [si],al
    inc x_pos
    inc index
    add file_size,2
    jmp user
    ent:
    call save_y
    mov codes,al
    mov bx,file_size
    mov file_size1,bx
    mov cx,1
    call shift_right_cx
    inc file_size
    mov bx,file_size
    mov file_size1,bx
    mov cx ,1
    mov si,offset buffer
    add si,index
    call shift_right_cx
    mov si,offset buffer
    add si,index
    mov al,codes
    mov [si],al
    inc si
    mov al,10
    mov [si],al
    inc x_pos
    add index,2
    add file_size,2
    mov x_pos,0
    inc y_pos 
    jmp user
    tab:
     mov bx,file_size
    mov file_size1,bx
    mov cx,1
    call shift_right_cx
     mov si,offset buffer
    add si,index
    mov al,9
    mov [si],al
    ;     mov bx,file_size
    ;mov file_size1,bx
    ;mov cx,1
  ;  call shift_right_cx
   ;      mov si,offset buffer
   ; add si,index
   ; mov bl,x_pos
    ;cmp bl,73
    ;jae  aaaaa

    ;mov dx,0
    ;mov ax,0
    ;mov al,x_pos
    ;cbw
    ;mov bx,ax
    ;mov ax,8
    ;sub ax,bx
    ;add 
    ;mov bx,8
    ;div bx
    ;mov bx,dx
    ;mov cx,dx
    ;mov tab_shift,dx
    inc index
    add x_pos,8
    ;call inc_x_pos
 

   
       ;mov bx,tab_shift
   ; add index,1
   ; add x_pos,1
    aaaaa:
    jmp user
    UP:
    cmp y_pos,0
    je user
    dec y_pos
    jmp user
    DOWN:
    cmp y_pos,20
    je user
    inc y_pos
    jmp user
    Left:
     mov al,[si-1]
    cmp al,10
    je go_left_twice
    cmp al,9
    je go_left_tab
    cmp x_pos,0
    je user
    dec x_pos
    dec si
    dec index
    jmp user
    go_left_twice:
    call get_y
    dec y_pos
    mov bl,current_y
    mov x_pos,bl
    add index,-2
    add si,-2
    jmp user
    go_left_tab:
    add x_pos,-9
    add index,-2
    jmp user
    Right:
    mov al,[si]
    cmp al,13
    je right_twice
    mov bl,[si+1]
    cmp bl,9
    je right_tab
    ;mov bl,file_size2
    ;cmp x_pos,bl
    ;je user
    inc x_pos
    inc si
    inc index
    jmp user
    right_twice:
    mov bl,x_pos
    mov current_y,bl
    mov x_pos,0
    inc y_pos
    add si,2
    add index,2
    jmp user
    right_tab:
    add x_pos,9
    add index,2
    jmp user
    dell:

    mov al,0
    mov [si],al

    jmp user
    bs:
    cmp index,0
    je user
    mov al,9
    cmp [si-1],al
    je bs_tab
    mov bx,file_size
    mov file_size1,bx
    mov cx,1
    call shift_left_once

   sub file_size,2
    dec index
    dec x_pos

    jmp user
    bs_tab:
    mov bx,file_size
    mov file_size1,bx
    mov cx,1
    call shift_left_once
    sub file_size,2
    dec index
    sub x_pos,8
    ws:
    mov bx,file_size
    mov file_size1,bx
    mov cx,1
    call shift_right_cx
    mov al,39h
    mov [si],al
    inc file_size
    inc index
    add x_pos,1

    jmp user
 user ENDP
close proc
    mov ah, 3eh
    mov bx, handle
    int 21h
    jnc resume3
    resume3:
    ret
close endp
inc_x_pos proc

  mmmmm:
  cmp bx,0
  je gret
  add x_pos,1
  dec bx
  jmp mmmmm
  
  gret:
ret
inc_x_pos ENDP
OPEN_FILE_INS PROC
mov ah,3dh
mov al,0
mov dx, offset instruction
int 21h
jc aaas
mov handle,ax
aaas:
ret
OPEN_FILE_INS ENDP

OPEN_FILE PROC
    mov ah, 3Dh ; open existing file
 mov al, 2 ; read/write
 mov dx, offset file_name 
 int 21h
  jc Create_file
 mov handle, ax ; save the handle
 ; carry flag set, jump to error block 
    ret
OPEN_FILE ENDP
Create_file PROC
mov ah,3Ch
mov cx,0
mov dx,offset file_name
mov ah,3ch
int 21h
mov handle,ax
ret
Create_file ENDP
get_size PROC
mov ah, 42h ; Seek end of file
 mov bx, handle ; Bx takes the handle
 mov al, 2 ; end of file plus offset 
 mov cx, 0 ; Upper order of bytes to move
 mov dx, 0 ; Lower order of bytes to move
 int 21h
 mov file_size, ax 

 mov ah,42h
 mov bx,handle
 mov al,0
 mov cx,0
 mov dx,0
 int 21h
ret 
get_size ENDP
reset_seek PROC
 mov ah,42h
 mov bx,handle
 mov al,0
 mov cx,0
 mov dx,0
 int 21h
 ret
reset_seek ENDP
save_y PROC
mov di,offset y
mov bl,y_pos
cmp bl,0
je y_1
cmp bl,1
je y_2
cmp bl,2
je y_3
cmp bl,3
je y_4
cmp bl,4
je y_5
cmp bl,5
je y_6
cmp bl,6
je y_7
cmp bl,7
je y_8
cmp bl,8
je y_9
cmp bl,9
je y_10
cmp bl,10
je y_11
cmp bl,11
je y_12
cmp bl,12
je y_13
cmp bl,13
je y_14
cmp bl,14
je y_15
cmp bl,15
je y_16
cmp bl,16
je y_17
cmp bl,17
je y_18
cmp bl,19
je y_19
go_ret:
ret
y_1:
mov bl,x_pos
mov [di],bl
jmp go_ret
y_2:
mov bl,x_pos
add di,1
mov [di],bl
jmp go_ret
y_3:
mov bl,x_pos
add di,2
mov [di],bl
jmp go_ret
y_4:
mov bl,x_pos
add di,3
mov [di],bl
jmp go_ret
y_5:
mov bl,x_pos
add di,6
mov [di],bl
jmp go_ret
y_6:
mov bl,x_pos
add di,7
mov [di],bl
jmp go_ret
y_7:
mov bl,x_pos
add di,8
mov [di],bl
jmp go_ret
y_8:
mov bl,x_pos
add di,9
mov [di],bl
jmp go_ret
y_9:
mov bl,x_pos
add di,10
mov [di],bl
jmp go_ret
y_10:
mov bl,x_pos
add di,11
mov [di],bl
jmp go_ret
y_11:
mov bl,x_pos
add di,12
mov [di],bl
jmp go_ret
y_12:
mov bl,x_pos
add di,13
mov [di],bl
jmp go_ret
y_13:
mov bl,x_pos
add di,14
mov [di],bl
jmp go_ret
y_14:
mov bl,x_pos
add di,15
mov [di],bl
jmp go_ret
y_15:
mov bl,x_pos
add di,16
mov [di],bl
jmp go_ret
y_16:
mov bl,x_pos
add di,17
mov [di],bl
jmp go_ret
y_17:
mov bl,x_pos
add di,18
mov [di],bl
jmp go_ret
y_18:
mov bl,x_pos
add di,19
mov [di],bl
jmp go_ret
y_19:
mov bl,x_pos
add di,20
mov [di],bl
jmp go_ret
save_y ENDP
get_y PROC
mov di,offset y
mov bl,y_pos
cmp bl,1
je y1_1
cmp bl,2
je y1_2
cmp bl,3
je y1_3
cmp bl,4
je y1_4
cmp bl,5
je y1_5
cmp bl,6
je y1_6
cmp bl,7
je y1_7
cmp bl,8
je y1_8
cmp bl,9
je y1_9
cmp bl,10
je y1_10
cmp bl,11
je y1_11
cmp bl,12
je y1_12
cmp bl,13
je y1_13
cmp bl,14
je y1_14
cmp bl,15
je y1_15
cmp bl,16
je y1_16
cmp bl,17
je y1_17
cmp bl,18
je y1_18
cmp bl,19
je y1_19
get_ret:
ret
y1_1:
mov bl,[di]
mov current_y,bl
jmp get_ret
y1_2:

add di,1
mov bl,[di]
mov current_y,bl
jmp get_ret
y1_3:

add di,2
mov bl,[di]
mov current_y,bl
jmp get_ret
y1_4:

add di,3
mov bl,[di]
mov current_y,bl
jmp get_ret
y1_5:

add di,6
mov bl,[di]
mov current_y,bl
jmp get_ret
y1_6:

add di,7
mov bl,[di]
mov current_y,bl
jmp get_ret
y1_7:

add di,8
mov bl,[di]
mov current_y,bl
jmp get_ret
y1_8:

add di,9
mov bl,[di]
mov current_y,bl
jmp get_ret
y1_9:

add di,10
mov bl,[di]
mov current_y,bl
jmp get_ret
y1_10:

add di,11
mov bl,[di]
mov current_y,bl
jmp get_ret
y1_11:

add di,12
mov bl,[di]
mov current_y,bl
jmp get_ret
y1_12:

add di,13
mov bl,[di]
mov current_y,bl
jmp get_ret
y1_13:

add di,14
mov bl,[di]
mov current_y,bl
jmp get_ret
y1_14:

add di,15
mov bl,[di]
mov current_y,bl
jmp get_ret
y1_15:

add di,16
mov bl,[di]
mov current_y,bl
jmp get_ret
y1_16:

add di,17
mov bl,[di]
mov current_y,bl
jmp get_ret
y1_17:

add di,18
mov bl,[di]
mov current_y,bl
jmp get_ret
y1_18:

add di,19
mov bl,[di]
mov current_y,bl
jmp get_ret
y1_19:

add di,20
mov bl,[di]
mov current_y,bl
jmp get_ret
get_y ENDP
read PROC
    mov ah,3fh
    mov di,offset handle
    mov bx,[di]
    mov cx,file_size
    mov dx,offset buffer
    int 21h
    cmp file_size,0
    je go_back
    call write
    mov bl,file_size2
    go_back:
    ret
    read ENDP
reset_buffer PROC
mov si,offset buffer
mov al,0
clearBUF:
cmp file_size,0
je clearret
mov [si],al
inc si
dec file_size
jmp clearBUF
clearret:
ret
reset_buffer ENDP
write PROC
;call ClearScreen
;call get_size
mov cx,file_size
mov bx,0
mov x_count,0
mov si,offset buffer
;mov file_size2,0
mov x_count_2,0
mov di,offset y
kkk:
cmp cx,0
je rett
;mov ax,10
mov al,[si]
cmp al,13
je print_enter
cmp al,9
je print_tab
;mov bl,1
mov Byte PTR ES:[BX],al
ADD BX,2
INC si
add x_count,2
;inc file_size2
inc x_count_2
dec cx
jmp kkk
rett:
ret
print_enter:
mov dl,x_count_2
mov [di],dl
inc di
mov x_count_2,0
add si,2
add bx,160
sub bx,x_count
;sub BX,6
sub cx,2
mov x_count,0
add file_size2,2
jmp kkk
print_tab:
mov al,0
    mov Byte PTR ES:[BX],al
    add bx,2
    mov al,0
    mov Byte PTR ES:[BX],al
    add bx,2
    mov al,0
    mov Byte PTR ES:[BX],al
    add bx,2
    mov al,0
    mov Byte PTR ES:[BX],al
    add bx,2
    mov al,0
    mov Byte PTR ES:[BX],al
    add bx,2
    mov al,0
    mov Byte PTR ES:[BX],al
    add bx,2
    mov al,0
    mov Byte PTR ES:[BX],al
    add bx,2
    mov al,0
    mov Byte PTR ES:[BX],al
    add bx,2
    ;mov temp_bx,bx
    ;mov temp_cx,cx
    ;mov temp_dx,dx
    ;mov temp_ax,ax
    ;mov dx,0
    ;mov ax,0
    ;mov bx,0
    ;mov al,x_count_2
    ;cbw
   ; mov bx,ax
   ; mov ax,8
   ; sub ax,bx
    ;add 
    ;mov bx,8
    ;div bx
    ;mov bx,temp_bx
    ;mov al,0
    ;add x_count,1
   ; add bx,2
  ; mov dx,8
  ; mov al,0
   ; print_0:
    ;cmp dx,0
    ;je fromret
    
   ; mov Byte PTR ES:[BX],al
   ; ADD BX,2
   ; add dx,-1
   ; jmp print_0
   ; fromret:
    ;ADD BX,2
   ; add bx,dx
  ; mov dx,temp_dx
   add x_count_2,8
    add x_count,16
   ; sub cx,2
    inc si
    jmp kkk
write ENDP


shift_one proc  
cmp file_size,0
je end_shifting
    mov  al, [ si ]    
shifting:
   
    inc  si
    mov  ah, [si]
    mov  [si], al
    xchg al, ah
    dec file_size1
     cmp  file_size1, 0       
    je   end_shifting  
    jmp  shifting
end_shifting: 
    ret
shift_one endp


shift_right_cx proc
    push si
    call shift_one     
    pop  si
    loop shift_right_cx    
    ret
shift_right_cx endp
shift_left_cx PROC
    push si
    call shift_left_once
    pop si
    loop shift_left_cx
ret
shift_left_cx ENDP
shift_left_once proc
cmp file_size,0
je end_shift_left
shift_left:
    mov al,[si]
    mov [si-1],al
    dec file_size1
    inc si
    cmp file_size1,0
    je end_shift_left
    jmp shift_left
end_shift_left:
ret
shift_left_once endp

start:
    mov ax,0b800h
    mov es,ax
    mov ax,@data
    mov ds,ax
    call ClearScreen
    call OPEN_FILE_INS
    call get_size
    call read
    
    asdasdsdf:
    int 10h
     mov ah, 00h 
	int 16h 
    cmp ax,011bh
    je cons
    jmp  asdasdsdf
    cons:
    call close
    call reset_buffer
    call reset_seek
    call OPEN_FILE
    call get_size
    call read
    mov x_pos,0
    mov y_pos,0
    mov index, 0
    MOV AH,01h
    MOV CH,7
    MOV CL,7
    INT 10H
    
    mov si,offset buffer
    call user
    end start
