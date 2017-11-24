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

module tcod.console;

import core.stdc.stdarg;

import tcod.c.all;
import tcod.c.functions;
import tcod.c.types;
import tcod.color;

/**
    The console emulator handles the rendering of the game screen and the
    keyboard input.

    Classic real time game loop:

    Example:
    ---
    TCODConsole.initRoot(80,50,"my game",false);
    TCODSystem.setFps(25); // limit framerate to 25 frames per second
    while (!endGame && !TCODConsole.isWindowClosed()) {
        // ... draw on TCODConsole.root
        TCODConsole.flush();
        TCOD_key_t key = TCODConsole.checkForKeypress();
        updateWorld (key, TCODSystem.getLastFrameLength());
        // updateWorld(TCOD_key_t key, float elapsed) (using key if key.vk != TCODK_NONE)
        // use elapsed to scale any update that is time dependant.
    }
    ---

    Classic turn by turn game loop:

    Example:
    ---
    TCODConsole.initRoot(80,50,"my game",false);
    while (!endGame && !TCODConsole.isWindowClosed) {
        // ... draw on TCODConsole.root
        TCODConsole.flush();
        TCOD_key_t key = TCODConsole.waitForKeypress(true);
        //... update world, using key
    }
    ---
*/

class TCODConsole {
public :
    static TCODConsole root;

    /**
    Creating an offscreen console

    You can create as many off-screen consoles as you want by using this
    function. You can draw on them as you would do with the root console,
    but you cannot flush them to the screen. Else, you can blit them on other
    consoles, including the root console. See blit.

    Params:
        w = console width (0 < w)
        h = console height (0 < h)

    Example:
    ---
    // Creating a 40x20 offscreen console, filling it with red and blitting it
    // on the root console at position 5, 5
    TCODConsole offscreenConsole = new TCODConsole(40, 20);
    offscreenConsole.setDefaultBackground(TCODColor.red);
    offscreenConsole.clear();
    TCODConsole.blit(offscreenConsole, 0, 0, 40, 20, TCODConsole.root, 5, 5, 255);
    ---
    */
    this(int w, int h) {
        data = TCOD_console_new(w, h);
    }

    /**
    Creating an offscreen console from a .asc or .apf file

    You can create an offscreen console from a file created with Ascii Paint
    with this constructor

    Params:
        filename = path to the .asc or .apf file created with Ascii Paint

    Example:
    ---
    // Creating an offscreen console, filling it with data from the .asc file
    TCODConsole offscreenConsole = new TCODConsole("myfile.asc");
    ---
    */
    this(const char *filename) {
        data = TCOD_console_from_file(filename);
    }

    this(TCOD_console_t con) {
        data = con;
    }

    /**
    Creating the game window
    Params:
        w = width of the console(in characters).
        h = height of the console(in characters). The default font in libtcod
            (./terminal.png) uses 8x8 pixels characters. You can change the
            font by calling setCustomFont before calling initRoot.
        title = title of the window. It's not visible when you are in fullscreen.
            Note 1 : you can dynamically change the window title with TCODConsole.setWindowTitle
        fullscreen = wether you start in windowed or fullscreen mode.
            Note 1 : you can dynamically change this mode with TCODConsole::setFullscreen
            Note 2 : you can get current mode with TCODConsole.isFullscreen
        renderer = which renderer to use. Possible values are:
            * TCOD_RENDERER_GLSL : works only on video cards with pixel shaders
            * TCOD_RENDERER_OPENGL : works on all video cards supporting OpenGL 1.4
            * TCOD_RENDERER_SDL : should work everywhere!
            Note 1: if you select a renderer that is not supported by the player's machine, libtcod scan the lower renderers until it finds a working one.
            Note 2: on recent video cards, GLSL results in up to 900% increase of framerates in the true color sample compared to SDL renderer.
            Note 3: whatever renderer you use, it can always be overriden by the player through the libtcod.cfg file.
            Note 4: you can dynamically change the renderer after calling initRoot with TCODSystem::setRenderer.
            Note 5: you can get current renderer with TCODSystem::getRenderer. It might be different from the one you set in initRoot in case it's not supported on the player's computer.

    Example:
    ---
    TCODConsole.initRoot(80, 50, "The Chronicles Of Doryen v0.1");
    ---
    */
    static void initRoot(int w, int h, const char* title, bool fullscreen=false, TCOD_renderer_t renderer=TCOD_RENDERER_SDL) {
        root = new TCODConsole();
        TCOD_console_init_root(w, h, title, fullscreen, renderer);
        root.data = TCOD_ctx.root;
    }

    /**
    Using a custom bitmap font

    This function allows you to use a bitmap font (png or bmp) with custom character size or layout.
    It should be called before initializing the root console with initRoot.
    Once this function is called, you can define your own custom mappings using mapping functions
    <h5>Different font layouts</h5>
    <table>
    <tr><td>ASCII_INROW</td><td>ASCII_INCOL</td><td>TCOD</td></tr>

    <tr><td><img src='terminal8x8_gs_ro.png' /></td><td><img src='terminal8x8_gs_as.png' /></td><td><img src='terminal8x8_gs_tc.png' /></td></tr>
    </table>
    <ul>
    <li>ascii, in columns : characters 0 to 15 are in the first column. The space character is at coordinates 2,0.</li>
    <li>ascii, in rows : characters 0 to 15 are in the first row. The space character is at coordinates 0,2.</li>
    <li>tcod : special mapping. Not all ascii values are mapped. The space character is at coordinates 0,0.</li>
    </ul>
    <h5>Different font types</h5>
    <table>
    <tr><td>standard<br />(non antialiased)</td><td>antialiased<br />(32 bits PNG)</td><td>antialiased<br />(greyscale)</td></tr>

    <tr><td><img src='terminal.png' /></td><td><img src='terminal8x8_aa_as.png' /></td><td><img src='terminal8x8_gs_as2.png' /></td></tr>
    </table>
    <ul>
    <li>standard : transparency is given by a key color automatically detected by looking at the color of the space character</li>
    <li>32 bits : transparency is given by the png alpha layer. The font color does not matter but it must be desaturated</li>
    <li>greyscale : transparency is given by the pixel value. You can use white characters on black background or black characters on white background. The background color is automatically detected by looking at the color of the space character</li>
    </ul>
    Examples of fonts can be found in libtcod's fonts directory. Check the Readme file there.

    Params:
        fontFile = Name of a .bmp or .png file containing the font.
        flags = Used to define the characters layout in the bitmap and the font type:
                TCOD_FONT_LAYOUT_ASCII_INCOL : characters in ASCII order, code 0-15 in the first column
                TCOD_FONT_LAYOUT_ASCII_INROW : characters in ASCII order, code 0-15 in the first row
                TCOD_FONT_LAYOUT_TCOD : simplified layout. See examples below.
                TCOD_FONT_TYPE_GREYSCALE : create an anti-aliased font from a greyscale bitmap
        nbCharHoriz = Number of characters in the font (horizontal).
        nbCharVertic = Number of characters in the font (vertical).
                       Should be 16x16 for ASCII layouts, 32x8 for TCOD layout.
                       But you can use any other layout.
                       If set to 0, there are deduced from the font layout flag.

    Example:
    ---
    TCODConsole.setCustomFont("standard_8x8_ascii_in_col_font.bmp", TCOD_FONT_LAYOUT_ASCII_INCOL);
    TCODConsole.setCustomFont("32bits_8x8_ascii_in_row_font.png", TCOD_FONT_LAYOUT_ASCII_INROW);
    TCODConsole.setCustomFont("greyscale_8x8_tcod_font.png", TCOD_FONT_LAYOUT_TCOD | TCOD_FONT_TYPE_GREYSCALE);
    ---
    */
    static void setCustomFont(const char *fontFile, int flags=TCOD_FONT_LAYOUT_ASCII_INCOL,int nbCharHoriz=0, int nbCharVertic=0) {
        TCOD_console_set_custom_font(fontFile,flags,nbCharHoriz,nbCharVertic);
    }

