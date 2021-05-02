%include "simple_io.inc"

global asm_main

SECTION .data
error1: db "wrong number of command line arguments",10,0
error2: db "the call used ",0
error3: db " command line arguements",10,0
error4: db "usage -- ",0
error5: db " <string>",10,0

SECTION .text

Arg_handler:
     enter 0,0
     saveregs

     mov     rax, error1
     call     print_string

     mov     rax, error2
     call     print_string
     mov     rax, [rbp+32]
     call     print_int
     mov     rax, error3
     call     print_string

        mov     rax, error4
        call    print_string
     mov     rax, [rbp+24]
     call     print_string
     mov     rax, error5
     call     print_string

     restoregs
     leave
     ret

asm_main:
     enter 0,0
     saveregs

     mov     r12, rdi
     mov     r13, [rsi]
     
     cmp     r12, qword 2
     jne     ERROR

     mov r14, [rsi+8]
     mov rcx, qword 0
     LOOP1:     
          mov     al, byte [r14]
          cmp     al, byte 0
          je      LOOP1_end

          inc     rcx
          add     r14, qword 1
          jmp      LOOP1     
     
     LOOP1_end:
     
     mov     rbx, rcx
     
     mov     r15, r14
     mov      r14, [rsi+8]
     
     mov     rax, rbx
     call     print_int
     
     mov     al, ' '
     call     print_char
     
     mov      rax, r14
     call     print_string
     call     print_nl

     cmp     rbx, qword 5
     jb     LOOP2
     je     LOOP3

     LOOP4:

          mov     rcx, qword 0

          LOOP4_first:
               mov     al, byte [r14]
               call     print_char
               inc      rcx

               add     r14, qword 1
               cmp     rcx, rbx
               jne     LOOP4_first

          mov     al, '*'
          call     print_char
          mov     rcx, qword 0

          LOOP4_second:
               sub     r14, qword 1
               mov     al, byte [r14]
               call     print_char

               inc     rcx
               cmp     rcx, rbx
               jne     LOOP4_second

          call     print_nl
          jmp asm_main_end     

        LOOP2:
          mov     al, '@'
          call     print_char
          mov     rcx, qword 0

          LOOP2_first:
               sub     r15, qword 1
               mov     al, byte[r15]
               call     print_char

               inc     rcx
               cmp     rcx, rbx
               jne     LOOP2_first
          
             mov     al, '*'
          call     print_char
          mov     rcx, qword 0

          LOOP2_second:
               mov     al, byte [r15]
               call     print_char
               inc      rcx

               add     r15, qword 1
               cmp     rcx, rbx
               jne     LOOP2_second

          mov     al, '@'
          call     print_char
          call     print_nl
     
          jmp asm_main_end

        LOOP3:
          mov     al, '@'
                call    print_char
                mov     rcx, qword 0
          
          LOOP3_first:
                        sub     r15, qword 1
                        mov     al, byte[r15]
                        call    print_char

                        inc     rcx
                        cmp     rcx, rbx
                        jne     LOOP3_first

                mov     al, '@'
                call    print_char
                call    print_nl
           jmp asm_main_end


     ERROR:
          sub     r12, qword 1
          push     r12
          push     r13
          sub     rsp, 8
          call     Arg_handler
          add      rsp, 24

     asm_main_end:

     restoregs
     leave
     ret