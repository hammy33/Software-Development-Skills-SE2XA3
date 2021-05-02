%include "simple_io.inc"

global asm_main

SECTION .data

wrongCLA: db "Incorrect number of command line arguments",10,0
tooLONG: db "Input string is longer than 12",10,0

input: db "Input string: ",0

stringBordar: db "border array: ",0 
emptyBordar: dq 0,0,0,0,0,0,0,0,0,0
separateArray: db ", ",0

fd1: db "+++  ",0
fd2: db "...  ",0
fd3: db "     ",0

SECTION .text

maxboard:

   enter        0,0
   saveregs
   
   mov	rax, qword 0
   mov	r12, [rbp+24]
   mov	r13, [rbp+32]

   mov	rbx, qword 1
   mov 	r15, r12
   add	r15, r13
   sub	r15, rbx   

   OUTER_maxboard:
   	mov  r14, qword 1         
   	mov  rcx, qword 0
	
	INNER_maxboard:
		mov	r9b, byte [r12]
		mov	r10b, byte [r15]
		cmp 	r9b, r10b
		jne	OUTER_continue

		inc	rcx
		cmp	rcx, rbx
		je	INNER_end

		add	r12, qword 1
		add	r15, qword 1
		jmp	INNER_maxboard
	INNER_end:

	cmp	r14, qword 1                          ;; 51
	jne	OUTER_continue
	
	cmp	rax, rbx
	jae	OUTER_continue
	
	mov	rax, rbx
	dec	rcx

	OUTER_continue:
		sub	r12, rcx
		sub	r14, rcx
		sub	r15, qword 1
		inc	rbx
		cmp	rbx, r13
		jb	OUTER_maxboard
   restoregs
   leave
   ret	


simple_display:
   enter        0,0
   saveregs

   mov	rax, stringBordar 
   call	print_string

   mov 	r12, [rbp+24]
   mov 	r15, [rbp+32]

   mov	rax, [r12]
   call	print_int
   
   add r12, qword 8
   mov rcx, qword 1
   SIMPLE:
   	mov	rax, separateArray
	call	print_string

	mov	rax, [r12]
	call	print_int

	add	r12, qword 8
	inc	rcx
	cmp	rcx, r15
	jb	SIMPLE
	
   call print_nl
   restoregs
   leave
   ret

display_line:                             ;; 101
   enter 0,0
   saveregs

   mov	r12, qword 0
   mov	r13, [rbp+16]
   mov	r14, [rbp+24]
   mov	r15, [rbp+32]

   DISPLAY:
	inc	r12
	cmp	r12, r15
	ja	display_line_end

	DISPLAY_1:
	   cmp	r14, qword 1
	   jne	DISPLAY_2

	   cmp	qword[r13], qword 0
	   jbe	DISPLAY_1_dot

		DISPLAY_1_plus:
		   mov	rax, fd1
		   call	print_string
		   jmp	DISPLAY_continue

		DISPLAY_1_dot:
		   mov	rax, fd2
		   call	print_string
		   jmp	DISPLAY_continue

	DISPLAY_2:
	   cmp	qword[r13], r14
	   jae	DISPLAY_2_plus

		DISPLAY_2_space:
		   mov	rax, fd3
		   call	print_string
		   jmp	DISPLAY_continue

		DISPLAY_2_plus:
		   mov	rax, fd1
		   call	print_string
	
	DISPLAY_continue:
	   add	r13, qword 8
	   cmp	rcx, r15
	   jb	DISPLAY

	display_line_end:
	call	print_nl
	
	restoregs
	leave 
	ret

fancy_display:
   enter	0,0
   saveregs

   mov	r12, [rbp+24]
   mov	r15, [rbp+32]
   mov	rcx, r15
   
   FANCY:
	push	r15
	push	rcx
	push	r12
	call	display_line
	add	rsp, 24

	dec	rcx
	cmp	rcx, qword 0
	ja	FANCY

   restoregs
   leave
   ret

asm_main:

   enter	0,0             
   saveregs              	
   
   mov	r12, rdi	
   cmp	r12, qword 2
   jne	WRONG_CLA			

   mov	r13, [rsi+8]

   mov 	rcx, qword 0   
   LENGTH:			;; length of the argument 		
	mov	bl, byte [r13]	
	cmp	bl, byte 0
	je 	LENGTH_end
	
	inc	rcx
	add	r13, qword 1
	jmp 	LENGTH		
   LENGTH_end:

   mov 	r12, [rsi+8]	
   mov 	r13, rcx
	
   cmp  r13, qword 12			;; rbc holds length
   ja   TOO_LONG

   mov	rax, input
   call	print_string

   mov	rax, r12
   call	print_string
   call	print_nl
       
   mov	r14, emptyBordar
   mov	r15, r13

   mov	rbx, r13
   sub	rbx, qword 1

   mov	rcx, qword 0
   BORDAR_TRAVERSE_1:
	mov 	rdx, rcx
	push	r15
	push	r12
	sub	rsp, 8
	call 	maxboard
	add	rsp, 24

	mov	rcx, rdx
	mov	[r14], rax		
	add	r14, qword 8
	add 	r12, qword 1

	dec	r15
	inc	rcx

	cmp	rcx, rbx
	jb	BORDAR_TRAVERSE_1

   BORDAR_TRAVERSE_2:
	sub	r14, qword 8
	dec 	rcx
	cmp	rcx, qword 0
	ja	BORDAR_TRAVERSE_2

   push r13
   push	r14
   sub	rsp, 8
   call	simple_display
   call fancy_display
   add	rsp, 24
	
   jmp asm_main_end

   WRONG_CLA:
	mov rax, wrongCLA
	call print_string
	jmp asm_main_end

   TOO_LONG:
   	mov rax, tooLONG
   	call print_string
	
   asm_main_end:
	
	restoregs
	leave
	ret