    /**
    Mapping a single ASCII code to a character

    These functions allow you to map characters in the bitmap font to ASCII codes.
    They should be called after initializing the root console with initRoot.
    You can dynamically change the characters mapping at any time, allowing to use several fonts in the same screen.

    Params:
        asciiCode = ASCII code to map.
        fontCharX = X Coordinate of the character in the bitmap font (in characters, not pixels).
        fontCharY = Y Coordinate of the character in the bitmap font (in characters, not pixels).
    */
    static void mapAsciiCodeToFont(int asciiCode, int fontCharX, int fontCharY) {
        TCOD_console_map_ascii_code_to_font(asciiCode, fontCharX, fontCharY);
    }

    /**
    Mapping consecutive ASCII codes to consecutive characters

    Params:
        firstAsciiCode = first ASCII code to map
        nbCodes = number of consecutive ASCII codes to map
        fontCharX = X coordinate of the character in the bitmap font (in
                    characters, not pixels) corresponding to the first ASCII code
        fontCharY = Y coordinate of the character in the bitmap font (in
                    characters, not pixels) corresponding to the first ASCII code
    */
    static void mapAsciiCodesToFont(int firstAsciiCode, int nbCodes, int fontCharX, int fontCharY) {
        TCOD_console_map_ascii_codes_to_font(firstAsciiCode, nbCodes, fontCharX, fontCharY);
    }

    /**
    Mapping ASCII code from a string to consecutive characters

    Params:
        s = string containing the ASCII codes to map.
        fontCharX = X coordinate of the character in the bitmap font (in
                      characters, not pixels) corresponding to the first
                      ASCII code in the string
        fontCharY = Y coordinate of the character in the bitmap font (in
                    characters, not pixels) corresponding to the first
                    ASCII code in the string
    */
    static void mapStringToFont(const char *s, int fontCharX, int fontCharY) {
        TCOD_console_map_string_to_font(s, fontCharX, fontCharY);
    }

    /** ditto */
    static void mapStringToFont(const wchar_t *s, int fontCharX, int fontCharY) {
        TCOD_console_map_string_to_font_utf(s, fontCharX, fontCharY);
    }

    /**
    Getting the current mode

    This function returns true if the current mode is fullscreen.
    */
    static bool isFullscreen() {
        return TCOD_console_is_fullscreen() != 0;
    }

    /**
    Switching between windowed and fullscreen modes

    This function switches the root console to fullscreen or windowed mode.
    Note that there is no predefined key combination to switch to/from
    fullscreen. You have to do this in your own code.

    Params:
        fullscreen = true to switch to fullscreen mode.
                     false to switch to windowed mode.

    Example:
    ---
    TCOD_key_t key = TCODConsole.checkForKeypress();
    if (key.vk == TCODK_ENTER && key.lalt)
        TCODConsole.setFullscreen(!TCODConsole.isFullscreen());
    ---
    */
    static void setFullscreen(bool fullscreen) {
        TCOD_console_set_fullscreen(fullscreen);
    }

    /**
    Changing the window title

    This function dynamically changes the title of the game window.
    Note that the window title is not visible while in fullscreen.

    Params:
        title = New title of the game window
    */
    static void setWindowTitle(const char *title) {
        TCOD_console_set_window_title(title);
    }

    /**
    Handling "close window" events.

    When you start the program, this returns false. Once a "close window"
    event has been sent by the window manager, it will allways return true.
    You're supposed to exit cleanly the game.
    */
    static bool isWindowClosed() {
        return TCOD_console_is_window_closed() != 0;
    }


    /**
    Use these functions to display credits, as seen in the samples.
    You can print a "Powered by libtcod x.y.z" screen during your game startup
    simply by calling this function after initRoot. The credits screen can be
    skipped by pressing any key.
    */
    static void credits() {
        TCOD_console_credits();
    }

    /**
    Embedding credits in an existing page

    You can also print the credits on one of your game screens (your main menu
    for example) by calling this function in your main loop. This function
    returns true when the credits screen is finished, indicating that you no
    longer need to call it.

    Params:
        x = x Position of the credits text in your root console
        y = y Position of the credits text in your root console
        alpha = If true, credits are transparently added on top of the existing
                screen. For this to work, this function must be placed between
                your screen rendering code and the console flush.

    Example:
    ---
    // initialize the root console
    TCODConsole.initRoot(80, 50, "The Chronicles Of Doryen v0.1", false);
    bool endCredits = false;
    // your game loop
    while (!TCODConsole.isWindowClosed()) {
        // your game rendering here...
        // render transparent credits near the center of the screen
        if (!endCredits) endCredits = TCODConsole.renderCredits(35, 25, true);
        TCODConsole.flush();
    }
    ---
    */
    static bool renderCredits(int x, int y, bool alpha) {
        return TCOD_console_credits_render(x,y,alpha) != 0;
    }

    /**
    Restart the credits animation

    When using rederCredits, you can restart the credits animation from the
    begining before it's finished by calling this function.
    */
    static void resetCredits() {
        TCOD_console_credits_reset();
    }

    /**
    Setting the default background color

    This function changes the default background color for a console. The
    default background color is used by several drawing functions like clear,
    putChar, ...

    Params:
        back = the new default background color for this console

    Example:
    ---
    TCODConsole.root.setDefaultBackground(myColor)
    ---
    */
    void setDefaultBackground(TCODColor back) {
        TCOD_color_t bg = {back.r, back.g, back.b};
        TCOD_console_set_default_background(data, bg);
    }

    /**
    Setting the default foreground color

    This function changes the default foreground color for a console. The
    default foreground color is used by several drawing functions like clear,
    putChar, ...

    Params:
        fore = the new default foreground color for this console

    Example:
    ---
    TCODConsole.root.setDefaultForeground(myColor)
    ---
    */
    void setDefaultForeground(TCODColor fore) {
        TCOD_color_t fg = {fore.r, fore.g, fore.b};
        TCOD_console_set_default_foreground(data, fg);
    }

    /**
    Clearing a console

    This function modifies all cells of a console:
    <ul>
    <li>set the cell's background color to the console default background color</li>
    <li>set the cell's foreground color to the console default foreground color</li>
    <li>set the cell's ASCII code to 32 (space)</li>
    </ul>
    */
    void clear() {
        TCOD_console_clear(data);
    }

