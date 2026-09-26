# MA24BTECH11022: Lab-2: GCD (Greatest Common Divisor) calculation

# The gcd calculation follows the C code snippet given below.

# int gcd(int a, int b){
#    if(a>b) return gcd(b, a);
#    if(a==0) return 0;
#    if(a==b) return a;
#    return gcd(a, b-a);
# }

# int main(){
#    int gcdNum;
#    int i = 0;
#    int* ptr = 0;
#    int* res = 0;
#    while(i<gcdNum){
#        int g = gcd(*(ptr+i+1), *(ptr+i+2));
#        *res = g;
#        res++;
#        i+=2;
#    }
# }

.data
.dword 3, 12, 3, 125, 50, 32, 16 

.text
    lui x3, 0x10000
    ld x4, 0(x3) # x4 = gcdNum
    add x4, x4, x4 # x4 = 2*gcdNum
    add x5, x0, x0 # x5 = i
    add x6, x0, x3 # x6 = ptr pointer
    addi x7, x3, 512 # x7 = res pointer
    
    blt x5, x4, while_block
    jal x0, end
    
while_block:
    slli x12, x5, 3 # x12 = i * 8
    add x12, x12, x6 # x12 = ptr+i
    ld x8, 8(x12) # x8 = *(ptr+i+1)
    ld x9, 16(x12) # x9 = *(ptr+i+2)
    
    jal x1, gcd
    # at this point, x8 = gcd(a, b)
    sd x8, 0(x7)
    
    addi x7, x7, 8
    addi x5, x5, 2
    
    blt x5, x4, while_block
    jal x0, end

gcd:
    addi x2, x2, -24
    sd x1, 16(x2) # storing the return address into the stack
    sd x8, 8(x2) # storing a into the stack
    sd x9, 0(x2) # storing b into the stack
    
    blt x9, x8, swap_a_and_b
    beq x8, x0, return_zero
    beq x8, x9, return_a
    
    sub x9, x9, x8
    jal x1, gcd
    jal x0, return_a
    
swap_a_and_b:
    add x11, x0, x8
    add x8, x0, x9
    add x9, x0, x11
    
    blt x9, x8, swap_a_and_b
    beq x8, x0, return_zero
    beq x8, x9, return_a
    
    sub x9, x9, x8
    jal x1, gcd
    jal x0, return_a
    
return_zero:
    addi x8, x0, 0
    ld x1, 16(x2)
    addi x2, x2, 24
    jalr x0, x1, 0
    
return_a:
    ld x1, 16(x2)
    addi x2, x2, 24
    jalr x0, x1, 0
    
end: 
    nop

    
    
    
    



