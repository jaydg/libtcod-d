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

module tcod.image;

import std.string : toStringz;

import tcod.c.functions;
import tcod.c.types;
import tcod.console;
import tcod.color;

/**
This toolkit contains some image manipulation utilities.
*/

class TCODImage {
public :
    /**
    Creating an empty image.

    You can create an image of any size, filled with black with this function.

    Params:
        width = width of the image in pixels.
        height = height of the image in pixels.

    Example:
    ---
    TCODImage pix = new TCODImage(80, 50);
    ---
    */
    this(int width, int height) {
        data = TCOD_image_new(width, height);
        deleteData = true;
    }

    /**
    Loading a .bmp or .png image.

    You can read data from a .bmp or .png file (for example to draw an image
    using the background color of the console cells). Note that only 24bits
    and 32bits PNG files are currently supported.


    Params:
        filename = Name of the .bmp or .png file to load.

    Example:
    ---
    TCODImage pix = new TCODImage("mypic.bmp");
    ---
    */
    this(const char *filename) {
        data = TCOD_image_load(filename);
        deleteData = true;
    }

    /** ditto */
    this(const string filename) {
        this(filename.toStringz);
    }

    /**
    Creating an image from a console.

    You can create an image from any console (either the root console or an
    offscreen console). The image size will depend on the console size and
    the font characters size. You can then save the image to a file with the
    save function.

    Params:
        console = The console to capture.

    Example:
    ---
    TCODImage pix = new TCODImage(TCODConsole.root);
    ---
    */
    this(TCODConsole console) {
        data = TCOD_image_from_console(console.data);
    }

    this(TCOD_image_t img) {
        data = img;
        deleteData = false;
    }

    ~this() {
        if (deleteData) TCOD_image_delete(data);
    }

    /**
    Refreshing an image created from a console.

    If you need to refresh the image with the console's new content, you don't
    have to delete it and create another one. Instead, use this function. Note
    that you must use the same console that was used in the
    TCOD_image_from_console call (or at least a console with the same size).

    Params:
        console = The console to capture.

    Example:
    ---
    // create an image from the root console
    TCODImage pix = new TCODImage(TCODConsole.root);
    // ... modify the console
    // update the image with the console's new content
    pix.refreshConsole(TCODConsole.root);
    ---
    */
    void refreshConsole(TCODConsole console) {
        TCOD_image_refresh_console(data, console.data);
    }

    /**
    Getting the size of an image

    You can read the size of an image in pixels with this function.

    Params:
        w = When the function returns, this variable contains the width of the image.
        h = When the function returns, this variable contains the height of the image.

    Example:
    ---
    TCODImage pix = new TCODImage(80, 50);
    int w, h;
    pix.getSize(&w, &h); // w = 80, h = 50
    ---
    */
    void getSize(int *w, int *h) {
        TCOD_image_get_size(data, w, h);
    }

    /**
    Getting the color of a pixel.

    You can read the colors from an image with this function.

    Params:
        x = The pixel coordinates inside the image.
            0 <= x < width
        y = The pixel coordinates inside the image.
            0 <= y < height

    Example:
    ---
    TCODImage pix = new TCODImage(80, 50);
    TCODColor col = pix.getPixel(40, 25);
    ---
    */
    TCODColor getPixel(int x, int y) {
        return TCODColor(TCOD_image_get_pixel(data, x, y));
    }

    /**
    Getting the alpha value of a pixel.

    If you have set a key color for this image with setKeyColor, or if this
    image was created from a 32 bits PNG file (with alpha layer), you can get
    the pixel transparency with this function. This function returns a value
    between 0 (transparent pixel) and 255 (opaque pixel).

    Params:
        x = The pixel coordinates inside the image.
            0 <= x < width
        y = The pixel coordinates inside the image.
            0 <= y < height
    */
    int getAlpha(int x, int y) {
        return TCOD_image_get_alpha(data, x, y);
    }

    /**
    Checking if a pixel is transparent

    You can use this simpler version (for images with alpha layer, returns
    true only if alpha == 0) :

    Params:
        x = The pixel coordinates inside the image.
            0 <= x < width
        y = The pixel coordinates inside the image.
            0 <= y < height
    */
       bool isPixelTransparent(int x, int y) {
        return TCOD_image_is_pixel_transparent(data, x, y) != 0;
    }

    /**
    Getting the average color of a part of the image

    This method uses mipmaps to get the average color of an arbitrary
    rectangular region of the image. It can be used to draw a scaled-down
    version of the image. It's used by libtcod's blitting functions.

    Params:
        x0 = x coordinate in pixels of the upper-left corner of the region.
            0.0 <= x0 < x1
        y0 = y coordinate in pixels of the upper-left corner of the region.
            0.0 <= y0 < y1
        x1 = x coordinate in pixels of the lower-right corner of the region.
            x0 < x1 < width
        y1 = y coordinate in pixels of the lower-right corner of the region.
            y0 < y1 < height

    Example:
    ---
    // Get the average color of a 5x5 "superpixel" in the center of the image.
    TCODImage pix = new TCODImage(80, 50);
    TCODColor col = pix.getMipMapPixel(37.5f, 22.5f, 42.5f, 28.5f);
    ---
    */
       TCODColor getMipmapPixel(float x0, float y0, float x1, float y1) {
        return TCODColor(TCOD_image_get_mipmap_pixel(data, x0, y0, x1, y1));
    }

    /**
    Filling an image with a color.

    Params:
        color = The color to use.
    */
    void clear(const TCODColor color) {
        TCOD_color_t ccol = {color.r, color.g, color.b};
        TCOD_image_clear(data, ccol);
    }