    /**
    Setting the background color of a cell

    This function modifies the background color of a cell, leaving other properties (foreground color and ASCII code) unchanged.

    Params:
        x = x coordinate of the cell in the console.
             0 <= x < console width
        y = y coordinate of the cell in the console.
             0 <= y < console height
        col = the background color to use. You can use color constants
        flag = this flag defines how the cell's background color is modified
               See TCOD_bkgnd_flag_t
    */
    void setCharBackground(int x, int y, ref const TCODColor col, TCOD_bkgnd_flag_t flag = TCOD_BKGND_SET)  {
        TCOD_color_t c = {col.r, col.g, col.b};
        TCOD_console_set_char_background(data, x, y, c, flag);
    }

    /**
    Setting the foreground color of a cell

    This function modifies the foreground color of a cell, leaving other
    properties (background color and ASCII code) unchanged.

    Params:
        x = x coordinate of the cell in the console.
              0 <= x < console width
        y = y coordinate of the cell in the console.
              0 <= y < console height
        col = the foreground color to use. You can use color constants
    */
    void setCharForeground(int x, int y, ref const TCODColor col) {
        TCOD_color_t c = {col.r, col.g, col.b};
        TCOD_console_set_char_foreground(data, x, y, c);
    }

    /**
    Setting the ASCII code of a cell

    This function modifies the ASCII code of a cell, leaving other properties
    (background and foreground colors) unchanged. Note that since a clear
    console has both background and foreground colors set to black for every
    cell, using setChar will produce black characters on black background. Use
    putChar instead.

    Params:
        x = x coordinate of the cell in the console.
            0 <= x < console width
        y = y coordinate of the cell in the console.
            0 <= y < console height
        c = the new ASCII code for the cell. You can use ASCII constants
    */
    void setChar(int x, int y, int c) {
        TCOD_console_set_char(data, x, y, c);
    }

    /**
    Setting every property of a cell using default colors

    This function modifies every property of a cell:
    <ul>
        <li>update the cell's background color according to the console default background color (see TCOD_bkgnd_flag_t).</li>
        <li>set the cell's foreground color to the console default foreground color</li>
        <li>set the cell's ASCII code to c</li>
    </ul>

    Params:
        x = x coordinate of the cell in the console.
            0 <= x < console width
        y = y coordinate of the cell in the console.
            0 <= y < console height
        c = the new ASCII code for the cell. You can use ASCII constants
        flag = this flag defines how the cell's background color is modified.
               See TCOD_bkgnd_flag_t
    */
    void putChar(int x, int y, int c, TCOD_bkgnd_flag_t flag = TCOD_BKGND_DEFAULT) {
        TCOD_console_put_char(data,x,y,c,flag);
    }


    /**
    Setting every property of a cell using specific colors

    This function modifies every property of a cell:
    <ul>
        <li>set the cell's background color to back.</li>
        <li>set the cell's foreground color to fore.</li>
        <li>set the cell's ASCII code to c.</li>
    </ul>

    Params:
        x = x coordinate of the cell in the console.
            0 <= x < console width
        y = y coordinate of the cell in the console.
            0 <= y < console height
        c =  the new ASCII code for the cell. You can use ASCII constants
        fore = new foreground color for this cell
        back = new background color for this cell
    */
    void putCharEx(int x, int y, int c, ref const TCODColor fore, ref const TCODColor back) {
        TCOD_color_t fg = {fore.r, fore.g, fore.b};
        TCOD_color_t bg = {back.r, back.g, back.b};
        TCOD_console_put_char_ex(data, x, y, c, fg, bg);
    }

    /**
    Background effect flags

    This flag is used by most functions that modify a cell background color. It defines how the console's current background color is used to modify the cell's existing background color :
        TCOD_BKGND_NONE : the cell's background color is not modified.
        TCOD_BKGND_SET : the cell's background color is replaced by the console's default background color : newbk = curbk.
        TCOD_BKGND_MULTIPLY : the cell's background color is multiplied by the console's default background color : newbk = oldbk * curbk
        TCOD_BKGND_LIGHTEN : newbk = MAX(oldbk,curbk)
        TCOD_BKGND_DARKEN : newbk = MIN(oldbk,curbk)
        TCOD_BKGND_SCREEN : newbk = white - (white - oldbk) * (white - curbk) // inverse of multiply : (1-newbk) = (1-oldbk)*(1-curbk)
        TCOD_BKGND_COLOR_DODGE : newbk = curbk / (white - oldbk)
        TCOD_BKGND_COLOR_BURN : newbk = white - (white - oldbk) / curbk
        TCOD_BKGND_ADD : newbk = oldbk + curbk
        TCOD_BKGND_ADDALPHA(alpha) : newbk = oldbk + alpha*curbk
        TCOD_BKGND_BURN : newbk = oldbk + curbk - white
        TCOD_BKGND_OVERLAY : newbk = curbk.x <= 0.5 ? 2*curbk*oldbk : white - 2*(white-curbk)*(white-oldbk)
        TCOD_BKGND_ALPHA(alpha) : newbk = (1.0f-alpha)*oldbk + alpha*(curbk-oldbk)
        TCOD_BKGND_DEFAULT : use the console's default background flag
        Note that TCOD_BKGND_ALPHA and TCOD_BKGND_ADDALPHA are MACROS that needs a float parameter between (0.0 and 1.0). TCOD_BKGND_ALPH and TCOD_BKGND_ADDA should not be used directly (else they will have the same effect as TCOD_BKGND_NONE).
    */

    /**
    Setting the default background flag

    This function defines the background mode (see TCOD_bkgnd_flag_t) for the
    console. This default mode is used by several functions (print, printRect,
    ...)

    Params:
        flag = this flag defines how the cell's background color is modified.
               See TCOD_bkgnd_flag_t
    */
    void setBackgroundFlag(TCOD_bkgnd_flag_t flag) {
        TCOD_console_set_background_flag(data, flag);
    }

    /**
    Getting the default background flag

    This function returns the background mode (see TCOD_bkgnd_flag_t) for the
    console. This default mode is used by several functions (print, printRect, ...)
    */
    TCOD_bkgnd_flag_t getBackgroundFlag() {
        return TCOD_console_get_background_flag(data);
    }

    /**
    Setting the default alignment

    This function defines the default alignment (see TCOD_alignment_t) for the
    console. This default alignment is used by several functions (print,
    printRect, ...). Values for alignment: TCOD_LEFT, TCOD_CENTER, TCOD_RIGHT

    Params:
        alignment = defines how the strings are printed on screen.
    */
    void setAlignment(TCOD_alignment_t alignment) {
        TCOD_console_set_alignment(data,alignment);
    }

    /**
    Getting the default alignment

    This function returns the default alignment (see TCOD_alignment_t) for the
    console. This default mode is used by several functions (print, printRect,
    ...). Values for alignment : TCOD_LEFT, TCOD_CENTER, TCOD_RIGHT
    */
    TCOD_alignment_t getAlignment() {
        return TCOD_console_get_alignment(data);
    }

