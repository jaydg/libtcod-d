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

ATTENTION: the x86_64 version of the Linux library seems to be very unstable
and the demo application crashed immediately upon startup. The x86 variant
works almost fine, though.

To try the samples, run `dub run -a x86 -c samples_d`

The bindings are a strict port of the C API, so refer to libtcod
documentation for more details. If I can get motivated, an object
wrapper that would be similar to the C++ API may be forthcoming, so watch
this space.

For comments and complaints, use the issue system on GitHub.

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
