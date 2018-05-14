.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc

includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "TETRIS",0
area_width EQU 640
area_height EQU 480
area DD 0


counter DD 0 ; numara evenimentele de tip timer
can_move dd 0
copy dd 0

contor dd 0

matrice_back DD 400 dup(0)

matrice_solid dd 3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3
			  dd 3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3
			  dd 3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3
			  dd 3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3
			  dd 3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3
			  dd 3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3
			  dd 3,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,3
			  dd 3,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,3
			  dd 3,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,3
			  dd 3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3
			  dd 3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3
			  dd 3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3
			  dd 3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3
			  dd 3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3
			  dd 3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3
			  dd 3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3
			  dd 3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3
			  dd 3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3
			  dd 3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3
			  dd 3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3
			  


start_x dd 500
start_y dd 0
lung dd 200

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20

pieces  DB 0, 1, 1, 0, 0, 0, 0, 0, 0, 0
        DB 0, 1, 1, 0, 0, 0, 0, 0, 0, 0
        DB 0, 1, 1, 0, 0, 0, 0, 0, 0, 0
        DB 0, 1, 1, 0, 0, 0, 0, 0, 0, 0
        DB 0, 1, 1, 0, 0, 0, 0, 1, 1, 0
        DB 0, 1, 1, 0, 0, 0, 0, 1, 1, 0
        DB 0, 1, 1, 0, 0, 0, 0, 1, 1, 0
        DB 0, 1, 1, 0, 0, 0, 0, 1, 1, 0
        DB 0, 1, 1, 0, 0, 0, 0, 1, 1, 0
        DB 0, 1, 1, 0, 0, 0, 0, 1, 1, 0
        DB 0, 1, 1, 0, 0, 0, 0, 0, 0, 0
        DB 0, 1, 1, 0, 0, 0, 0, 1, 1, 0
        DB 0, 1, 1, 0, 0, 0, 0, 1, 1, 0
        DB 0, 1, 1, 0, 0, 0, 0, 1, 1, 0
        DB 0, 1, 1, 0, 0, 0, 0, 1, 1, 0
        DB 0, 1, 1, 0, 0, 0, 0, 1, 1, 0
        DB 0, 1, 1, 0, 0, 0, 0, 1, 1, 0
        DB 0, 1, 1, 0, 0, 0, 0, 1, 1, 0
        DB 0, 1, 1, 0, 0, 0, 0, 0, 0, 0
        DB 0, 1, 1, 0, 0, 0, 0, 0, 0, 0

symbol_width EQU 10
symbol_height EQU 20
include digits.inc
include letters.inc
;include pieces.inc

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
	shl eax,2; inmultim cu 4, avem un DWORD per pixel
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

make_text_white proc
	
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
	shl eax,2; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 0FFFFFFh
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
make_text_white endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

clear_area macro

	mov copy, eax
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255
	push area
	call memset
	add esp, 12
	mov eax, copy	
	add ebx, 20
	
endm



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

check macro
	
	mov ebx, matrice_solid
	add ebx, 20
	cmp	[matrice_solid+8], 20
	je afara
	make_text_macro 'A', area, counter, counter
	afara:
	

endm

redraw macro 
	
	mov ebx, matrice_solid
	mov eax, 0
	mov ecx, 20
	
	mov edi, 0; x
	mov esi, 0; y
	
	compara:
	inc eax
	inc edi
	cmp eax, 400
	je iesire
	; incrementam coordonata x a piesei, cand ajunge la 20 se va trece la rand nou, adica mov edi, 0 add esi, 10
	cmp [matrice_solid+4*eax], 0 ;daca in matrice este 3, atunci se va desena zid
	je nu_este
	cmp [matrice_solid+4*eax], 3
	je nu_este
     shl edi, 4;doar pentru afisare
	make_text_macro 'A', area, edi, esi; desenam piesa
	 shr edi, 4; revenim la x-ul initial
	nu_este:	; se va executa chia daca nu este 0 in matrice_solid
	cmp edi, 20 ;in caz ca s-a ajuns la capat de rand in matrice_solid
	jne ns
	mov edi, 0	;daca s-a ajuns atunci se reseteaza x-ul
	add esi, 20; se incrementeaza y-ul
	ns:

	jmp compara
	iesire:
	
	compara2:
	
	
	
endm

move_piece proc
	
	push ebp
	mov ebp, esp
	
	mov ebx, 80
	shl ebx, 2
	mov eax, 0
	
	l:
	inc eax
	cmp eax, 400
	je a
	cmp [matrice_solid+4*eax],1	; cautam prin matrice daca avem 1 si daca avem mutam la stanga toti 1
	jne n

	cmp [matrice_solid+4*eax-4], 0
	jne n
	mov [matrice_solid+4*eax],0	; stergem piesa de pe pozitia anterioara
	dec eax
	mov [matrice_solid+4*eax],1	; afisam piesa pe pozitia noua
	inc eax
	n:
	jmp l
	a:
	
	
	mov esp, ebp
	pop ebp
	ret
move_piece endp

