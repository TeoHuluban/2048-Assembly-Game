.586
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc
extern fopen: proc
extern fclose: proc
extern fprintf: proc
extern fscanf: proc

includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
image_width0 EQU 48
image_height EQU 80
image_width1 EQU 32
include patru.inc
window_title DB "2048 - Huluban Teodora",0
area_width EQU 640
area_height EQU 480
area DD 0

counter DD 0 ; numara evenimentele de tip timer

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20

file dd 0
format_score db "%d ", 0
mode_append DB "a", 0
mode_read DB "r", 0
file_name DB "scores.txt", 0
unusase dd 16
doi dd 2
zece dd 10
color dd 0

tabla1 dd 0,0,0,0
	   dd 0,0,0,0
	   dd 0,0,0,0
	   dd 0,0,0,0
	   
tabla2 dd 0,0,0,0
	   dd 0,0,0,0
	   dd 0,0,0,0
	   dd 0,0,0,0
	   
tabla_aux dd 0,0,0,0
	      dd 0,0,0,0
	      dd 0,0,0,0
	      dd 0,0,0,0
	   
tabla_combinare dd 0,0,0,0
				dd 0,0,0,0
				dd 0,0,0,0
				dd 0,0,0,0
	   
tablax dd 95,175,255,335
	   dd 95,175,255,335
	   dd 95,175,255,335
	   dd 95,175,255,335
	   
tablay dd 130,130,130,130
	   dd 210,210,210,210
	   dd 290,290,290,290
	   dd 370,370,370,370

score dd 0
score_back dd 0 
game_over dd 2
c0 dd 0
c1 dd 0
c2 dd 0
c3 dd 0
symbol_width EQU 10
symbol_height EQU 20
include digits.inc
include letters.inc

.code
make_image0 proc
	push ebp
	mov ebp, esp
	pusha

	lea esi, var_0
	
draw_image:
	mov ecx, image_height
loop_draw_lines:
	mov edi, [ebp+arg1] ; pointer to pixel area
	mov eax, [ebp+arg3] ; pointer to coordinate y
	
	add eax, image_height
	sub eax, ecx ; current line to draw (total - ecx)
	
	mov ebx, area_width
	mul ebx	; get to current line
	
	add eax, [ebp+arg2] ; get to coordinate x in current line
	shl eax, 2 ; multiply by 4 (DWORD per pixel)
	add edi, eax
	
	push ecx
	mov ecx, image_width0 ; store drawing width for drawing loop
	
loop_draw_columns:

	push eax
	mov eax, dword ptr[esi] 
	mov dword ptr [edi], eax ; take data from variable to canvas
	pop eax
	
	add esi, 4
	add edi, 4 ; next dword (4 Bytes)
	
	loop loop_draw_columns
	
	pop ecx
	loop loop_draw_lines
	popa
	
	mov esp, ebp
	pop ebp
	ret
make_image0 endp

make_image1 proc
	push ebp
	mov ebp, esp
	pusha

	lea esi, var_1
	
draw_image:
	mov ecx, image_height
loop_draw_lines:
	mov edi, [ebp+arg1] ; pointer to pixel area
	mov eax, [ebp+arg3] ; pointer to coordinate y
	
	add eax, image_height
	sub eax, ecx ; current line to draw (total - ecx)
	
	mov ebx, area_width
	mul ebx	; get to current line
	
	add eax, [ebp+arg2] ; get to coordinate x in current line
	shl eax, 2 ; multiply by 4 (DWORD per pixel)
	add edi, eax
	
	push ecx
	mov ecx, image_width1 ; store drawing width for drawing loop
	
loop_draw_columns:

	push eax
	mov eax, dword ptr[esi] 
	mov dword ptr [edi], eax ; take data from variable to canvas
	pop eax
	
	add esi, 4
	add edi, 4 ; next dword (4 Bytes)
	
	loop loop_draw_columns
	
	pop ecx
	loop loop_draw_lines
	popa
	
	mov esp, ebp
	pop ebp
	ret
make_image1 endp

; simple macro to call the procedure easier
make_image_macro macro drawArea, x, y, z
local next, final
	push y
	push x
	push drawArea
	mov eax, z
	cmp eax, 0
	jne next
	call make_image0
	jmp final
	next:
	call make_image1
	final:
	add esp, 12
endm

image macro x, y
	make_image_macro area, x, y, 0
	make_image_macro area, x+48, y, 1
endm

; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y

make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov edx, color
	mov dword ptr [edi], edx
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], 0FFFFFFh
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp

; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;TABLA;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
linie_o macro x, y, len, color
local bucla
	mov eax, y
	mov ebx, area_width
	mul ebx
	add eax, x
	shl eax, 2
	add eax, area
	mov ecx, len
	bucla:
		mov dword ptr[eax], color
		add eax, 4
	loop bucla
endm

linie_v macro x, y, len, color
local bucla
	mov eax, y
	mov ebx, area_width
	mul ebx
	add eax, x
	shl eax, 2
	add eax, area
	mov ecx, len
	bucla:
		mov dword ptr[eax], color
		add eax, 4*area_width
	loop bucla
endm

patrat macro x, y, dim, color
	linie_o x, y, dim, color
	linie_o x, y+dim, dim, color
	linie_v x, y, dim, color
	linie_v x+dim, y, dim, color
endm


creare_tabla macro x, y, dim, color
	patrat x, y, dim/4, 0
	patrat x+dim/4, y, dim/4, 0
	patrat x+(dim/4)*2, y, dim/4, 0
	patrat x+(dim/4)*3, y, dim/4, 0
	
	patrat x, y+dim/4, dim/4, 0
	patrat x+dim/4, y+dim/4, dim/4, 0
	patrat x+(dim/4)*2, y+dim/4, dim/4, 0
	patrat x+(dim/4)*3, y+dim/4, dim/4, 0
	
	patrat x, y+(dim/4)*2, dim/4, 0
	patrat x+dim/4, y+(dim/4)*2, dim/4, 0
	patrat x+(dim/4)*2, y+(dim/4)*2, dim/4, 0
	patrat x+(dim/4)*3, y+(dim/4)*2, dim/4, 0
	
	patrat x, y+(dim/4)*3, dim/4, 0
	patrat x+dim/4, y+(dim/4)*3, dim/4, 0
	patrat x+(dim/4)*2, y+(dim/4)*3, dim/4, 0
	patrat x+(dim/4)*3, y+(dim/4)*3, dim/4, 0
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	patrat x-1, y-1, dim/4, 0
	patrat x-1+dim/4, y-1, dim/4, 0
	patrat x-1+(dim/4)*2, y-1, dim/4, 0
	patrat x-1+(dim/4)*3, y-1, dim/4, 0
	
	patrat x-1, y+dim/4-1, dim/4, 0
	patrat x-1+dim/4, y+dim/4-1, dim/4, 0
	patrat x-1+(dim/4)*2, y+dim/4-1, dim/4, 0
	patrat x-1+(dim/4)*3, y+dim/4-1, dim/4, 0
	
	patrat x-1, y+(dim/4)*2-1, dim/4, 0
	patrat x-1+dim/4, y+(dim/4)*2-1, dim/4, 0
	patrat x-1+(dim/4)*2, y+(dim/4)*2-1, dim/4, 0
	patrat x-1+(dim/4)*3, y+(dim/4)*2-1, dim/4, 0
	
	patrat x-1, y+(dim/4)*3-1, dim/4, 0
	patrat x-1+dim/4, y+(dim/4)*3-1, dim/4, 0
	patrat x-1+(dim/4)*2, y+(dim/4)*3-1, dim/4, 0
	patrat x-1+(dim/4)*3, y+(dim/4)*3-1, dim/4, 0
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	patrat x-2, y-2, dim/4, 0
	patrat x-2+dim/4, y-2, dim/4, 0
	patrat x-2+(dim/4)*2, y-2, dim/4, 0
	patrat x-2+(dim/4)*3, y-2, dim/4, 0
	
	patrat x-2, y+dim/4-2, dim/4, 0
	patrat x-2+dim/4, y+dim/4-2, dim/4, 0
	patrat x-2+(dim/4)*2, y+dim/4-2, dim/4, 0
	patrat x-2+(dim/4)*3, y+dim/4-2, dim/4, 0
	
	patrat x-2, y+(dim/4)*2-2, dim/4, 0
	patrat x-2+dim/4, y+(dim/4)*2-2, dim/4, 0
	patrat x-2+(dim/4)*2, y+(dim/4)*2-2, dim/4, 0
	patrat x-2+(dim/4)*3, y+(dim/4)*2-2, dim/4, 0
	
	patrat x-2, y+(dim/4)*3-2, dim/4, 0
	patrat x-2+dim/4, y+(dim/4)*3-2, dim/4, 0
	patrat x-2+(dim/4)*2, y+(dim/4)*3-2, dim/4, 0
	patrat x-2+(dim/4)*3, y+(dim/4)*3-2, dim/4, 0
endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;PLASARE_RANDOM;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
randPozGen proc
	rdtsc
	mov edx, 0
	div unusase
	mov eax, edx
	ret
randPozGen endp

randNumGen proc
	rdtsc
	mov edx, 0
	div zece
	cmp edx, 5
	ja _patru
	_doi:
	mov eax, 2
	jmp _ret
	_patru:
	mov eax, 4
	_ret:
	ret
randNumGen endp

pls_mat proc 
	call randNumGen
	mov ebx, eax
	call randPozGen
	dec eax
	mov ecx, 16
	_loop:
	inc eax
	cmp eax, 16
	jb _cmp
	mov eax, 0
	_cmp:
	cmp dword ptr[tabla1[eax*4]], 0
	je afr
	loop _loop
	mov game_over, 1
	jmp _ret
	afr:
	mov dword ptr[tabla1[eax*4]], ebx
	_ret:
	ret
pls_mat endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;AFISARE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
afis2 macro x,y
mov color, 0EE8900h
make_text_macro '2', area, x, y
endm

afis4 macro x,y
mov color, 028417h
make_text_macro '4', area, x, y
endm

afis8 macro x,y
mov color, 0199A6h
make_text_macro '8', area, x, y
endm

afis16 macro x,y
mov color, 566CFFh
mov edx, x
sub edx, 5
make_text_macro '1', area, edx, y
add edx, 10
make_text_macro '6', area, edx, y
endm

afis32 macro x,y
mov color, 0BA250Ah
mov edx, x
sub edx, 5
make_text_macro '3', area, edx, y
add edx, 10
make_text_macro '2', area, edx, y
endm

afis64 macro x,y
mov color, 6F12DDh
mov edx, x
sub edx, 5
make_text_macro '6', area, edx, y
add edx, 10
make_text_macro '4', area, edx, y
endm

afis128 macro x,y
mov color, 0022C3h
mov edx, x
sub edx, 10
make_text_macro '1', area, edx, y
add edx, 10
make_text_macro '2', area, edx, y
add edx, 10
make_text_macro '8', area, edx, y
endm

afis256 macro x,y
mov color, 348845h
mov edx, x
sub edx, 10
make_text_macro '2', area, edx, y
add edx, 10
make_text_macro '5', area, edx, y
add edx, 10
make_text_macro '6', area, edx, y
endm

afis512 macro x,y
mov color, 96008Ah
mov edx, x
sub edx, 10
make_text_macro '5', area, edx, y
add edx, 10
make_text_macro '1', area, edx, y
add edx, 10
make_text_macro '2', area, edx, y
endm

afis1024 macro x,y
mov color, 717474h
mov edx, x
sub edx, 15
make_text_macro '1', area, edx, y
add edx, 10
make_text_macro '0', area, edx, y
add edx, 10
make_text_macro '2', area, edx, y
add edx, 10
make_text_macro '4', area, edx, y
endm

afis2048 macro x,y
mov color, 0FF0000h
mov edx, x
sub edx, 15
make_text_macro '2', area, edx, y
add edx, 10
make_text_macro '0', area, edx, y
add edx, 10
make_text_macro '4', area, edx, y
add edx, 10
make_text_macro '8', area, edx, y
endm

afis_mat proc
	mov eax, 0
	_loop:
	spatiu:
	mov edx, tablax[eax*4]
	sub edx, 15
	make_text_macro ' ', area, edx, tablay[eax*4]
	add edx, 10
	make_text_macro ' ', area, edx, tablay[eax*4]
	add edx, 10
	make_text_macro ' ', area, edx, tablay[eax*4]
	add edx, 10
	make_text_macro ' ', area, edx, tablay[eax*4]
	cmp tabla1[eax*4], 0
	je fin
	
	_2:
	cmp tabla1[eax*4], 2
	jne _4
	afis2 tablax[eax*4], tablay[eax*4]
	jmp fin
	
	_4:
	cmp tabla1[eax*4], 4
	jne _8
	afis4 tablax[eax*4], tablay[eax*4]
	jmp fin
	
	_8:
	cmp tabla1[eax*4], 8
	jne _16
	; image 95-35, 130-30
	afis8 tablax[eax*4], tablay[eax*4]
	jmp fin
	
	_16:
	cmp tabla1[eax*4], 16
	jne _32
	afis16 tablax[eax*4], tablay[eax*4]
	jmp fin
	
	_32:
	cmp tabla1[eax*4], 32
	jne _64
	afis32 tablax[eax*4], tablay[eax*4]
	jmp fin
	
	_64:
	cmp tabla1[eax*4], 64
	jne _128
	afis64 tablax[eax*4], tablay[eax*4]
	jmp fin
	
	_128:
	cmp tabla1[eax*4], 128
	jne _256
	afis128 tablax[eax*4], tablay[eax*4]
	jmp fin
	
	_256:
	cmp tabla1[eax*4], 256
	jne _512
	afis256 tablax[eax*4], tablay[eax*4]
	jmp fin
	
	_512:
	cmp tabla1[eax*4], 512
	jne _1024
	afis512 tablax[eax*4], tablay[eax*4]
	jmp fin
	
	_1024:
	cmp tabla1[eax*4], 1024
	jne _2048
	afis1024 tablax[eax*4], tablay[eax*4]
	jmp fin
	
	_2048:
	cmp tabla1[eax*4], 2048
	jne fin
	afis2048 tablax[eax*4], tablay[eax*4]
	jmp fin
	
	fin:
	inc eax
	cmp eax, 16
	jl _loop
	
	ret
