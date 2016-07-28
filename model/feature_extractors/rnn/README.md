## Troubleshooting
### Error compiling Theano
Possible error message: "compilation failed relocation R_X86_64_32S against \`_Py_NotImplementedStruct' can not be used when making a shared object; recompile with -fPIC. /opt/python-3.4.2/lib/libpython3.4m.a: could not read symbols: Bad value. collect2: error: ld returned 1 exit status."
Resolve by re-compiling Python with `--enable-shared`: http://stackoverflow.com/a/21345831/2225200

