# Fazang

![build](https://github.com/zoziha/fazang/actions/workflows/build.yml/badge.svg)

`Fazang` is a Fortran library for reverse-mode automatic differentiation, inspired by [Stan/Math library](https://mc-stan.org/users/interfaces/math).


## Quick start

`Fazang` provides user-facing variable `var` type. It is the type for dependent and independent variables of which derivatives will be calculated.

```fortran
program var_grad_test
  use fazang ! load Fazang library

  implicit none

  real(rk) :: y, fx_d
  type(var) :: f, sigma, mu

  ! data
  y = 1.3d0

  ! independent variables
  mu = var(0.5d0)
  sigma = var(1.2d0)

  ! dependent
  f = var(-0.5d0 * log(2 * pi))
  f = f - log(sigma)
  f = f - 0.5d0 * ((y - mu) / sigma) ** 2.d0;

  ! use grad() to calculate df/d(mu) and df/d(sigma). Each var's
  ! derivative (also called adjoint) can be access through var%adj().

  call f%grad()
  write(*, *) "df/d(mu): ", mu%adj()
  write(*, *) "df/d(sigma): ", sigma%adj()
end program var_grad_test
```

An alternative to the same problem above is to write a function then use it as a procedure argument to `Fazang` 's `gradient` funcion.

```fortran
module func
  use fazang ! load Fazang library
  implicit none

  real(rk), parameter :: y = 1.3d0

contains
  type(var) function f(x)
    type(var), intent(in) :: x(:)
    type(var) :: mu, sigma
    mu = x(1)
    sigma = x(2)
    f = -0.5d0 * log(2 * pi) - log(sigma) - 0.5d0 * ((y - mu) / sigma) ** 2.d0;
  end function f

end module func

program grad_test
  use iso_c_binding
  use fazang
  use func

  implicit none

  real(rk) :: fx(3), x(2)
  x = [0.5d0, 1.2d0]

  fx = gradient(f, x)
  write(*, *) "f(x): ", fx(1)
  write(*, *) "df/d(x(1)): ", fx(2)
  write(*, *) "df/d(x(2)): ", fx(3)
end program grad_test
```


## Use `Fazang`

User guide can be found [here](https://github.com/yizhang-yiz/fazang/blob/main/doc/fazang_user_guide.pdf).


### Build

`Fazang` uses `meson` to build.

```bash
cd /path/to/fazang
mkdir build
cd build
meson compile
```

Afterwards one can run the unit tests

```bash
meson test
```


### Use the library

`Fazang` can be accessed by `use fazang` module.

A variable declared `var`

```fortran
type(var) x
```

can be defined as

```fortran
x = var()           ! value of x is 0.d0
x = var(1.5d0)      ! value of x is 1.5d0
```

`Fazang` overloads instrinc arithmatic unary and binary functions. A list of supported functions can be found in [the user guide](https://github.com/yizhang-yiz/fazang/blob/main/doc/fazang_user_guide.pdf).

All the downstream variables that depend on a `var` should also be `var`

```fortran
type(var) x, y
x = var(1.d0)
y = sin(x)
```

The value and the adjoint (derivative) of a `var` can be accessed using `var%val()` and `var%adj()` functions, respectively.

```fortran
write(*, *) y%val()   ! equals to sin(x%val())
write(*, *) y%adj()   ! equals to 0.d0 before any gradient operations
```

`Fazang`'s unary and binary functions are `elemental`, so they can be extended to arrays.

```fortran
type(var) a(3), b, c(3), d
a = var([1.d0, 2.d0, 3.d0])
b = var(0.5d0)
c = 2.d0 * a
d = log(b * a * exp(c))
```

To calculate a dependent variable's derivatives, call `var%grad()` function

```fortran
call d(2)%grad()
```

and access each upstream variable's derivative through `var%adj()` afterwards.

```fortran
write(*, *) c%adj()    ! should be [0.0, 1.0, 0.0]
```

Though `Fazang` uses special storge pattern for array and matrix operations for efficiency purpose, the storage mechanism is transparent to the user.

```fortran
type(var) :: x(4, 2), y(2, 5), z(4, 5)
real(rk) :: a(4, 2) = reshape([1.d0, 47.d0, 3.d0, 53.d0, 21.d0,&
& 7.d0, 3.d0, 3.d0], [4, 2])
real(rk) :: b(2, 5) = reshape([1.d0, 47.d0, 3.d0, 53.d0, 21.d0,&
& 7.d0, 3.d0, 3.d0, 3.2d0, 8.d0], [2, 5])

x = var(a)
y = var(b)
z = matmul(x, y)
do j = 1, 5
   do i = 1, 4
      call z(i, j)%grad()
      ! ...
      call set_zero_all_adj()  ! reset all adjionts to zero
   end do
end do
```

PS. Since the original [fazang](https://github.com/yizhang-yiz/fazang) repository
cannot be compiled successfully, this repository provides a version of fazang without ODE.

## Name

The library is named after ancient Chinese philosopher [Fazang](https://en.wikipedia.org/wiki/Fazang) (法藏), who views the cosmos "as an infinite number of interdependent and interpenetrating parts" (一法为因，万法为果；万法为因，一法为果).
