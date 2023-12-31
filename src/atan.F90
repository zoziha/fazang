module fazang_atan_op_mod
  use iso_fortran_env
  use fazang_vari_mod, only : vari, adstack, callstack
  use fazang_var_mod
  use fazang_env_mod

  implicit none

contains
  
  subroutine chain_atan(this)
    class(vari), intent(in) :: this
    real(rk) :: adj(1), val(1)
    val = this%operand_val()
    adj(1) = this%adj() / (1.d0 + val(1) * val(1))
    call this%set_operand_adj(adj)
  end subroutine chain_atan
  
  impure elemental function atan_v(v) result(s)
    type(var), intent(in) :: v
    type(var) :: s
    s = var(atan(v%val()), [v])
    call s%set_chain(chain_atan)
  end function atan_v

end module fazang_atan_op_mod

module fazang_atan_mod
  use fazang_atan_op_mod
  implicit none

  interface atan
     module procedure atan_v
  end interface atan
end module fazang_atan_mod
