/*
 * Not a whole lot of archtectural thought went into this;
 * it's pretty much the same as the C version, with some
 * obvious differences here and there.
 */
import std.stdio;
import std.string;
import std.random;
import std.math;
import std.conv;
import core.stdc.stdlib : malloc, free, exit;
import core.stdc.string;

import derelict.sdl2.sdl;
import tcod.c.all;

Mt19937 gen;

/// Sample screen size.
const int SAMPLE_SCREEN_WIDTH = 46;
const int SAMPLE_SCREEN_HEIGHT = 20;
/// Sample screen position.
const int SAMPLE_SCREEN_X = 20;
const int SAMPLE_SCREEN_Y = 10;

string[] smap = [
    "##############################################",
    "#######################      #################",
    "#####################    #     ###############",
    "######################  ###        ###########",
    "##################      #####             ####",
    "################       ########    ###### ####",
    "###############      #################### ####",
    "################    ######                  ##",
    "########   #######  ######   #     #     #  ##",
    "########   ######      ###                  ##",
    "########                                    ##",
    "####       ######      ###   #     #     #  ##",
    "#### ###   ########## ####                  ##",
    "#### ###   ##########   ###########=##########",
    "#### ##################   #####          #####",
    "#### ###             #### #####          #####",
    "####           #     ####                #####",
    "########       #     #### #####          #####",
    "########       #####      ####################",
    "##############################################"];

interface Sample
{
    /// The sample's printable name.
    string name();
    void render(bool first, ref TCOD_key_t key, ref TCOD_mouse_t mouse);
}

// The offscreen console in which the samples are rendered.
TCOD_console_t sample_console;

/// ====================
/// True colours sample.
/// ====================
class ColoursSample : Sample
{
    string name() { return "  True colors        "; }
    void render(bool first, ref TCOD_key_t key, ref TCOD_mouse_t mouse)
    {
        enum { TOPLEFT, TOPRIGHT, BOTTOMLEFT, BOTTOMRIGHT }
        // Random corner colours.
        static TCOD_color_t[4] cols = [{50,40,150},{240,85,5},{50,35,240},{10,200,130}];
        static int[4] dirr = [1, -1, 1, 1], dirg = [1, -1, -1, 1], dirb = [1, 1, 1, -1];

        if (first) {
            TCOD_sys_set_fps(0);
            TCOD_console_clear(sample_console);
        }

        // ==== Slightly modify the corner colours. ====
        for (int i = 0; i < cols.length; i++) {
            // Move each corner colour.
            int component = uniform(0, 3, gen);
            switch (component) {
            case 0:
                cols[i].r += 5 * dirr[i];
                if (cols[i].r == 255) dirr[i] = -1;
                else if (cols[i].r == 0) dirr[i] = 1;
                break;
            case 1:
                cols[i].g += 5 * dirg[i];
                if (cols[i].g == 255) dirg[i] = -1;
                else if (cols[i].g == 0) dirg[i] = 1;
                break;
            case 2:
                cols[i].b += 5 * dirb[i];
                if (cols[i].b == 255) dirb[i] = -1;
                else if (cols[i].b == 0) dirb[i] = 1;
                break;
            default:
                assert(false);
            }
        }

        // ==== Scan the whole screen, interpolating corner colours. ====
        for (int x = 0; x < SAMPLE_SCREEN_WIDTH; x++) {
            float xcoef = cast(float)(x) / (SAMPLE_SCREEN_WIDTH - 1);
            // Get the current column top and bottom colours.
            TCOD_color_t top = TCOD_color_lerp(cols[TOPLEFT], cols[TOPRIGHT], xcoef);
            TCOD_color_t bottom = TCOD_color_lerp(cols[BOTTOMLEFT], cols[BOTTOMRIGHT], xcoef);
            for (int y = 0; y < SAMPLE_SCREEN_HEIGHT; y++) {
                float ycoef = cast(float)(y) / (SAMPLE_SCREEN_HEIGHT - 1);
                // Get the current cell colour.
                TCOD_color_t curColor = TCOD_color_lerp(top, bottom, ycoef);
                TCOD_console_set_char_background(sample_console, x, y, curColor,
                                      TCOD_BKGND_SET);
            }
        }

        // === Print the text. ====
        // Get the background colour at the text position...
        auto textColor = TCOD_console_get_char_background(sample_console, SAMPLE_SCREEN_WIDTH / 2, 5);
        // ...and invert it.
        textColor.r = cast(ubyte)(255 - textColor.r);
        textColor.g = cast(ubyte)(255 - textColor.g);
        textColor.b = cast(ubyte)(255 - textColor.b);
        TCOD_console_set_default_foreground(sample_console, textColor);
        // Put random text (for performance tests).
        for (int x = 0; x < SAMPLE_SCREEN_WIDTH; x++) {
            for (int y = 0; y < SAMPLE_SCREEN_HEIGHT; y++) {
                TCOD_color_t col = TCOD_console_get_char_background(sample_console, x, y);
                col = TCOD_color_lerp(col, TCOD_black, 0.5f);
                int c = uniform('a', 'z' + 1, gen);
                TCOD_console_set_default_foreground(sample_console, col);
                TCOD_console_put_char(sample_console, x, y, c,
                                      TCOD_BKGND_NONE);
            }
        }
        // The background behind the text is slightly darkened using BKGND_MULTIPLY.
        TCOD_console_set_default_background(sample_console, TCOD_grey);
        TCOD_console_print_rect_ex(sample_console, SAMPLE_SCREEN_WIDTH / 2, 5,
                                       SAMPLE_SCREEN_WIDTH - 2, SAMPLE_SCREEN_HEIGHT - 1,
                                       TCOD_BKGND_MULTIPLY, TCOD_CENTER,
                                       "The Doryen library uses 24 bits colors, for both background and foreground.");
    }
}

/// =========================
/// Offscreen console sample.
/// =========================
class OffscreenSample : Sample
{
    private:

    TCOD_console_t secondary;
    TCOD_console_t screenshot;
    int counter;
    int x = 0;
    int y = 0;
    int xdir = 1;
    int ydir = 1;

    public:

    this()
    {

        secondary = TCOD_console_new(SAMPLE_SCREEN_WIDTH / 2, SAMPLE_SCREEN_HEIGHT / 2);
        screenshot = TCOD_console_new(SAMPLE_SCREEN_WIDTH, SAMPLE_SCREEN_HEIGHT);

        TCOD_console_print_frame(secondary, 0, 0, SAMPLE_SCREEN_WIDTH / 2,
                                 SAMPLE_SCREEN_HEIGHT / 2, false, TCOD_BKGND_SET,
                                 "Offscreen console");
        TCOD_console_print_rect_ex(secondary, SAMPLE_SCREEN_WIDTH / 4, 2,
                                       (SAMPLE_SCREEN_WIDTH / 2) - 2,
                                       SAMPLE_SCREEN_HEIGHT / 2,
                                       TCOD_BKGND_NONE, TCOD_CENTER,
                                       "You can render to an offscreen console and blit in on another one, simulating alpha transparency.");
    }

    string name() { return "  Offscreen console  "; }
    void render(bool first, ref TCOD_key_t key, ref TCOD_mouse_t mouse)
    {
        if (first) {
            TCOD_sys_set_fps(30);
            TCOD_console_blit(sample_console, 0, 0, SAMPLE_SCREEN_WIDTH,
                              SAMPLE_SCREEN_HEIGHT, screenshot, 0, 0, 1.0f, 1.0f);
        }

        if (++counter % 20 == 0) {
            // Move the secondary screen every two seconds.
            x += xdir; y += ydir;
            if (x == SAMPLE_SCREEN_WIDTH / 2+5) xdir = -1;
            else if (x == -5) xdir = 1;
            if (y == SAMPLE_SCREEN_HEIGHT / 2+5) ydir = -1;
            else if (y == -5) ydir = 1;
        }
        // Restore the initial screen.
        TCOD_console_blit(screenshot, 0, 0, SAMPLE_SCREEN_WIDTH, SAMPLE_SCREEN_HEIGHT,
                          sample_console, 0, 0, 1.0f, 1.0f);
        // Blit the overlapping screen.
        TCOD_console_blit(secondary, 0, 0, SAMPLE_SCREEN_WIDTH / 2, SAMPLE_SCREEN_HEIGHT / 2,
                          sample_console, x, y, 1.0f, 0.75f);
    }
}

/// ====================
/// Line drawing sample.
/// ====================
TCOD_bkgnd_flag_t bk_flag = TCOD_BKGND_SET;  /// Current blending mode.
extern (C) bool line_listener(int x, int y)
{
    if (x >= 0 && y >= 0 && x < SAMPLE_SCREEN_WIDTH && y < SAMPLE_SCREEN_HEIGHT) {
        TCOD_console_set_char_background(sample_console, x, y, TCOD_light_blue, bk_flag);
    }

    return true;
}

class LinesSample : Sample
{
    private:

    TCOD_console_t bk;  /// Coloured background.

