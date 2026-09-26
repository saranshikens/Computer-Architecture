.data
.word 11, 0, 0x3f800000, 5, 1, 0x3f800000, 5, 2, 0x40000000, 5, 3, 0x3fc00000, 4, 4, 0x3fc00000, 4, 5, 0x3f800000, 5, 0, 0x3f800000, 0, 1, 0x3f800000, -1, 3, 0x00000000, 5, 3, 0xbf800000, 5, 4, 0x00000000, 5

      
.text
lui x3, 0x10010 # base pointer for input
lui x26, 0x10010 # base pointer for output
addi x26, x26, 0x200

lw x24, 0(x3) # N = number of function values to be calculated
addi x3, x3, 4 # points to the first function

addi x25, x0, 0 # pointer for the outermost loop

OUTER_LOOP:
    bge x25, x24, END 

    lw x30, 0(x3) # code
    lw x5, 4(x3) # x 
    lw x6, 8(x3) # terms
    addi x3, x3, 12 # points to the next function
    addi x25, x25, 1 # i++

    bge x0, x6, INVALID # if terms<0, we have an invalid operation at hand

    # 0 = exp, 1 = sin, 2 = cos, 3 = ln, 4 = 1/x
    # next few lines simply behave like a switch-case statement
    # that map function code to their respective functions
    beq x30, x0, EXP
    addi x7, x0, 1
    beq x30, x7, SIN
    addi x7, x0, 2
    beq x30, x7, COS
    addi x7, x0, 3
    beq x30, x7, LN
    addi x7, x0, 4
    beq x30, x7, RECIPROCAL

    jal x0, INVALID # if the function code is invalid, we have an invalid operation at hand


EXP:
    fmv.w.x f10, x5 # x
    addi x10, x6, 0 # terms
    jal x1, EXP_IMPLEMENTATION # jump to the actual implementation of the exponential function
    jal x0, STORE # store the result at the appropriate address


SIN:
    fmv.w.x f10, x5 # x
    addi x10, x6, 0 # terms
    jal x1, SIN_IMPLEMENTATION # jump to the actual implementation of the sine function
    jal x0, STORE # store the result at the appropriate address


COS:
    fmv.w.x f10, x5 # x
    addi x10, x6, 0 # terms
    jal x1, COS_IMPLEMENTATION # jump to the actual implementation of the cosine function
    jal x0, STORE # store the result at the appropriate address


LN:
    fmv.w.x f10, x5 # x
    addi x10, x6, 0 # terms
    jal x1, LN_IMPLEMENTATION # jump to the actual implementation of the logarithm function
    jal x0, STORE # store the result at the appropriate address


RECIPROCAL:
    fmv.w.x f10, x5 # x
    addi x10, x6, 0 # terms
    jal x1, RECIPROCAL_IMPLEMENTATION # jump to the actual implementation of the 1/x function
    jal x0, STORE # store the result at the appropriate address



EXP_IMPLEMENTATION:
    addi x2, x2, -16 # decrementing the stack pointer to accomodate the inputs to EXP i.e. x and 						terms
    sw x1, 12(x2)

    li x5, 0x3f800000 # res = 1.0
    fmv.w.x f0, x5           # res = 1.0
    fmv.x.w x5, f10
    fmv.w.x f1, x5           # t = x
    addi x6, x0, 1           # i = 2

EXP_LOOP:
    bge x6, x10, EXP_COMPLETE

    fmul.s f1, f1, f10 # t = t*x
    fcvt.s.w f2, x6 # since t depends on i, we convert it to float for accurate computations
    fdiv.s f1, f1, f2 # t = t / i
    fadd.s f0, f0, f1 # res = res + t

    addi x6, x6, 1
    jal x0, EXP_LOOP

EXP_COMPLETE:
    fmv.x.w x5, f0
    fmv.w.x f10, x5

    lw x1, 12(x2)
    addi x2, x2, 16
    jalr x0, 0(x1)



SIN_IMPLEMENTATION:
    addi x2, x2, -16 # decrementing the stack pointer to accomodate the inputs to EXP i.e. x and 						terms
    sw x1, 12(x2)

    # res = x
    fmv.x.w x5, f10
    fmv.w.x f0, x5

    fmv.w.x f1, x5 # t = x
    fmul.s f3, f10, f10 # x*x
    fmv.w.x f5, x0
    addi x6, x0, 2 # i = 2, pointer for the loop inside the SIN function

SIN_LOOP:
    bgt x6, x10, SIN_COMPLETE

    slli x7, x6, 1
    addi x28, x7, -1
    addi x29, x7, -2
    mul x28, x28, x29 # (2*i-1) * (2*i-2) = denominator
    fcvt.s.w f2, x28 # converting to float

    fsub.s f4, f5, f3 # -(x*x)
    fmul.s f1, f1, f4 # t = t*(-(x*x))
    fdiv.s f1, f1, f2 # t = t/denominator
    fadd.s f0, f0, f1 # res += t

    addi x6, x6, 1
    jal x0, SIN_LOOP

