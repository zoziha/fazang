#include "test_macro.fi"

program sub_test
  use, intrinsic :: iso_fortran_env
  use fazang_test_mod
  use fazang_vari_mod, only : vari, adstack, callstack, vari_at
  use fazang_env_mod
  use fazang_var_mod
  use fazang_sub_mod
  use fazang_add_mod
  use fazang_cos_mod
  use fazang_sin_mod
  use fazang_grad_mod
  implicit none

  type(var) :: x, y1, y2, y3, y4
  real(rk) :: z1 = 2.4d0, z2 = 3.9d0
  type(vari), pointer :: vp

  x = var(1.5d0)
  x = x - z1
  y1 = x
  EXPECT_EQ(callstack%head, 3)
  EXPECT_FLOAT_EQ(y1%val(), 1.5d0 - z1)

  vp => vari_at(y1%vi)
  call vp%set_adj(0.4d0)
  call vp%chain()
  EXPECT_FLOAT_EQ(0.4d0, x%adj())
  EXPECT_FLOAT_EQ(0.4d0, y1%adj())

  y2 = var(2.6d0)
  y3 = y2 - y1
  EXPECT_EQ(callstack%head, 5)
  EXPECT_FLOAT_EQ(y3%val(), y2%val() - y1%val())

  call set_zero_all_adj()
  vp => vari_at(y3%vi)
  call vp%init_dependent()
  call vp%chain()
  EXPECT_FLOAT_EQ(y2%adj(), 1.d0)
  EXPECT_FLOAT_EQ(y1%adj(), -1.d0)

  y4 = y1 - z1 - y2 - z2
  EXPECT_EQ(callstack%head, 8)
  call set_zero_all_adj()
  call y4%grad()
  EXPECT_FLOAT_EQ(y1%adj(), 1.d0)
  EXPECT_FLOAT_EQ(y2%adj(), -1.d0)

  call callstack%set_zero_all_adj()
  y4 = sin(y1) - sin(z1) - cos(y2) + cos(z2)
  EXPECT_EQ(callstack%head, 13)
  call set_zero_all_adj()
  call y4%grad()
  EXPECT_FLOAT_EQ(y4%val(), sin(y1%val()) - sin(z1) - cos(y2%val()) + cos(z2))
  EXPECT_FLOAT_EQ(y1%adj(), cos(y1%val()))
  EXPECT_FLOAT_EQ(y2%adj(), sin(y2%val()))

  y4 = -y3
  call set_zero_all_adj()
  call y4%grad()
  EXPECT_FLOAT_EQ(y3%adj(), -1.0d0)

  y4 = y2 - y2
  call set_zero_all_adj()
  call y4%grad()
  EXPECT_FLOAT_EQ(y2%adj(), 0.0d0)
  y4 = y2 - y2 - y2
  call set_zero_all_adj()
  call y4%grad()
  EXPECT_FLOAT_EQ(y2%adj(), -1.0d0)

end program sub_test
