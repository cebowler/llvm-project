// REQUIRES: arm
// RUN: llvm-mc --triple=armv7a-linux-gnueabihf -arm-add-build-attributes -filetype=obj -o %t.o %s
// RUN: ld.lld %t.o --defsym sym=0x13001 -o %t 2>&1 | FileCheck %s --check-prefix=WARN
// RUN: llvm-objdump --no-show-raw-insn -d %t | FileCheck %s

/// A similar test to arm-thumb-interwork-notfunc.s this time exercising the
/// case where a symbol does not have type STT_FUNC but it does have the bottom
/// bit set. We use absolute symbols to represent assembler labels as the
/// minimum alignment of a label in code is 2.
.syntax unified
.global sym
.global _start
.type _start, %function
.text
.balign 0x1000
_start:
arm_caller:
.arm
  b sym
  bl sym
// WARN: branch and link relocation: R_ARM_CALL to non STT_FUNC symbol: sym interworking not performed; consider using directive '.type sym, %function' to give symbol type STT_FUNC if interworking between ARM and Thumb is required
  blx sym
.thumb
thumb_caller:
  b sym
  bl sym
  blx sym
// WARN: branch and link relocation: R_ARM_THM_CALL to non STT_FUNC symbol: sym interworking not performed; consider using directive '.type sym, %function' to give symbol type STT_FUNC if interworking between ARM and Thumb is required

// CHECK: 00012000 <arm_caller>:
// CHECK-NEXT:    12000: b   #4088
// CHECK-NEXT:    12004: bl  #4084
// CHECK-NEXT:    12008: blx #4080

// CHECK: 0001200c <thumb_caller>:
// CHECK-NEXT:    1200c: b.w     #4080
// CHECK-NEXT:    12010: bl      #4076
// CHECK-NEXT:    12014: blx     #4076
