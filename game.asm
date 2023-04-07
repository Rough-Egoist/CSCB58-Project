#####################################################################
#
# CSCB58 Winter 2023 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: Name, Student Number, UTorID, official email
#
# Bitmap Display Configuration:
# - Unit width in pixels: 4 (update this as needed)
# - Unit height in pixels: 4 (update this as needed)
# - Display width in pixels: 512 (update this as needed)
# - Display height in pixels: 256 (update this as needed)
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestones have been reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1/2/3 (choose the one the applies)
#
# Which approved features have been implemented for milestone 3?
# (See the assignment handout for the list of additional features)
# 1. (fill in the feature, if any)
# 2. (fill in the feature, if any)
# 3. (fill in the feature, if any)
# ... (add more if necessary)
#
# Link to video demonstration for final submission:
# - (insert YouTube / MyMedia / other URL here). Make sure we can view it!
#
# Are you OK with us sharing the video with people outside course staff?
# - yes / no / yes, and please share this project github link as well!
#
# Any additional information that the TA needs to know:
# - (write here, if any)
#
####################################################################

#############Constants

.eqv SCREEN_WIDTH 64
.eqv SCREEN_HEIGHT 32



######data
.data
framebuffer_base: .word 0x10008000
framebuffer_width: .word 512
framebuffer_height: .word 256


.text
.globl main
main:
    # 初始化 Bitmap Display
    li $v0, 50
    la $a0, framebuffer_base
    la $a1, framebuffer_width
    la $a2, framebuffer_height
    syscall

    # 初始化键盘输入
    li $v0, 33
    li $a0, 1
    syscall

screen_loop:
    # 检测用户输入
    li $v0, 34
    syscall

    # 根据输入的键切换画面
    li $t1, 49  # ASCII 码：'1'
    beq $v0, $t1, draw_screen_1
    li $t1, 50  # ASCII 码：'2'
    beq $v0, $t1, draw_screen_2
    li $t1, 51
    beq $v0, $t1, draw_screen_3

    # 无效输入，继续检测
    j screen_loop

draw_screen_1:
    # 绘制画面 1
    # ... （在此处添加画面 1 的绘制代码）

    # 返回 screen_loop
    j screen_loop

draw_screen_2:
    # 绘制画面 2
    # ... （在此处添加画面 2 的绘制代码）

    # 返回 screen_loop
    j screen_loop


# 检查边界上的像素
check_collision:
    # 参数：$a0 - 角色 x；$a1 - 角色 y；$a2 - 角色宽度；$a3 - 角色高度
    # 返回值：$v0 - 是否发生碰撞（0 为无碰撞，1 为碰撞）

    # 假设：角色和屏幕边界之间的空白像素具有透明的 alpha 值（0）

    move $t0, $a0          # 保存角色 x
    move $t1, $a1          # 保存角色 y
    move $t2, $a2          # 保存角色宽度
    move $t3, $a3          # 保存角色高度
    la $t4, framebuffer_base

    li $v0, 0              # 默认返回值为 0（无碰撞）

    # 检查顶部边界
    move $t5, $t1
    jal check_row
    bne $v0, 0, collision_detected

    # 检查底部边界
    add $t5, $t1, $t3
    subi $t5, $t5, 1
    jal check_row
    bne $v0, 0, collision_detected

    # 检查左侧边界
    move $t5, $t0
    jal check_column
    bne $v0, 0, collision_detected

    # 检查右侧边界
    add $t5, $t0, $t2
    subi $t5, $t5, 1
    jal check_column
    bne $v0, 0, collision_detected

    jr $ra

collision_detected:
    li $v0, 1              # 设置返回值为 1（碰撞）
    jr $ra

check_row:
    # 检查指定行上的像素，$t5 为行号
    move $t6, $t0
row_loop:
    mul $t7, $t5, 512      # 计算像素在帧缓冲区中的行偏移
    add $t7, $t7, $t6      # 添加列（x）偏移
    sll $t7, $t7, 2        # 每个像素有 4 字节（32 位）
    add $t7, $t7, $t4      # 添加帧缓冲区基址

    lw $t8, 0($t7)         # 读取像素颜色值
    andi $t8, $t8, 0xFF    # 提取 alpha 值（低 8 位）
    bne $t8, 0, collision_detected