    /**
    Printing a string with default parameters.

    This function print a string at a specific position using current default
    alignment, background flag, foreground and background colors.

    Params:
        x = y coordinate of the character in the console, depending on the
            default alignment for this console.
        y = y coordinate of the character in the console, depending on the
            default alignment for this console:
            * TCOD_LEFT : leftmost character of the string
            * TCOD_CENTER : center character of the string
            * TCOD_RIGHT : rightmost character of the string
        fmt = printf-like format string, eventually followed by parameters. You
              can use control codes to change the colors inside the string.
    */
    void print(int x, int y, const char *fmt, A...)(A args) {
        TCOD_console_print(data, x, y, fmt, args);
    }

    /** ditto */
    void print(int x, int y, const wchar_t *fmt, A...)(A args) {
        TCOD_console_print_utf(data, x, y, fmt, args);
    }

    /**
    Printing a string with specific alignment and background mode.

    This function print a string at a specific position using specific
    alignment and background flag, but default foreground and background colors.

    Params:
        x = y coordinate of the character in the console, depending on the
            default alignment for this console.
        y = y coordinate of the character in the console, depending on the
            default alignment for this console:
            * TCOD_LEFT : leftmost character of the string
            * TCOD_CENTER : center character of the string
            * TCOD_RIGHT : rightmost character of the string
        flag = this flag defines how the cell's background color is modified
               See TCOD_bkgnd_flag_t
        alignment = defines how the strings are printed on screen.
        fmt = printf-like format string, eventually followed by parameters. You
              can use control codes to change the colors inside the string.
    */
    void printEx(int x, int y, TCOD_bkgnd_flag_t flag, TCOD_alignment_t alignment, const char *fmt, A...)(A args) {
        TCOD_console_print_ex(data, x, y, flag, alignment, fmt, args);
    }

    /** ditto */
    void printEx(int x, int y, TCOD_bkgnd_flag_t flag, TCOD_alignment_t alignment, const wchar_t *fmt, A...)(A args) {
        TCOD_console_print_ex_utf(data, x, y, flag, alignment, fmt, args);
    }

    /**
    Printing a string with default parameters and autowrap.

    This function draws a string in a rectangle inside the console, using default colors, alignment and background mode.
        If the string reaches the borders of the rectangle, carriage returns are inserted.
        If h > 0 and the bottom of the rectangle is reached, the string is truncated. If h = 0, the string is only truncated if it reaches the bottom of the console.
        The function returns the height (number of console lines) of the printed string.

    Params:
        x = y coordinate of the character in the console, depending on the
            default alignment for this console.
        y = y coordinate of the character in the console, depending on the
            default alignment for this console:
            * TCOD_LEFT : leftmost character of the string
            * TCOD_CENTER : center character of the string
            * TCOD_RIGHT : rightmost character of the string
        w = width of the rectangle
            x <= x+w < console width
        h = height of the rectangle
            y <= y+h < console height
        fmt = printf-like format string, eventually followed by parameters. You
              can use control codes to change the colors inside the string.
    */
    int printRect(int x, int y, int w, int h, const char *fmt, A...)(A args) {
        return TCOD_console_print_rect(data, x, y, w, h, fmt, args);
    }

    /** ditto */
    int printRect(int x, int y, int w, int h, const wchar_t *fmt, A...)(A args) {
        return TCOD_console_print_rect_utf(data, x, y, w, h, fmt, args);
    }

    /**
    Printing a string with specific alignment and background mode and autowrap.

    This function draws a string in a rectangle inside the console, using
    default colors, but specific alignment and background mode. If the string
    reaches the borders of the rectangle, carriage returns are inserted. If
    h > 0 and the bottom of the rectangle is reached, the string is truncated.
    If h = 0, the string is only truncated if it reaches the bottom of the
    console. The function returns the height (number of console lines) of the
    printed string.


    Params:
        x = y coordinate of the character in the console, depending on the
            default alignment for this console.
        y = y coordinate of the character in the console, depending on the
            default alignment for this console:
            * TCOD_LEFT : leftmost character of the string
            * TCOD_CENTER : center character of the string
            * TCOD_RIGHT : rightmost character of the string
        w = width of the rectangle
            x <= x+w < console width
        h = height of the rectangle
            y <= y+h < console height
        flag = this flag defines how the cell's background color is modified
               See TCOD_bkgnd_flag_t
        alignment = defines how the strings are printed on screen.
        fmt = printf-like format string, eventually followed by parameters. You
              can use control codes to change the colors inside the string.
    */
    int printRectEx(int x, int y, int w, int h, TCOD_bkgnd_flag_t flag, TCOD_alignment_t alignment, const char *fmt, A...)(A args) {
        return TCOD_console_print_rect_ex(data, x, y, w, h, flag, alignment, fmt, args);
    }

    /** ditto */
    int printRectEx(int x, int y, int w, int h, TCOD_bkgnd_flag_t flag, TCOD_alignment_t alignment, const wchar_t *fmt, A...)(A args) {
        return TCOD_console_print_rect_ex_utf(data, x, y, w, h, flag, alignment, fmt, args);
    }

    /**
    Compute the height of an autowrapped string.

    This function returns the expected height of an autowrapped string without
    actually printing the string with printRect or printRectEx

    Params:
        x = y coordinate of the character in the console, depending on the
            default alignment for this console.
        y = y coordinate of the character in the console, depending on the
            default alignment for this console:
            * TCOD_LEFT : leftmost character of the string
            * TCOD_CENTER : center character of the string
            * TCOD_RIGHT : rightmost character of the string
        w = width of the rectangle
            x <= x+w < console width
        h = height of the rectangle
            y <= y+h < console height
        fmt = printf-like format string, eventually followed by parameters. You
              can use control codes to change the colors inside the string.
    */
    int getHeightRect(int x, int y, int w, int h, const char *fmt, A...)(A args) {
        return TCOD_console_get_height_rect(data, x, y, w, h, fmt, args);
    }

    /** ditto */
    int getHeightRect(int x, int y, int w, int h, const wchar_t *fmt, A...)(A args) {
        return TCOD_console_get_height_rect_utf(data, x, y, w, h, fmt, args);
    }