afis_mat endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;COPIERE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
copy_mat proc
	mov eax, tabla_aux[0]
	mov tabla1[0], eax
	
	mov ecx, 15
	_loop:
	mov eax, tabla_aux[ecx*4]
	mov tabla1[ecx*4], eax
	loop _loop
	ret
copy_mat endp

copy_mat_back proc
	mov eax, tabla1[0]
	mov tabla2[0], eax
	
	mov ecx, 15
	_loop:
	mov eax, tabla1[ecx*4]
	mov tabla2[ecx*4], eax
	loop _loop
	ret
copy_mat_back endp

copy_from_mat_back proc
	mov eax, tabla2[0]
	mov tabla1[0], eax
	
	mov ecx, 15
	_loop:
	mov eax, tabla2[ecx*4]
	mov tabla1[ecx*4], eax
	loop _loop
	ret
copy_from_mat_back endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;ROTIRE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
rotire_mat proc
	mov ecx, tabla1[3*4]
	mov tabla_aux[0], ecx
	mov ecx, tabla1[7*4]
	mov tabla_aux[1*4], ecx
	mov ecx, tabla1[11*4]
	mov tabla_aux[2*4], ecx
	mov ecx, tabla1[15*4]
	mov tabla_aux[3*4], ecx
	mov ecx, tabla1[2*4]
	mov tabla_aux[4*4], ecx
	mov ecx, tabla1[6*4]
	mov tabla_aux[5*4], ecx
	mov ecx, tabla1[10*4]
	mov tabla_aux[6*4], ecx
	mov ecx, tabla1[14*4]
	mov tabla_aux[7*4], ecx
	mov ecx, tabla1[1*4]
	mov tabla_aux[8*4], ecx
	mov ecx, tabla1[5*4]
	mov tabla_aux[9*4], ecx
	mov ecx, tabla1[9*4]
	mov tabla_aux[10*4], ecx
	mov ecx, tabla1[13*4]
	mov tabla_aux[11*4], ecx
	mov ecx, tabla1[0*4]
	mov tabla_aux[12*4], ecx
	mov ecx, tabla1[4*4]
	mov tabla_aux[13*4], ecx
	mov ecx, tabla1[8*4]
	mov tabla_aux[14*4], ecx
	mov ecx, tabla1[12*4]
	mov tabla_aux[15*4], ecx
	call copy_mat
	ret
rotire_mat endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;STERGERE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
stergere_mat proc
	mov tabla_combinare[0], 0
	mov ecx, 15
	_loop:
	mov tabla_combinare[ecx*4], 0
	loop _loop
	ret
stergere_mat endp

stergere proc
	mov tabla1[0], 0
	mov ecx, 15
	_loop:
	mov tabla1[ecx*4], 0
	loop _loop
	ret
stergere endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;DEPLASARE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
deplasare_sus proc
	call stergere_mat
	mov edx, 0
	mov eax, 3
_loop1:
	inc eax
	cmp eax, 15
	ja fin
	mov ecx, eax
	mov ebx, eax
	sub ebx, 4
	_loop2:	
		mov edx, tabla1[ebx*4]
		cmp tabla1[ebx*4], 0
		je _add
		
		cmp tabla_combinare[ecx*4], 1
		je _loop1

		cmp tabla1[ecx*4], edx
		jne _loop1
		mov tabla_combinare[ebx*4], 1
		mov tabla_combinare[ecx*4], 1
		jmp _add
		
		_add:
			add score, edx
			add score, edx
			add edx, tabla1[ecx*4]
			mov tabla1[ebx*4], edx
			mov tabla1[ecx*4], 0
			cmp ebx, 4
			jb _loop1
			sub ecx, 4
			sub ebx, 4
			jmp _loop2
	fin:
	ret