    static string[] flag_names = [
        "TCOD_BKGND_NONE",
        "TCOD_BKGND_SET",
        "TCOD_BKGND_MULTIPLY",
        "TCOD_BKGND_LIGHTEN",
        "TCOD_BKGND_DARKEN",
        "TCOD_BKGND_SCREEN",
        "TCOD_BKGND_COLOR_DODGE",
        "TCOD_BKGND_COLOR_BURN",
        "TCOD_BKGND_ADD",
        "TCOD_BKGND_ADDALPHA",
        "TCOD_BKGND_BURN",
        "TCOD_BKGND_OVERLAY",
        "TCOD_BKGND_ALPHA"];

    public:

    this()
    {
        bk = TCOD_console_new(SAMPLE_SCREEN_WIDTH, SAMPLE_SCREEN_HEIGHT);
        // Initialise the coloured background.
        for (int x = 0; x < SAMPLE_SCREEN_WIDTH; x++) {
            for (int y = 0; y < SAMPLE_SCREEN_HEIGHT; y++) {
                TCOD_color_t col;
                col.r = cast(ubyte)(x * 255 / (SAMPLE_SCREEN_WIDTH - 1));
                col.g = cast(ubyte)((x + y) * 255 / (SAMPLE_SCREEN_WIDTH - 1 +
                                                     SAMPLE_SCREEN_HEIGHT));
                col.b = cast(ubyte)((y * 255 / (SAMPLE_SCREEN_HEIGHT - 1)));
                TCOD_console_set_char_background(bk, x, y, col, TCOD_BKGND_SET);
            }
        }
    }

    string name() { return "  Line drawing       "; }
    void render(bool first, ref TCOD_key_t key, ref TCOD_mouse_t mouse)
    {

        int xo, yo, xd, yd, x, y;  // Segment start, end, and current position.
        float alpha;
        float angle, cos_angle, sin_angle;
        int recty;  /// Gradient vertical position.
        if (key.vk == TCODK_ENTER || key.vk == TCODK_KPENTER) {
            // Switch to the next blending mode.
            bk_flag++;
            if ((bk_flag & 0xff) > TCOD_BKGND_ALPH) bk_flag = TCOD_BKGND_NONE;
        }
        if ((bk_flag & 0xff) > TCOD_BKGND_ALPH) {
            // For the alpha mode, update alpha every frame.
            alpha = (1.0f + cos(TCOD_sys_elapsed_seconds() * 2)) / 2.0f;
            bk_flag = TCOD_BKGND_ALPHA(alpha);
        } else if ((bk_flag & 0xff) == TCOD_BKGND_ADDA) {
            // For the add alpha mode, update alpha every frame.
            alpha = (1.0f + cos(TCOD_sys_elapsed_seconds() * 2)) / 2.0f;
            bk_flag = TCOD_BKGND_ADDALPHA(alpha);
        }

        if (first) {
            TCOD_sys_set_fps(30);
            TCOD_console_set_default_foreground(sample_console, TCOD_white);
        }

        // Blit the background.
        TCOD_console_blit(bk, 0, 0, SAMPLE_SCREEN_WIDTH, SAMPLE_SCREEN_HEIGHT,
                          sample_console, 0, 0, 1.0f, 1.0f);
        // Render the gradient.
        recty = cast(int)((SAMPLE_SCREEN_HEIGHT - 2) * ((1.0f + cos(TCOD_sys_elapsed_seconds()))
                                                        / 2.0f));
        for (x = 0; x < SAMPLE_SCREEN_WIDTH; x++) {
            TCOD_color_t col;
            col.r = cast(ubyte)(x * 255 / SAMPLE_SCREEN_WIDTH);
            col.g = cast(ubyte)(x * 255 / SAMPLE_SCREEN_WIDTH);
            col.b = cast(ubyte)(x * 255 / SAMPLE_SCREEN_WIDTH);
            TCOD_console_set_char_background(sample_console, x, recty, col, bk_flag);
            TCOD_console_set_char_background(sample_console, x, recty + 1, col, bk_flag);
            TCOD_console_set_char_background(sample_console, x, recty + 2, col, bk_flag);
        }

        // Calculate the segment ends.
        angle = TCOD_sys_elapsed_seconds() * 2.0f;
        cos_angle = cos(angle);
        sin_angle = sin(angle);

        xo = cast(int)(SAMPLE_SCREEN_WIDTH / 2 * (1 + cos_angle));
        yo = cast(int)(SAMPLE_SCREEN_HEIGHT / 2 + sin_angle * SAMPLE_SCREEN_WIDTH / 2);
        xd = cast(int)(SAMPLE_SCREEN_WIDTH / 2 * (1 - cos_angle));
        yd = cast(int)(SAMPLE_SCREEN_HEIGHT / 2 - sin_angle * SAMPLE_SCREEN_WIDTH / 2);

        // Render the line.
        TCOD_line(xo, yo, xd, yd, &line_listener);

        // Print the current flag.
        TCOD_console_print(sample_console, 2, 2,
                                "%s (ENTER to change)", toStringz(flag_names[bk_flag & 0xff]));
    }
}

/// =============
/// Noise sample.
/// =============
class NoiseSample : Sample
{
    private:

    enum { PERLIN, SIMPLEX, WAVELET, FBM_PERLIN, TURBULENCE_PERLIN,
            FBM_SIMPLEX, TURBULENCE_SIMPLEX, FBM_WAVELET, TURBULENCE_WAVELET }
    string[] funcName = [
        "1 : perlin noise       ",
        "2 : simplex noise      ",
        "3 : wavelet noise      ",
        "4 : perlin fbm         ",
        "5 : perlin turbulence  ",
        "6 : simplex fbm        ",
        "7 : simplex turbulence ",
        "8 : wavelet fbm        ",
        "9 : wavelet turbulence "];
    int func = PERLIN;
    TCOD_noise_t noise;
    float dx = 0.0f;
    float dy = 0.0f;
    float octaves = 4.0f;
    float hurst = TCOD_NOISE_DEFAULT_HURST;
    float lacunarity = TCOD_NOISE_DEFAULT_LACUNARITY;
    TCOD_image_t img = null;
    float zoom = 3.0f;

    public:

    this()
    {
        noise = TCOD_noise_new(2, hurst, lacunarity, null);
        img = TCOD_image_new(SAMPLE_SCREEN_WIDTH * 2, SAMPLE_SCREEN_HEIGHT * 2);
    }

