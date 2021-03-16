model tiny

false_pass_x 		equ 0
false_pass_y		equ 5

greeting_x		equ 0
greeting_y		equ 20

bitcoin_ident_x         equ 41

correct_pass_x          equ 21
correct_pass_y		equ 5

sleep_time		equ 0B808h

;================================================================================
size_x  	equ 7
size_y  	equ 3
ident_x 	equ 30
ident_y		equ 9
count		equ 6
width_x_step	equ 7

size_frame_x  	equ 43
size_frame_y  	equ 14
ident_frame_x 	equ 19
ident_frame_y	equ 3

border_x 	equ 0cdh		
border_y 	equ 0bah		                                        

corner_lu 	equ 0c9h		
corner_ru 	equ 0bbh	
corner_ld 	equ 0c8h	
corner_rd 	equ 0bch	

filler 		equ 0b0h		
color 		equ 4eh

color_backgrd	equ 1bh
color_frame	equ 3eh
color_message	equ 4eh
color_number	equ 5eh
color_screen	equ 70h
color_none	equ 0h

shade_bright	equ 0b2h
shade_middle    equ 0b1h
shade_dim       equ 0b1h

start_row 	equ 10
start_column	equ 15

message_ident_y equ 5
message_ident_x equ 24

hex_len		equ 8
dec_len         equ 8
bin_len         equ 8

break_time 	equ 8480h

video_mem	equ 0b800h
;================================================================================

.code
org 100h

Start:
	mov bx, 0b800h
	mov es, bx
	
	mov dl, 0
	mov dh, 0
	call get_string

;	[bp+4]  ident y
;	[bp+6]  ident x
;	[bp+8]  message id

;	mov ax, offset buffer
;	push ax
;	mov ax, last_ident_x
;	push ax
;	mov ax, last_ident_y
;	push ax
 
;	call make_message
	
	mov di, offset buffer
	call check_password

;	mov si, offset test_cmp1
;	mov di, offset test_cmp2
;	mov cx, test_cmp_len 	
;	call strcmp	
	
;	int 3h	

	mov ax, 4c00h
	int 21h



;----------------------------------------------------------------------------------                                                        
;print message with number on screen
;needed es to be b800h
;used reg: bp ax si bx cx
;input data:
;	[bp+4]  ident y
;	[bp+6]  ident x
;	[bp+8]  message id
;----------------------------------------------------------------------------------
make_message proc
	push bp
	mov bp, sp

	mov ax, [bp+4]			;getting y size	of frame and conter rows
	
	mov si, 160
	mul si

	mov si, [bp+6] 	
	sal si, 1			;mult by 2
	
	add ax, si
	mov bx, ax			;can't [ax] lol

	mov si, [bp+8]			;message offset

	mov al, [si]
	inc si
loop_message:                   
	
	call make_sleep		

	mov byte ptr es:[bx], al

	inc bx
	inc bx		
	
	mov al, [si]
	inc si
	cmp al, '$'
	jne loop_message
                       	
	pop bp
	ret 2 * 3
make_message endp

MACRO_MAKE_MESSAGE MACRO ident_x, indent_y, message_id
	nop
	nop
	
	mov ax, offset message_id
	push ax
	mov ax, ident_x
	push ax	
	mov ax, ident_y
	push ax,
	call make_message

	nop	
	nop
ENDM

;----------------------------------------------------------------------------------                                                        
;used reg: ah, bh, dx
;input data:
;	dh - row
;	dl - column	 
;----------------------------------------------------------------------------------
set_cursor proc
	mov ah, 02
	mov bh, 0     		

	int 10h

	ret
set_cursor endp

;----------------------------------------------------------------------------------                                                        
;input data:
;	di - adress of buffer with password (pass ends with '$')
;return data:
;	
;----------------------------------------------------------------------------------
check_password proc

;	si - adress of correct password
;	di - adress of user password (buffer adress)
;	cx - number of symbols in password               
	mov si, offset correct_password
	mov cx, password_len
	call strcmp

	or ax, ax
	je print_correct
	jmp print_incorrect

print_correct:
;	making message
;	[bp+4]  ident y
;	[bp+6]  ident x
;	[bp+8]  message id

	mov cx, count
	mov di,	ident_x
	mov dx, ident_y
	mov bx, size_x
	mov ax, size_y
	call draw_animated_background

	call draw_frame
	call draw_shades
	
	mov ax, offset account_logged
	push ax
	mov ax, correct_pass_x
	push ax	
	mov ax, correct_pass_y + 1
	push ax
	call make_message
	
	mov ax, offset bits_message
	push ax
	mov ax, correct_pass_x
	push ax	
	mov ax, correct_pass_y + 5
	push ax
	call make_message

	mov ax, offset bitcoin_value
	push ax
	mov ax, bitcoin_ident_x
	push ax	
	mov ax, correct_pass_y + 5
	push ax
	call make_message