    /**
    Changing the colors while printing a string

    If you want to draw a string using different colors for each word, the basic solution is to call a string printing function several times, changing the default colors between each call.
    The TCOD library offers a simpler way to do this, allowing you to draw a string using different colors in a single call. For this, you have to insert color control codes in your string.
    A color control code is associated with a color set (a foreground color and a background color). If you insert this code in your string, the next characters will use the colors associated with the color control code.
    There are 5 predefined color control codes :
        TCOD_COLCTRL_1
        TCOD_COLCTRL_2
        TCOD_COLCTRL_3
        TCOD_COLCTRL_4
        TCOD_COLCTRL_5
    To associate a color with a code, use setColorControl.
    To go back to the console's default colors, insert in your string the color stop control code :
        TCOD_COLCTRL_STOP

    You can also use any color without assigning it to a control code, using the generic control codes :
        TCOD_COLCTRL_FORE_RGB
        TCOD_COLCTRL_BACK_RGB

    Those controls respectively change the foreground and background color used to print the string characters. In the string, you must insert the r,g,b components of the color (between 1 and 255. The value 0 is forbidden because it represents the end of the string in C/C++) immediately after this code.

    Params:
        con = the color control TCOD_COLCTRL_x, 1<=x<=5
        fore = foreground color when this control is activated
        back = background color when this control is activated

    Example:
    ---
    // A string with a red over black word, using predefined color control codes
    TCODConsole.setColorControl(TCOD_COLCTRL_1, TCODColor.red, TCODColor.black);
    TCODConsole.root.print(1, 1, "String with a %cred%c word.",TCOD_COLCTRL_1,TCOD_COLCTRL_STOP);
    // A string with a red over black word, using generic color control codes
    TCODConsole.root.print(1, 1, "String with a %c%c%c%c%c%c%c%cred%c word.",
            TCOD_COLCTRL_FORE_RGB, 255, 1, 1, TCOD_COLCTRL_BACK_RGB, 1, 1, 1, TCOD_COLCTRL_STOP);
    // A string with a red over black word, using generic color control codes
    TCODConsole.root.print(1, 1, "String with a %c%c%c%c%c%c%c%cred%c word.",
            TCOD_COLCTRL_FORE_RGB, 255, 1, 1, TCOD_COLCTRL_BACK_RGB, 1, 1, 1, TCOD_COLCTRL_STOP);
    ---
    */
    static void setColorControl(TCOD_colctrl_t con, ref const TCODColor fore, ref const TCODColor back) {
        TCOD_color_t b={back.r, back.g, back.b}, f={fore.r, fore.g, fore.b};
        TCOD_console_set_color_control(con,f,b);
    }

    /**
    Filling a rectangle with the background color

    Fill a rectangle inside a console. For each cell in the rectangle, the
    cell's background color is set to the console default background color,
    if clear is true, the cell's ASCII code is set to 32 (space).

    Params:
        x = x coordinate of rectangle upper-left corner in the console.
            0 <= x < console width
        y = y coordinate of rectangle upper-left corner in the console.
            0 <= y < console height
        rw = width of the rectangle in the console.
            x <= x+w < console width
        rh = height of the rectangle in the console.
            y <= y+h < console height
        clear = if true, all characters inside the rectangle are set to ASCII
                code 32 (space). If false, only the background color is
                modified.
        flag = this flag defines how the cell's background color is modified.
               See TCOD_bkgnd_flag_t
    */
    void rect(int x, int y, int rw, int rh, bool clear, TCOD_bkgnd_flag_t flag = TCOD_BKGND_DEFAULT) {
        TCOD_console_rect(data, x, y, rw, rh, clear, flag);
    }

    /**
    Drawing an horizontal line.

    Draws an horizontal line in the console, using ASCII code TCOD_CHAR_HLINE
    (196), and the console's default background/foreground colors.

    Params:
        x = x coordinate of the line's left end in the console.
            0 <= x < console width
        y = y coordinate of the line's left end in the console.
            0 <= y < console height
        l = The length of the line in cells 1 <= l <= console width - x
        flag = this flag defines how the cell's background color is modified.
               See TCOD_bkgnd_flag_t
    */
    void hline(int x, int y, int l, TCOD_bkgnd_flag_t flag = TCOD_BKGND_DEFAULT) {
        TCOD_console_hline(data, x, y, l, flag);
    }

    /**
    Drawing an vertical line.

    Draws an vertical line in the console, using ASCII code TCOD_CHAR_VLINE
    (179), and the console's default background/foreground colors.

    Params:
        x = x coordinate of the line's upper end in the console.
            0 <= x < console width
        y = y coordinate of the line's upper end in the console.
            0 <= y < console height
        l = The length of the line in cells 1 <= l <= console height - x
        flag = this flag defines how the cell's background color is modified.
               See TCOD_bkgnd_flag_t
    */
    void vline(int x,int y, int l, TCOD_bkgnd_flag_t flag = TCOD_BKGND_DEFAULT) {
        TCOD_console_vline(data,x,y,l,flag);
    }

    /**
    Drawing a window frame

    This function calls the rect function using the supplied background mode
    flag, then draws a rectangle with the console's default foreground color.
    If fmt is not NULL, it is printed on the top of the rectangle, using
    inverted colors.


    Params:
        x = x coordinate of rectangle upper-left corner in the console.
            0 <= x < console width
        y = y coordinate of rectangle upper-left corner in the console.
            0 <= y < console height
        w = width of the rectangle in the console.
            x <= x+w < console width
        h = height of the rectangle in the console.
            y <= y+h < console height
        clear = if true, all characters inside the rectangle are set to ASCII
                code 32 (space). If false, only the background color is
                modified.
        flag = this flag defines how the cell's background color is modified.
               See TCOD_bkgnd_flag_t
        fmt = if null, the funtion only draws a rectangle. Else, printf-like
              format string, eventually followed by parameters. You can use
              control codes to change the colors inside the string.
        args = Variadic argument list.
    */
    void printFrame(int x,int y, int w,int h, bool clear=true, TCOD_bkgnd_flag_t flag = TCOD_BKGND_DEFAULT, const char *fmt=null, A...)(args A) {
        TCOD_console_print_frame(data, x, y, w, h, clear, flag, fmt, args);
    }

    /**
    Get the console's width.

    This function returns the width of a console (either the root console or
    an offscreen console)
    */
    int getWidth() {
        return TCOD_console_get_width(data);
    }


    /**
    Get the console's height.

    This function returns the height of a console (either the root console or
    an offscreen console)
    */
    int getHeight() {
        return TCOD_console_get_height(data);
    }

    /**
    Reading the default background color.

    This function returns the default background color of a console.
    */
    TCODColor getDefaultBackground() {
        TCOD_color_t c = TCOD_console_get_default_background(data);
        return TCODColor(c.r, c.g, c.b);
    }

    /**
    Reading the default foreground color.

    This function returns the default foreground color of a console.
    */
    TCODColor getDefaultForeground() {
        return TCODColor(TCOD_console_get_default_foreground(data));
    }

    /**
    Reading the background color of a cell

    Params:
        x = x coordinate of the cell in the console.
            0 <= x < console width
        y = y coordinate of the cell in the console.
            0 <= y < console height
    */
    TCODColor getCharBackground(int x, int y) {
        return TCODColor(TCOD_console_get_char_background(data, x, y));
    }

    /**
    This function returns the foreground color of a cell.

    Params:
        x = x coordinate of the cell in the console.
            0 <= x < console width
        y = y coordinate of the cell in the console.
            0 <= y < console height
    */
    TCODColor getCharForeground(int x, int y) {
        return TCODColor(TCOD_console_get_char_foreground(data, x, y));
    }

    /**
    This function returns the ASCII code of a cell.

    Params:
        x = x coordinate of the cell in the console.
            0 <= x < console width
        y = y coordinate of the cell in the console.
            0 <= y < console height
    */
    int getChar(int x, int y) {
        return TCOD_console_get_char(data,x,y);
    }