    string name() { return "  Noise              "; }
    void render(bool first, ref TCOD_key_t key, ref TCOD_mouse_t mouse)
    {
        if (first) {
            TCOD_sys_set_fps(30);
        }
        TCOD_console_clear(sample_console);
        // Texture animation.
        dx += 0.01f;
        dy += 0.01f;

        float* f = cast(float*)malloc(2 * float.sizeof);
        if (!f) {
            exit(1);
        }

        // Render the 2D noise function.
        for (int y = 0; y < 2 * SAMPLE_SCREEN_HEIGHT; y++) {
            for (int x = 0; x < 2 * SAMPLE_SCREEN_WIDTH; x++) {

                ubyte c;
                TCOD_color_t col;
                f[0] = zoom * x / (2 * SAMPLE_SCREEN_WIDTH) + dx;
                f[1] = zoom * y / (2 * SAMPLE_SCREEN_HEIGHT) + dy;
                float value = 0.0f;

                switch (func) {
                    case PERLIN: value = TCOD_noise_get_ex(noise, f,TCOD_NOISE_PERLIN); break;
                    case SIMPLEX: value = TCOD_noise_get_ex(noise, f,TCOD_NOISE_SIMPLEX); break;
                    case WAVELET: value = TCOD_noise_get_ex(noise, f,TCOD_NOISE_WAVELET); break;
                    case FBM_PERLIN: value = TCOD_noise_get_fbm_ex(noise, f, octaves,TCOD_NOISE_PERLIN); break;
                    case TURBULENCE_PERLIN:
                        value = TCOD_noise_get_turbulence_ex(noise, f, octaves,TCOD_NOISE_PERLIN);
                        break;
                    case FBM_SIMPLEX:
                        value = TCOD_noise_get_fbm_ex(noise, f, octaves,TCOD_NOISE_SIMPLEX);
                        break;
                    case TURBULENCE_SIMPLEX:
                        value = TCOD_noise_get_turbulence_ex(noise, f, octaves,TCOD_NOISE_SIMPLEX);
                        break;
                    case FBM_WAVELET:
                        value = TCOD_noise_get_fbm_ex(noise, f, octaves,TCOD_NOISE_WAVELET);
                        break;
                    case TURBULENCE_WAVELET:
                        value = TCOD_noise_get_turbulence_ex(noise, f, octaves,TCOD_NOISE_WAVELET);
                        break;
                    default:
                        assert(false);
                }

                c = cast(ubyte)((value + 1.0f) / 2.0f * 255);
                // Use a blue-ish colour.
                col.r = col.g = cast(ubyte)(c / 2);
                col.b = c;
                TCOD_image_put_pixel(img, x, y, col);
            }
        }

        // Blit the noise image with subcell resolution.
        TCOD_image_blit_2x(img, sample_console, 0, 0, 0, 0, -1, -1);

        free(f);

        // Draw a transparent rectangle.
        TCOD_console_set_default_background(sample_console, TCOD_grey);
        TCOD_console_rect(sample_console, 2, 2, 23,
                          (func <= WAVELET ? 10 : 13), false, TCOD_BKGND_MULTIPLY);

        for (int y = 2; y < 2 + (func <= WAVELET ? 10 : 13); y++) {
            for (int x = 2; x < 2 + 23; x++) {
                TCOD_color_t col = TCOD_console_get_char_foreground(sample_console, x, y);
                col = TCOD_color_multiply(col, TCOD_grey);
                TCOD_console_set_char_foreground(sample_console, x, y, col);
            }
        }

        // Draw the text.
        for (int curfunc = PERLIN; curfunc <= TURBULENCE_WAVELET; curfunc++) {
            if (curfunc == func) {
                TCOD_console_set_default_foreground(sample_console, TCOD_white);
                TCOD_console_set_default_background(sample_console, TCOD_light_blue);
                TCOD_console_print_ex(sample_console, 2, 2 + curfunc, TCOD_BKGND_SET,
                                      TCOD_LEFT, toStringz(funcName[curfunc]));
            } else {
                TCOD_console_set_default_foreground(sample_console, TCOD_grey);
                TCOD_console_print(sample_console, 2, 2 + curfunc,
                                        toStringz(funcName[curfunc]));
            }
        }
        // Draw parameters.
        TCOD_console_set_default_foreground(sample_console, TCOD_white);
        TCOD_console_print(sample_console, 2, 11,
                           "Y/H : zoom (%2.1f)", zoom);
        if (func > WAVELET) {
            TCOD_console_print(sample_console, 2, 12,
                                    "E/D : hurst (%2.1f)", hurst);
            TCOD_console_print(sample_console, 2, 13,
                                    "R/F : lacunarity (%2.1f)", lacunarity);
            TCOD_console_print(sample_console, 2, 14,
                                    "T/G : octaves (%2.1f)", octaves);
        }

        // Handle keypress.
        if (key.vk == TCODK_NONE) return;
        if (key.vk == TCODK_TEXT && key.text[0] != '\0') {
            if (key.text[0] >= '1' && key.text[0] <= '9') {
                // Change the noise function.
                func = key.text[0] - '1';
            } else if (key.text[0] == 'E' || key.text[0] == 'e') {
                // Increase hurst.
                hurst += 0.1f;
                TCOD_noise_delete(noise);
                noise = TCOD_noise_new(2, hurst, lacunarity, null);
            } else if (key.text[0] == 'D' || key.text[0] == 'd') {
                // Decrease hurst.
                hurst -= 0.1f;
                TCOD_noise_delete(noise);
                noise = TCOD_noise_new(2, hurst, lacunarity, null);
            } else if (key.text[0] == 'R' || key.text[0] == 'r') {
                // Increase lacunarity.
                lacunarity += 0.5f;
                TCOD_noise_delete(noise);
                noise = TCOD_noise_new(2, hurst, lacunarity, null);
            } else if (key.text[0] == 'F' || key.text[0] == 'f') {
                // Decrease lacunarity.
                lacunarity -= 0.5f;
                TCOD_noise_delete(noise);
                noise = TCOD_noise_new(2, hurst, lacunarity, null);
            } else if (key.text[0] == 'T' || key.text[0] == 't') {
                // Increase octaves.
                octaves += 0.5f;
            } else if (key.text[0] == 'G' || key.text[0] == 'g') {
                // Decrease octaves.
                octaves -= 0.5f;
            } else if (key.text[0] == 'Y' || key.text[0] == 'y') {
                // Increase zoom.
                zoom += 0.2f;
            } else if (key.text[0] == 'H' || key.text[0] == 'h') {
                // Decrease zoom.
                zoom -= 0.2f;
            }
        }
    }
}

/// ===========
/// FOV Sample.
/// ===========
const float TORCH_RADIUS = 10.0f;
const float SQUARED_TORCH_RADIUS = (TORCH_RADIUS * TORCH_RADIUS);

class FOVSample : Sample
{
    private:

    int px = 20, py = 10;  // Player position.
    bool recompute_fov = true;
    bool torch = false;
    bool light_walls = true;
    TCOD_map_t map = null;
    TCOD_color_t dark_wall = {0, 0, 100};
    TCOD_color_t light_wall = {130, 110, 50};
    TCOD_color_t dark_ground = {50, 50, 150};
    TCOD_color_t light_ground = {200, 180, 50};
    TCOD_noise_t noise;
    int algonum = 0;
    string[] algo_names = [
        "BASIC      ",
        "DIAMOND    ",
        "SHADOW     ",
        "PERMISSIVE0", "PERMISSIVE1", "PERMISSIVE2", "PERMISSIVE3",
        "PERMISSIVE4", "PERMISSIVE5", "PERMISSIVE6", "PERMISSIVE7",
        "PERMISSIVE8", "RESTRICTIVE"];
    float torchx = 0.0f;   /// Torch light position in the Perlin Noise.
    charptr on = null;
    charptr off = null;

    public:

    this()
    {
        map = TCOD_map_new(SAMPLE_SCREEN_WIDTH, SAMPLE_SCREEN_HEIGHT);
        for (int y = 0; y < SAMPLE_SCREEN_HEIGHT; y++) {
            for (int x = 0; x < SAMPLE_SCREEN_WIDTH; x++) {
                if (smap[y][x] == ' ') {  // Ground.
                    TCOD_map_set_properties(map, x, y, true, true);
                } else if (smap[y][x] == '=') {  // Window.
                    TCOD_map_set_properties(map, x, y, true, false);
                }
            }
        }
        noise = TCOD_noise_new(1, 1.0f, 1.0f, null);  // 1D noise for the torch.
        on = toStringz("on ");
        off = toStringz("off");
    }

    void print_text()
    {
        TCOD_console_set_default_foreground(sample_console, TCOD_white);
        TCOD_console_print(sample_console, 1, 0,
                                "IJKL : move around\n"
                                ~ "T : torch fx %s\n"
                                ~ "W : light walls %s\n"
                                ~ "+-: algo %s\n",
                                torch ? on : off,
                                light_walls ? on : off,
                                toStringz(algo_names[algonum]));
        TCOD_console_set_default_foreground(sample_console, TCOD_black);
    }

    string name() { return "  Field of view      "; }
    void render(bool first, ref TCOD_key_t key, ref TCOD_mouse_t mouse)
    {
        // Torch position and intensity variation.
        float dx = 0.0f, dy = 0.0f, di = 0.0f;
        if (first) {
            TCOD_sys_set_fps(30);
            TCOD_console_clear(sample_console);
            print_text();
            TCOD_console_put_char(sample_console, px, py, '@', TCOD_BKGND_NONE);
            for (int y = 0; y < SAMPLE_SCREEN_HEIGHT; y++) {
                for (int x = 0; x < SAMPLE_SCREEN_WIDTH; x++) {
                    if (smap[y][x] == '=') {
                        TCOD_console_put_char(sample_console, x, y, TCOD_CHAR_DHLINE,
                                              TCOD_BKGND_NONE);
                    }
                }
            }
        }
        if (recompute_fov) {
            recompute_fov = false;
            TCOD_map_compute_fov(map, px, py, torch ? cast(int)(TORCH_RADIUS) : 0,
                                 light_walls, cast(TCOD_fov_algorithm_t) algonum);
        }
        if (torch) {
            float tdx;
            torchx += 0.2f;
            tdx = torchx + 20.0f;
            dx = TCOD_noise_get(noise, &tdx) * 1.5f;
            tdx += 30.0f;
            dy = TCOD_noise_get(noise, &tdx) * 1.5f;
            di = 0.2f * TCOD_noise_get(noise, &torchx);
        }
        for (int y = 0; y < SAMPLE_SCREEN_HEIGHT; y++) {
            for (int x = 0; x < SAMPLE_SCREEN_WIDTH; x++) {
                bool visible = TCOD_map_is_in_fov(map, x, y);
                bool wall = smap[y][x] == '#';
                if (!visible) {
                    TCOD_console_set_char_background(sample_console, x, y,
                                          wall ? dark_wall : dark_ground,
                                          TCOD_BKGND_SET);
                } else {
                    if (!torch) {
                        TCOD_console_set_char_background(sample_console, x, y,
                                              wall ? light_wall : light_ground,
                                              TCOD_BKGND_SET);
                    } else {
                        TCOD_color_t base = wall ? dark_wall : dark_ground;
                        TCOD_color_t light = wall ? light_wall : light_ground;
                        // Cell distance to torch (squared).
                        float r = (x - px + dx) * (x - px + dx) +
                                  (y - py + dy) * (y - py + dy);
                        if (r < SQUARED_TORCH_RADIUS) {
                            float l = (SQUARED_TORCH_RADIUS - r) / SQUARED_TORCH_RADIUS + di;
                            l = CLAMP(0.0f, 1.0f, l);
                            base = TCOD_color_lerp(base, light, l);
                        }
                        TCOD_console_set_char_background(sample_console, x, y, base,
                                              TCOD_BKGND_SET);
                    }
                }
            }
        }

        if (key.vk == TCODK_TEXT && key.text[0] != '\0') {
            if (key.text[0] == 'I' || key.text[0] == 'i') {
                if (smap[py - 1][px] == ' ') {
                    TCOD_console_put_char(sample_console, px, py, ' ',
                                        TCOD_BKGND_NONE);
                    py--;
                    TCOD_console_put_char(sample_console, px, py, '@',
                                        TCOD_BKGND_NONE);
                    recompute_fov = true;
                }
            } else if (key.text[0] == 'K' || key.text[0] == 'k') {
                if (smap[py + 1][px] == ' ') {
                    TCOD_console_put_char(sample_console, px, py, ' ',
                                        TCOD_BKGND_NONE);
                    py++;
                    TCOD_console_put_char(sample_console, px, py, '@',
                                        TCOD_BKGND_NONE);
                    recompute_fov = true;
                }
            } else if (key.text[0] == 'J' || key.text[0] == 'j') {
                if (smap[py][px - 1] == ' ') {
                    TCOD_console_put_char(sample_console, px, py, ' ',
                                        TCOD_BKGND_NONE);
                    px--;
                    TCOD_console_put_char(sample_console, px, py, '@',
                                        TCOD_BKGND_NONE);
                    recompute_fov = true;
                }
            } else if (key.text[0] == 'L' || key.text[0] == 'l') {
                if (smap[py][px + 1] == ' ') {
                    TCOD_console_put_char(sample_console, px, py, ' ',
                                        TCOD_BKGND_NONE);
                    px++;
                    TCOD_console_put_char(sample_console, px, py, '@',
                                        TCOD_BKGND_NONE);
                    recompute_fov = true;
                }
            } else if (key.text[0] == 'T' || key.text[0] == 't') {
                torch = !torch;
                print_text();
            } else if (key.text[0] == 'W' || key.text[0] == 'w') {
                light_walls = !light_walls;
                print_text();
                recompute_fov = true;
            } else if (key.text[0] == '+' || key.text[0] == '-') {
                algonum += key.text[0] == '+' ? 1 : -1;
                algonum = CLAMP(0, NB_FOV_ALGORITHMS - 1, algonum);
                print_text();
                recompute_fov = true;
            }
        }
    }
}

