/*
* libtcod 1.5.1
* Copyright (c) 2008,2009,2010,2012 Jice & Mingos
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions are met:
*     * Redistributions of source code must retain the above copyright
*       notice, this list of conditions and the following disclaimer.
*     * Redistributions in binary form must reproduce the above copyright
*       notice, this list of conditions and the following disclaimer in the
*       documentation and/or other materials provided with the distribution.
*     * The name of Jice or Mingos may not be used to endorse or promote products
*       derived from this software without specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY JICE AND MINGOS ``AS IS'' AND ANY
* EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
* DISCLAIMED. IN NO EVENT SHALL JICE OR MINGOS BE LIABLE FOR ANY
* DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
* ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

module tcod.sys;

import core.vararg;
import tcod.c.functions;
import tcod.c.types;
import tcod.image;

/**
    System layer

    This toolkit contains some system specific miscellaneous utilities. Use
    them is you want your code to be easily portable.
 */
class TCODSystem {
public:
    /**
    Limit the frames per second.

    The setFps function allows you to limit the number of frames per second.
    If a frame is rendered faster than expected, the TCOD_console_flush
    function will wait so that the frame rate never exceed this value. You
    can call this function during your game initialization. You can
    dynamically change the frame rate. Just call this function once again.
    $(B You should always limit the frame rate, except during benchmarks,
    else your game will use 100% of the CPU power.)

    Params:
        val = Maximum number of frames per second. 0 means unlimited frame rate.
    */
    static void setFps(int val) {
        TCOD_sys_set_fps(val);
    }

    /**
    Get the number of frames rendered during the last second.
    The value returned by this function is updated every second.
    */
    static int getFps() {
        return TCOD_sys_get_fps();
    }

    /**
    Get the duration of the last frame

    This function returns the length in seconds of the last rendered frame.
    You can use this value to update every time dependent object in the world.

    Example:
    ---
    // moving an object at 5 console cells per second
    float x = 0, y = 0; // object coordinates
    x += 5 * TCODSystem.getLastFrameLength();
    TCODConsol.root.putChar(to!int(x), to!int(y), 'X');
    ---
    */
    static float getLastFrameLength() {
        return TCOD_sys_get_last_frame_length();
    }

    /**
    Pause the program.

    Use this function to stop the program execution for a specified number of
    milliseconds.

    Params:
        val = number of milliseconds before the function returns.
    */
    static void sleepMilli(uint val)  {
        TCOD_sys_sleep_milli(val);
    }

    /**
    Get global timer in milliseconds.

    Returns:
        the number of milliseconds since the program has started.
    */
    static uint getElapsedMilli() {
        return TCOD_sys_elapsed_milli();
    }

    /**
    Get global timer in seconds.

    Returns:
        the number of seconds since the program has started.
    */
    static float getElapsedSeconds() {
        return TCOD_sys_elapsed_seconds();
    }

    /++
    Waiting for any event (mouse or keyboard).

    There's a more generic function that waits for an event from the user. The
    eventMask shows what events we're waiting for. The return value indicate
    what event was actually triggered. Values in key and mouse structures are
    updated accordingly. If flush is false, the function waits only if there
    are no pending events, else it returns the first event in the buffer.

    Params:
        eventMask =  event types to wait for (other types are discarded)
        key = updated in case of a key event. Can be null if eventMask contains
              no key event type
        mouse = updated in case of a mouse event. Can be null if eventMask
                contains no mouse event type.
        flush = if true, all pending events are flushed from the buffer. Else,
                return the first available event

    Example:
    ---
    TCOD_key_t key;
    TCOD_mouse_t mouse;
    TCOD_event_t ev = TCODSystem::waitForEvent(TCOD_EVENT_ANY,&key,&mouse,true);
    if ( ev == TCOD_EVENT_KEY_PRESS && key.c == 'i' ) { /* ... open inventory ... */ }
    ---
    +/
    static TCOD_event_t waitForEvent(int eventMask, TCOD_key_t *key, TCOD_mouse_t *mouse, bool flush) {
        return TCOD_sys_wait_for_event(eventMask,key,mouse,flush);
    }