jmp end_check	

print_incorrect:

	mov ax, offset password_not_passed
	push ax
	push false_pass_x
	push false_pass_y
	call make_message

end_check:
	ret
check_password endp


draw_frame proc

	mov ax, ident_frame_y
	mov bx, ident_frame_x
	mov si, 2
	mov cx, size_frame_x
	mov dl, border_x
	mov dh, color_screen
	call draw_line

	mov byte ptr es:[bx], corner_ru
	mov byte ptr es:[bx+1], color_screen	
	
	mov ax, ident_frame_y + 1
	mov bx, ident_frame_x + size_frame_x
	mov si, 160
	mov cx, size_frame_y - 1
	mov dl, border_y
	mov dh, color_screen
	call draw_line

	mov byte ptr es:[bx], corner_rd
	mov byte ptr es:[bx+1], color_screen
	
	mov ax, ident_frame_y + size_frame_y
	mov bx, ident_frame_x + size_frame_x - 1
	mov si, -2
	mov cx, size_frame_x - 1
	mov dl, border_x
	mov dh, color_screen
	call draw_line

	mov byte ptr es:[bx], corner_ld
	mov byte ptr es:[bx+1], color_screen

	mov ax, ident_frame_y + size_frame_y - 1
	mov bx, ident_frame_x
	mov si, -160
	mov cx, size_frame_y - 1
	mov dl, border_y
	mov dh, color_screen
	call draw_line

	mov byte ptr es:[bx], corner_lu
	mov byte ptr es:[bx+1], color_screen

	ret
draw_frame endp

;-----------------------------
;prints a line with give coordinates with cx - number of elems to print
;jump - must be divisible by 2
;used reg: ax bx si cx dx  
;input data:
;	ax - y coord
;	bx - x coord
;	si - jump
;	cx - count
;	dl - elem type
;	dh - color
;returns: nothing
;-----------------------------
draw_line proc

        push dx
        push si
	mov si, 160
	mul si
	pop si
	pop dx	

	sal bx, 1
	add bx, ax

loop_print:
	call make_sleep	
	
	mov byte ptr es:[bx], dl
	mov byte ptr es:[bx+1], dh	

	add bx, si
	
	loop loop_print

	ret

draw_line endp 
	
;----------------------------------------------------------------------------------                                                        
;prints shades around our frame
;used reg: ax bx si cx dx  
;input data:
;	nothing
;returns: nothing     
;----------------------------------------------------------------------------------

draw_shades proc
	;First layer

	mov ax, ident_frame_y - 1
	mov bx, ident_frame_x + 1
	mov si, 2
	mov cx, size_frame_x + 2
	mov dl, shade_bright
	mov dh, color_screen
	call draw_line
	                   	
	mov ax, ident_frame_y + size_frame_y - 1
	mov bx, ident_frame_x + size_frame_x + 1
	mov si, -160
	mov cx, size_frame_y
	mov dl, shade_bright
	mov dh, color_screen
	call draw_line

	mov ax, ident_frame_y + size_frame_y - 1
	mov bx, ident_frame_x + size_frame_x + 2
	mov si, -160
	mov cx, size_frame_y
	mov dl, shade_bright
	mov dh, color_screen
	call draw_line

	;Second layer

	mov ax, ident_frame_y - 2
	mov bx, ident_frame_x + 2
	mov si, 2
	mov cx, size_frame_x + 3
	mov dl, shade_dim
	mov dh, color_screen
	call draw_line
	                   	
	mov ax, ident_frame_y + size_frame_y - 2
	mov bx, ident_frame_x + size_frame_x + 3
	mov si, -160
	mov cx, size_frame_y
	mov dl, shade_dim
	mov dh, color_screen
	call draw_line

	mov ax, ident_frame_y + size_frame_y - 2
	mov bx, ident_frame_x + size_frame_x + 4
	mov si, -160
	mov cx, size_frame_y
	mov dl, shade_dim
	mov dh, color_screen
	call draw_line
	
	ret

draw_shades endp

;----------------------------------------------------------------------------------                                                        
;makes program wait for some time
;used reg: ax cx dx
;input data:
;returns nothing	
;----------------------------------------------------------------------------------

make_sleep proc
	push ax
	push cx
	push dx

	mov ah, 86h 			;waiting
	xor cx, cx			;time in cx:dx 
	mov dx, break_time		;put time in here
	int 15h
	
	pop dx
	pop cx
	pop ax
	ret
	
make_sleep endp