/// =============
/// Image sample.
/// =============
class ImageSample : Sample
{
    private:

    TCOD_image_t img = null;
    TCOD_image_t circle = null;
    TCOD_color_t blue = {0, 0, 255};
    TCOD_color_t green = {0, 255, 0};

    public:

    this()
    {
        img = TCOD_image_load("data/img/skull.png");
        TCOD_image_set_key_color(img, TCOD_black);
        circle = TCOD_image_load("data/img/circle.png");
    }

    string name() { return "  Image toolkit      "; }

    void render(bool first, ref TCOD_key_t key, ref TCOD_mouse_t mouse)
    {
        if (first) {
            TCOD_sys_set_fps(30);
        }

        TCOD_console_set_default_background(sample_console, TCOD_black);
        TCOD_console_clear(sample_console);
        float x = SAMPLE_SCREEN_WIDTH / 2 + cos(TCOD_sys_elapsed_seconds()) * 10.0f;
        float y = cast(float)(SAMPLE_SCREEN_HEIGHT / 2);
        float scalex = 0.2f + 1.8f * (1.0f + cos(TCOD_sys_elapsed_seconds() / 2)) / 2.0f;
        float scaley = scalex;
        float angle = TCOD_sys_elapsed_seconds();
        long elapsed = TCOD_sys_elapsed_milli() / 2000;
        if (elapsed & 1) {
            // Split the colour channels of circle.png.
            /*** Red channel. ***/
            TCOD_console_set_default_background(sample_console, TCOD_red);
            TCOD_console_rect(sample_console, 0, 3, 15, 15, false, TCOD_BKGND_SET);
            TCOD_image_blit_rect(circle, sample_console, 0, 3, -1, -1, TCOD_BKGND_MULTIPLY);
            /*** Green channel. ***/
            TCOD_console_set_default_background(sample_console, green);
            TCOD_console_rect(sample_console, 15, 3, 15, 15, false, TCOD_BKGND_SET);
            TCOD_image_blit_rect(circle, sample_console, 15, 3, -1, -1, TCOD_BKGND_MULTIPLY);
            /*** Blue channel. ***/
            TCOD_console_set_default_background(sample_console, blue);
            TCOD_console_rect(sample_console, 30, 3, 15, 15, false, TCOD_BKGND_SET);
            TCOD_image_blit_rect(circle, sample_console, 30, 3, -1, -1, TCOD_BKGND_MULTIPLY);
        } else {
            // Render circle as normal.
            TCOD_image_blit_rect(circle, sample_console, 0, 3, -1, -1, TCOD_BKGND_SET);
            TCOD_image_blit_rect(circle, sample_console, 15, 3, -1, -1, TCOD_BKGND_SET);
            TCOD_image_blit_rect(circle, sample_console, 30, 3, -1, -1, TCOD_BKGND_SET);
        }
        TCOD_image_blit(img, sample_console, x, y,
                        TCOD_BKGND_SET, scalex, scaley, angle);
    }
}

/// =============
/// Mouse sample.
/// =============
class MouseSample : Sample
{
    private:

    bool lbut = false;
    bool rbut = false;
    bool mbut = false;
    charptr on = null;
    charptr off = null;

    public:

    this()
    {
        /* Once a string literal has gone through a ternary, passing
         * it to C makes Bad Things happen.
         */
        on = toStringz(" ON");
        off = toStringz("OFF");
    }
    string name() { return "  Mouse support      "; }
    void render(bool first, ref TCOD_key_t key, ref TCOD_mouse_t mouse)
    {
        if (first) {
            TCOD_console_set_default_background(sample_console, TCOD_grey);
            TCOD_console_set_default_foreground(sample_console, TCOD_light_yellow);
            TCOD_mouse_move(320, 200);
            TCOD_mouse_show_cursor(true);
            TCOD_sys_set_fps(30);
        }

        TCOD_console_clear(sample_console);
        if (mouse.lbutton_pressed) lbut = !lbut;
        if (mouse.rbutton_pressed) rbut = !rbut;
        if (mouse.mbutton_pressed) mbut = !mbut;

        TCOD_console_print(sample_console, 1, 1,
                                "%s\n"
                                ~ "Mouse position : %4dx%4d %s\n"
                                ~ "Mouse cell     : %4dx%4d\n"
                                ~ "Mouse movement : %4dx%4d\n"
                                ~ "Left button    : %s (toggle %s)\n"
                                ~ "Right button   : %s (toggle %s)\n"
                                ~ "Middle button  : %s (toggle %s)\n",
                                TCOD_console_is_active() ? "" : toStringz("APPLICATION INACTIVE"),
                                mouse.x, mouse.y, TCOD_console_has_mouse_focus() ? "" : toStringz("OUT OF FOCUS"),
                                mouse.cx, mouse.cy,
                                mouse.dx, mouse.dy,
                                mouse.lbutton ? on : off, lbut ? on : off,
                                mouse.rbutton ? on : off, rbut ? on : off,
                                mouse.mbutton ? on : off, mbut ? on : off);
        TCOD_console_print(sample_console, 1, 10,
                               "1 : Hide cursor\n2 : Show cursor");
        if (key.vk == TCODK_TEXT && key.text[0] != '\0') {
            if (key.text[0] == '1') TCOD_mouse_show_cursor(false);
            else if (key.text[0] == '2') TCOD_mouse_show_cursor(true);
        }
    }
}

/// ============
/// Path sample.
/// ============

class PathSample : Sample
{
    private:

    int px = 20, py = 10;  // Player position.
    int dx = 24, dy = 1;   // Player destination.
    TCOD_map_t map = null;
    TCOD_color_t dark_wall = {0, 0, 100};
    TCOD_color_t dark_ground = {50, 50, 150};
    TCOD_color_t light_ground = {200, 180, 50};
    TCOD_path_t path = null;
    bool usingAstar = true;
    float dijkstraDist = 0.0;
    TCOD_dijkstra_t dijkstra = null;
    bool recalculatePath = false;
    float busy = 0.0f;
    int oldChar = ' ';

    public:

    this()
    {
        map = TCOD_map_new(SAMPLE_SCREEN_WIDTH, SAMPLE_SCREEN_HEIGHT);
        for (int y = 0; y < SAMPLE_SCREEN_HEIGHT; y++) {
            for (int x = 0; x < SAMPLE_SCREEN_WIDTH; x++) {
                if (smap[y][x] == ' ') {  // Ground.
                    TCOD_map_set_properties(map, x, y, true, true);
                } else if (smap[y][x] == '=') {  // Window.
                    TCOD_map_set_properties(map, x, y, true, false);
                }
            }
        }
        path = TCOD_path_new_using_map(map, 1.41f);
        dijkstra = TCOD_dijkstra_new(map, 1.41f);
    }