deplasare_sus endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;SCOR;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
afis_scor proc
	mov color, 0
	cmp edx, 0
	jne unu
	make_text_macro '0', area, ebx, ecx
	jmp fin
	unu:
	cmp edx, 1
	jne _doi
	make_text_macro '1', area, ebx, ecx
	jmp fin
	_doi:
	cmp edx, 2
	jne trei
	make_text_macro '2', area, ebx, ecx
	jmp fin
	trei:
	cmp edx, 3
	jne patru
	make_text_macro '3', area, ebx, ecx
	jmp fin
	patru:
	cmp edx, 4
	jne cinci
	make_text_macro '4', area, ebx, ecx
	jmp fin
	cinci:
	cmp edx, 5
	jne sase
	make_text_macro '5', area, ebx, ecx
	jmp fin
	sase:
	cmp edx, 6
	jne sapte
	make_text_macro '6', area, ebx, ecx
	jmp fin
	sapte:
	cmp edx, 7
	jne opt
	make_text_macro '7', area, ebx, ecx
	jmp fin
	opt:
	cmp edx, 8
	jne noua
	make_text_macro '8', area, ebx, ecx
	jmp fin
	noua:
	make_text_macro '9', area, ebx, ecx
	fin:
	ret
afis_scor endp

scor proc
	mov ecx, 160
	mov eax, score
	
	mov edx, 0
	mov ebx, 530
	div zece
	call afis_scor
	
	mov edx, 0
	mov ebx, 520
	div zece
	call afis_scor
	
	mov edx, 0
	mov ebx, 510
	div zece
	call afis_scor
	
	mov edx, 0
	mov ebx, 500
	div zece
	call afis_scor
	ret
scor endp

	; mov ecx, 4
	; _loop1:
	; cmp tabla1[ecx *4], 0
	; jne _next1
	; loop _loop1
	; _next1:
	; mov eax, tabla1[ecx*4]
	; mov tabla1[3*4], eax
	; mov tabla1[ecx*4], 0

	; mov ecx, 3
	; _loop2:
	; cmp tabla1[ecx*4], 0
	; jne _next2
	; loop _loop2
	; _next2:
	; mov eax, tabla1[ecx*4]
	; mov tabla1[3*4], eax
	; mov tabla1[ecx*4], 0
	
	; mov ecx, 2
	; _loop3:
	; cmp tabla1[ecx*4], 0
	; jne _next3
	; loop _loop3
	; _next3:
	; mov eax, tabla1[ecx*4]
	; mov tabla1[3*4], eax
	; mov tabla1[ecx*4], 0
	
	
	; cmp tabla1[eax*4], 0
	; je _unu
	; cmp tabla1[ebx*4], 0
	; je _unu
	; cmp tabla1[ebx*4],tabla1[eax*4]

	; _unu:
; mov pozc1,16
; mov pozc2,16
; mov pozm1,16
; mov pozm2,16
	; cmp tabla1[eax*4], 0 ;verificam daca pozitia 3 e libera
	; jne _pozc1 ;daca nu e libera sarim la _pozc1
	; mov pozm1, eax ;daca e libera eax devine pozm1
	; jmp _loop ;
	; _pozc1: 
	; mov pozc1, eax ;eax devine pozc1
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; cmp tabla1[ecx*4], 0 
	; je _pozm ;daca pozitia 2 e libera 
	; jne _pozc  ;daca pozitia 2 nu e libera 
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; _pozc:
	; cmp pozc1, 16 
	; jne _pozc2 ;daca pozc1 e ocupat
	; mov pozc1, tabla1[ecx*4]
	; jmp _loop
	
	; _pozc2:
	; mov pozc2, tabla1[ecx*4]
	
	; jmp _loop
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; _pozm:
	; _pozm2:
	; mov pozm2, ecx
	
	; cmp eax, 0
	; jne _pozc1
	; mov pozm1, eax
	; jmp _loop
	; _pozc1
	; mov pozc1, eax
	
	; cmp eax, 0
	; jne _pozc1
	; mov pozm1, eax
	; jmp _loop
	; _pozc1
	; mov pozc1, eax
	; _comp:
	; mov eax, tabla1[ecx*4]
	; cmp eax, tabla1[(ecx+1)*4]
	; jne _next
	; add tabla1[(ecx+1)*4], eax
	; cmp tabla1[2*4], 0
	; je _poz1
	; mov eax, tabla1[2*4]
	; cmp eax, tabla1[3*4]
	; jne _next
	; add tabla1[3*4], eax
	; jmp _next
	; _poz1:
	
	; _next:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click, 3 - s-a apasat o tasta)
