 # MA24BTECH11022 Lab-1 Basic assembly programming
 
 # The assembly code implements the logic given below
 # Technique implemented:- 153*37 = 153*(32+4+1) = 153*32+153*4*153*1
 #                       = (153<<5)+(153<<2)+(153<<1)
 # C implementation given below the Assembly code. It would be more convenient for
 # the reader to look at the C code first, the comments in the Assembly code closely follow the 
 # variable naming and logic of C implementation.
 
 
 # ASSEMBLY CODE
 
 # x -> x7, y -> x8 : Our inputs
 # result -> x9
 # ptr -> x10 : tracks the current bit of y
 
 # Loading the inputs
 lui  x5, 0x10000
 lw   x7, 0x000(x5)
 lw   x8, 0x008(x5)
 
 # Initialize result = 0, ptr = 0
 addi x9, x0, 0
 addi x10, x0, 0
 
 # x1 = 1
 addi x1, x0, 1 # will help in comparing the current bit of y with 1
 
 add x2, x0, x8 # x2 = y
 srli x2, x2, 31 # x2 = MSB of y
 
 # following the 2's complement format, 
 # x2==1, y is negative, else non-negative
 beq x2, x1, y_is_Negative 
 bne x2, x1, y_is_Non_Negative
 
 y_is_Negative:
     # y = -y
     sub x8, x0, x8
     
     bne x8, x0, while_block # while y>0, execute the while block
     j loop_done
     
 y_is_Non_Negative:
     bne x8, x0, while_block # while y>0, execute the while block
     j loop_done
     
 while_block:
     beq x8, x0, loop_done
     
     andi x11, x8, 1 # x11 = y&1
     
     beq x11, x1, add_to_result # if current bit of y is set, we add its contribution to the result
     addi x10, x10, 1 # x10++, i.e. increment the ptr pointer
     srli x8, x8, 1 # y >>= 1
     j while_block
     
 add_to_result:
     sll x11, x7, x10 # x11 = x<<ptr
     add x9, x9, x11 # x9 += x11
     addi x10,x10, 1 # x10++, i.e. increment the ptr pointer
     srli x8, x8, 1 # y >>= 1
     j while_block

 loop_done:
     beq x2, x1, negate_result 
     j exit
     
 negate_result:
     # result = -result
     sub x9, x0, x9
     
 exit:
     sw x9, 0x50(x5)    # stores the result to 0x10000050
     nop
   
# C Implementation  
     
##include <stdio.h>
#
#int main(){
#    signed int x, y;
#    scanf("%d %d", &x, &y);
#    signed int res = 0;
#    int ptr = 0;
#    if(y<0){
#        y = -y;
#        while(y){
#            if(y&1) res += x << ptr;
#            ptr++;
#            y >>= 1;
#        }
#        res = -res;
#    } 
#    else{
#        while(y){
#            if(y&1) res += x << ptr;
#            ptr++;
#            y >>= 1;
#        }
#    }
#    printf("%d\n", res);
#}