    string name() { return "  Path finding       "; }
    void render(bool first, ref TCOD_key_t key, ref TCOD_mouse_t mouse)
    {
        if (first) {
            TCOD_sys_set_fps(30);
            /*
             * We draw the foreground only the first time.
             * During player movement, only the @ is redrawn.
             * The rest impacts only the background colour.
             */
            // Draw the help text and the player '@'.
            TCOD_console_clear(sample_console);
            TCOD_console_set_default_foreground(sample_console, TCOD_white);
            TCOD_console_put_char(sample_console, dx, dy, '+', TCOD_BKGND_NONE);
            TCOD_console_put_char(sample_console, px, py, '@', TCOD_BKGND_NONE);
            TCOD_console_print(sample_console, 1, 1,
                                    "IJKL / mouse :\nmove destination\nTAB : A*/dijkstra");
            TCOD_console_print(sample_console, 1, 4, "Using : A*");
            for (int y = 0; y < SAMPLE_SCREEN_HEIGHT; y++) {
                for (int x = 0; x < SAMPLE_SCREEN_WIDTH; x++) {
                    if (smap[y][x] == '=') {
                        TCOD_console_put_char(sample_console, x, y,
                                              TCOD_CHAR_DHLINE, TCOD_BKGND_NONE);
                    }
                }
            }

            recalculatePath = true;
        }
        int x, y;
        if (recalculatePath) {
            if (usingAstar) {
                TCOD_path_compute(path, px, py, dx, dy);
            } else {
                dijkstraDist = 0.0f;
                // Compute the distance grid.
                TCOD_dijkstra_compute(dijkstra, px, py);
                for (y = 0; y < SAMPLE_SCREEN_HEIGHT; y++) {
                    for (x = 0; x < SAMPLE_SCREEN_WIDTH; x++) {
                        float d = TCOD_dijkstra_get_distance(dijkstra, x, y);
                        if (d > dijkstraDist) dijkstraDist = d;
                    }
                }
                // Compute the path.
                TCOD_dijkstra_path_set(dijkstra, dx, dy);
            }
            recalculatePath = false;
            busy = 0.2f;
        }
        // Draw the dungeon.
        for (y = 0; y < SAMPLE_SCREEN_HEIGHT; y++) {
            for (x = 0; x < SAMPLE_SCREEN_WIDTH; x++) {
                bool wall = smap[y][x] == '#';
                TCOD_console_set_char_background(sample_console, x, y,
                                      wall ? dark_wall : dark_ground,
                                      TCOD_BKGND_SET);
            }
        }

        // Draw the path.
        if (usingAstar) {
            for (int i = 0; i < TCOD_path_size(path); i++) {
                int tmpx, tmpy;
                TCOD_path_get(path, i, &tmpx, &tmpy);
                TCOD_console_set_char_background(sample_console, tmpx, tmpy, light_ground,
                                      TCOD_BKGND_SET);
            }
        } else {
            for (y = 0; y < SAMPLE_SCREEN_HEIGHT; y++) {
                for (x = 0; x < SAMPLE_SCREEN_WIDTH; x++) {
                    bool wall = smap[y][x] == '#';
                    if (!wall) {
                        float d = TCOD_dijkstra_get_distance(dijkstra, x, y);
                        TCOD_console_set_char_background(sample_console, x, y, TCOD_color_lerp(light_ground, dark_ground, 0.9f * d / dijkstraDist), TCOD_BKGND_SET);
                    }
                }
            }
            for (int i = 0; i < TCOD_dijkstra_size(dijkstra); i++) {
                TCOD_dijkstra_get(dijkstra, i, &x, &y);
                TCOD_console_set_char_background(sample_console, x, y, light_ground, TCOD_BKGND_SET);
            }
        }

        // Move the creature.
        busy -= TCOD_sys_get_last_frame_length();
        if (busy <= 0.0f) {
            busy += 0.2f;
            if (usingAstar) {
                if (!TCOD_path_is_empty(path)) {
                    TCOD_console_put_char(sample_console, px, py, ' ', TCOD_BKGND_NONE);
                    TCOD_path_walk(path, &px, &py, true);
                    TCOD_console_put_char(sample_console, px, py, '@', TCOD_BKGND_NONE);
                }
            } else {
                if (!TCOD_dijkstra_is_empty(dijkstra)) {
                    TCOD_console_put_char(sample_console, px, py, ' ', TCOD_BKGND_NONE);
                    TCOD_dijkstra_path_walk(dijkstra, &px, &py);
                    TCOD_console_put_char(sample_console, px, py, '@', TCOD_BKGND_NONE);
                    recalculatePath = true;
                }
            }
        }

        void destMoved()
        {
            oldChar = TCOD_console_get_char(sample_console, dx, dy);
            TCOD_console_put_char(sample_console, dx, dy, '+', TCOD_BKGND_NONE);
            if (smap[dy][dx] == ' ') {
                recalculatePath = true;
            }
        }

        if (key.vk == TCODK_TAB) {
            usingAstar = !usingAstar;
            if (usingAstar)
                TCOD_console_print(sample_console, 1, 4, "Using : A*      ");
            else
                TCOD_console_print(sample_console, 1, 4, "Using : Dijkstra");
            recalculatePath = true;
        } else if (key.vk == TCODK_TEXT && key.text[0] != '\0') {
            if ((key.text[0] == 'I' || key.text[0] == 'i') && dy > 0) {
                // North.
                TCOD_console_put_char(sample_console, dx, dy, oldChar, TCOD_BKGND_NONE);
                dy--;
                destMoved();
            } else if ((key.text[0] == 'K' || key.text[0] == 'k') && dy < SAMPLE_SCREEN_HEIGHT - 1) {
                // South.
                TCOD_console_put_char(sample_console, dx, dy, oldChar, TCOD_BKGND_NONE);
                dy++;
                destMoved();
            } else if ((key.text[0] == 'J' || key.text[0] == 'j') && dx > 0) {
                // West.
                TCOD_console_put_char(sample_console, dx, dy, oldChar, TCOD_BKGND_NONE);
                dx--;
                destMoved();
            } else if ((key.text[0] == 'L' || key.text[0] == 'l') && dx < SAMPLE_SCREEN_WIDTH - 1) {
                // East.
                TCOD_console_put_char(sample_console, dx, dy, oldChar, TCOD_BKGND_NONE);
                dx++;
                destMoved();
            }
        }

        int mx = mouse.cx - SAMPLE_SCREEN_X;
        int my = mouse.cy - SAMPLE_SCREEN_Y;
        if (mx >= 0 && mx < SAMPLE_SCREEN_WIDTH &&
            my >= 0 && my < SAMPLE_SCREEN_HEIGHT &&
            (dx != mx || dy != my)) {
            TCOD_console_put_char(sample_console, dx, dy, oldChar, TCOD_BKGND_NONE);
            dx = mx; dy = my;
            destMoved();
        }
    }
}

/// ===========
/// BSP sample.
/// ===========
const byte FLOOR = 0;
const byte WALL = 1;
static bool randomRoom = false;
static bool roomWalls = true;
static int minRoomSize = 4;

/// Draw a vertical line.
void vline(ubyte* map, int x, int y1, int y2)
{
    int y = y1;
    int dy = (y1 > y2 ? -1 : 1);
    map[index(x, y)] = FLOOR;
    if (y1 == y2) return;
    do {
        y += dy;
        map[index(x, y)] = FLOOR;
    } while (y != y2);
}

/// Draw a vertical line up until we hit an empty space.
void vline_up(ubyte* map, int x, int y)
{
    while (y >= 0 && map[index(x, y)] != FLOOR) {
        map[index(x, y)] = FLOOR;
        y--;
    }
}

/// Draw a vertical line down until we hit an empty space.
void vline_down(ubyte* map, int x, int y)
{
    while (y < SAMPLE_SCREEN_HEIGHT && map[index(x, y)] != FLOOR) {
        map[index(x, y)] = FLOOR;
        y++;
    }
}

/// Draw a horizontal line.
void hline(ubyte* map, int x1, int y, int x2)
{
    int x = x1;
    int dx = (x1 > x2 ? -1 : 1);
    map[index(x, y)] = FLOOR;
    if (x1 == x2) return;
    do {
        x += dx;
        map[index(x, y)] = FLOOR;
    } while (x != x2);
}

/// Draw a horizontal line up until we hit an empty space.
void hline_left(ubyte* map, int x, int y)
{
    while (x >= 0 && map[index(x, y)] != FLOOR) {
        map[index(x, y)] = FLOOR;
        x--;
    }
}

/// Draw a horizontal line down until we hit an empty space.
void hline_right(ubyte* map, int x, int y)
{
    while (x < SAMPLE_SCREEN_WIDTH && map[index(x, y)] != FLOOR) {
        map[index(x, y)] = FLOOR;
        x++;
    }
}