    /**
    Changing the fading parameters

    This function defines the fading parameters, allowing to easily fade the
    game screen to/from a color. Once they are defined, the fading parameters
    are valid for ever. You don't have to call setFade for each rendered frame
    (unless you change the fading parameters).

    Params:
        fade = the fading amount. 0 => the screen is filled with the fading
               color. 255 => no fading effect
        fadingColor = the color to use during the console flushing operation

    Example:
    ---
    for (int fade = 255; fade >= 0; fade --) {
        TCODConsole.setFade(fade,TCODColor.black);
        TCODConsole.flush();
    }
    ---
    */
    static void setFade(ubyte fade, ref const TCODColor fadingColor) {
        TCOD_color_t f = {fadingColor.r, fadingColor.g, fadingColor.b};
        TCOD_console_set_fade(fade, f);
    }

    /**
    This function returns the current fade amount, previously defined by setFade.
    */
    static ubyte getFade() {
        return TCOD_console_get_fade();
    }

    /**
    This function returns the current fading color, previously defined by setFade.
    */
    static TCODColor getFadingColor() {
        return TCODColor(TCOD_console_get_fading_color());
    }

    /**
    Flushing the root console.

    Once the root console is initialized, you can use one of the printing
    functions to change the background colors, the foreground colors or the
    ASCII characters on the console. Once you've finished rendering the root
    console, you have to actually apply the updates to the screen with this
    function.
    */
    static void flush() {
        TCOD_console_flush();
    }

    /**
    Some useful graphic characters in the terminal.bmp font.
        Single line walls:
        TCOD_CHAR_HLINE=196 (HorzLine)
        TCOD_CHAR_VLINE=179 (VertLine)
        TCOD_CHAR_NE=191 (NE)
        TCOD_CHAR_NW=218 (NW)
        TCOD_CHAR_SE=217 (SE)
        TCOD_CHAR_SW=192 (SW)

        Double lines walls:
        TCOD_CHAR_DHLINE=205 (DoubleHorzLine)
        TCOD_CHAR_DVLINE=186 (DoubleVertLine)
        TCOD_CHAR_DNE=187 (DoubleNE)
        TCOD_CHAR_DNW=201 (DoubleNW)
        TCOD_CHAR_DSE=188 (DoubleSE)
        TCOD_CHAR_DSW=200 (DoubleSW)

        Single line vertical/horizontal junctions (T junctions):
        TCOD_CHAR_TEEW=180 (TeeWest)
        TCOD_CHAR_TEEE=195 (TeeEast)
        TCOD_CHAR_TEEN=193 (TeeNorth)
        TCOD_CHAR_TEES=194 (TeeSouth)

        Double line vertical/horizontal junctions (T junctions):
        TCOD_CHAR_DTEEW=185 (DoubleTeeWest)
        TCOD_CHAR_DTEEE=204 (DoubleTeeEast)
        TCOD_CHAR_DTEEN=202 (DoubleTeeNorth)
        TCOD_CHAR_DTEES=203 (DoubleTeeSouth)

        Block characters:
        TCOD_CHAR_BLOCK1=176 (Block1)
        TCOD_CHAR_BLOCK2=177 (Block2)
        TCOD_CHAR_BLOCK3=178 (Block3)

        Cross-junction between two single line walls:
        TCOD_CHAR_CROSS=197 (Cross)

        Arrows:
        TCOD_CHAR_ARROW_N=24 (ArrowNorth)
        TCOD_CHAR_ARROW_S=25 (ArrowSouth)
        TCOD_CHAR_ARROW_E=26 (ArrowEast)
        TCOD_CHAR_ARROW_W=27 (ArrowWest)

        Arrows without tail:
        TCOD_CHAR_ARROW2_N=30 (ArrowNorthNoTail)
        TCOD_CHAR_ARROW2_S=31 (ArrowSouthNoTail)
        TCOD_CHAR_ARROW2_E=16 (ArrowEastNoTail)
        TCOD_CHAR_ARROW2_W=17 (ArrowWestNoTail)

        Double arrows:
        TCOD_CHAR_DARROW_H=29 (DoubleArrowHorz)
        TCOD_CHAR_ARROW_V=18 (DoubleArrowVert)

        GUI stuff:
        TCOD_CHAR_CHECKBOX_UNSET=224
        TCOD_CHAR_CHECKBOX_SET=225
        TCOD_CHAR_RADIO_UNSET=9
        TCOD_CHAR_RADIO_SET=10

        Sub-pixel resolution kit:
        TCOD_CHAR_SUBP_NW=226 (SubpixelNorthWest)
        TCOD_CHAR_SUBP_NE=227 (SubpixelNorthEast)
        TCOD_CHAR_SUBP_N=228 (SubpixelNorth)
        TCOD_CHAR_SUBP_SE=229 (SubpixelSouthEast)
        TCOD_CHAR_SUBP_DIAG=230 (SubpixelDiagonal)
        TCOD_CHAR_SUBP_E=231 (SubpixelEast)
        TCOD_CHAR_SUBP_SW=232 (SubpixelSouthWest)

        Miscellaneous characters:
        TCOD_CHAR_SMILY = 1 (Smilie)
        TCOD_CHAR_SMILY_INV = 2 (SmilieInv)
        TCOD_CHAR_HEART = 3 (Heart)
        TCOD_CHAR_DIAMOND = 4 (Diamond)
        TCOD_CHAR_CLUB = 5 (Club)
        TCOD_CHAR_SPADE = 6 (Spade)
        TCOD_CHAR_BULLET = 7 (Bullet)
        TCOD_CHAR_BULLET_INV = 8 (BulletInv)
        TCOD_CHAR_MALE = 11 (Male)
        TCOD_CHAR_FEMALE = 12 (Female)
        TCOD_CHAR_NOTE = 13 (Note)
        TCOD_CHAR_NOTE_DOUBLE = 14 (NoteDouble)
        TCOD_CHAR_LIGHT = 15 (Light)
        TCOD_CHAR_EXCLAM_DOUBLE = 19 (ExclamationDouble)
        TCOD_CHAR_PILCROW = 20 (Pilcrow)
        TCOD_CHAR_SECTION = 21 (Section)
        TCOD_CHAR_POUND = 156 (Pound)
        TCOD_CHAR_MULTIPLICATION = 158 (Multiplication)
        TCOD_CHAR_FUNCTION = 159 (Function)
        TCOD_CHAR_RESERVED = 169 (Reserved)
        TCOD_CHAR_HALF = 171 (Half)
        TCOD_CHAR_ONE_QUARTER = 172 (OneQuarter)
        TCOD_CHAR_COPYRIGHT = 184 (Copyright)
        TCOD_CHAR_CENT = 189 (Cent)
        TCOD_CHAR_YEN = 190 (Yen)
        TCOD_CHAR_CURRENCY = 207 (Currency)
        TCOD_CHAR_THREE_QUARTERS = 243 (ThreeQuarters)
        TCOD_CHAR_DIVISION = 246 (Division)
        TCOD_CHAR_GRADE = 248 (Grade)
        TCOD_CHAR_UMLAUT = 249 (Umlaut)
        TCOD_CHAR_POW1 = 251 (Pow1)
        TCOD_CHAR_POW3 = 252 (Pow2)
        TCOD_CHAR_POW2 = 253 (Pow3)
        TCOD_CHAR_BULLET_SQUARE = 254 (BulletSquare)
    */

