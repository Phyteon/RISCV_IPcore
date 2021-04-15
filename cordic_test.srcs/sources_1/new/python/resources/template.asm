    .file   "main.c"
    .text
    .globl  myfunc
    .type   myfunc, @function
myfunc:
.LFB0:
    .cfi_startproc
    pushq   %rbp
    .cfi_def_cfa_offset 16
    .cfi_offset 6, -16
    movq    %rsp, %rbp
    .cfi_def_cfa_register 6
    movl    %edi, -4(%rbp)
    movl    -4(%rbp), %eax
    addl    $1, %eax
    popq    %rbp
    .cfi_def_cfa 7, 8
    ret
    .cfi_endproc
.LFE0:
    .size   myfunc, .-myfunc
    .ident  "GCC: (Ubuntu 8.3.0-6ubuntu1) 8.3.0"
    .section    .note.GNU-stack,"",@progbits