move_piece_right proc

	push ebp
	mov ebp, esp
	
	
	mov ecx, 400
	
	loop2:
	cmp [matrice_solid+4*ecx],1	; cautam prin matrice daca avem 1 si daca avem mutam la stanga toti 1
	jne jk

	cmp [matrice_solid+4*ecx+4], 0
	jne jk
	mov [matrice_solid+4*ecx],0	; stergem piesa de pe pozitia anterioara
	mov [matrice_solid+4*ecx+4],1	; afisam piesa pe pozitia noua
	jk:
	loop loop2
	afa:
	
	
	mov esp, ebp
	pop ebp
	ret
	
move_piece_right endp
	
move_piece_down proc
	push ebp
	mov ebp, esp
	
	mov ebx, 0
	mov ecx, 400
	
	lop1:
	
	cmp [matrice_solid+4*ecx], 3
	je over
	
	cmp [matrice_solid+4*ecx-80],3
	je over
	
	cmp [matrice_solid+4*ecx],2
	je over
	
	cmp [matrice_solid+4*ecx],1
		jne ov
			cmp [matrice_solid+4*ecx+80],3
				je sol
					cmp[matrice_solid+4*ecx+80],2
						je sol
						
	ov:
	mov ebx, [matrice_solid+4*ecx-80]
	mov [matrice_solid+4*ecx], ebx
	
	jmp over
	
	sol:
		call make_solid
		jmp a
	over:
	
	loop lop1
	a:
	mov esp, ebp
	pop ebp
	ret
move_piece_down endp


make_solid proc
	
	push ebp
	mov ebp,esp
	
	mov eax, 0
	l:
	inc eax
	cmp eax, 400
	je a
	cmp [matrice_solid+4*eax],1
	jne n
	mov [matrice_solid+4*eax],2
	n:
	jmp l
	a:
	
	call reset
	
	mov esp, ebp
	pop ebp
	ret
make_solid endp

reset proc
	
	push ebp
	mov ebp, esp
	
		mov [matrice_solid+440],1
	mov esp, ebp
	pop ebp
	ret
reset endp
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm

make_text_white_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text_white
	add esp, 16
endm

make_line macro x,y,lungime
	local lop
	
	mov esi, x
	mov edi, y; j
	
	mov ecx, lungime
	mov ebx, area
	lop:
	mov eax, area_width
	mul esi
	add eax, esi
	;mov ebx, area
	mov dword ptr[ebx +4*eax], 0F1h
	dec edi
	loop lop
 endm
 
 linie_stergere proc
 
	push ebp
	mov ebp, esp
	pusha
	
	mov esi, [ebp+arg1]
	mov edi, [ebp+arg2]; j
	
	mov ecx, [ebp+arg3]
	mov ebx, area
	lop:
	mov eax, area_width
	mul esi
	add eax, edi
	;mov ebx, area
	mov dword ptr[ebx +4*eax], 0FFFFFFh
	dec edi
	loop lop
	
	popa
	mov esp, ebp
	pop ebp
	
	ret
	
linie_stergere endp
 
 linie proc 
	
	push ebp
	mov ebp, esp
	pusha
	
	mov esi, [ebp+arg1]
	mov edi, [ebp+arg2]; j
	
	mov ecx, [ebp+arg3]
	mov ebx, area
	lop:
	mov eax, area_width
	mul esi
	add eax, edi
	;mov ebx, area
	mov dword ptr[ebx +4*eax], 023h
	dec edi
	loop lop
	
	popa
	mov esp, ebp
	pop ebp
	
	ret
linie endp
	
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
	jmp afisare_litere
	
evt_click:
	
	;make_text_macro 'A', area, [ebp+arg2], [ebp+arg3]
	;inc ebx
	
	;call move_piece_down
	mov ebx, [ebp+arg2]
	cmp ebx, 320
	jl stanga
	call move_piece_right
	jmp ie
	stanga:
	call move_piece 
	
	ie:

	
	
evt_timer:

	inc counter
	inc contor
	
	mov ebx, contor 
	cmp ebx, 5 
	jne sa
	;call move_piece
	call move_piece_down
	mov contor, 0
	sa:
	make_text_macro 'T', area, 210, 20
	make_text_macro 'E', area, 220, 20
	make_text_macro 'T', area, 230, 20
	make_text_macro 'R', area, 240, 20
	make_text_macro 'I', area, 250, 20
	make_text_macro 'S', area, 260, 20
	
	;make_text_macro 'A', area, [ebp+arg2], counter


afisare_litere:
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
	
	;scriem un mesaj
	make_text_macro 'T', area, 210, 20
	make_text_macro 'E', area, 220, 20
	make_text_macro 'T', area, 230, 20
	make_text_macro 'R', area, 240, 20
	make_text_macro 'I', area, 250, 20
	make_text_macro 'S', area, 260, 20
	

final_draw:
	
	;make_text_macro 'A', area, counter, counter
	
	
	

	
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	;vrem sa afisam piesa care cade 
	
	;add counter,20
	;sub counter,20
	clear_area
	redraw
	;check 
	
	;make_text_macro 'A', area, 100 ,counter
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	;make_text_macro 'A', area, 100, 100
	
	nu1:
	make_text_macro 'T', area, 210, 20
	make_text_macro 'E', area, 220, 20
	make_text_macro 'T', area, 230, 20
	make_text_macro 'R', area, 240, 20
	make_text_macro 'I', area, 250, 20
	make_text_macro 'S', area, 260, 20
	
	push 300
	push 408
	push 84
	call linie
	add esp, 12
	
	push 300
	push 410
	push 380
	call linie
	add esp, 12
	
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
