# libtcod-d 1.6.7-1

libtcod-d is a set of bindings for using the excellent
[libtcod](https://github.com/libtcod/libtcod) with the D programming
language.

The DLL (libtcod.so on Linux, libtcod.dll on Windows) is dynamically loaded
on start up, not linked at compile time. Programs built with this library
will search for libtcod_debug.so, and if that can't be found, for libtcod.so
on the executable's path (or dlls if on Windows).

ATTENTION: the x86_64 version of the library doesnt't work with DMD; the
sample application crashes immediately as some function calls simply don't
work - the parameters are totally garbled. Please use LDC to compile
applications on x86_64 platforms.

To try the samples, run `dub run -c samples_d` on 32bit platforms or
`dub run --compiler ldc2 -c samples_d` on 64bit platforms.

The bindings are a strict port of the C API, so refer to libtcod
documentation for more details. If I can get motivated, an object
wrapper that would be similar to the C++ API may be forthcoming, so watch
this space.

For comments and complaints, use the issue system on GitHub.