; arg2 - x (in cazul apasarii unei taste, x contine codul ascii al tastei care a fost apasata)
; arg3 - y
draw proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz evt_click
	cmp eax, 3
	jz evt_tasta
	cmp eax, 2
	jz evt_timer ; nu s-a efectuat click pe nimic
	;mai jos e codul care intializeaza fereastra cu pixeli albi
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255
	push area
	call memset
	add esp, 12
	jmp afisare_litere

evt_click:
	back:
	mov eax, [ebp+arg2] ;x
	mov ebx, [ebp+arg3] ;y
	cmp eax, 470
	jb new_game?
	cmp eax, 570
	ja new_game?
	cmp ebx, 360
	jb new_game?
	cmp ebx, 400
	ja new_game?
	
	mov eax, score_back
	mov score, eax
	call copy_from_mat_back
	jmp fin2
	
	new_game?:
	mov eax, [ebp+arg2] ;x
	mov ebx, [ebp+arg3] ;y
	cmp eax, 470
	jb scores?
	cmp eax, 570
	ja scores?
	cmp ebx, 300
	jb scores?
	cmp ebx, 340
	ja scores?
	new_game:
	mov counter, 0
	mov game_over, 0
	call stergere
	mov score, 0
	mov score_back, 0
	call pls_mat
	call pls_mat
	call copy_mat_back
	jmp fin2
	
	scores?:
	mov eax, [ebp+arg2] ;x
	mov ebx, [ebp+arg3] ;y
	cmp eax, 350
	jb fin2
	cmp eax, 450
	ja fin2
	cmp ebx, 300
	jb fin2
	cmp ebx, 340
	ja fin2
	scores:
	push offset mode_read
	push offset file_name
	call fopen
	add ESP, 8
	mov file, eax
	push score
	push offset format_score
	push file
	call fscanf
	add esp, 12
	call score
	jmp continue
	
	
	
evt_tasta:
	call copy_mat_back
	mov eax, score
	mov score_back, eax
	mov ebx, [ebp+arg2]
	cmp ebx, '&'
	je sus
	cmp ebx, '('
	je jos
	cmp ebx, "'"
	je dreapta
	cmp ebx, '%'
	je stanga
	jmp fin2

	sus:
	call deplasare_sus
	jmp fin
	
	jos:
	call rotire_mat
	call rotire_mat
	call deplasare_sus
	call rotire_mat
	call rotire_mat
	jmp fin
	
	dreapta:
	call rotire_mat
	call deplasare_sus
	call rotire_mat
	call rotire_mat
	call rotire_mat
	jmp fin
	
	stanga:
	call rotire_mat
	call rotire_mat
	call rotire_mat
	call deplasare_sus
	call rotire_mat
	
	fin:
	call pls_mat
	cmp game_over, 1
	jne fin2
	push offset mode_append
	push offset file_name
	call fopen
	add ESP, 8
	mov file, eax
	push score
	push offset format_score
	push eax
	call fprintf
	add esp, 12
	push file
	call fclose
	add ESP, 4 
	
	fin2:

