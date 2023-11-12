; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -loop-vectorize -instcombine -force-vector-width=4 -S < %s 2>&1 | FileCheck %s

target datalayout = "e-m:e-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128"

;;;; Derived from the following C code
;; void forked_ptrs_different_base_same_offset(float *A, float *B, float *C, int *D) {
;;   for (int i=0; i<100; i++) {
;;     if (D[i] != 0) {
;;       C[i] = A[i];
;;     } else {
;;       C[i] = B[i];
;;     }
;;   }
;; }

define dso_local void @forked_ptrs_different_base_same_offset(float* nocapture readonly %Base1, float* nocapture readonly %Base2, float* nocapture %Dest, i32* nocapture readonly %Preds) {
; CHECK-LABEL: @forked_ptrs_different_base_same_offset(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[BASE1_FR:%.*]] = freeze float* [[BASE1:%.*]]
; CHECK-NEXT:    [[BASE2_FR:%.*]] = freeze float* [[BASE2:%.*]]
; CHECK-NEXT:    [[DEST_FR:%.*]] = freeze float* [[DEST:%.*]]
; CHECK-NEXT:    br i1 false, label [[SCALAR_PH:%.*]], label [[VECTOR_MEMCHECK:%.*]]
; CHECK:       vector.memcheck:
; CHECK-NEXT:    [[DEST1:%.*]] = ptrtoint float* [[DEST_FR]] to i64
; CHECK-NEXT:    [[PREDS2:%.*]] = ptrtoint i32* [[PREDS:%.*]] to i64
; CHECK-NEXT:    [[BASE23:%.*]] = ptrtoint float* [[BASE2_FR]] to i64
; CHECK-NEXT:    [[BASE15:%.*]] = ptrtoint float* [[BASE1_FR]] to i64
; CHECK-NEXT:    [[TMP0:%.*]] = sub i64 [[DEST1]], [[PREDS2]]
; CHECK-NEXT:    [[DIFF_CHECK:%.*]] = icmp ult i64 [[TMP0]], 16
; CHECK-NEXT:    [[TMP1:%.*]] = sub i64 [[DEST1]], [[BASE23]]
; CHECK-NEXT:    [[DIFF_CHECK4:%.*]] = icmp ult i64 [[TMP1]], 16
; CHECK-NEXT:    [[CONFLICT_RDX:%.*]] = or i1 [[DIFF_CHECK]], [[DIFF_CHECK4]]
; CHECK-NEXT:    [[TMP2:%.*]] = sub i64 [[DEST1]], [[BASE15]]
; CHECK-NEXT:    [[DIFF_CHECK7:%.*]] = icmp ult i64 [[TMP2]], 16
; CHECK-NEXT:    [[CONFLICT_RDX8:%.*]] = or i1 [[CONFLICT_RDX]], [[DIFF_CHECK7]]
; CHECK-NEXT:    br i1 [[CONFLICT_RDX8]], label [[SCALAR_PH]], label [[VECTOR_PH:%.*]]
; CHECK:       vector.ph:
; CHECK-NEXT:    [[BROADCAST_SPLATINSERT:%.*]] = insertelement <4 x float*> poison, float* [[BASE2_FR]], i64 0
; CHECK-NEXT:    [[BROADCAST_SPLAT:%.*]] = shufflevector <4 x float*> [[BROADCAST_SPLATINSERT]], <4 x float*> poison, <4 x i32> zeroinitializer
; CHECK-NEXT:    [[BROADCAST_SPLATINSERT9:%.*]] = insertelement <4 x float*> poison, float* [[BASE1_FR]], i64 0
; CHECK-NEXT:    [[BROADCAST_SPLAT10:%.*]] = shufflevector <4 x float*> [[BROADCAST_SPLATINSERT9]], <4 x float*> poison, <4 x i32> zeroinitializer
; CHECK-NEXT:    br label [[VECTOR_BODY:%.*]]
; CHECK:       vector.body:
; CHECK-NEXT:    [[INDEX:%.*]] = phi i64 [ 0, [[VECTOR_PH]] ], [ [[INDEX_NEXT:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[TMP3:%.*]] = or i64 [[INDEX]], 1
; CHECK-NEXT:    [[TMP4:%.*]] = or i64 [[INDEX]], 2
; CHECK-NEXT:    [[TMP5:%.*]] = or i64 [[INDEX]], 3
; CHECK-NEXT:    [[TMP6:%.*]] = getelementptr inbounds i32, i32* [[PREDS]], i64 [[INDEX]]
; CHECK-NEXT:    [[TMP7:%.*]] = bitcast i32* [[TMP6]] to <4 x i32>*
; CHECK-NEXT:    [[WIDE_LOAD:%.*]] = load <4 x i32>, <4 x i32>* [[TMP7]], align 4
; CHECK-NEXT:    [[TMP8:%.*]] = icmp eq <4 x i32> [[WIDE_LOAD]], zeroinitializer
; CHECK-NEXT:    [[TMP9:%.*]] = select <4 x i1> [[TMP8]], <4 x float*> [[BROADCAST_SPLAT]], <4 x float*> [[BROADCAST_SPLAT10]]
; CHECK-NEXT:    [[TMP10:%.*]] = extractelement <4 x float*> [[TMP9]], i64 0
; CHECK-NEXT:    [[TMP11:%.*]] = getelementptr inbounds float, float* [[TMP10]], i64 [[INDEX]]
; CHECK-NEXT:    [[TMP12:%.*]] = extractelement <4 x float*> [[TMP9]], i64 1
; CHECK-NEXT:    [[TMP13:%.*]] = getelementptr inbounds float, float* [[TMP12]], i64 [[TMP3]]
; CHECK-NEXT:    [[TMP14:%.*]] = extractelement <4 x float*> [[TMP9]], i64 2
; CHECK-NEXT:    [[TMP15:%.*]] = getelementptr inbounds float, float* [[TMP14]], i64 [[TMP4]]
; CHECK-NEXT:    [[TMP16:%.*]] = extractelement <4 x float*> [[TMP9]], i64 3
; CHECK-NEXT:    [[TMP17:%.*]] = getelementptr inbounds float, float* [[TMP16]], i64 [[TMP5]]
; CHECK-NEXT:    [[TMP18:%.*]] = load float, float* [[TMP11]], align 4
; CHECK-NEXT:    [[TMP19:%.*]] = load float, float* [[TMP13]], align 4
; CHECK-NEXT:    [[TMP20:%.*]] = load float, float* [[TMP15]], align 4
; CHECK-NEXT:    [[TMP21:%.*]] = load float, float* [[TMP17]], align 4
; CHECK-NEXT:    [[TMP22:%.*]] = insertelement <4 x float> poison, float [[TMP18]], i64 0
; CHECK-NEXT:    [[TMP23:%.*]] = insertelement <4 x float> [[TMP22]], float [[TMP19]], i64 1
; CHECK-NEXT:    [[TMP24:%.*]] = insertelement <4 x float> [[TMP23]], float [[TMP20]], i64 2
; CHECK-NEXT:    [[TMP25:%.*]] = insertelement <4 x float> [[TMP24]], float [[TMP21]], i64 3
; CHECK-NEXT:    [[TMP26:%.*]] = getelementptr inbounds float, float* [[DEST_FR]], i64 [[INDEX]]
; CHECK-NEXT:    [[TMP27:%.*]] = bitcast float* [[TMP26]] to <4 x float>*
; CHECK-NEXT:    store <4 x float> [[TMP25]], <4 x float>* [[TMP27]], align 4
; CHECK-NEXT:    [[INDEX_NEXT]] = add nuw i64 [[INDEX]], 4
; CHECK-NEXT:    [[TMP28:%.*]] = icmp eq i64 [[INDEX_NEXT]], 100
; CHECK-NEXT:    br i1 [[TMP28]], label [[MIDDLE_BLOCK:%.*]], label [[VECTOR_BODY]], !llvm.loop [[LOOP0:![0-9]+]]
; CHECK:       middle.block:
; CHECK-NEXT:    br i1 true, label [[FOR_COND_CLEANUP:%.*]], label [[SCALAR_PH]]
; CHECK:       scalar.ph:
; CHECK-NEXT:    [[BC_RESUME_VAL:%.*]] = phi i64 [ 100, [[MIDDLE_BLOCK]] ], [ 0, [[ENTRY:%.*]] ], [ 0, [[VECTOR_MEMCHECK]] ]
; CHECK-NEXT:    br label [[FOR_BODY:%.*]]
; CHECK:       for.cond.cleanup:
; CHECK-NEXT:    ret void
; CHECK:       for.body:
; CHECK-NEXT:    [[INDVARS_IV:%.*]] = phi i64 [ [[BC_RESUME_VAL]], [[SCALAR_PH]] ], [ [[INDVARS_IV_NEXT:%.*]], [[FOR_BODY]] ]
; CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds i32, i32* [[PREDS]], i64 [[INDVARS_IV]]
; CHECK-NEXT:    [[TMP29:%.*]] = load i32, i32* [[ARRAYIDX]], align 4
; CHECK-NEXT:    [[CMP1_NOT:%.*]] = icmp eq i32 [[TMP29]], 0
; CHECK-NEXT:    [[SPEC_SELECT:%.*]] = select i1 [[CMP1_NOT]], float* [[BASE2_FR]], float* [[BASE1_FR]]
; CHECK-NEXT:    [[DOTSINK_IN:%.*]] = getelementptr inbounds float, float* [[SPEC_SELECT]], i64 [[INDVARS_IV]]
; CHECK-NEXT:    [[DOTSINK:%.*]] = load float, float* [[DOTSINK_IN]], align 4
; CHECK-NEXT:    [[TMP30:%.*]] = getelementptr inbounds float, float* [[DEST_FR]], i64 [[INDVARS_IV]]
; CHECK-NEXT:    store float [[DOTSINK]], float* [[TMP30]], align 4
; CHECK-NEXT:    [[INDVARS_IV_NEXT]] = add nuw nsw i64 [[INDVARS_IV]], 1
; CHECK-NEXT:    [[EXITCOND_NOT:%.*]] = icmp eq i64 [[INDVARS_IV_NEXT]], 100
; CHECK-NEXT:    br i1 [[EXITCOND_NOT]], label [[FOR_COND_CLEANUP]], label [[FOR_BODY]], !llvm.loop [[LOOP2:![0-9]+]]
;
entry:
  br label %for.body

for.cond.cleanup:
  ret void

for.body:
  %indvars.iv = phi i64 [ 0, %entry ], [ %indvars.iv.next, %for.body ]
  %arrayidx = getelementptr inbounds i32, i32* %Preds, i64 %indvars.iv
  %0 = load i32, i32* %arrayidx, align 4
  %cmp1.not = icmp eq i32 %0, 0
  %spec.select = select i1 %cmp1.not, float* %Base2, float* %Base1
  %.sink.in = getelementptr inbounds float, float* %spec.select, i64 %indvars.iv
  %.sink = load float, float* %.sink.in, align 4
  %1 = getelementptr inbounds float, float* %Dest, i64 %indvars.iv
  store float %.sink, float* %1, align 4
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %exitcond.not = icmp eq i64 %indvars.iv.next, 100
  br i1 %exitcond.not, label %for.cond.cleanup, label %for.body
}

;;;; Derived from the following C code
;; void forked_ptrs_same_base_different_offset(float *A, float *B, int *C) {
;;   int offset;
;;   for (int i = 0; i < 100; i++) {
;;     if (C[i] != 0)
;;       offset = i;
;;     else
;;       offset = i+1;
;;     B[i] = A[offset];
;;   }
;; }

define dso_local void @forked_ptrs_same_base_different_offset(float* nocapture readonly %Base, float* nocapture %Dest, i32* nocapture readonly %Preds) {
; CHECK-LABEL: @forked_ptrs_same_base_different_offset(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[FOR_BODY:%.*]]
; CHECK:       for.cond.cleanup:
; CHECK-NEXT:    ret void
; CHECK:       for.body:
; CHECK-NEXT:    [[INDVARS_IV:%.*]] = phi i64 [ 0, [[ENTRY:%.*]] ], [ [[INDVARS_IV_NEXT:%.*]], [[FOR_BODY]] ]
; CHECK-NEXT:    [[I_014:%.*]] = phi i32 [ 0, [[ENTRY]] ], [ [[ADD:%.*]], [[FOR_BODY]] ]
; CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds i32, i32* [[PREDS:%.*]], i64 [[INDVARS_IV]]
; CHECK-NEXT:    [[TMP0:%.*]] = load i32, i32* [[ARRAYIDX]], align 4
; CHECK-NEXT:    [[CMP1_NOT:%.*]] = icmp eq i32 [[TMP0]], 0
; CHECK-NEXT:    [[INDVARS_IV_NEXT]] = add nuw nsw i64 [[INDVARS_IV]], 1
; CHECK-NEXT:    [[ADD]] = add nuw nsw i32 [[I_014]], 1
; CHECK-NEXT:    [[TMP1:%.*]] = trunc i64 [[INDVARS_IV]] to i32
; CHECK-NEXT:    [[OFFSET_0:%.*]] = select i1 [[CMP1_NOT]], i32 [[ADD]], i32 [[TMP1]]
; CHECK-NEXT:    [[IDXPROM213:%.*]] = zext i32 [[OFFSET_0]] to i64
; CHECK-NEXT:    [[ARRAYIDX3:%.*]] = getelementptr inbounds float, float* [[BASE:%.*]], i64 [[IDXPROM213]]
; CHECK-NEXT:    [[TMP2:%.*]] = load float, float* [[ARRAYIDX3]], align 4
; CHECK-NEXT:    [[ARRAYIDX5:%.*]] = getelementptr inbounds float, float* [[DEST:%.*]], i64 [[INDVARS_IV]]
; CHECK-NEXT:    store float [[TMP2]], float* [[ARRAYIDX5]], align 4
; CHECK-NEXT:    [[EXITCOND_NOT:%.*]] = icmp eq i64 [[INDVARS_IV_NEXT]], 100
; CHECK-NEXT:    br i1 [[EXITCOND_NOT]], label [[FOR_COND_CLEANUP:%.*]], label [[FOR_BODY]]
;
entry:
  br label %for.body

for.cond.cleanup:                                 ; preds = %for.body
  ret void

for.body:                                         ; preds = %entry, %for.body
  %indvars.iv = phi i64 [ 0, %entry ], [ %indvars.iv.next, %for.body ]
  %i.014 = phi i32 [ 0, %entry ], [ %add, %for.body ]
  %arrayidx = getelementptr inbounds i32, i32* %Preds, i64 %indvars.iv
  %0 = load i32, i32* %arrayidx, align 4
  %cmp1.not = icmp eq i32 %0, 0
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %add = add nuw nsw i32 %i.014, 1
  %1 = trunc i64 %indvars.iv to i32
  %offset.0 = select i1 %cmp1.not, i32 %add, i32 %1
  %idxprom213 = zext i32 %offset.0 to i64
  %arrayidx3 = getelementptr inbounds float, float* %Base, i64 %idxprom213
  %2 = load float, float* %arrayidx3, align 4
  %arrayidx5 = getelementptr inbounds float, float* %Dest, i64 %indvars.iv
  store float %2, float* %arrayidx5, align 4
  %exitcond.not = icmp eq i64 %indvars.iv.next, 100
  br i1 %exitcond.not, label %for.cond.cleanup, label %for.body
}