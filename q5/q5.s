.section .rodata # Read only data
input_filename:
  .asciz "input.txt"
yes_msg:
  .asciz "Yes\n"
no_msg:
  .asciz "No\n"

.section .text
.globl main

main:
  addi x2, x2, -48 # save registers. Also using bottom 2 bytes of stack for storage, 
  sd x1, 40(x2)
  sd x8, 32(x2)
  sd x9, 24(x2)
  sd x18, 16(x2)
  sd x19, 8(x2)

  li x10, -100 # at current working directory 
  la x11, input_filename # load file addres 
  li x12, 0    # readonly 
  li x17, 56   # system call for openat 
  ecall # call the openat 

  mv x8, x10   # x8 = file descriptor 

  mv x10, x8  #preparing arguemnts for lseek 
  li x11, 0    # offset of 0 
  li x12, 2    # SEEK_END
  li x17, 62   # syscall for  lseek
  ecall        #gets size 

  mv x9, x10   # x9 = file length
  beq x9, x0, .print_yes #Null length 

.last_newline:
  addi x5, x9, -1 #index of last character 
  mv x10, x8 # descriptor  
  mv x11, x5 # offset 
  li x12, 0    # exact byte, seek_set  
  li x17, 62   # set call and call 
  ecall

  mv x10, x8 #descriptor
  mv x11, x2 # read into stack=buffer 
  li x12, 1 #1 byte 
  li x17, 63   # read
  ecall
  lbu x5, 0(x2) #load into x5 
  li x6, 10 # loads \n to x6 
  beq x5, x6, .drop_last_char # if equal drop 
  j .length_ready

.drop_last_char: 
  addi x9, x9, -1 # decreases use length by 1 
  beq x9, x0, .print_yes # if null, then yes  
  j .length_ready

.length_ready:
  li x5, 1
  ble x9, x5, .print_yes # if length is 1 

  li x18, 0 # left index = 0 
  addi x19, x9, -1 # right index = effective length - 1 

.compare_loop:
  bge x18, x19, .print_yes # if crosee yes  

  mv x10, x8 #descriptor
  mv x11, x18 #offset 
  li x12, 0    # SEEK_SET , start of file 
  li x17, 62   # call lseek 
  ecall

  mv x10, x8 #read 
  mv x11, x2 # buffer = sp 
  li x12, 1 # 1 byte 
  li x17, 63   # call read 
  ecall

  mv x10, x8 #descriptor
  mv x11, x19 #right index 
  li x12, 0    # SEEK_SETfrom file start 
  li x17, 62   # call lseek 
  ecall

  mv x10, x8 # setup read 
  addi x11, x2, 1 # buffer = sp 
  li x12, 1 # 1 byte 
  li x17, 63   # read
  ecall

  lbu x5, 0(x2) #load char 1 
  lbu x6, 1(x2) # load char 2 
  bne x5, x6, .print_no # if not equal, print no 

  addi x18, x18, 1 # l = l + 1 
  addi x19, x19, -1 # r = r - 1 
  j .compare_loop #loop 
 
.print_yes:
  li x10, 1 #stdout 
  la x11, yes_msg 
  li x12, 4 # length is 4 bytes incld \n 
  li x17, 64   # write
  ecall #call 
  j .close 

.print_no:
  li x10, 1 #Same thing as above 
  la x11, no_msg
  li x12, 3 # 3 bytes 
  li x17, 64   # write
  ecall #cal 
  j .close

.close:
  mv x10, x8 #descriptor 
  li x17, 57   # close
  ecall
  li x10, 0 #done 0 for success 
  j .main_done


.main_done:
  ld x19, 8(x2) #load saved registers and reset sp 
  ld x18, 16(x2)
  ld x9, 24(x2)
  ld x8, 32(x2)
  ld x1, 40(x2)
  addi x2, x2, 48
  ret
