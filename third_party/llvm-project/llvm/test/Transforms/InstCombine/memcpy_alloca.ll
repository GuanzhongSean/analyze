; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -passes=instcombine -S | FileCheck %s

; Memcpy is copying known-undef, and is thus removable
define void @test(i8* %dest) {
; CHECK-LABEL: @test(
; CHECK-NEXT:    ret void
;
  %a = alloca [7 x i8]
  %src = getelementptr inbounds [7 x i8], [7 x i8]* %a, i64 0, i64 0
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %dest, i8* %src, i64 7, i1 false)
  ret void
}

; Some non-undef elements
define void @test2(i8* %dest) {
; CHECK-LABEL: @test2(
; CHECK-NEXT:    [[A:%.*]] = alloca [7 x i8], align 1
; CHECK-NEXT:    [[SRC:%.*]] = getelementptr inbounds [7 x i8], [7 x i8]* [[A]], i64 0, i64 0
; CHECK-NEXT:    store i8 0, i8* [[SRC]], align 1
; CHECK-NEXT:    call void @llvm.memcpy.p0i8.p0i8.i64(i8* noundef nonnull align 1 dereferenceable(7) [[DEST:%.*]], i8* noundef nonnull align 1 dereferenceable(7) [[SRC]], i64 7, i1 false)
; CHECK-NEXT:    ret void
;
  %a = alloca [7 x i8]
  %src = getelementptr inbounds [7 x i8], [7 x i8]* %a, i64 0, i64 0
  store i8 0, i8* %src
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %dest, i8* %src, i64 7, i1 false)
  ret void
}

; Volatile write is still required
define void @test3(i8* %dest) {
; CHECK-LABEL: @test3(
; CHECK-NEXT:    [[A:%.*]] = alloca [7 x i8], align 1
; CHECK-NEXT:    [[SRC:%.*]] = getelementptr inbounds [7 x i8], [7 x i8]* [[A]], i64 0, i64 0
; CHECK-NEXT:    call void @llvm.memcpy.p0i8.p0i8.i64(i8* [[DEST:%.*]], i8* [[SRC]], i64 7, i1 true)
; CHECK-NEXT:    ret void
;
  %a = alloca [7 x i8]
  %src = getelementptr inbounds [7 x i8], [7 x i8]* %a, i64 0, i64 0
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %dest, i8* %src, i64 7, i1 true)
  ret void
}

define void @test4(i8* %dest) {
; CHECK-LABEL: @test4(
; CHECK-NEXT:    ret void
;
  %a = alloca [7 x i8]
  %src = bitcast [7 x i8]* %a to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %dest, i8* %src, i64 7, i1 false)
  ret void
}

define void @test5(i8* %dest) {
; CHECK-LABEL: @test5(
; CHECK-NEXT:    ret void
;
  %a = alloca [7 x i8]
  %p1 = bitcast [7 x i8]* %a to i32*
  %p2 = getelementptr i32, i32* %p1, i32 1
  %src = bitcast i32* %p2 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %dest, i8* %src, i64 3, i1 false)
  ret void
}

define void @test6(i8* %dest) {
; CHECK-LABEL: @test6(
; CHECK-NEXT:    [[A:%.*]] = alloca [7 x i8], align 1
; CHECK-NEXT:    [[P2:%.*]] = getelementptr inbounds [7 x i8], [7 x i8]* [[A]], i64 0, i64 2
; CHECK-NEXT:    [[TMP1:%.*]] = bitcast i8* [[P2]] to i16*
; CHECK-NEXT:    store i16 42, i16* [[TMP1]], align 2
; CHECK-NEXT:    call void @llvm.memcpy.p0i8.p0i8.i64(i8* noundef nonnull align 1 dereferenceable(7) [[DEST:%.*]], i8* noundef nonnull align 1 dereferenceable(7) [[P2]], i64 7, i1 false)
; CHECK-NEXT:    ret void
;
  %a = alloca [7 x i8]
  %p1 = bitcast [7 x i8]* %a to i16*
  %p2 = getelementptr i16, i16* %p1, i32 1
  store i16 42, i16* %p2
  %src = bitcast i16* %p2 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %dest, i8* %src, i64 7, i1 false)
  ret void
}

declare void @llvm.memcpy.p0i8.p0i8.i64(i8*, i8*, i64, i1)