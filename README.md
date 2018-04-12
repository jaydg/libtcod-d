# libtcod-d 1.5.1-1

libtcod-d is a set of bindings for using the excellent
[libtcod](http://roguecentral.org/doryen/libtcod/) in the D programming
language.

The DLL (libtcod.so on Linux, libtcod.dll on Windows) is dynamically loaded
on start up, not linked at compile time.

It searches for libtcod_debug.so, and if it can't find that, then libtcod.so
on the executable's path (or dlls if on Windows). The current release build of
libtcod.so 1.5.1 is lacking the functions `TCOD_mouse_includes_touch` and
`TCOD_sys_get_sdl_window`, and will fail on attempting to load those functions.

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