    /**
    Changing the color of a pixel

    Params:
        x = The pixel coordinates inside the image.
            0 <= x < width
        y = The pixel coordinates inside the image.
            0 <= y < height
        col = The new color of the pixel.
    */
    void putPixel(int x, int y, const TCODColor col) {
        TCOD_color_t ccol = {col.r, col.g, col.b};
        TCOD_image_put_pixel(data, x, y, ccol);
    }

    /**
    Scaling an image.

    You can resize an image and scale its content. If neww < oldw or newh <
    oldh, supersampling is used to scale down the image. Else the image is
    scaled up using nearest neightbor.

    Params:
        neww = The new width of the image.
        newh = The new height of the image.
    */
    void scale(int neww, int newh) {
        TCOD_image_scale(data, neww, newh);
    }

    /**
    Flipping the image horizontally.
    */
    void hflip() {
        TCOD_image_hflip(data);
    }

    /**
    Flipping the image vertically.
    */
    void vflip() {
        TCOD_image_vflip(data);
    }

    /**
    Rotate the image clockwise by increment of 90 degrees.

    Params:
        numRotations = Number of 90 degrees rotations. Should be between 1 and 3.
    */
    void rotate90(int numRotations=1) {
        TCOD_image_rotate90(data,numRotations);
    }

    /**
    Inverting the colors of the image
    */
    void invert() {
        TCOD_image_invert(data);
    }

    /**
    Saving an image to a bmp or png file.

    You can save an image to a 24 bits .bmp or .png file.

    Params:
        filename = Name of the .bmp or .png file.

    Example:
    ---
    TCODImage pix = new TCODImage(10, 10);
    pix.save("mypic.bmp");
    ---
      */
    void save(const char *filename) {
        TCOD_image_save(data, filename);
    }

    /** ditto */
    void save(const string filename) {
        save(filename.toStringz);
    }

    /**
    Standard blitting

    This function blits a rectangular part of the image on a console without
    scaling it or rotating it. Each pixel of the image fills a console cell.

    Params:
        console    = The console on which the image will be drawn.
        x = x coordinate in the console of the upper-left corner of the image.
        y = y coordinate in the console of the upper-left corner of the image.
        w = width of the image on the console. Use -1,-1 to use the image size.
        h = height of the image on the console. Use -1,-1 to use the image size.
        bkgnd_flag = This flag defines how the cell's background color is
                     modified. See TCOD_bkgnd_flag_t.
    */
    void blitRect(TCODConsole console, int x, int y, int w=-1, int h=-1, TCOD_bkgnd_flag_t bkgnd_flag = TCOD_BKGND_SET ) {
        TCOD_image_blit_rect(data, console.data, x, y, w, h, bkgnd_flag);
    }

    /**
    Blitting with scaling and/or rotation.

    This function allows you to specify the floating point coordinates of the
    center of the image, its scale and its rotation angle.

    Params:
        console = The console on which the image will be drawn.
        x = x coordinate in the console of the center of the image.
        y = y coordinate in the console of the center of the image.
        bkgnd_flag = This flag defines how the cell's background color is
                     modified. See TCOD_bkgnd_flag_t.
        scalex = x scale coefficient. Must be > 0.0.
        scaley = y scale coefficient. Must be > 0.0.
        angle = Rotation angle in radians.
    */
    void blit(TCODConsole console, float x, float y, TCOD_bkgnd_flag_t bkgnd_flag = TCOD_BKGND_SET, float scalex=1.0f, float scaley=1.0f, float angle=0.0f) {
        TCOD_image_blit(data, console.data, x, y, bkgnd_flag, scalex, scaley, angle);
    }

    /**
    Blitting with a mask.

    When blitting an image, you can define a key color that will be ignored by
    the blitting function. This makes it possible to blit non rectangular
    images or images with transparent pixels.

    Params:
        color = Pixels with this color will be skipped by blitting functions.

    Example:
    ---
    TCODImage pix = TCODImage("mypix.bmp");
    pix.setKeyColor(TCODColor.red);
    // blitting the image, omitting red pixels
    pix.blitRect(TCODConsole.root, 40, 25);
    ---
    */
    void setKeyColor(const TCODColor color) {
        TCOD_color_t ccol = {color.r, color.g, color.b};
        TCOD_image_set_key_color(data, ccol);
    }

    /**
    Blitting with subcell resolution

    Eventually, you can use some special characters in the libtcod fonts :
        <img src="subcell.png">
        to double the console resolution using this blitting function.
        <table><tr><td>
        Comparison before/after subcell resolution in TCOD :<br />
        <img src="subcell_comp.png"></td><td>
        Pyromancer ! screenshot, making full usage of subcell resolution :<br />
        <img src="subcell_pyro.png"></td></tr></table>

    Params:
        dest = The console of which the image will be blited. Foreground,
               background and character data will be overwritten.
        dx = x coordinate of the console cell where the upper left corner of
             the blitted image will be.
        dy = y coordinate of the console cell where the upper left corner of
             the blitted image will be.
        sx = Part of the image to blit.
        sy = Part of the image to blit.
        w = Part of the image to blit. Use -1 to blit the whole image.
        h = Part of the image to blit. Use -1 to blit the whole image.
    */
    void blit2x(TCODConsole dest, int dx, int dy, int sx=0, int sy=0, int w=-1, int h=-1) {
        TCOD_image_blit_2x(data, dest.data, dx, dy, sx, sy, w, h);
    }

package :
    TCOD_image_t data;
    bool deleteData;
}