    /++
    Checking for any event (mouse or keyboard).

    There's a more generic function that checks if an event from the user is
    in the buffer. The eventMask shows what events we're waiting for. The
    return value indicate what event was actually found. Values in key and
    mouse structures are updated accordingly.

    Params:
        eventMask = event types to wait for (other types are discarded)
        key = updated in case of a key event. Can be null if eventMask
              contains no key event type.
        mouse = updated in case of a mouse event. Can be null if eventMask
                contains no mouse event type.

    Example:
    ---
    TCOD_key_t key;
    TCOD_mouse_t mouse;
    TCOD_event_t ev = TCODSystem.checkForEvent(TCOD_EVENT_ANY, &key, &mouse);
    if ( ev == TCOD_EVENT_KEY_PRESS && key.c == 'i' ) { /*... open inventory ... */}
    ---
    +/
    static TCOD_event_t checkForEvent(int eventMask, TCOD_key_t* key, TCOD_mouse_t* mouse) {
        return TCOD_sys_check_for_event(eventMask, key, mouse);
    }

    /**
    Easy screenshots.

    This function allows you to save the current game screen in a png file,
    or possibly a bmp file if you provide a filename ending with .bmp.

    Params:
        filename = Name of the file. If null, a filename is automatically
                   generated with the form "./screenshotNNN.png", NNN being
                   the first free number (if a file named screenshot000.png
                   already exist, screenshot001.png will be used, and so on...).
    */
    static void saveScreenshot(const char *filename) {
        TCOD_sys_save_screenshot(filename);
    }

    /**
    Create a directory.

    Params:
        path = Directory path. The immediate father directory (<path>/..) must
               exist and be writable.
    */
    static bool createDirectory(const char *path) {
        return TCOD_sys_create_directory(path) != 0;
    }

    /**
    Delete an empty directory.

    Params:
        path = directory path. This directory must exist, be writable and empty.
    */
    static bool deleteDirectory(const char *path) {
        return TCOD_sys_delete_directory(path) != 0;
    }

    /**
    Delete a file

    Params:
        path = File path. This file must exist and be writable.
    */
    static bool deleteFile(const char *path){
        return TCOD_sys_delete_file(path) != 0;
    }

    /**
    Check if a path is a directory

    Params:
        path = a path to check
    */
    static bool isDirectory(const char *path) {
        return TCOD_sys_is_directory(path) != 0;
    }

    /**
    List files in a directory.

    To get the list of entries in a directory (including sub-directories,
    except . and ..). The returned list is allocated by the function and must
    be deleted by you. All the const char* inside must be also freed with
    TCODList.clearAndDelete.

    Params:
        path = a directory
        pattern = If null or empty, returns all directory entries. Else returns
                  only entries matching the pattern. The pattern is NOT a
                  regular expression. It can only handle one '*' wildcard.
                  Examples : *.png, saveGame*, font*.png
    */
    static TCOD_list_t getDirectoryContent(const char *path, const char *pattern) {
        return TCOD_sys_get_directory_content(path, pattern);
    }

    /**
    Check if a given file exists
    In order to check whether a given file exists in the filesystem. Useful for detecting errors caused by missing files.

    Params:
        filename = the file name, using printf-like formatting
        A =  optional arguments for filename formatting

    Example:
    ---
    if (!TCODSystem::fileExists("myfile.%s","txt")) {
        fprintf(stderr,"no such file!");
    }
    ---
    */
    static bool fileExists(const char* filename, A...)(args A) {
        return cast(bool)TCOD_sys_file_exists(filename, args);
    }

    /**
    Read the content of a file into memory.

    This is a portable function to read the content of a file from disk.

    Params:
        filename = the file name
        buf = a buffer to be allocated and filled with the file content (must
                be freed with free(buf)).
        size = the size of the allocated buffer.

    Example:
    ---
    unsigned char *buf;
    uint32 size;
    if (TCODSystem.readFile("myfile.dat", &buf, &size)) {
        // do something with buf
        free(buf);
    }
    ---
    */
    static bool readFile(const char* filename, const(char)** buf, uint* size) {
        return TCOD_sys_read_file(filename, buf, size) != 0;
    }