SIN_COMPLETE:
    fmv.x.w x5, f0
    fmv.w.x f10, x5

    lw x1, 12(x2)
    addi x2, x2, 16
    jalr x0, 0(x1)



COS_IMPLEMENTATION:
    addi x2, x2, -16 # decrementing the stack pointer to accomodate the inputs to EXP i.e. x and 						terms
    sw x1, 12(x2) 

    
    li x5, 0x3f800000 # res = 1.0
    fmv.w.x f0, x5
    fmv.w.x f1, x5 # t = 1.0
    fmul.s f3, f10, f10 # x*x

    fmv.w.x f5, x0
    addi x6, x0, 2 # i = 2, pointer for the loop inside the COS function

COS_LOOP:
    bgt x6, x10, COS_COMPLETE

    slli x7, x6, 1
    addi x28, x7, -2
    addi x29, x7, -3
    mul x28, x28, x29 # (2*i-2)*(2*i-3) = denominator
    fcvt.s.w f2, x28 # converting to float

    fsub.s f4, f5, f3 # -(x*x)
    fmul.s f1, f1, f4 # t = t * (-(x*x))
    fdiv.s f1, f1, f2 # t = t / denominator
    fadd.s f0, f0, f1 # res += t

    addi x6, x6, 1
    jal x0, COS_LOOP

COS_COMPLETE:
    fmv.x.w x5, f0
    fmv.w.x f10, x5

    lw x1, 12(x2)
    addi x2, x2, 16
    jalr x0, 0(x1)



LN_IMPLEMENTATION:
    addi x2, x2, -16 # decrementing the stack pointer to accomodate the inputs to EXP i.e. x and 						terms
    sw x1, 12(x2)

    fmv.w.x f4, x0
    fle.s x5, f10, f4
    bne x5, x0, INVALID_LN # the taylor series converges for x>0, so if x<=0, we have an invalid 							 operation at hand

    
    li x6, 0x3f800000 # y = x-1
    fmv.w.x f3, x6
    fsub.s f3, f10, f3

    # res = y
    fmv.x.w x5, f3
    fmv.w.x f0, x5

    li x6, 0x3f800000 # t = y
    fmv.s f1, f3

    addi x6, x0, 2 # i = 2, pointer for the loop inside the LN function

LN_LOOP:
    bgt x6, x10, LN_COMPLETE
    
    fmv.w.x f5, x0 

    fsub.s f4, f5, f3 # f4 = -y
    fmul.s f1, f1, f4 # t = t*(-y)

    fcvt.s.w f2, x6 # converting i to float
    # res += t/i
    fdiv.s f4, f1, f2
    fadd.s f0, f0, f4

    addi x6, x6, 1
    jal x0, LN_LOOP

LN_COMPLETE:
    fmv.x.w x5, f0
    fmv.w.x f10, x5

    lw x1, 12(x2)
    addi x2, x2, 16
    jalr x0, 0(x1)

INVALID_LN:
    li x5, 0x7fc00000
    fmv.w.x f10, x5

    lw x1, 12(x2)
    addi x2, x2, 16
    jalr x0, 0(x1)



RECIPROCAL_IMPLEMENTATION:
    addi x2, x2, -16 # decrementing the stack pointer to accomodate the inputs to EXP i.e. x and 						terms
    sw x1, 12(x2)

    fmv.w.x f4, x0

    # check x == 0
    feq.s x5, f10, f4
    bne x5, x0, INVALID_RECIPROCAL # the taylor series converges for x!=0, so if x==0, we have an        								invalid operation at hand
    
    li x6, 0x3f800000
    fmv.w.x f3, x6
    fsub.s f3, f10, f3 # y = x - 1

    li x6, 0x3f800000
    fmv.w.x f0, x6 # res = 1

    fmv.w.x f1, x6 # t = 1

    addi x6, x0, 2 # i = 2, pointer for the loop inside the RECIPROCAL function

RECIPROCAL_LOOP:
    bgt x6, x10, RECIPROCAL_COMPLETE   

    fmv.w.x f4, x0                    
    fsub.s f4, f4, f3 # f4 = -(x-1)
    fmul.s f1, f1, f4 # t = t*(-(x-1))
    fadd.s f0, f0, f1 # res = res + t

    addi x6, x6, 1                  
    jal x0, RECIPROCAL_LOOP        

RECIPROCAL_COMPLETE:
    fmv.x.w x5, f0
    fmv.w.x f10, x5

    lw x1, 12(x2)
    addi x2, x2, 16
    jalr x0, 0(x1)


INVALID_RECIPROCAL:
    li x5, 0x7fc00000
    fmv.w.x f10, x5

    lw x1, 12(x2)
    addi x2, x2, 16
    jalr x0, 0(x1)



STORE:
    fsw f10, 0(x26)
    addi x26, x26, 4
    jal x0, OUTER_LOOP


INVALID:
    li x5, 0x7fc00000
    sw x5, 0(x26)
    addi x26, x26, 4
    jal x0, OUTER_LOOP


END:
    nop