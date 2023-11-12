; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; Check that function calls involving conversion from/to byval aren't transformed.
; RUN: opt < %s -passes=instcombine -S | FileCheck %s

%Foo = type { i64 }
define i64 @foo (ptr byval(%Foo) %foo) {
; CHECK-LABEL: @foo(
; CHECK-NEXT:    [[TMP1:%.*]] = load i64, ptr [[FOO:%.*]], align 4
; CHECK-NEXT:    ret i64 [[TMP1]]
;
  %1 = load i64, ptr %foo, align 4
  ret i64 %1
}

define i64 @bar(i64 %0) {
; CHECK-LABEL: @bar(
; CHECK-NEXT:    [[TMP2:%.*]] = tail call i64 @foo(i64 [[TMP0:%.*]])
; CHECK-NEXT:    ret i64 [[TMP2]]
;
  %2 = tail call i64 @foo(i64 %0)
  ret i64 %2
}

define i64 @qux(ptr byval(%Foo) %qux) {
; CHECK-LABEL: @qux(
; CHECK-NEXT:    [[TMP1:%.*]] = tail call i64 @bar(ptr nonnull byval([[FOO:%.*]]) [[QUX:%.*]])
; CHECK-NEXT:    ret i64 [[TMP1]]
;
  %1 = tail call i64 @bar(ptr byval(%Foo) %qux)
  ret i64 %1
}