    /**
    Write the content of a memory buffer to a file. This is a portable
    function to write some data to a file.

    Params:
        filename = the file name
        buf = a buffer containing the data to write
        size = the number of bytes to write.

    Example:
    ---
    TCODSystem::writeFile("myfile.dat", buf, size));
    ---
    */
    static bool writeFile(const char* filename, const(char)* buf, uint size) {
        return TCOD_sys_write_file(filename, buf, size) != 0;
    }

    /**
    You can register a callback that will be called after the libtcod rendering
    phase, but before the screen buffer is swapped. This callback receives the
    screen SDL_Surface reference. This makes it possible to use any SDL drawing
    functions (including openGL) on top of the libtcod console.

    To disable the custom renderer, call the same method with a null parameter.
    Note that to keep libtcod from requiring the SDL headers, the callback
    parameter is a void pointer. You have to include SDL headers and cast it
    to SDL_Surface in your code.

    Params:
        callback = The renderer to call before swapping the screen buffer.
                   If null, custom rendering is disabled.

    Example:
    ---
    SDL_renderer_t renderer() {
        SDL_Surface *s = (SDL_Surface *)sdlSurface;
        // ... draw something on s
    }

    TCODSystem.registerSDLRenderer(renderer);
    ---
    */
    static void registerSDLRenderer(SDL_renderer_t callback) {
        renderer = callback;
        TCOD_sys_register_SDL_renderer(callback);
    }

    /**
    Managing screen redraw.

    libtcod is not aware of the part of the screen your SDL renderer has
    updated. If no change occured in the console, it won't redraw them except
    if you tell him to do so with this function.

    Params:
        x = x starting position of the root console you want to redraw even if
            nothing has changed in the console back/fore/char.
        y = y starting position
        w = width
        h = height
    */
    static void setDirty(int x, int y, int w, int h) {
        TCOD_console_set_dirty(x, y, w, h);
    }

    /**
    Using a custom resolution for the fullscreen mode.

    This function allows you to force the use of a specific resolution in
    fullscreen mode. The default resolution depends on the root console size
    and the font character size.

    Params:
        width = Resolution to use when switching to fullscreen.
        height = Resolution to use when switching to fullscreen.
                Will use the smallest available resolution so that:
                resolution width >= width and resolution width >= root console
                width * font char width and resolution width >= height and
                resolution height >= root console height * font char height

    Example:
    ---
    // use 800x600 in fullscreen instead of 640x400
    TCODSystem.forceFullscreenResolution(800, 600);
    // 80x50 console with 8x8 char => 640x400 default resolution
    TCODConsole.initRoot(80, 50, "", true);
    ---
    */
    static void forceFullscreenResolution(int width, int height) {
        TCOD_sys_force_fullscreen_resolution(width, height);
    }

    /**
    Get current resolution

    You can get the current screen resolution with getCurrentResolution. You
    can use it for example to get the desktop resolution before initializing
    the root console.

    Params:
        width =  contains screen width when the function returns.
        height = contains current screen height when the function returns.
    */
    static void getCurrentResolution(int *width, int *height) {
        TCOD_sys_get_current_resolution(width, height);
    }

    /**
    Get fullscreen offset.

    If the fullscreen resolution does not matches the console size in pixels,
    black borders are added. This function returns the position in pixels of
    the console top left corner in the screen.

    Params:
        offx = contains the x position of the console on the screen when using
               fullscreen mode.
        offy = contains the y position of the console on the screen when using
               fullscreen mode.
    */
    static void getFullscreenOffsets(int *offx, int *offy) {
        TCOD_sys_get_fullscreen_offsets(offx, offy);
    }

    /**
    Get the font size.

    Params:
        width = contains character width when the function returns
        height = contains a character height when the function returns
    */
    static void getCharSize(int *width, int *height) {
        TCOD_sys_get_char_size(width, height);
    }

