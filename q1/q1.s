.text
.globl make_node
.globl insert
.globl get
.globl getAtMost

# struct Node layout on RV64:
#   0: int val
#   8: struct Node* left
#  16: struct Node* right

make_node:
  addi x2, x2, -16 
  sd x1, 8(x2)  # Save return address 
  sw x10, 4(x2) # Save integer value temporarily

  li x10, 24 # Load 24 to malloc argument 
  call malloc # Malloc hte space 

 
  lw x5, 4(x2) # Loads the value to x5 
  sw x5, 0(x10) # Stores value at the allocated struct's first struct 
  sd x0, 8(x10) # Stores null at left for node 
  sd x0, 16(x10) # Stores null at right for node 

  ld x1, 8(x2) # Load the stack pointer back  
  addi x2, x2, 16 # Reset stack pointer 
  ret # return 

insert:
  addi x2, x2, -32 # Make space in stack pointer 
  sd x1, 24(x2) #Store return address  
  sd x8, 16(x2) # save "saved" registers we use in this function 
  sd x9, 8(x2)
  sd x18, 0(x2)

  mv x8, x10 # x8 = root 
  mv x9, x11 # x9 = val 

  beq x8,x0,  .insert_empty  # if it's zero jump to wherever

  mv x18, x8 # x18 is current node pointer, starting at root. 

.insert_loop:
  lw x5, 0(x18) # this is the value of current node 
  blt x9, x5, .insert_left # if it's lower insert left , 
  ld x6, 16(x18) 

  beq x6,x0, .insert_attach_right # if right node is empty, and this is bigger than the current node, then attach it as rihght mode 
  mv x18, x6 # Set current node as right node 
  j .insert_loop # run loop again. 

.insert_left:
  ld x6, 8(x18) # load left pointer 
  beq x0, x6, .insert_attach_left # if it's equal to null, attach it to left
  mv x18, x6 # set current one as left 
  j .insert_loop # continue loop with the left one as current 

.insert_attach_left:
  mv x10, x9 # Put's value in x10 
  call make_node # creates a new node with the value 
  sd x10, 8(x18) # stores the new node pointer into current-> left 
  mv x10, x8 # since insert returns original root, we keep original root in x10. 
  j .insert_done

.insert_attach_right:
  mv x10, x9 # put's value in x10 
  call make_node # m akes node with value 
  sd x10, 16(x18) # stores pointer into current-> right; 
  mv x10, x8 #same thing as earlier 
  j .insert_done

.insert_empty:
  mv x10, x9 #Inserts value into current 
  call make_node #Creates the new node, and returns its address 

.insert_done:
  ld x18, 0(x2) #Load saved registers back from stack 
  ld x9, 8(x2)
  ld x8, 16(x2)
  ld x1, 24(x2) #load return address 
  addi x2, x2, 32 # fix stack pointer 
  ret # return 

get:
  mv x5, x10 # Store value in x5 

.get_loop:
  beq x0, x5, .get_not_found #if current is not null, return not found 

  lw x6, 0(x5) # Loads value 
  beq x11, x6, .get_found # if it's equal, then break 
  blt x11, x6, .get_go_left # if it's less, go to left branch 

  ld x5, 16(x5) # If not left or equal, then load it into right, 
  j .get_loop # continue with loop 

.get_go_left:
  ld x5, 8(x5) # load left 
  j .get_loop # continue loop 

.get_found: 
  mv x10, x5 # stores current in x10 
  ret #return 

.get_not_found:
  li x10, 0 #load it with null  
  ret # reuurn 

getAtMost:
  li x5, -1 #Stores best variable 
  mv x6, x11 # copy root to x6 

.get_at_most_loop:
  beqz x6, .get_at_most_done # if it's zero, then it's null so we reached end, go back. 

  lw x7, 0(x6) # load value 
  blt x10, x7, .get_at_most_left # if val < current-> val, then it's too big. 

  mv x5, x7 #current val is good enough, store it as best . 
  ld x6, 16(x6) # Current is right child. 
  j .get_at_most_loop # start loop again 

.get_at_most_left:
  ld x6, 8(x6) # load left 
  j .get_at_most_loop # continue 

.get_at_most_done:
  mv x10, x5 # move best to x10 
  ret # return 