evt_timer:
;buton new game
	mov color, 0
	linie_o 470,300,100,0A12605h
	linie_o 470,340,100,0E43506h
	linie_v 470,300,40,0A12605h
	linie_v 570,300,40,0E43506h
	linie_o 470-1,300-1,100,0A12605h
	linie_o 470-1,340-1,100,0E43506h
	linie_v 470-1,300-1,40,0A12605h
	linie_v 570-1,300-1,40,0E43506h
	linie_o 470-2,300-2,100,0A12605h
	linie_o 470-2,340-2,100,0E43506h
	linie_v 470-2,300-2,40,0A12605h
	linie_v 570-2,300-2,40,0E43506h
	make_text_macro 'N', area, 480, 310
	make_text_macro 'E', area, 490, 310
	make_text_macro 'W', area, 500, 310
	make_text_macro ' ', area, 510, 310
	make_text_macro 'G', area, 520, 310
	make_text_macro 'A', area, 530, 310
	make_text_macro 'M', area, 540, 310
	make_text_macro 'E', area, 550, 310
	
	linie_o 350,300,100,0A12605h
	linie_o 350,340,100,0E43506h
	linie_v 350,300,40,0A12605h
	linie_v 450,300,40,0E43506h
	linie_o 350-1,300-1,100,0A12605h
	linie_o 350-1,340-1,100,0E43506h
	linie_v 350-1,300-1,40,0A12605h
	linie_v 450-1,300-1,40,0E43506h
	linie_o 350-2,300-2,100,0A12605h
	linie_o 350-2,340-2,100,0E43506h
	linie_v 350-2,300-2,40,0A12605h
	linie_v 450-2,300-2,40,0E43506h
	
	make_text_macro 'S', area, 370, 310
	make_text_macro 'C', area, 380, 310
	make_text_macro 'O', area, 390, 310
	make_text_macro 'R', area, 400, 310
	make_text_macro 'E', area, 410, 310
	make_text_macro 'S', area, 420, 310
	
	make_text_macro 'H', area, 120, 440
	make_text_macro 'U', area, 130, 440
	make_text_macro 'L', area, 140, 440
	make_text_macro 'U', area, 150, 440
	make_text_macro 'B', area, 160, 440
	make_text_macro 'A', area, 170, 440
	make_text_macro 'N', area, 180, 440
	make_text_macro ' ', area, 190, 440
	make_text_macro 'T', area, 200, 440
	make_text_macro 'E', area, 210, 440
	make_text_macro 'O', area, 220, 440
	make_text_macro 'D', area, 230, 440
	make_text_macro 'O', area, 240, 440
	make_text_macro 'R', area, 250, 440
	make_text_macro 'A', area, 260, 440
	cmp game_over, 2
	jz continue
	inc counter
	