extern (C) bool traverse_node(TCOD_bsp_t* node, void* userData)
in
{
    assert(userData);
}
body
{
    ubyte* map = cast(ubyte*)userData;

    if (TCOD_bsp_is_leaf(node)) {
        int minx = node.x + 1;
        int maxx = node.x + node.w - 1;
        int miny = node.y + 1;
        int maxy = node.y + node.h - 1;
        if (!roomWalls) {
            if (minx > 1) minx--;
            if (miny > 1) miny--;
        }
        if (maxx == SAMPLE_SCREEN_WIDTH - 1) maxx--;
        if (maxy == SAMPLE_SCREEN_HEIGHT - 1) maxy--;
        if (randomRoom) {
            // Might as well check that TCOD's generator works...
            minx = TCOD_random_get_int(null,minx,maxx-minRoomSize+1);
            miny = TCOD_random_get_int(null,miny,maxy-minRoomSize+1);
            maxx = TCOD_random_get_int(null,minx+minRoomSize-1,maxx);
            maxy = TCOD_random_get_int(null,miny+minRoomSize-1,maxy);
        }
        // Resize the node to fit the room.
        node.x = minx;
        node.y = miny;
        node.w = maxx - minx + 1;
        node.h = maxy - miny + 1;
        // Dig the room.
        for (int x = minx; x <= maxx; x++) {
            for (int y = miny; y <= maxy; y++) {
                map[index(x, y)] = FLOOR;
            }
        }
    } else {
        // Resize the node to fit its sons.
        TCOD_bsp_t* left = TCOD_bsp_left(node);
        TCOD_bsp_t* right = TCOD_bsp_right(node);
        node.x = MIN(left.x, right.x);
        node.y = MIN(left.y, right.y);
        node.w = MAX(left.x + left.w, right.x + right.w) - node.x;
        node.h = MAX(left.x + left.h, right.y + right.h) - node.y;
        // Create a corridor between the two lower nodes.
        if (node.horizontal) {  // Vertical corridor.
            if (left.x + left.w - 1 < right.x || right.x + right.w - 1 < left.x) {
                // NO OVERLAPPING ZONES.
                int x1 = TCOD_random_get_int(null, left.x, (left.x + left.w - 1));
                int x2 = TCOD_random_get_int(null, right.x, (right.x + right.w - 1));
                int y  = TCOD_random_get_int(null, left.y + left.h, right.y);
                vline_up(map, x1, y - 1);
                hline(map, x1, y, x2);
                vline_down(map, x2, y + 1);
            } else {
                int minx = MAX(left.x, right.x);
                int maxx = MIN(left.x + left.w - 1, right.x + right.w - 1);
                int x = TCOD_random_get_int(null, minx, maxx);
                vline_down(map, x, right.y);
                vline_up(map, x, right.y - 1);
            }
        } else {  // Horizontal corridor.
            // horizontal corridor
            if ( left.y+left.h -1 < right.y || right.y+right.h-1 < left.y ) {
                // no overlapping zone. we need a Z shaped corridor
                int y1=TCOD_random_get_int(null,left.y,left.y+left.h-1);
                int y2=TCOD_random_get_int(null,right.y,right.y+right.h-1);
                int x=TCOD_random_get_int(null,left.x+left.w,right.x);
                hline_left(map,x-1,y1);
                vline(map,x,y1,y2);
                hline_right(map,x+1,y2);
            } else {
                // straight horizontal corridor
                int miny= MAX(left.y,right.y);
                int maxy= MIN(left.y+left.h-1,right.y+right.h-1);
                int y=TCOD_random_get_int(null,miny,maxy);
                hline_left(map,right.x-1,y);
                hline_right(map,right.x,y);
            }
        }
    }

    return true;
}

/// Returns an index to the map for the given coords.
int index(int x, int y)
in
{
//    assert(x >= 0 && x <= SAMPLE_SCREEN_WIDTH);
//    assert(y >= 0 && y <= SAMPLE_SCREEN_HEIGHT);
}
out(result)
{
//    assert(result >= 0 && result < SAMPLE_SCREEN_WIDTH * SAMPLE_SCREEN_HEIGHT);
}
body
{
    return (y * SAMPLE_SCREEN_WIDTH) + x;
}

class BSPSample : Sample
{
    private:

    TCOD_bsp_t* bsp = null;
    bool generate = true;
    bool refresh = false;
    TCOD_color_t darkWall = {0, 0, 100};
    TCOD_color_t darkGround = {50, 50, 150};
    int bspDepth = 8;
    charptr on = null;
    charptr off = null;

    ubyte[SAMPLE_SCREEN_WIDTH * SAMPLE_SCREEN_HEIGHT] map = void;

    public:

    this()
    {
        on = toStringz("ON ");
        off = toStringz("OFF");
    }

    string name() { return "  Bsp toolkit        "; }
    void render(bool first, ref TCOD_key_t key, ref TCOD_mouse_t mouse)
    {
        if (generate || refresh) {
            if (!bsp) {
                bsp = TCOD_bsp_new_with_size(0, 0, SAMPLE_SCREEN_WIDTH, SAMPLE_SCREEN_HEIGHT);
            } else {
                // Restore the node's size.
                TCOD_bsp_resize(bsp, 0, 0, SAMPLE_SCREEN_WIDTH, SAMPLE_SCREEN_HEIGHT);
            }
            map[] = WALL;
            if (generate) {
                // Build a new random BSP tree.
                TCOD_bsp_remove_sons(bsp);
                TCOD_bsp_split_recursive(bsp, null, bspDepth,
                                         minRoomSize + (roomWalls ? 1 : 0),
                                         minRoomSize + (roomWalls ? 1 : 0),
                                         1.5f, 1.5f);
            }
            // Create the dungeon from the BSP.
            TCOD_bsp_traverse_inverted_level_order(bsp, &traverse_node, cast(void*)&map);
            generate = false;
            refresh = false;
        }
        TCOD_console_clear(sample_console);
        TCOD_console_set_default_foreground(sample_console, TCOD_white);
        TCOD_console_print(sample_console, 1, 1,
                                "ENTER : rebuild bsp\n"
                                ~ "SPACE : rebuild dungeon\n"
                                ~ "+-: bsp depth %d\n"
                                ~ "*/: room size %d\n"
                                ~ "1: random room size %s",
                                bspDepth, minRoomSize,
                                randomRoom ? on : off);
        if (randomRoom) {
            TCOD_console_print(sample_console, 1, 6,
                               "2 : room walls %s", roomWalls ? on : off);
        }
        // Render the level.
        for (int y = 0; y < SAMPLE_SCREEN_HEIGHT; y++) {
            for (int x = 0; x < SAMPLE_SCREEN_WIDTH; x++) {
                bool wall = (map[index(x, y)] == WALL);
                TCOD_console_set_char_background(sample_console, x, y, wall ? darkWall : darkGround,
                                      TCOD_BKGND_SET);
            }
        }
        if (key.vk == TCODK_ENTER || key.vk == TCODK_KPENTER) {
            generate = true;
        } else if (key.vk == TCODK_TEXT && key.text[0] != '\0') {
            if (key.text[0] == ' ') {
                refresh = true;
            } else if (key.text[0] == '+') {
                bspDepth++;
                generate = true;
            } else if (key.text[0] == '-' && bspDepth > 1) {
                bspDepth--;
                generate = true;
            } else if (key.text[0] == '*') {
                minRoomSize++;
                generate = true;
            } else if (key.text[0] == '/' && minRoomSize > 2) {
                minRoomSize--;
                generate = true;
            } else if (key.text[0] == '1' || key.vk == TCODK_1 || key.vk == TCODK_KP1) {
                randomRoom = !randomRoom;
                if (!randomRoom) roomWalls = true;
                refresh = true;
            } else if (key.text[0] == '2' || key.vk == TCODK_2 || key.vk == TCODK_KP2) {
                roomWalls = !roomWalls;
                refresh = true;
            }
        }
    }
}


// ---------------------
// Name Generator Sample
// ---------------------

class NameGeneratorSample : Sample
{
    private:

    int nbSets;
    int curSet = 0;
    float delay = 0.0f;
    TCOD_list_t sets = null;
    TCOD_list_t names = null;

    public:

    string name() { return "  Name generator     "; }

    this()
    {
        TCOD_list_t files;
        char **it;
        names = TCOD_list_new();
        files = TCOD_sys_get_directory_content("data/namegen", "*.cfg");
        // Parse all the files.
        for (it = cast(char **) TCOD_list_begin(files); it != cast(char **) TCOD_list_end(files); it++) {
            char* tmp;
            tmp = cast(char*) malloc(236);
            assert(tmp);
            sprintf(tmp, "data/namegen/%s", *it);
            TCOD_namegen_parse(tmp, null);
            free(tmp);
        }
        // Get the sets list.
        sets = TCOD_namegen_get_sets();
        nbSets = TCOD_list_size(sets);
    }

    void render(bool first, ref TCOD_key_t key, ref TCOD_mouse_t mouse)
    {
        if (first) {
            TCOD_sys_set_fps(30);  // Limited to 30 FPS.
        }

        while (TCOD_list_size(names) >= 15) {
            TCOD_list_remove_iterator(names, TCOD_list_begin(names));
        }

        TCOD_console_clear(sample_console);
        TCOD_console_set_default_foreground(sample_console, TCOD_white);
        if (TCOD_list_size(sets) > 0) {
            TCOD_console_print(sample_console, 1, 1, "%s\n\n+ : next generator\n- : prev generator", cast(charptr)TCOD_list_get(sets, curSet));
            for (int i = 0; i < TCOD_list_size(names); i++) {
                charptr name = cast(charptr) TCOD_list_get(names, i);
                if (strlen(name) < SAMPLE_SCREEN_WIDTH) {
                    TCOD_console_print_ex(sample_console, SAMPLE_SCREEN_WIDTH -2, 2 + i, TCOD_BKGND_NONE, TCOD_RIGHT, name);
                }
            }

            delay += TCOD_sys_get_last_frame_length();
            if (delay >= 0.5f) {
                delay -= 0.5f;
                // Add a new name to the list.
                TCOD_list_push(names, cast(void*) TCOD_namegen_generate(cast(charptr)TCOD_list_get(sets, curSet), true));
            }
            if (key.vk == TCODK_TEXT && key.text[0] != '\0') {
                if (key.text[0] == '+') {
                    curSet++;
                    if (curSet == nbSets) curSet = 0;
                    TCOD_list_push(names, cast(void*) "======".dup);
                } else if (key.text[0] == '-') {
                    curSet--;
                    if (curSet < 0) curSet = nbSets - 1;
                    TCOD_list_push(names, cast(void*) "======".dup);
                }
            }
        } else {
            TCOD_console_print(sample_console, 1, 1, "Unable to find name config data files.");
        }
    }
}