;----------------------------------------------------------------------------------                                                        
;draw one background with given paremeters
;needed es to be b800h
;used reg: dx bp di si ax cx
;input data:
;	[bp+4]  width y
;	[bp+6]  width x
;	[bp+8]  ident y
;	[bp+10]	ident x
;	[bp+12] color of background
;----------------------------------------------------------------------------------
draw_background proc	
	push bp
	mov bp, sp
	push di
	push dx
	push bx
	push ax
	push cx
	
	mov dx, [bp+4]			;getting y size	of frame and conter rows
	xor di, di                      ;
loop_rows:

	mov ax, [bp+8]
	add ax, di			;going down rows
	inc di

	push dx				;need to be saved because of mul
	mov si, 160
	mul si
	pop dx

	mov si, [bp+10] 	
	sal si, 1			;mult by 2
	
	add ax, si
	inc ax				;full adress found
	mov bx, ax			;can't [ax] lol

	mov cx, [bp+6]			;counter elem in row
	mov ax, [bp+12]
loop_colums:
	
	mov byte ptr es:[bx], al	;set color
	
	inc bx
	inc bx

	loop loop_colums	
	
        dec dx
	cmp dx, 0
	jne loop_rows

	pop cx
	pop ax
	pop bx
	pop dx
	pop di
	pop bp
	ret 10 				;number of bytes to clear	

draw_background endp

;----------------------------------------------------------------------------------                                                        
;draw animated background
;needed es to be b800h
;used reg: 
;input data:
;	ax width y
;	bx width x
;	dx ident y
;	di ident x
;	cx count
;returns nothing 
;----------------------------------------------------------------------------------
draw_animated_background proc
	push bp
	mov bp, sp	

loop_draw:
	
	push color_backgrd
	push di
	push dx
	push bx
	push ax
	call draw_background 	

	call make_sleep
	inc ax
	inc ax
        add bx, width_x_step
	dec dx	
	dec di
	dec di

	loop loop_draw

	pop bp

	ret 0
draw_animated_background endp


;----------------------------------------------------------------------------------                                                        
;STRCMP
;used reg:
;input data:
;	si - adress of correct password
;	di - adress of user password (buffer adress)
;	cx - number of symbols in password
;	cmpsb - compares byte with adress DS:SI with byte adress ES:DI 
;return data:
;	ax - comparison result (0 if string are equal)    
;----------------------------------------------------------------------------------
strcmp proc
	push bp
	mov bp, sp	

strcmp_loop:
	mov ah, [si]
	mov al, [di]
	inc si
	inc di

	cmp ah, al
	jne end_strcmp

	cmp ah, '$'
	je end_strcmp

	loop strcmp_loop	

end_strcmp:
	sub al, ah
	xor ah, ah	
	
	pop bp

	ret
strcmp endp

COMMENT %
;----------------------------------------------------------------------------------                                                        
;makes program wait for some time
;used reg: ax cx dx
;input data:
;	dx - sleep_time
;returns nothing	
;----------------------------------------------------------------------------------
make_sleep proc
	push ax
	push cx
	push dx

	mov ah, 86h 			;waiting
	xor cx, cx			;time in cx:dx 
	mov dx, 0A800h
	int 15h
	
	pop dx
	pop cx
	pop ax

	ret
make_sleep endp
%

;----------------------------------------------------------------------------------                                                        
;used reg:ax di bx bp dxs
;input data:
;	dh - cursor pos row
;	dl - cursor pos column
;	keyboard input
;----------------------------------------------------------------------------------

get_string proc

	mov ax, offset greeting_message
	push ax
	mov ax, greeting_x
	push ax
	mov ax, greeting_y
	push ax
	call make_message	

	mov dh, greeting_y
	mov dl, greeting_len
	call set_cursor

	mov bx, offset buffer

loop_get_string:		
	xor ah, ah
	
	mov ah, 01h
	int 21h
       
	cmp al, 0ah	
	je loop_get_end

	mov byte ptr [bx], al 
	inc bx
	
	cmp bx, offset buffer + 128
	jae buffer_overflow

end_buffer_overflow:
	jmp loop_get_string    

loop_get_end:
	mov al, '$'
	mov byte ptr [bx], al 

	ret
                                  
buffer_overflow:
	sub bx, buff_size
jmp end_buffer_overflow
;END buffer

get_string endp

buff_size	equ 144

password_not_passed db 'This is incorrect password!$'        ;28

greeting_message db 'Enter your bitcoin wallet password:$'   ;36
greeting_len	 equ $ - greeting_message

bitcoin_value	 db '0.00128$'                               ;8
correct_password db 'qwerty$'                                ;7
password_len	 equ $ - correct_password

buffer db 128 dup (0)

account_logged	 db 'Now you are logged in bitcoin wallet.$'
bits_message     db 'Your current value:$'

end	Start