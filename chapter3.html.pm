#lang pollen

◊chapter[#:index "3"]{Instructions}

◊strong{Instructions} specify actions that the computer can perform. To a computer, data values are like nouns. Instructions are like verbs.

Instructions consist of an operation, and multiple operands. The word “instruction” can also refer to just the operation itself. Operands specify the input data for the operation. An operand can be an ◊keyword{immediate} (a constant, hardcoded) value, or the address of a memory location containing the value. ◊keyword{Registers}, special high-speed data storage units, are also valid operands. Although the theoretical ◊keyword{random access machine} model does not involve registers, only memory, real computers have a set of registers, collectively called the ◊keyword{register file}, which serve as scratch space for computations. 

◊section{Registers store high-traffic data}

Registers are about 3-12 times faster to access than the fastest parts of memory making them ideal for storing frequently used data. They’re also usually several times the size of a single byte allowing them to store multi-byte values. A typical CPU has eight to perhaps thirty registers, though some specialized chips, like GPUs, can have hundreds.

◊aside{We can assume the first four names were chosen so that they would spell out the first four letters of the alphabet when abbreviated. Don’t ask what the ◊code{r} stands for, or the ◊code{x} for that matter. It’s a certified mess.}

Unlike memory locations, registers do not have addresses. Instructions refer to them by name. In the ◊keyword{x86_64 architecture}, the first eight ◊keyword{general-purpose registers} are named ◊x86asm{rax}, ◊x86asm{rcx}, ◊x86asm{rdx}, ◊x86asm{rbx}, ◊x86asm{rsp}, ◊x86asm{rbp}, ◊x86asm{rsi}, and ◊x86asm{rdi}, which stand for “◊em{accumulator}”, “◊em{counter}”, “◊em{data}”, “◊em{base}”, “◊em{stack pointer}”, “◊em{base pointer}”, “◊em{source}”, and “◊em{destination}”. The names came from what the designers of x86_64 first assumed people would mainly use them for, though today, most people use them interchangably. The next eight registers are just numbered ◊x86asm{r8} through ◊x86asm{r15}.

◊section{Architectures define instruction sets}

Architectures define ◊keyword{instruction sets}, which are the sets of operations processors can do. The x86_64 architecture and its parent, x86, are some of the most common in the world. They are by no means the only ones. ARM, an alternative class of architectures, is common in mobile devices. Your phone’s processor is probably ARM. Your desktop’s is probably x86_64. This book will use x86_64 for its examples, though the specific architecture used is unimportant.

Instruction sets usually come with ◊keyword{mnemonics}, short human-readable names that stand for types of processor operations. Examples of x86_64 mnemonics include ◊x86asm{mov} (the “move” instruction) and ◊x86asm{add} (the “add” instruction). Instructions written in mnemonics are called ◊keyword{assembly}.

◊section{x86 assembly basics}

◊aside{Here we use the ◊keyword{GNU assembly}, or ◊keyword{GAS} x86 syntax. Another x86 syntax called ◊keyword{Intel syntax} also exists, which we won’t use.}

Instructions in x86 assembly take the form: 

◊pre{
    operation operand1, operand2
}

Some instructions only take one operand and so are just written: 

◊pre{
    operation operand
}

Register operands are written with the name of the register, prefixed with a percent sign (◊x86asm{%rax}). For most instructions, all the general-purpose registers are valid operands, though a few require a specific register like ◊x86asm{%rcx} to be used. 

Memory operands are written in ◊keyword{addressing modes}, a system for computing addresses given up to four parameters. The syntax for an addressing mode is 

◊pre{
    displacement(base, index, stride)
}

which yields the address ◊math{◊var{displacement} + ◊var{base} + ◊var{index} × ◊var{stride}}. The base and index parameters are registers, while the displacement and stride parameters are constant values. Only strides of 1, 2, 4, and 8 are allowed. For example, ◊x86asm{4(%rbx, %rcx, 8)} evaluates to the memory address ◊math{4 + ◊var{rbx} + 8◊var{rcx}}.

All four addressing mode parameters are optional. By default, the displacement, base, and index parameters are 0, while the stride parameter is 1. ◊x86asm{4(%rbx, %rcx)}, ◊x86asm{4(%rbx)}, ◊x86asm{4(, %rcx, 8)}, and ◊x86asm{(%rbx)} are all valid addressing modes. Literal numbers by themselves, like ◊x86asm{4}, are also valid addressing modes; in this case, ◊x86asm{4} refers to memory location 4. 

Immediate (literal) operands are written with a dollar sign prefix (◊x86asm{$15}). Forgetting to prefix immediate values with the ◊code{$} is a common beginner mistake. ◊x86asm{$15} is the constant number 15, while ◊x86asm{15} is the value ◊em{stored in memory location} 15. Not all instructions accept immediate operands; some of the less-common ones require you to first load the value into a register and then specify the register as the operand. 

Instructions that take two operands can take a maximum of one immediate operand and one memory operand, so ◊x86asm{addq $22, $22}, and ◊x86asm{addq (%eax), (%eax)} are not valid x86 instructions. An operation on two immediate values always evaluates to a constant, so there’s no point in allowing an instruction to take two immediate operands. The memory operand restriction is a limitation of the x86 architecture. In theory you could design a processor that could operate on two memory locations at a time, though it probably wouldn’t be very efficient.

Modern x86_64 has well over 900 instructions, though only a dozen or so are used commonly. Each instruction comes in one or more flavors which indicate the size of the data they operate on. The size is written as a suffix, ◊code{b} (“byte”, 1 byte), ◊code{w} (“word”, 2 bytes), ◊code{l} (“long”, 4 bytes), or ◊code{q} (“quadword”, 8 bytes), at the end of the mnemonic. For example, ◊x86asm{movq} is the move instruction for 8-byte values.

◊aside{Memorizing x86 instructions is not important. All that is relevant is knowing they exist and knowing the kinds of things they can do.}

Some of the most commonly used x86_64 instructions are listed below for reference. Only the quadword flavor of each instruction is shown.

◊section{Data movement instructions}

◊pre[#:class "x86-prototype"]{
◊keyword{movq} source, destination
}

Moves the value in ◊code{source} into ◊code{destination}. 

◊em{Example:} ◊x86asm{movq %rax, (%rdi)}

◊pre[#:class "x86-prototype"]{
◊keyword{pushq} source
}

Decrements ◊code{rsp} by 8 (for a quadword) and then stores ◊code{source} in the memory location referenced by ◊code{rsp}. This instruction is useful when using ◊code{rsp} as a pointer to the top of a stack.

◊em{Example:} ◊x86asm{pushq %rax}

◊pre[#:class "x86-prototype"]{
◊keyword{popq} destination
}

Loads the value from the memory location referenced by ◊code{rsp} into ◊code{destination} and then increments ◊code{rsp} by 8 (for a quadword). This instruction is the opposite of ◊x86asm{pushq}.

◊em{Example:} ◊x86asm{popq %rax}

◊section{Arithmetic instructions}

◊pre[#:class "x86-prototype"]{
◊keyword{addq} addend, destination
}

Adds the value in ◊code{addend} to the value in ◊code{destination}, and stores the result in ◊code{destination}. 

◊em{Example:} ◊x86asm{addq $15, (%rdx)}

◊pre[#:class "x86-prototype"]{
◊keyword{subq} subtrahend, destination
}

Subtracts the value in ◊code{subtrahend} from the value in ◊code{destination}, and stores the result in ◊code{destination}. 

◊em{Example:} ◊x86asm{subq $10, %rax}

◊pre[#:class "x86-prototype"]{
◊keyword{mulq} factor
}

Multiplies the value in ◊code{factor} with the value in ◊code{rax}, and stores the low 64 bits of the result in ◊code{rax}. The high 64 bits (overflow bits) go into ◊code{rdx}. The multiplication performed is unsigned.

◊em{Example:} ◊x86asm{mulq %rcx}

◊pre[#:class "x86-prototype"]{
◊keyword{divq} divisor
}

Divides the 128-bit value stored jointly by ◊code{rax} (low 64 bits) and ◊code{rdx} (high 64 bits) by the value in ◊code{divisor}, and stores the result in ◊code{rax}. The division performed is unsigned. Note that the result may overflow ◊code{rax}.

◊em{Example:} ◊x86asm{divq %rcx}

◊pre[#:class "x86-prototype"]{
◊keyword{negq} destination
}

Negates the value stored in ◊code{destination}.

◊em{Example:} ◊x86asm{negq %rax}

◊section{Shift instructions}

◊pre[#:class "x86-prototype"]{
◊keyword{shlq} amount, destination
}

Shifts the value in ◊code{destination} left by ◊code{amount}, which must be either an immediate value or the register ◊code{cl} (the lowest byte of ◊code{rcx}.)

◊em{Example:} ◊x86asm{shlq %cl, (%edi)}

◊pre[#:class "x86-prototype"]{
◊keyword{shrq} amount, destination
}

Logically shifts the value in ◊code{destination} right by ◊code{amount}, which must be either an immediate value or the register ◊code{cl} (the lowest byte of ◊code{rcx}.)

◊em{Example:} ◊x86asm{shrq $3, %edx}

◊pre[#:class "x86-prototype"]{
◊keyword{sarq} amount, destination
}

Arithmetically shifts the value in ◊code{destination} right by ◊code{amount}, which must be either an immediate value or the register ◊code{cl} (the lowest byte of ◊code{rcx}.)

◊em{Example:} ◊x86asm{sarq $1, 8(%ebx)}

◊section{Logical instructions}

◊pre[#:class "x86-prototype"]{
◊keyword{notq} destination
}

Inverts the bits in ◊code{destination}.

◊em{Example:} ◊x86asm{notq %edx}

◊pre[#:class "x86-prototype"]{
◊keyword{andq} mask, destination
}

Stores the bitwise conjunction of ◊code{mask} and ◊code{destination} in ◊code{destination}.

◊em{Example:} ◊x86asm{andq $15, %eax}


◊pre[#:class "x86-prototype"]{
◊keyword{orq} value, destination
}

Stores the bitwise disjunction of ◊code{value} and ◊code{destination} in ◊code{destination}.

◊em{Example:} ◊x86asm{orq %ecx, %eax}

◊pre[#:class "x86-prototype"]{
◊keyword{xorq} value, destination
}

Stores the bitwise exclusive disjunction of ◊code{value} and ◊code{destination} in ◊code{destination}.

◊em{Example:} ◊x86asm{xorq %eax, %eax}

◊section{Assembly programs}

Assembly instructions form the building blocks of ◊keyword{programs}. For example, the following instructions executed in sequence compute the absolute value of ◊code{rcx} and store the result in ◊code{rax}.

◊pre[#:class "x86asm"]{
movq    %rcx, %rax 
sarq    $63 , %rcx
xorq    %rcx, %rax
subq    %rcx, %rax
}

Let’s review what each of these instructions do.

◊pre[#:class "x86asm"]{
    movq    %rcx, %rax 
}

The first instruction makes a copy of the value in ◊code{rcx} and places it in ◊code{rax}.

◊pre[#:class "x86asm"]{
    sarq    $63 , %rcx
}

An arithmetic right shift takes the sign bit of ◊code{rcx} and copies it into the other 63 bits of the register. Since the sign bit of a binary integer is 0 if positive or 1 if negative, ◊code{rcx} will contain the all-zeroes bit pattern ◊code{0x0000_0000_0000_0000} if positive, or the all-ones bit pattern ◊code{0xffff_ffff_ffff_ffff} if negative. 

◊pre[#:class "x86asm"]{
xorq    %rcx, %rax
}

Since a value xor-ed with the all-zeroes bit pattern gives you the original value, and a value xor-ed with the all-ones bit pattern flips all its bits, this instruction takes the ones complement of ◊code{rax} if it’s negative. Recall this is the first step in negating a binary signed integer. 

◊pre[#:class "x86asm"]{
subq    %rcx, %rax
}

This instruction subtracts ◊code{rcx} from ◊code{rax}. Remember that in signed integer representation, the all-zeros bit pattern is 0, and the all-ones bitpattern is −1. Since subtracting −1 is the same as adding 1, this instruction adds either 0 or 1 to ◊code{rax} depending on ◊code{rcx}. Recall adding 1 is the second step in negating a binary signed integer. So at the end of this, ◊code{rax} contains the negative of ◊code{rcx} if negative, and ◊code{rcx} itself if positive.