    /**
    @PageTitle Handling keyboard input
    @PageDesc The keyboard handling functions allow you to get keyboard input from the user, either for turn by turn games (the function wait until the user press a key), or real time games (non blocking function).
    <b>WARNING : for proper redraw event handling, the keyboard functions should always be called just after TCODConsole::flush !</b>
    */

    /**
    This function waits for the user to press a key. It returns the code of the
    key pressed as well as the corresponding character. See TCOD_key_t. If the
    flush parameter is true, every pending keypress event is discarded, then
    the function wait for a new keypress. If flush is false, the function waits
    only if there are no pending keypress events, else it returns the first
    event in the keyboard buffer.

    Params:
        flush = if true, all pending keypress events are flushed from the
                keyboard buffer. Else, return the first available event

    Example:
    ---
    TCOD_key_t key = TCODConsole.waitForKeypress(true);
    if ( key.c == 'i' ) { ... open inventory ... }
    ---
    */

    static TCOD_key_t waitForKeypress(bool flush) {
        return TCOD_console_wait_for_keypress(flush);
    }

    /**
    This function checks if the user has pressed a key. It returns the code of
    the key pressed as well as the corresponding character. See TCOD_key_t.
    If the user didn't press a key, this function returns the key code
    TCODK_NONE. <b>Note that key repeat only results in TCOD_KEY_PRESSED events.</b>

    Params:
        flags = filter key events:
                TCOD_KEY_PRESSED: only keypress events are returned.
                TCOD_KEY_RELEASED: only key release events are returnes.
                TCOD_KEY_PRESSED | TCOD_KEY_RELEASED: events of both types are returned.

    Example:
    ---
    TCOD_key_t key = TCODConsole.checkForKeypress();
    if ( key.vk == TCODK_NONE ) return; // no key pressed
    if ( key.c == 'i' ) { ... open inventory ... }
    ---
    */
    static TCOD_key_t checkForKeypress(int flags=TCOD_KEY_RELEASED) {
        return TCOD_console_check_for_keypress(flags);
    }

    /**
    You can also get the status of any special key at any time with

    Params:
        key = Any key code defined in keycode_t except TCODK_CHAR (Char) and
              TCODK_NONE (NoKey)
    */
    static bool isKeyPressed(TCOD_keycode_t key) {
        return TCOD_console_is_key_pressed(key) != 0;
    }

    /**
    This function changes the keyboard repeat times.

    @Param initialDelay delay in millisecond between the time when a key is pressed, and keyboard repeat begins. If 0, keyboard repeat is disabled
    @Param interval interval in millisecond between keyboard repeat events
    */
    static void setKeyboardRepeat(int initialDelay, int interval) {
        TCOD_console_set_keyboard_repeat(initialDelay, interval);
    }


    /**
    You can also disable the keyboard repeat feature with this function (it's
    equivalent to setKeyboardRepeat(0,0) ).
    */
    static void disableKeyboardRepeat() {
        TCOD_console_disable_keyboard_repeat();
    }

    /**
    This structure contains information about a key pressed/released by the user.

    @Param vk An arbitrary value representing the physical key on the keyboard. Possible values are stored in the TCOD_keycode_t enum. If no key was pressed, the value is TCODK_NONE
    @Param c If the key correspond to a printable character, the character is stored in this field. Else, this field contains 0.
    @Param pressed true if the event is a key pressed, or false for a key released.
    @Param lalt This field represents the status of the left Alt key : true => pressed, false => released.
    @Param lctrl This field represents the status of the left Control key : true => pressed, false => released.
    @Param ralt This field represents the status of the right Alt key : true => pressed, false => released.
    @Param rctrl This field represents the status of the right Control key : true => pressed, false => released.
    @Param shift This field represents the status of the shift key : true => pressed, false => released.
    */

    /**
    @PageDesc TCOD_keycode_t is a libtcod specific code representing a key on the keyboard.
        For python, replace TCODK by KEY: libtcod.KEY_NONE. C# and Lua, the value is in parenthesis. Possible values are :
        When no key was pressed (see checkForKeypress) : TCOD_NONE (NoKey)
        Special keys :
        TCODK_ESCAPE (Escape)
        TCODK_BACKSPACE (Backspace)
        TCODK_TAB (Tab)
        TCODK_ENTER (Enter)
        TCODK_SHIFT (Shift)
        TCODK_CONTROL (Control)
        TCODK_ALT (Alt)
        TCODK_PAUSE (Pause)
        TCODK_CAPSLOCK (CapsLock)
        TCODK_PAGEUP (PageUp)
        TCODK_PAGEDOWN (PageDown)
        TCODK_END (End)
        TCODK_HOME (Home)
        TCODK_UP (Up)
        TCODK_LEFT (Left)
        TCODK_RIGHT (Right)
        TCODK_DOWN (Down)
        TCODK_PRINTSCREEN (Printscreen)
        TCODK_INSERT (Insert)
        TCODK_DELETE (Delete)
        TCODK_LWIN (Lwin)
        TCODK_RWIN (Rwin)
        TCODK_APPS (Apps)
        TCODK_KPADD (KeypadAdd)
        TCODK_KPSUB (KeypadSubtract)
        TCODK_KPDIV (KeypadDivide)
        TCODK_KPMUL (KeypadMultiply)
        TCODK_KPDEC (KeypadDecimal)
        TCODK_KPENTER (KeypadEnter)
        TCODK_F1 (F1)
        TCODK_F2 (F2)
        TCODK_F3 (F3)
        TCODK_F4 (F4)
        TCODK_F5 (F5)
        TCODK_F6 (F6)
        TCODK_F7 (F7)
        TCODK_F8 (F8)
        TCODK_F9 (F9)
        TCODK_F10 (F10)
        TCODK_F11 (F11)
        TCODK_F12 (F12)
        TCODK_NUMLOCK (Numlock)
        TCODK_SCROLLLOCK (Scrolllock)
        TCODK_SPACE (Space)

        numeric keys :

        TCODK_0 (Zero)
        TCODK_1 (One)
        TCODK_2 (Two)
        TCODK_3 (Three)
        TCODK_4 (Four)
        TCODK_5 (Five)
        TCODK_6 (Six)
        TCODK_7 (Seven)
        TCODK_8 (Eight)
        TCODK_9 (Nine)
        TCODK_KP0 (KeypadZero)
        TCODK_KP1 (KeypadOne)
        TCODK_KP2 (KeypadTwo)
        TCODK_KP3 (KeypadThree)
        TCODK_KP4 (KeypadFour)
        TCODK_KP5 (KeypadFive)
        TCODK_KP6 (KeypadSix)
        TCODK_KP7 (KeypadSeven)
        TCODK_KP8 (KeypadEight)
        TCODK_KP9 (KeypadNine)

        Any other (printable) key :

        TCODK_CHAR (Char)

        Codes starting with TCODK_KP represents keys on the numeric keypad (if available).
    */

