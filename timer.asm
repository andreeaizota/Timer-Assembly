.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc
extern printf: proc
includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "Timer",0
area_width EQU 600
area_height EQU 500
area DD 0
format DB "%d",0
counter DD 0 ; numara evenimentele de tip timer

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20

x DD 0
y DD 0

decrementeaza DD 0

hours DD 0
minutes DD 0
seconds DD 0

symbol_width EQU 34
symbol_height EQU 70
include digits.inc
include letters.inc

.code
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
	mov dword ptr [edi], 0
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

macro_linie_verticala macro x,y,lungime,culoare
	LOCAL repeta
	pusha
	mov esi,x
	mov edi,y
	mov ecx,lungime
	mov ebx,area
	repeta:
		mov eax,area_width
		xor edx,edx
		mul edi
		add eax,esi
		mov dword ptr[ebx+eax*4],culoare
		inc edi
	loop repeta
	popa
endm

macro_linie_orizontala macro x,y,lungime,culoare
	LOCAL repeta
	pusha
	mov esi,x
	mov edi,y
	mov ecx,lungime
	mov ebx,area
	repeta:
		mov eax,area_width
		xor edx,edx
		mul edi
		add eax,esi
		mov dword ptr[ebx+eax*4],culoare
		inc esi
	loop repeta
	popa
endm

macro_buton macro x,y,litera,culoare
	pusha
	
	mov eax,x
	add eax,20
	mov ebx,y
	add ebx,2
	make_text_macro litera,area,eax,ebx
	macro_linie_orizontala x,y,50,culoare
	mov edx,y
	add edx,29
	macro_linie_orizontala x,edx,50,culoare
	macro_linie_verticala x,y,30,culoare
	mov edx,x
	add edx,49
	macro_linie_verticala edx,y,30,culoare
	
	popa
endm

macro_start macro x,y,culoare
		pusha
		
		mov eax,x
		add eax,55
		mov ebx,y
		add ebx,2
		push eax
		push ebx
		make_text_macro 'S',area,eax,ebx
		pop ebx
		pop eax
		add eax,20
		push eax
		push ebx
		make_text_macro 'T',area,eax,ebx
		pop ebx
		pop eax
		add eax,20
		push eax
		push ebx
		make_text_macro 'A',area,eax,ebx
		pop ebx
		pop eax
		add eax,20
		push eax
		push ebx
		make_text_macro 'R',area,eax,ebx
		pop ebx
		pop eax
		add eax,20
		push eax
		push ebx
		make_text_macro 'T',area,eax,ebx
		pop ebx
		pop eax
		macro_linie_orizontala x,y,200,culoare
		macro_linie_verticala x,y,30,culoare
		mov edx,y
		add edx,29
		macro_linie_orizontala x,edx,200,culoare
		mov ebx,x
		add ebx,200
		macro_linie_verticala ebx,y,30,culoare
		
		popa
endm

macro_stop macro x,y,culoare
		pusha
		
		mov eax,x
		add eax,65
		mov ebx,y
		add ebx,2
		push eax
		push ebx
		make_text_macro 'S',area,eax,ebx
		pop ebx
		pop eax
		add eax,20
		push eax
		push ebx
		make_text_macro 'T',area,eax,ebx
		pop ebx
		pop eax
		add eax,20
		push eax
		push ebx
		make_text_macro 'O',area,eax,ebx
		pop ebx
		pop eax
		add eax,20
		push eax
		push ebx
		make_text_macro 'P',area,eax,ebx
		pop ebx
		pop eax
		macro_linie_orizontala x,y,200,culoare
		macro_linie_verticala x,y,30,culoare
		mov edx,y
		add edx,29
		macro_linie_orizontala x,edx,200,culoare
		mov ebx,x
		add ebx,200
		macro_linie_verticala ebx,y,30,culoare
		
		popa
endm

macro_reset macro x,y,culoare
		pusha
		
		mov eax,x
		add eax,55
		mov ebx,y
		add ebx,2
		push eax
		push ebx
		make_text_macro 'R',area,eax,ebx
		pop ebx
		pop eax
		add eax,20
		push eax
		push ebx
		make_text_macro 'E',area,eax,ebx
		pop ebx
		pop eax
		add eax,20
		push eax
		push ebx
		make_text_macro 'S',area,eax,ebx
		pop ebx
		pop eax
		add eax,20
		push eax
		push ebx
		make_text_macro 'E',area,eax,ebx
		pop ebx
		pop eax
		add eax,20
		push eax
		push ebx
		make_text_macro 'T',area,eax,ebx
		pop ebx
		pop eax
		macro_linie_orizontala x,y,200,culoare
		macro_linie_verticala x,y,30,culoare
		mov edx,y
		add edx,29
		macro_linie_orizontala x,edx,200,culoare
		mov ebx,x
		add ebx,200
		macro_linie_verticala ebx,y,30,culoare
		
		popa
endm

macro_punct macro x,y,culoare
	LOCAL repeta
	pusha
	mov ebx,area
	mov esi,x
	mov edi,y
	mov ecx,6
	repeta: mov eax,area_width
		mul edi
		add eax,esi
		mov dword ptr[ebx+4*eax],culoare
		mov dword ptr[ebx+4*eax+4],culoare
		mov dword ptr[ebx+4*eax+8],culoare
		mov dword ptr[ebx+4*eax+12],culoare
		mov dword ptr[ebx+4*eax+16],culoare
		mov dword ptr[ebx+4*eax+20],culoare
		inc edi
	loop repeta
	popa