afisare_litere:
	mov color, 0
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255
	push area
	call memset
	add esp, 12
	;afisam valoarea counter-ului curent (sute, zeci si unitati)
	mov ebx, 10
	mov eax, counter
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 30, 10
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 20, 10
	;cifra sutelor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 10, 10

	make_text_macro '2', area, 175, 65
	make_text_macro '0', area, 200, 65
	make_text_macro '4', area, 225, 65
	make_text_macro '8', area, 250, 65
	
	cmp game_over, 2
	jz continue
	
	;scor
	make_text_macro 'S', area, 485, 120
	make_text_macro 'C', area, 500, 120
	make_text_macro 'O', area, 515, 120
	make_text_macro 'R', area, 530, 120
	make_text_macro 'E', area, 545, 120
	linie_o 460,150,120,0A9AF05h
	linie_o 460,190,120,0C7CD04h
	linie_v 460,150,40,0A9AF05h
	linie_v 580,150,40,0C7CD04h
	linie_o 460-1,150-1,120,0A9AF05h
	linie_o 460-1,190-1,120,0C7CD04h
	linie_v 460-1,150-1,40,0A9AF05h
	linie_v 580-1,150-1,40,0C7CD04h
	linie_o 460-2,150-2,120,0A9AF05h
	linie_o 460-2,190-2,120,0C7CD04h
	linie_v 460-2,150-2,40,0A9AF05h
	linie_v 580-2,150-2,40,0C7CD04h
	
	;buton new game
	linie_o 470,300,100,064F89h
	linie_o 470,340,100,0776CFh
	linie_v 470,300,40,064F89h
	linie_v 570,300,40,0776CFh
	linie_o 470-1,300-1,100,064F89h
	linie_o 470-1,340-1,100,0776CFh
	linie_v 470-1,300-1,40,064F89h
	linie_v 570-1,300-1,40,0776CFh
	linie_o 470-2,300-2,100,064F89h
	linie_o 470-2,340-2,100,0776CFh
	linie_v 470-2,300-2,40,064F89h
	linie_v 570-2,300-2,40,0776CFh
	make_text_macro 'N', area, 480, 310
	make_text_macro 'E', area, 490, 310
	make_text_macro 'W', area, 500, 310
	make_text_macro ' ', area, 510, 310
	make_text_macro 'G', area, 520, 310
	make_text_macro 'A', area, 530, 310
	make_text_macro 'M', area, 540, 310
	make_text_macro 'E', area, 550, 310
	
	;buton back
	linie_o 470,360,100,064F89h
	linie_o 470,400,100,0776CFh
	linie_v 470,360,40,064F89h
	linie_v 570,360,40,0776CFh
	linie_o 470-1,360-1,100,064F89h
	linie_o 470-1,400-1,100,0776CFh
	linie_v 470-1,360-1,40,064F89h
	linie_v 570-1,360-1,40,0776CFh
	linie_o 470-2,360-2,100,064F89h
	linie_o 470-2,400-2,100,0776CFh
	linie_v 470-2,360-2,40,064F89h
	linie_v 570-2,360-2,40,0776CFh
	make_text_macro 'B', area, 500, 370
	make_text_macro 'A', area, 510, 370
	make_text_macro 'C', area, 520, 370
	make_text_macro 'K', area, 530, 370
	
	make_text_macro 'H', area, 120, 440
	make_text_macro 'U', area, 130, 440
	make_text_macro 'L', area, 140, 440
	make_text_macro 'U', area, 150, 440
	make_text_macro 'B', area, 160, 440
	make_text_macro 'A', area, 170, 440
	make_text_macro 'N', area, 180, 440
	make_text_macro ' ', area, 190, 440
	make_text_macro 'T', area, 200, 440
	make_text_macro 'E', area, 210, 440
	make_text_macro 'O', area, 220, 440
	make_text_macro 'D', area, 230, 440
	make_text_macro 'O', area, 240, 440
	make_text_macro 'R', area, 250, 440
	make_text_macro 'A', area, 260, 440
	
	creare_tabla 60, 100, 320, 0
	
	call afis_mat
	call scor

	_game_over:
	cmp game_over, 1
	jne continue

	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255
	push area
	call memset
	add esp, 12
	
	make_text_macro 'S', area, 485, 120
	make_text_macro 'C', area, 500, 120
	make_text_macro 'O', area, 515, 120
	make_text_macro 'R', area, 530, 120
	make_text_macro 'E', area, 545, 120
	linie_o 460,150,120,0A9AF05h
	linie_o 460,190,120,0C7CD04h
	linie_v 460,150,40,0A9AF05h
	linie_v 580,150,40,0C7CD04h
	linie_o 460-1,150-1,120,0A9AF05h
	linie_o 460-1,190-1,120,0C7CD04h
	linie_v 460-1,150-1,40,0A9AF05h
	linie_v 580-1,150-1,40,0C7CD04h
	linie_o 460-2,150-2,120,0A9AF05h
	linie_o 460-2,190-2,120,0C7CD04h
	linie_v 460-2,150-2,40,0A9AF05h
	linie_v 580-2,150-2,40,0C7CD04h
	call scor 
	make_text_macro 'G', area, 200, 200
	make_text_macro 'A', area, 220, 200
	make_text_macro 'M', area, 240, 200
	make_text_macro 'E', area, 260, 200
	make_text_macro ' ', area, 280, 200
	make_text_macro 'O', area, 300, 200
	make_text_macro 'V', area, 320, 200
	make_text_macro 'E', area, 340, 200
	make_text_macro 'R', area, 360, 200
	linie_o 470,300,100,0A12605h
	linie_o 470,340,100,0E43506h
	linie_v 470,300,40,0A12605h
	linie_v 570,300,40,0E43506h
	linie_o 470-1,300-1,100,0A12605h
	linie_o 470-1,340-1,100,0E43506h
	linie_v 470-1,300-1,40,0A12605h
	linie_v 570-1,300-1,40,0E43506h
	linie_o 470-2,300-2,100,0A12605h
	linie_o 470-2,340-2,100,0E43506h
	linie_v 470-2,300-2,40,0A12605h
	linie_v 570-2,300-2,40,0E43506h
	make_text_macro 'N', area, 480, 310
	make_text_macro 'E', area, 490, 310
	make_text_macro 'W', area, 500, 310
	make_text_macro ' ', area, 510, 310
	make_text_macro 'G', area, 520, 310
	make_text_macro 'A', area, 530, 310
	make_text_macro 'M', area, 540, 310
	make_text_macro 'E', area, 550, 310
	
	make_text_macro 'H', area, 120, 440
	make_text_macro 'U', area, 130, 440
	make_text_macro 'L', area, 140, 440
	make_text_macro 'U', area, 150, 440
	make_text_macro 'B', area, 160, 440
	make_text_macro 'A', area, 170, 440
	make_text_macro 'N', area, 180, 440
	make_text_macro ' ', area, 190, 440
	make_text_macro 'T', area, 200, 440
	make_text_macro 'E', area, 210, 440
	make_text_macro 'O', area, 220, 440
	make_text_macro 'D', area, 230, 440
	make_text_macro 'O', area, 240, 440
	make_text_macro 'R', area, 250, 440
	make_text_macro 'A', area, 260, 440
	continue:
	
final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp 

start:
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	call pls_mat
	call pls_mat
	call copy_mat_back
	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	
	;terminarea programului
	push 0
	call exit
end start
