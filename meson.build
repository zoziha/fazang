project(
    'fazang',
    'fortran',
    version : '0.1.20230611',
    meson_version: '>=0.60.0',
    default_options: [
        'default_library=both',
        'buildtype=debugoptimized',
        'fortran_std=f2018',
    ],
)

if meson.get_compiler('fortran').get_id() == 'gcc'
    add_project_arguments(
        '-ffree-line-length-none',
        language : 'fortran',
    )
endif

subdir('src')
subdir('test/unit')
subdir('test/unit/prob')

fazang_lic = files('LICENSE')
install_data(
    fazang_lic,
    install_dir : join_paths(get_option('prefix'), 'share', 'licenses', meson.project_name()),
)