// -------------------
// SDL Callback Sample
// -------------------
TCOD_noise_t noise = null;
bool sdl_callback_enabled = false;
int effectNum = 0;
float delay = 3.0f;

void burn(SDL_Surface *screen, int samplex, int sampley, int samplew, int sampleh) {
    int ridx=screen.format.Rshift/8;
    int gidx=screen.format.Gshift/8;
    int bidx=screen.format.Bshift/8;
    int x,y;
    for (x=samplex; x < samplex + samplew; x ++ ) {
        Uint8 *p = cast(Uint8 *)screen.pixels + x * screen.format.BytesPerPixel + sampley * screen.pitch;
        for (y=sampley; y < sampley + sampleh; y ++ ) {
            int ir=0,ig=0,ib=0;
            Uint8 *p2 = p + screen.format.BytesPerPixel; // get pixel at x+1,y
            ir += p2[ridx];
            ig += p2[gidx];
            ib += p2[bidx];
            p2 -= 2*screen.format.BytesPerPixel; // get pixel at x-1,y
            ir += p2[ridx];
            ig += p2[gidx];
            ib += p2[bidx];
            p2 += screen.format.BytesPerPixel+ screen.pitch; // get pixel at x,y+1
            ir += p2[ridx];
            ig += p2[gidx];
            ib += p2[bidx];
            p2 -= 2*screen.pitch; // get pixel at x,y-1
            ir += p2[ridx];
            ig += p2[gidx];
            ib += p2[bidx];
            ir/=4;
            ig/=4;
            ib/=4;
            p[ridx]=cast(ubyte)ir;
            p[gidx]=cast(ubyte)ig;
            p[bidx]=cast(ubyte)ib;
            p += screen.pitch;
        }
    }
}

void explode(SDL_Surface *screen, int samplex, int sampley, int samplew, int sampleh) {
    int ridx=screen.format.Rshift/8;
    int gidx=screen.format.Gshift/8;
    int bidx=screen.format.Bshift/8;
    int dist=cast(int)(10*(3.0f - delay));
    int x,y;
    for (x=samplex; x < samplex + samplew; x ++ ) {
        Uint8 *p = cast(Uint8 *)screen.pixels + x * screen.format.BytesPerPixel + sampley * screen.pitch;
        for (y=sampley; y < sampley + sampleh; y ++ ) {
            int ir=0,ig=0,ib=0,i;
            for (i=0; i < 3; i++) {
                int dx = TCOD_random_get_int(null,-dist,dist);
                int dy = TCOD_random_get_int(null,-dist,dist);
                Uint8 *p2;
                p2 = p + dx * screen.format.BytesPerPixel;
                p2 += dy * screen.pitch;
                ir += p2[ridx];
                ig += p2[gidx];
                ib += p2[bidx];
            }
            ir/=3;
            ig/=3;
            ib/=3;
            p[ridx]=cast(ubyte)ir;
            p[gidx]=cast(ubyte)ig;
            p[bidx]=cast(ubyte)ib;
            p += screen.pitch;
        }
    }
}

void blur(SDL_Surface *screen, int samplex, int sampley, int samplew, int sampleh) {
    // let's blur that sample console
    float[3] f;
        float n=0.0f;
    int ridx=screen.format.Rshift/8;
    int gidx=screen.format.Gshift/8;
    int bidx=screen.format.Bshift/8;
    int x,y;
    f[2]=TCOD_sys_elapsed_seconds();
    if ( noise == null ) noise=TCOD_noise_new(3, TCOD_NOISE_DEFAULT_HURST, TCOD_NOISE_DEFAULT_LACUNARITY, null);
    for (x=samplex; x < samplex + samplew; x ++ ) {
        Uint8 *p = cast(Uint8 *)screen.pixels + x * screen.format.BytesPerPixel + sampley * screen.pitch;
        f[0]=cast(float)(x)/samplew;
        for (y=sampley; y < sampley + sampleh; y ++ ) {
            int ir=0,ig=0,ib=0,dec, count;
            if ( (y-sampley)%8 == 0 ) {
                f[1]=cast(float)(y)/sampleh;
                n=TCOD_noise_get_fbm(noise,cast(float*)f,3.0f);
            }
            dec = cast(int)(3*(n+1.0f));
            count=0;
            switch(dec) {
                case 4:
                    count += 4;
                    // get pixel at x,y
                    ir += p[ridx];
                    ig += p[gidx];
                    ib += p[bidx];
                    p -= 2*screen.format.BytesPerPixel; // get pixel at x+2,y
                    ir += p[ridx];
                    ig += p[gidx];
                    ib += p[bidx];
                    p -= 2*screen.pitch; // get pixel at x+2,y+2
                    ir += p[ridx];
                    ig += p[gidx];
                    ib += p[bidx];
                    p+= 2*screen.format.BytesPerPixel; // get pixel at x,y+2
                    ir += p[ridx];
                    ig += p[gidx];
                    ib += p[bidx];
                    p += 2*screen.pitch;
                    goto case 3;
                case 3:
                    count += 4;
                    // get pixel at x,y
                    ir += p[ridx];
                    ig += p[gidx];
                    ib += p[bidx];
                    p += 2*screen.format.BytesPerPixel; // get pixel at x+2,y
                    ir += p[ridx];
                    ig += p[gidx];
                    ib += p[bidx];
                    p += 2*screen.pitch; // get pixel at x+2,y+2
                    ir += p[ridx];
                    ig += p[gidx];
                    ib += p[bidx];
                    p-= 2*screen.format.BytesPerPixel; // get pixel at x,y+2
                    ir += p[ridx];
                    ig += p[gidx];
                    ib += p[bidx];
                    p -= 2*screen.pitch;
                    goto case 2;
                case 2:
                    count += 4;
                    // get pixel at x,y
                    ir += p[ridx];
                    ig += p[gidx];
                    ib += p[bidx];
                    p -= screen.format.BytesPerPixel; // get pixel at x-1,y
                    ir += p[ridx];
                    ig += p[gidx];
                    ib += p[bidx];
                    p -= screen.pitch; // get pixel at x-1,y-1
                    ir += p[ridx];
                    ig += p[gidx];
                    ib += p[bidx];
                    p+= screen.format.BytesPerPixel; // get pixel at x,y-1
                    ir += p[ridx];
                    ig += p[gidx];
                    ib += p[bidx];
                    p += screen.pitch;
                    goto case 1;
                case 1:
                    count += 4;
                    // get pixel at x,y
                    ir += p[ridx];
                    ig += p[gidx];
                    ib += p[bidx];
                    p += screen.format.BytesPerPixel; // get pixel at x+1,y
                    ir += p[ridx];
                    ig += p[gidx];
                    ib += p[bidx];
                    p += screen.pitch; // get pixel at x+1,y+1
                    ir += p[ridx];
                    ig += p[gidx];
                    ib += p[bidx];
                    p-= screen.format.BytesPerPixel; // get pixel at x,y+1
                    ir += p[ridx];
                    ig += p[gidx];
                    ib += p[bidx];
                    p -= screen.pitch;
                    ir/=count;
                    ig/=count;
                    ib/=count;
                    p[ridx]=cast(ubyte)ir;
                    p[gidx]=cast(ubyte)ig;
                    p[bidx]=cast(ubyte)ib;
                break;
                default:break;
            }
            p += screen.pitch;
        }
    }
}

extern(C) void SDL_render(void *sdlSurface) {
    SDL_Surface *screen = cast(SDL_Surface *)sdlSurface;
    // now we have almighty access to the screen's precious pixels !!
    // get the font character size
    int charw,charh,samplex,sampley;
    TCOD_sys_get_char_size(&charw,&charh);
    // compute the sample console position in pixels
    samplex = SAMPLE_SCREEN_X * charw;
    sampley = SAMPLE_SCREEN_Y * charh;
    delay -= TCOD_sys_get_last_frame_length();
    if ( delay < 0.0f ) {
        delay = 3.0f;
        effectNum = (effectNum + 1) % 3;
        if ( effectNum == 2 ) sdl_callback_enabled=false; // no forced redraw for burn effect
        else sdl_callback_enabled=true;
    }
    switch(effectNum) {
        case 0 : blur(screen,samplex,sampley,SAMPLE_SCREEN_WIDTH * charw,SAMPLE_SCREEN_HEIGHT * charh); break;
        case 1 : explode(screen,samplex,sampley,SAMPLE_SCREEN_WIDTH * charw,SAMPLE_SCREEN_HEIGHT * charh); break;
        case 2 : burn(screen,samplex,sampley,SAMPLE_SCREEN_WIDTH * charw,SAMPLE_SCREEN_HEIGHT * charh); break;
                default: assert(false);
    }
}


