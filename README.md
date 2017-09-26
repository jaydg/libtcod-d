# libtcod-d 1.5.1-1

libtcod-d is a set of bindings for using the excellent
[libtcod](http://doryen.eptalys.net/libtcod/) in the D programming language.

The DLL (libtcod.so on Linux, libtcod.dll on Windows) is dynamically loaded
on start up, not linked at compile time. Note that this means that on Linux
you must link with libdl by adding -ldl to your linking command to ensure
that your program runs.

It searches for libtcod_debug.so, and if it can't find that, then libtcod.so
on the current path (or dlls if on Windows). The current release build of
libtcod.so 1.5.1 is lacking the functions `TCOD_mouse_includes_touch` and
`TCOD_sys_get_sdl_window`, and will fail on attempting to load those functions.

To try the samples, change to examples/samples_d and run dub.

The bindings are a strict port of the C API, so refer to libtcod
documentation for more details. If I can get motivated, an object
wrapper that would be similar to the C++ API may be forthcoming, so watch
this space.

For comments and complaints, use the issue system on GitHub.
or email me at b (dot) helyer (at) gmail (dot) com.

## Developing with libtcod-d

The libtcod-d code is maintained in a Git repository at github.org.
If you are also using Git for your own project, you should consider
using "git submodule" to add the libtcod-d repository as submodule
under your project. If you have experience with svn externals, git
submodules are a similar feature.

Git submodules allow your repository to point at a single, static point
in a separate repository as a child element. This avoids having to
copy the code into your repo, etc.

Git submodules use a frozen point - not "HEAD" or any of the branch
heads - so that you can develop against a stable background. If you
want to update the submodule to a later version of its own code, you
have to do that explicitly. This keeps your environment stable until
you ask for it to change.

Of course, the best reason for using submodules is that you can clone
the libtcod-d repository on github (or somewhere else), point your
submodule at your clone, and make updates to the libtcod-d sources
within the submodule directory. Then you can contribute to libtcod-d
by pushing your changes back upstream. :)