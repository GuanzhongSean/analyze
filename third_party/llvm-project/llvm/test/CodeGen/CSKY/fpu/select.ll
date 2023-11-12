; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -verify-machineinstrs -csky-no-aliases < %s -mtriple=csky -mattr=+2e3,+hard-float,+fpuv2_sf,+fpuv2_df -float-abi=hard | FileCheck %s
; RUN: llc -verify-machineinstrs -csky-no-aliases < %s -mtriple=csky -mattr=+2e3,+hard-float,+fpuv3_sf,+fpuv3_df -float-abi=hard | FileCheck %s --check-prefix=CHECK-DF3
; RUN: llc -verify-machineinstrs -csky-no-aliases < %s -mtriple=csky -mattr=+btst16,+hard-float,+fpuv2_sf,+fpuv2_df -float-abi=hard | FileCheck %s --check-prefix=GENERIC

define float @selectRR_eq_float(i1 %x, float %n, float %m) {
; CHECK-LABEL: selectRR_eq_float:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    btsti32 a0, 0
; CHECK-NEXT:    bt32 .LBB0_2
; CHECK-NEXT:  # %bb.1: # %entry
; CHECK-NEXT:    fmovs vr1, vr0
; CHECK-NEXT:  .LBB0_2: # %entry
; CHECK-NEXT:    fmovs vr0, vr1
; CHECK-NEXT:    rts16
;
; CHECK-DF3-LABEL: selectRR_eq_float:
; CHECK-DF3:       # %bb.0: # %entry
; CHECK-DF3-NEXT:    btsti32 a0, 0
; CHECK-DF3-NEXT:    fsel.32 vr0, vr1, vr0
; CHECK-DF3-NEXT:    rts16
;
; GENERIC-LABEL: selectRR_eq_float:
; GENERIC:       # %bb.0: # %entry
; GENERIC-NEXT:    .cfi_def_cfa_offset 0
; GENERIC-NEXT:    subi16 sp, sp, 4
; GENERIC-NEXT:    .cfi_def_cfa_offset 4
; GENERIC-NEXT:    btsti16 a0, 0
; GENERIC-NEXT:    bt16 .LBB0_2
; GENERIC-NEXT:  # %bb.1: # %entry
; GENERIC-NEXT:    fmovs vr1, vr0
; GENERIC-NEXT:  .LBB0_2: # %entry
; GENERIC-NEXT:    fmovs vr0, vr1
; GENERIC-NEXT:    addi16 sp, sp, 4
; GENERIC-NEXT:    rts16
entry:
  %ret = select i1 %x, float %m, float %n
  ret float %ret
}

define double @selectRR_eq_double(i1 %x, double %n, double %m) {
; CHECK-LABEL: selectRR_eq_double:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    btsti32 a0, 0
; CHECK-NEXT:    bt32 .LBB1_2
; CHECK-NEXT:  # %bb.1: # %entry
; CHECK-NEXT:    fmovd vr1, vr0
; CHECK-NEXT:  .LBB1_2: # %entry
; CHECK-NEXT:    fmovd vr0, vr1
; CHECK-NEXT:    rts16
;
; CHECK-DF3-LABEL: selectRR_eq_double:
; CHECK-DF3:       # %bb.0: # %entry
; CHECK-DF3-NEXT:    btsti32 a0, 0
; CHECK-DF3-NEXT:    fsel.64 vr0, vr1, vr0
; CHECK-DF3-NEXT:    rts16
;
; GENERIC-LABEL: selectRR_eq_double:
; GENERIC:       # %bb.0: # %entry
; GENERIC-NEXT:    .cfi_def_cfa_offset 0
; GENERIC-NEXT:    subi16 sp, sp, 4
; GENERIC-NEXT:    .cfi_def_cfa_offset 4
; GENERIC-NEXT:    btsti16 a0, 0
; GENERIC-NEXT:    bt16 .LBB1_2
; GENERIC-NEXT:  # %bb.1: # %entry
; GENERIC-NEXT:    fmovd vr1, vr0
; GENERIC-NEXT:  .LBB1_2: # %entry
; GENERIC-NEXT:    fmovd vr0, vr1
; GENERIC-NEXT:    addi16 sp, sp, 4
; GENERIC-NEXT:    rts16
entry:
  %ret = select i1 %x, double %m, double %n
  ret double %ret
}