class SDLCallbackSample : Sample
{
    string name() { return "  SDL callback       "; }

    void render(bool first, ref TCOD_key_t key, ref TCOD_mouse_t mouse)
    {
        if (first) {
            TCOD_sys_set_fps(30);  // Limited to 30 FPS.
            // Use noise sample as background. Rendering is done in SampleRenderer.
            TCOD_console_set_default_background(sample_console, TCOD_light_blue);
            TCOD_console_set_default_foreground(sample_console, TCOD_white);
            TCOD_console_clear(sample_console);
            TCOD_console_print_rect_ex(sample_console, SAMPLE_SCREEN_WIDTH / 2, 3, SAMPLE_SCREEN_WIDTH, 0, TCOD_BKGND_NONE, TCOD_CENTER,
                "The SDL callback gives you access to the screen surface so that you can alter the pixels one by one using the SDL API or any API on top of SDL. SDL is used here to blur the sample console.\n\nHit TAB to enable/disable the callback. While enabled, it will be active on other samples too.");
        }
        if (key.vk == TCODK_TAB) {
            sdl_callback_enabled = !sdl_callback_enabled;
            if (sdl_callback_enabled) {
                TCOD_sys_register_SDL_renderer(&SDL_render);
            } else {
                TCOD_sys_register_SDL_renderer(null);
                // We want libtcod to redraw the sample console even if nothing has changed in it.
                TCOD_console_set_dirty(SAMPLE_SCREEN_X, SAMPLE_SCREEN_Y, SAMPLE_SCREEN_WIDTH, SAMPLE_SCREEN_HEIGHT);
            }
        }
    }
}

void main(string[] args)
{
    size_t cur_sample = 0;  // Index of the current sample.
    bool first = true;  // First time we render a sample.
    string font = "data/fonts/consolas10x10_gs_tc.png";
    int font_flags = TCOD_FONT_TYPE_GREYSCALE | TCOD_FONT_LAYOUT_TCOD;
    int font_new_flags = 0;
    int nb_char_horiz = 0, nb_char_vertic = 0;
    TCOD_key_t key = {TCODK_NONE, 0};
    TCOD_mouse_t mouse;
    int fullscreen_width = 0;
    int fullscreen_height = 0;
    bool fullscreen = false;
    bool credits_end = false;

    for (int argn = 1; argn < args.length; argn++) {
        // We match -font-nb-char behaviour to the C samples, so we don't use std.getopt.
        if (args[argn] == "-help") {
            usage();
            return;
        } else if (args[argn] == "-font" && (argn + 1) < args.length) {
            argn++;
            font = args[argn];
            font_flags = 0;
        } else if (args[argn] == "-font-nb-char" && argn + 2 < args.length) {
            try {
                nb_char_horiz = parse!(int)(args[++argn]);
                nb_char_vertic = parse!(int)(args[++argn]);
            } catch (ConvException e) {
                nb_char_horiz = 0;
                nb_char_vertic = 0;
            }
        } else if (args[argn] == "-fullscreen") {
            fullscreen = true;
        } else if (args[argn] == "-fullscreen-resolution" && argn + 2 < args.length) {
            try {
                fullscreen_width = parse!(int)(args[++argn]);
                fullscreen_height = parse!(int)(args[++argn]);
            } catch (ConvException e) {
                fullscreen_width = 0;
                fullscreen_height = 0;
            }
        } else if (args[argn] == "-font-in-row") {
            font_flags = 0;
            font_new_flags |= TCOD_FONT_LAYOUT_ASCII_INROW;
        } else if (args[argn] == "-font-greyscale") {
            font_flags = 0;
            font_new_flags |= TCOD_FONT_TYPE_GREYSCALE;
        } else if (args[argn] == "-font-tcod") {
            font_flags = 0;
            font_new_flags |= TCOD_FONT_LAYOUT_TCOD;
        }
    }

    if (font_flags == 0) font_flags = font_new_flags;
    TCOD_console_set_custom_font(toStringz(font), font_flags, nb_char_horiz, nb_char_vertic);
    if (fullscreen_width > 0) {
        TCOD_sys_force_fullscreen_resolution(fullscreen_width, fullscreen_height);
    }
    TCOD_console_init_root(80, 50, toStringz("libtcod D sample"), fullscreen, TCOD_RENDERER_SDL);

    Sample[] samples;
    populateSamplesList(samples);


    // Initialise the offscreen console for the samples.
    sample_console = TCOD_console_new(SAMPLE_SCREEN_WIDTH, SAMPLE_SCREEN_HEIGHT);
    while (!TCOD_console_is_window_closed()) {
        if (!credits_end) {
            credits_end = TCOD_console_credits_render(60, 43, false);
        }

        // Print the list of samples.
        foreach (i, sample; samples) {
            if (i == cur_sample) {
                // Set colours for currently selected sample.
                TCOD_console_set_default_foreground(null, TCOD_white);
                TCOD_console_set_default_background(null, TCOD_light_blue);
            } else {
                // Set colours for the other samples.
                TCOD_console_set_default_foreground(null, TCOD_grey);
                TCOD_console_set_default_background(null, TCOD_black);
            }
            // Print the sample name.
            TCOD_console_print_ex(null, 2, cast(uint)(46 - (samples.length - i)),
                                  TCOD_BKGND_SET, TCOD_LEFT,
                                  toStringz(sample.name()));
        }

        // Print the help message.
        TCOD_console_set_default_foreground(null, TCOD_grey);
        TCOD_console_print_ex(null, 79, 46, TCOD_BKGND_NONE, TCOD_RIGHT,
                              "last frame : %3d ms (%3d fps)",
                              cast(int)(TCOD_sys_get_last_frame_length() * 1000),
                              TCOD_sys_get_fps());
        TCOD_console_print_ex(null, 79, 47, TCOD_BKGND_NONE, TCOD_RIGHT,
                              "elapsed : %8dms %4.2fs",
                              TCOD_sys_elapsed_milli(), TCOD_sys_elapsed_seconds());
        TCOD_console_print(null, 2, 47,
                           "%c%c : select a sample",
                           TCOD_CHAR_ARROW_N, TCOD_CHAR_ARROW_S);
        TCOD_console_print(null, 2, 48,
                           "ALT-ENTER : switch to %s",
                           TCOD_console_is_fullscreen() ? toStringz("windowed mode  ")
                           : toStringz("fullscreen mode"));

        samples[cur_sample].render(first, key, mouse);
        first = false;

        TCOD_console_blit(sample_console, 0, 0, SAMPLE_SCREEN_WIDTH,
                          SAMPLE_SCREEN_HEIGHT, null, SAMPLE_SCREEN_X,
                          SAMPLE_SCREEN_Y, 1.0f, 1.0f);
        TCOD_console_flush();

        // Did the user hit a key?
        TCOD_sys_check_for_event(cast(TCOD_event_t)(TCOD_EVENT_KEY_PRESS | TCOD_EVENT_MOUSE),
                                 &key, &mouse);
        if (key.vk == TCODK_DOWN) {
            // Down arrow: next sample.
            cur_sample = (cur_sample + 1) % samples.length;
            first = true;
        } else if (key.vk == TCODK_UP) {
            // Up arrow: previous sample.
            if (cur_sample == 0) {
                cur_sample = cast(int)samples.length - 1;
            } else {
                cur_sample--;
            }
            first = true;
        } else if (key.vk == TCODK_ENTER && key.lalt) {
            // ALT-ENTER: Toggle fullscreen.
            TCOD_console_set_fullscreen(!TCOD_console_is_fullscreen());
        } else if (key.vk == TCODK_PRINTSCREEN) {
            // Print screen: Save a screenshot.
            TCOD_sys_save_screenshot(null);
        }
    }
}

void populateSamplesList(out Sample[] samples)
{
    samples ~= new ColoursSample();
    samples ~= new OffscreenSample();
    samples ~= new LinesSample();
    samples ~= new NoiseSample();
    samples ~= new FOVSample();
    samples ~= new PathSample();
    samples ~= new BSPSample();
    samples ~= new ImageSample();
    samples ~= new MouseSample();
    samples ~= new NameGeneratorSample();
    samples ~= new SDLCallbackSample();
}

/// Print a usage string to stdout.
void usage()
{
    writefln("options:");
    writefln("-font <filename>: use a custom font.");
    writefln("-font-nb-char <nb_char_horiz> <nb_char_vertic>: number of characters in the font.");
    writefln("-font-in-row: the font layout is in rows instead of columns.");
    writefln("-font-tcod: the font uses TCOD layout instead of ASCII.");
    writefln("-font-greyscale: antialiased font using greyscale bitmap.");
    writefln("-fullscreen: start in fullscreen.");
    writefln("-fullscreen-resolution <screen_width> <screen_height>: force fullscreen resolution.");
    writefln("-help: print this message, and exit.");
}
