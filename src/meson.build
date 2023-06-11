sources = [
    'env.F90',
    'arith.F90',
    'tape.F90',
    'nested.F90',
    'vari.F90',
    'array_in_tape.F90',
    'test.F90',
    'var.F90',
    'value_of.F90',
    'grad.F90',
    'chain_eager_adj.F90',
    'abs.F90',
    'sin.F90',
    'cos.F90',
    'tan.F90',
    'asin.F90',
    'acos.F90',
    'atan.F90',
    'sinh.F90',
    'cosh.F90',
    'tanh.F90',
    'asinh.F90',
    'acosh.F90',
    'atanh.F90',
    'sqrt.F90',
    'inv.F90',
    'square.F90',
    'inv_square.F90',
    'inv_sqrt.F90',
    'exp.F90',
    'log.F90',
    'logit.F90',
    'inv_logit.F90',
    'erf.F90',
    'erfc.F90',
    'digamma.F90',
    'log_gamma.F90',
    'relational.F90',
    'add.F90',
    'sub.F90',
    'mul.F90',
    'div.F90',
    'pow.F90',
    'hypot.F90',
    'sum.F90',
    'norm2.F90',
    'log_sum_exp.F90',
    'dot_product.F90',
    'matmul.F90',
    'fazang.F90',
    'lognormal_lpdf.F90',
    'normal_lpdf.F90',
]

fazang_src = files(sources)

fazang_lib = library(
    meson.project_name(),
    fazang_src,
    version: meson.project_version(),
    install: true,
)

fazang_inc = fazang_lib.private_dir_include()
fazang_dep = declare_dependency(
    link_with: fazang_lib,
    include_directories: fazang_inc,
)

if host_machine.system() == 'windows'
    symbols_file = 'lib'+meson.project_name()+'-'+meson.project_version().split('.')[0]+'.dll.symbols'
    obj_suffix = '.obj'
else
    symbols_file = 'lib'+meson.project_name()+'.so.'+meson.project_version()+'.symbols'
    obj_suffix = '.o'
endif
fazang_obj = []
foreach source: sources
    fazang_obj += source+obj_suffix
endforeach
install_subdir(
    fazang_lib.full_path()+'.p',
    install_dir: 'include'/meson.project_name(),
    strip_directory: true,
    exclude_files: [
        'depscan.dd',
        meson.project_name()+'-deps.json',
        symbols_file,
        meson.project_name()+'.dat',
        fazang_obj,
    ]
)

pkg = import('pkgconfig')
pkg.generate(
  name: meson.project_name(),
  libraries: fazang_lib,
  description: 'Fortran library for reverse-mode automatic differentiation',
  version: meson.project_version(),
  subdirs: meson.project_name(),
)