    /**
    Dynamically updating the font bitmap

    You can dynamically change the bitmap of a character in the font. All cells
    using this ascii code will be updated at next flush call.

    Params:
        asciiCode = ascii code corresponding to the character to update.
        fontx = x coordinate of the character in the bitmap font (in characters, not pixels)
        fonty = y coordinate of the character in the bitmap font (in characters, not pixels)
        img = image containing the new character bitmap
        x = x position in pixels of the top-left corner of the character in the image
        y = y position in pixels of the top-left corner of the character in the image
    */
    static void updateChar(int asciiCode, int fontx, int fonty, TCODImage img, int x, int y) {
        TCOD_sys_update_char(asciiCode, fontx, fonty, img.data, x, y);
    }

    /**
    Dynamically change libtcod's internal renderer.

    As of 1.5.1, libtcod contains 3 different renderers:
        * SDL : historic libtcod renderer. Should work and be pretty fast everywhere
        * OpenGL : requires OpenGL compatible video card. Might be much faster or much slower than SDL, depending on the drivers
        * GLSDL : requires OpenGL 1.4 compatible video card with GL_ARB_shader_objects extension. Blazing fast if you have the proper hardware and drivers.
    This function switches the current renderer dynamically.

    Params:
        renderer = Either TCOD_RENDERER_GLSL, TCOD_RENDERER_OPENGL or TCOD_RENDERER_SDL
    */
    static void setRenderer(TCOD_renderer_t renderer) {
        TCOD_sys_set_renderer(renderer);
    }

    /**
    Get the current internal renderer
    */
    static TCOD_renderer_t getRenderer() {
        return TCOD_sys_get_renderer();
    }


    /**
    Copy data to the clipboard.

    Params:
        value = Text to copy in the clipboard
    */
    static void setClipboard(const char *value) {
        TCOD_sys_clipboard_set(value);
    }

    /**
    Paste data from the clipboard.
    */
    static const(char)* getClipboard() {
        return TCOD_sys_clipboard_get();
    }

    // thread stuff
    extern(C) alias threadFunc = int function(void*);

    static int getNumCores() {
        return TCOD_sys_get_num_cores();
    }

    static TCOD_thread_t newThread(threadFunc* func, void* data) {
        return TCOD_thread_new(func, data);
    }

    static void deleteThread(TCOD_thread_t th) {
        TCOD_thread_delete(th);
    }

    static void waitThread(TCOD_thread_t th) {
        TCOD_thread_wait(th);
    }

    // mutex
    static TCOD_mutex_t newMutex() {
        return TCOD_mutex_new();
    }

    static void mutexIn(TCOD_mutex_t mut) {
        TCOD_mutex_in(mut);
    }

    static void mutexOut(TCOD_mutex_t mut) {
        TCOD_mutex_out(mut);
    }

    static void deleteMutex(TCOD_mutex_t mut) {
        TCOD_mutex_delete(mut);
    }

    // semaphore
    static TCOD_semaphore_t newSemaphore(int initVal) {
        return TCOD_semaphore_new(initVal);
    }

    static void lockSemaphore(TCOD_semaphore_t sem) {
        TCOD_semaphore_lock(sem);
    }

    static void unlockSemaphore(TCOD_semaphore_t sem) {
        TCOD_semaphore_unlock(sem);
    }

    static void deleteSemaphore( TCOD_semaphore_t sem) {
        TCOD_semaphore_delete(sem);
    }

    // condition
    static TCOD_cond_t newCondition() {
        return TCOD_condition_new();
    }

    static void signalCondition(TCOD_cond_t cond) {
        TCOD_condition_signal(cond);
    }

    static void broadcastCondition(TCOD_cond_t cond) {
        TCOD_condition_broadcast(cond);
    }

    static void waitCondition(TCOD_cond_t cond, TCOD_mutex_t mut) {
        TCOD_condition_wait(cond, mut);
    }

    static void deleteCondition( TCOD_cond_t cond) {
        TCOD_condition_delete(cond);
    }

private:
    static SDL_renderer_t renderer;
}