endm

; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click)
; arg2 - x
; arg3 - y
draw proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz evt_click
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
	jmp final_draw
	
evt_click:
	mov eax,[ebp+arg2] ;x
	mov ebx,[ebp+arg3] ;y
	
	test_reset: cmp eax,200
				jl et1
				cmp eax,400
				jg et1
				cmp ebx,150
				jl et1
				cmp ebx,180
				jg et1
	  resetare: mov decrementeaza,0
				mov hours,0
				mov minutes,0
				mov seconds,0		
et1: cmp decrementeaza,1
	je test_stop
	
	test_h: cmp eax,125
		jl test_m
		cmp eax,175
		jg test_m
		cmp ebx,400
		jl test_m
		cmp ebx,430
		jg test_m
		cmp hours,99
		je final_draw
		inc hours
		jmp final_draw
	
	test_m: cmp eax,275
		jl test_s
		cmp eax,325
		jg test_s
		cmp ebx,400
		jl test_s
		cmp ebx,430
		jg test_s
		cmp minutes,59
		je increase_hours
		inc minutes
		jmp final_draw
		
	test_s: cmp eax,425
		jl test_stop
		cmp eax,475
		jg test_stop
		cmp ebx,400
		jl test_stop
		cmp ebx,430
		jg test_stop
		cmp seconds,59
		je increase_minutes
		inc seconds
		jmp final_draw
			
	increase_hours: mov minutes,0
		cmp hours,99
		je final_draw
		inc hours
		jmp final_draw			

	increase_minutes: mov seconds,0
		cmp minutes,59
		je final_draw
		inc minutes
		jmp final_draw
		
	test_stop: cmp eax,300
			   jl test_start
			   cmp eax,500
			   jg test_start
			   cmp ebx,100
			   jl final_draw
			   cmp ebx,130
			   jg final_draw
			   
			   mov decrementeaza,0
			   
			   jmp final_draw
	
	test_start: cmp eax,50
			jl final_draw
			cmp eax,250
			jg final_draw
			cmp ebx,100
			jl final_draw
			cmp ebx,130
			jg final_draw
			mov decrementeaza,1
			mov counter,3
			
evt_timer: inc counter
		   cmp counter,5
		   jne final_draw
		   cmp decrementeaza,1
		   jne final_draw

start: mov counter,0
	cmp seconds,0
	je dec_minutes
	dec seconds
	jmp final_draw
	dec_minutes: cmp minutes,0
			je dec_hours
			dec minutes
			mov seconds,59
			jmp final_draw
	dec_hours: cmp hours,0
			je final_draw
			dec hours
			mov minutes,59
			jmp final_draw
	
final_draw:
	make_text_macro 'T',area,250,10
	make_text_macro 'I',area,270,10
	make_text_macro 'M',area,290,10
	make_text_macro 'E',area,310,10
	make_text_macro 'R',area,330,10
	
	make_text_macro 'I',area,230,40
	make_text_macro 'Z',area,240,40
	make_text_macro 'O',area,250,40
	make_text_macro 'T',area,260,40
	make_text_macro 'A',area,270,40
	make_text_macro ' ',area,280,40
	make_text_macro 'A',area,290,40
	make_text_macro 'N',area,300,40
	make_text_macro 'D',area,310,40
	make_text_macro 'R',area,320,40
	make_text_macro 'E',area,330,40
	make_text_macro 'E',area,340,40
	make_text_macro 'A',area,350,40
	
	macro_buton 125,400,'H',0
	macro_buton 275,400,'M',0
	macro_buton 425,400,'S',0
	
	macro_start 50,100,0
	macro_stop 300,100,0
	macro_reset 200,150,0
	
	macro_linie_orizontala 50,200,500,0
	macro_linie_orizontala 50,350,500,0
	macro_linie_verticala 50,200,150,0
	macro_linie_verticala 550,200,151,0
	macro_punct 212,260,0
	macro_punct 212,280,0
	macro_punct 380,260,0
	macro_punct 380,280,0
	
	mov eax,hours
	xor edx,edx
	mov ebx,10
	div ebx ;in eax prima cifra, in edx a doua cifra
	add edx,'0'
	add eax,'0'
	push eax
	make_text_macro edx,area,140,240
	pop eax
	make_text_macro eax,area,90,240
	
	mov eax,minutes
	xor edx,edx
	mov ebx,10
	div ebx ;in eax prima cifra, in edx a doua cifra
	add edx,'0'
	add eax,'0'
	push eax
	make_text_macro edx,area,310,240
	pop eax
	make_text_macro eax,area,260,240
	
	mov eax,seconds
	xor edx,edx
	mov ebx,10
	div ebx ;in eax prima cifra, in edx a doua cifra
	add edx,'0'
	add eax,'0'
	push eax
	make_text_macro edx,area,480,240
	pop eax
	make_text_macro eax,area,430,240
	
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp

start:
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
	
	;terminarea programului
	push 0
	call exit
end start