    /**
    Loading an offscreen console from a .asc file

    You can load data from a file created with Ascii Paint with this function. When needed, the console will be resized to fit the file size. The function returns false if it couldn't read the file.

    Params:
        filename = path to the .asc file created with Ascii Paint

    Example:
    ---
    // Creating a 40x20 offscreen console
    TCODConsole offscreenConsole = new TCODConsole(40, 20);
    // possibly resizing it and filling it with data from the .asc file
    offscreenConsole.loadAsc("myfile.asc");
    ---
    */
    bool loadAsc(const char *filename) {
        return TCOD_console_load_asc(data,filename) != 0;
    }

    /**
    Loading an offscreen console from a .apf file

    You can load data from a file created with Ascii Paint with this function. When needed, the console will be resized to fit the file size. The function returns false if it couldn't read the file.

    Params:
        filename = path to the .apf file created with Ascii Paint

    Example:
    ---
    // Creating a 40x20 offscreen console
    TCODConsole offscreenConsole = new TCODConsole(40, 20);
    // possibly resizing it and filling it with data from the .apf file
    offscreenConsole.loadApf("myfile.apf");
    ---
    */
    bool loadApf(const char *filename) {
        return TCOD_console_load_apf(data,filename) != 0;
    }

    /**
    Saving a console to a .asc file

    You can save data from a console to Ascii Paint format with this function.
    The function returns false if it couldn't write the file. This is the only
    ASC function that works also with the root console!

    Params:
        filename = path to the .asc file to be created

    Example:
    ---
    console.saveAsc("myfile.asc");
    ---
    */
    bool saveAsc(const char *filename) {
        return TCOD_console_save_asc(data,filename) != 0;
    }

    /**
    Saving a console to a .apf file

    You can save data from a console to Ascii Paint format with this function. The function returns false if it couldn't write the file. This is the only ASC function that works also with the root console !

    Params:
        filename = path to the .apf file to be created

    Example:
    ---
    console.saveApf("myfile.apf");
    ---
    */
    bool saveApf(const char *filename) {
        return TCOD_console_save_apf(data,filename) != 0;
    }

    /**
    Blitting a console on another one.

    This function allows you to blit a rectangular area of the source console
    at a specific position on a destination console. It can also simulate
    alpha transparency with the fade parameter.

    Params:
        src = The source console that must be blitted on another one.
        xSrc = x starting position of the rectangular area of the source
               console that will be blitted.
        ySrc = y starting position of the rectangular area of the source
               console that will be blitted.
        wSrc = width of the rectangular area of the source console that will
               be blitted. If wSrc == 0, the source console width is used.
        hSrc = height of the rectangular area of the source console that will
               be blitted. IfhSrc == 0, the source console height is used.
        dst = The destination console.
        xDst = x upper-left corner of the source area in the destination console.
        yDst = y upper-left corner of the source area in the destination console.
        foregroundAlpha = Alpha transparency of the blitted console.
        backgroundAlpha = Alpha transparency of the blitted console.
                          0.0 => The source console is completely transparent. This function does nothing.
                          1.0 => The source console is opaque. Its cells replace the destination cells.
                          0 < fade < 1.0 => The source console is partially blitted, simulating real transparency.

    Example:
    ---
    // Cross-fading between two offscreen consoles. We use two offscreen consoles with the same size as the root console. We render a different screen on each offscreen console. When the user hits a key, we do a cross-fading from the first screen to the second screen.
    TCODConsole off1 = new TCODConsole(80, 50);
    TCODConsole off2 = new TCODConsole(80, 50);
    // ... print screen1 on off1
    // ... print screen2 of off2
    // render screen1 in the game window
    TCODConsole.blit(off1, 0, 0, 80, 50, TCODConsole.root, 0, 0);
    TCODConsole.flush();
    // wait or a keypress
    TCODConsole.waitForKeypress(true);
    // do a cross-fading from off1 to off2
    for (int i = 1; i <= 255; i++) {
        // renders the first screen (opaque)
        TCODConsole.blit(off1, 0, 0, 80, 50, TCODConsole.root, 0, 0);
        // renders the second screen (transparent)
        TCODConsole.blit(off2, 0, 0, 80, 50, TCODConsole.root, 0, 0, i/255.0, i/255.0);
        TCODConsole.flush();
    }
    ---
    */
    static void blit(TCODConsole src,int xSrc, int ySrc, int wSrc,
                     int hSrc, TCODConsole dst, int xDst, int yDst,
                     float foregroundAlpha=1.0f, float backgroundAlpha=1.0f) {
        TCOD_console_blit(src.data, xSrc, ySrc, wSrc, hSrc, dst.data,
                          xDst, yDst, foregroundAlpha, backgroundAlpha);
    }

    /**
    Define a blit-transparent color.

    This function defines a transparent background color for an offscreen
    console. All cells with this background color are ignored by the blit
    operation. You can use it to blit only some parts of the console.

    Params:
        col = the transparent background color
    */

    void setKeyColor(ref const TCODColor col) {
        TCOD_color_t c = {col.r, col.g, col.b};
        TCOD_console_set_key_color(data, c);
    }

    /**
    Destroying an offscreen console

    Use this function to destroy an offscreen console and release any resources
    allocated. Don't use it on the root console.

    Example:
    ---
    TCODConsole off1 = new TCODConsole(80, 50);
    // ... use off1
    delete off1; // destroy the offscreen console
    ---
    */
    ~this() {
        TCOD_console_delete(data);
    }

    void setDirty(int x, int y, int w, int h) {
        TCOD_console_set_dirty(x, y, w, h);
    }

package:
    this() {};
    TCOD_console_t data;

private:
    /* definitions from libtcod_int.h */

    extern (C) struct TCOD_internal_context_t {
        /* number of characters in the bitmap font */
        int fontNbCharHoriz;
        int fontNbCharVertic;
        /* font type and layout */
        bool font_tcod_layout;
        bool font_in_row;
        bool font_greyscale;
        /* character size in font */
        int font_width;
        int font_height;
        char[512] font_file;
        char[512] window_title;
        /* ascii code to tcod layout converter */
        int *ascii_to_tcod;
        /* whether each character in the font is a colored tile */
        bool *colored;
        /* the root console */
        TCOD_console_t root;
        /* nb chars in the font */
        int max_font_chars;
        /* fullscreen data */
        bool fullscreen;
        int fullscreen_offsetx;
        int fullscreen_offsety;
        /* asked by the user */
        int fullscreen_width;
        int fullscreen_height;
        /* actual resolution */
        int actual_fullscreen_width;
        int actual_fullscreen_height;
        /* renderer to use */
        TCOD_renderer_t renderer;
        /* user post-processing callback */
        SDL_renderer_t sdl_cbk;
        /* fading data */
        TCOD_color_t fading_color;
        uint8 fade;
    }

    __gshared extern (C) TCOD_internal_context_t TCOD_ctx;

}
