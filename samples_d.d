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
import std.c.stdlib : malloc, free, exit;

import tcod.base;

version (D_Version2) {
    Mt19937 gen;
}

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
    void render(bool first, ref TCOD_key_t key);
}

// The offscreen console in which the samples are rendered.
TCOD_console_t sample_console;

/// ====================
/// True colours sample.
/// ====================
class ColoursSample : Sample
{
    string name() { return "  True colors        "; }
    void render(bool first, ref TCOD_key_t key)
    {
        enum { TOPLEFT, TOPRIGHT, BOTTOMLEFT, BOTTOMRIGHT };
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
            version (D_Version2) {
                int component = uniform(0, 3, gen);
            } else {
                int component = rand() % 3;
            }
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
                TCOD_console_set_back(sample_console, x, y, curColor,
                                      TCOD_BKGND_SET);
            }
        }

        // === Print the text. ====
        // Get the background colour at the text position...
        auto textColor = TCOD_console_get_back(sample_console, SAMPLE_SCREEN_WIDTH / 2, 5);
        // ...and invert it.
        textColor.r = cast(ubyte)(255 - textColor.r);
        textColor.g = cast(ubyte)(255 - textColor.g);
        textColor.b = cast(ubyte)(255 - textColor.b);
        TCOD_console_set_foreground_color(sample_console, textColor);
        // Put random text (for performance tests).
        for (int x = 0; x < SAMPLE_SCREEN_WIDTH; x++) {
            for (int y = 0; y < SAMPLE_SCREEN_HEIGHT; y++) {
                TCOD_color_t col = TCOD_console_get_back(sample_console, x, y);
                col = TCOD_color_lerp(col, TCOD_black, 0.5f);
                version (D_Version2) {
                    int c = uniform('a', 'z' + 1, gen);
                } else {
                    int c = (rand() % (('z' - 'a') + 1)) + 'a';
                }
                TCOD_console_set_foreground_color(sample_console, col);
                TCOD_console_put_char(sample_console, x, y, c,
                                      TCOD_BKGND_NONE);
            }
        }
        // The background behind the text is slightly darkened using BKGND_MULTIPLY.
        TCOD_console_set_background_color(sample_console, TCOD_grey);
        TCOD_console_print_center_rect(sample_console, SAMPLE_SCREEN_WIDTH / 2, 5,
                                       SAMPLE_SCREEN_WIDTH - 2, SAMPLE_SCREEN_HEIGHT - 1,
                                       TCOD_BKGND_MULTIPLY,
                                       "The Doryen library uses 24 bits colors, for both background and foreground.");
    }
}

/// =========================
/// Offscreen console sample.
/// =========================
class OffscreenSample : Sample
{
    this()
    {

        secondary = TCOD_console_new(SAMPLE_SCREEN_WIDTH / 2, SAMPLE_SCREEN_HEIGHT / 2);
        screenshot = TCOD_console_new(SAMPLE_SCREEN_WIDTH, SAMPLE_SCREEN_HEIGHT);

        TCOD_console_print_frame(secondary, 0, 0, SAMPLE_SCREEN_WIDTH / 2,
                                 SAMPLE_SCREEN_HEIGHT / 2, false,
                                 "Offscreen console");
        TCOD_console_print_center_rect(secondary, SAMPLE_SCREEN_WIDTH / 4, 2,
                                       (SAMPLE_SCREEN_WIDTH / 2) - 2,
                                       SAMPLE_SCREEN_HEIGHT / 2,
                                       TCOD_BKGND_NONE,
                                       "You can render to an offscreen console and blit in on another one, simulating alpha transparency.");
    }

    string name() { return "  Offscreen console  "; }
    void render(bool first, ref TCOD_key_t key)
    {
        if (first) {
            TCOD_sys_set_fps(30);
            TCOD_console_blit(sample_console, 0, 0, SAMPLE_SCREEN_WIDTH,
                              SAMPLE_SCREEN_HEIGHT, screenshot, 0, 0, 1.0f, 1.0f);
        }

        if (++counter % 20 == 0) {
            // Move the secondary screen every two seconds.
            x += xdir; y += ydir;
            if (x == SAMPLE_SCREEN_WIDTH / 2) xdir = -1;
            else if (x == 0) xdir = 1;
            if (y == SAMPLE_SCREEN_HEIGHT / 2) ydir = -1;
            else if (y == 0) ydir = 1;
        }
        // Restore the initial screen.
        TCOD_console_blit(screenshot, 0, 0, SAMPLE_SCREEN_WIDTH, SAMPLE_SCREEN_HEIGHT,
                          sample_console, 0, 0, 1.0f, 1.0f);
        // Blit the overlapping screen.
        TCOD_console_blit(secondary, 0, 0, SAMPLE_SCREEN_WIDTH / 2, SAMPLE_SCREEN_HEIGHT / 2,
                          sample_console, x, y, 1.0f, 0.75f);
    }

    TCOD_console_t secondary;
    TCOD_console_t screenshot;
    int counter;
    int x = 0;
    int y = 0;
    int xdir = 1;
    int ydir = 1;
}

/// ====================
/// Line drawing sample.
/// ====================
TCOD_bkgnd_flag_t bk_flag = TCOD_BKGND_SET;  /// Current blending mode.
extern (C) bool line_listener(int x, int y)
{
    if (x >= 0 && y >= 0 && x < SAMPLE_SCREEN_WIDTH && y < SAMPLE_SCREEN_HEIGHT) {
        TCOD_console_set_back(sample_console, x, y, TCOD_light_blue, bk_flag);
    }

    return true;
}

class LinesSample : Sample
{
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
                TCOD_console_set_back(bk, x, y, col, TCOD_BKGND_SET);
            }
        }
    }

    string name() { return "  Line drawing       "; }
    void render(bool first, ref TCOD_key_t key)
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
            TCOD_console_set_foreground_color(sample_console, TCOD_white);
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
            TCOD_console_set_back(sample_console, x, recty, col, bk_flag);
            TCOD_console_set_back(sample_console, x, recty + 1, col, bk_flag);
            TCOD_console_set_back(sample_console, x, recty + 2, col, bk_flag);
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
        TCOD_console_print_left(sample_console, 2, 2, TCOD_BKGND_NONE,
                                "%s (ENTER to change)", toStringz(flag_names[bk_flag & 0xff]));
    }

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
}

/// =============
/// Noise sample.
/// =============
class NoiseSample : Sample
{
    this()
    {
        noise = TCOD_noise_new(2, hurst, lacunarity, null);
    }

    string name() { return "  Noise              "; }
    void render(bool first, ref TCOD_key_t key)
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
        for (int y = 0; y < SAMPLE_SCREEN_HEIGHT; y++) {
            for (int x = 0; x < SAMPLE_SCREEN_WIDTH; x++) {

                ubyte c;
                TCOD_color_t col;
                f[0] = zoom * x / SAMPLE_SCREEN_WIDTH + dx;
                f[1] = zoom * y / SAMPLE_SCREEN_HEIGHT + dy;
                float value = 0.0f;

                switch (func) {
                    case PERLIN: value = TCOD_noise_perlin(noise, f); break;
                    case SIMPLEX: value = TCOD_noise_simplex(noise, f); break;
                    case WAVELET: value = TCOD_noise_wavelet(noise, f); break;
                    case FBM_PERLIN: value = TCOD_noise_fbm_perlin(noise, f, octaves); break;
                    case TURBULENCE_PERLIN:
                        value = TCOD_noise_turbulence_perlin(noise, f, octaves);
                        break;
                    case FBM_SIMPLEX:
                        value = TCOD_noise_fbm_simplex(noise, f, octaves);
                        break;
                    case TURBULENCE_SIMPLEX:
                        value = TCOD_noise_turbulence_simplex(noise, f, octaves);
                        break;
                    case FBM_WAVELET:
                        value = TCOD_noise_fbm_wavelet(noise, f, octaves);
                        break;
                    case TURBULENCE_WAVELET:
                        value = TCOD_noise_turbulence_wavelet(noise, f, octaves);
                        break;
                    default:
                        assert(false);
                }

                c = cast(ubyte)((value + 1.0f) / 2.0f * 255);
                // Use a blue-ish colour.
                col.r = col.g = cast(ubyte)(c / 2);
                col.b = c;
                TCOD_console_set_back(sample_console, x, y, col, TCOD_BKGND_SET);
            }
        }

        free(f);

        // Draw a transparent rectangle.
        TCOD_console_set_background_color(sample_console, TCOD_grey);
        TCOD_console_rect(sample_console, 2, 2, 23,
                          (func <= WAVELET ? 10 : 13), false, TCOD_BKGND_MULTIPLY);
        // Draw the text.
        for (int curfunc = PERLIN; curfunc <= TURBULENCE_WAVELET; curfunc++) {
            if (curfunc == func) {
                TCOD_console_set_foreground_color(sample_console, TCOD_white);
                TCOD_console_set_background_color(sample_console, TCOD_light_blue);
                TCOD_console_print_left(sample_console, 2, 2 + curfunc, TCOD_BKGND_SET,
                                        toStringz(funcName[curfunc]));
            } else {
                TCOD_console_set_foreground_color(sample_console, TCOD_grey);
                TCOD_console_print_left(sample_console, 2, 2 + curfunc, TCOD_BKGND_NONE,
                                        toStringz(funcName[curfunc]));
            }
        }
        // Draw parameters.
        TCOD_console_set_foreground_color(sample_console, TCOD_white);
        TCOD_console_print_left(sample_console, 2, 11, TCOD_BKGND_NONE,
                                "Y/H : zoom (%2.1f)", zoom);
        if (func > WAVELET) {
            TCOD_console_print_left(sample_console, 2, 12, TCOD_BKGND_NONE,
                                    "E/D : hurst (%2.1f)", hurst);
            TCOD_console_print_left(sample_console, 2, 13, TCOD_BKGND_NONE,
                                    "R/F : lacunarity (%2.1f)", lacunarity);
            TCOD_console_print_left(sample_console, 2, 14, TCOD_BKGND_NONE,
                                    "T/G : octaves (%2.1f)", octaves);
        }

        // Handle keypress.
        if (key.vk == TCODK_NONE) return;
        if (key.c >= '1' && key.c <= '9') {
            // Change the noise function.
            func = key.c - '1';
        } else if (key.c == 'E' || key.c == 'e') {
            // Increase hurst.
            hurst += 0.1f;
            TCOD_noise_delete(noise);
            noise = TCOD_noise_new(2, hurst, lacunarity, null);
        } else if (key.c == 'D' || key.c == 'd') {
            // Decrease hurst.
            hurst -= 0.1f;
            TCOD_noise_delete(noise);
            noise = TCOD_noise_new(2, hurst, lacunarity, null);
        } else if (key.c == 'R' || key.c == 'r') {
            // Increase lacunarity.
            lacunarity += 0.5f;
            TCOD_noise_delete(noise);
            noise = TCOD_noise_new(2, hurst, lacunarity, null);
        } else if (key.c == 'F' || key.c == 'f') {
            // Decrease lacunarity.
            lacunarity -= 0.5f;
            TCOD_noise_delete(noise);
            noise = TCOD_noise_new(2, hurst, lacunarity, null);
        } else if (key.c == 'T' || key.c == 't') {
            // Increase octaves.
            octaves += 0.5f;
        } else if (key.c == 'G' || key.c == 'g') {
            // Decrease octaves.
            octaves -= 0.5f;
        } else if (key.c == 'Y' || key.c == 'y') {
            // Increase zoom.
            zoom += 0.2f;
        } else if (key.c == 'H' || key.c == 'h') {
            // Decrease zoom.
            zoom -= 0.2f;
        }
    }

    enum { PERLIN, SIMPLEX, WAVELET, FBM_PERLIN, TURBULENCE_PERLIN,
            FBM_SIMPLEX, TURBULENCE_SIMPLEX, FBM_WAVELET, TURBULENCE_WAVELET }
    string funcName[] = [
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
    float zoom = 3.0f;
}

/// ===========
/// FOV Sample.
/// ===========
const float TORCH_RADIUS = 10.0f;
const float SQUARED_TORCH_RADIUS = (TORCH_RADIUS * TORCH_RADIUS);

class FOVSample : Sample
{
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
        TCOD_console_set_foreground_color(sample_console, TCOD_white);
        TCOD_console_print_left(sample_console, 1, 0, TCOD_BKGND_NONE,
                                "IJKL : move around\n"
                                "T : torch fx %s\n"
                                "W : light walls %s\n"
                                "+-: algo %s\n",
                                torch ? on : off,
                                light_walls ? on : off,
                                toStringz(algo_names[algonum]));
        TCOD_console_set_foreground_color(sample_console, TCOD_black);
    }

    string name() { return "  Field of view      "; }
    void render(bool first, ref TCOD_key_t key)
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
            dx = TCOD_noise_simplex(noise, &tdx) * 1.5f;
            tdx += 30.0f;
            dy = TCOD_noise_simplex(noise, &tdx) * 1.5f;
            di = 0.2f * TCOD_noise_simplex(noise, &torchx);
        }
        for (int y = 0; y < SAMPLE_SCREEN_HEIGHT; y++) {
            for (int x = 0; x < SAMPLE_SCREEN_WIDTH; x++) {
                bool visible = TCOD_map_is_in_fov(map, x, y);
                bool wall = smap[y][x] == '#';
                if (!visible) {
                    TCOD_console_set_back(sample_console, x, y,
                                          wall ? dark_wall : dark_ground,
                                          TCOD_BKGND_SET);
                } else {
                    if (!torch) {
                        TCOD_console_set_back(sample_console, x, y,
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
                        TCOD_console_set_back(sample_console, x, y, base,
                                              TCOD_BKGND_SET);
                    }
                }
            }
        }

        if (key.c == 'I' || key.c == 'i') {
            if (smap[py - 1][px] == ' ') {
                TCOD_console_put_char(sample_console, px, py, ' ',
                                      TCOD_BKGND_NONE);
                py--;
                TCOD_console_put_char(sample_console, px, py, '@',
                                      TCOD_BKGND_NONE);
                recompute_fov = true;
            }
        } else if (key.c == 'K' || key.c == 'k') {
            if (smap[py + 1][px] == ' ') {
                TCOD_console_put_char(sample_console, px, py, ' ',
                                      TCOD_BKGND_NONE);
                py++;
                TCOD_console_put_char(sample_console, px, py, '@',
                                      TCOD_BKGND_NONE);
                recompute_fov = true;
            }
        } else if (key.c == 'J' || key.c == 'j') {
            if (smap[py][px - 1] == ' ') {
                TCOD_console_put_char(sample_console, px, py, ' ',
                                      TCOD_BKGND_NONE);
                px--;
                TCOD_console_put_char(sample_console, px, py, '@',
                                      TCOD_BKGND_NONE);
                recompute_fov = true;
            }
        } else if (key.c == 'L' || key.c == 'l') {
            if (smap[py][px + 1] == ' ') {
                TCOD_console_put_char(sample_console, px, py, ' ',
                                      TCOD_BKGND_NONE);
                px++;
                TCOD_console_put_char(sample_console, px, py, '@',
                                      TCOD_BKGND_NONE);
                recompute_fov = true;
            }
        } else if (key.c == 'T' || key.c == 't') {
            torch = !torch;
            print_text();
        } else if (key.c == 'W' || key.c == 'w') {
            light_walls = !light_walls;
            print_text();
            recompute_fov = true;
        } else if (key.c == '+' || key.c == '-') {
            algonum += key.c == '+' ? 1 : -1;
            algonum = CLAMP(0, NB_FOV_ALGORITHMS - 1, algonum);
            print_text();
            recompute_fov = true;
        }
    }

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
}

/// =============
/// Image sample.
/// =============
class ImageSample : Sample
{
    this()
    {
        img = TCOD_image_load("skull.png");
        TCOD_image_set_key_color(img, TCOD_black);
        circle = TCOD_image_load("circle.png");
    }

    string name() { return "  Image toolkit      "; }

    void render(bool first, ref TCOD_key_t key)
    {
        if (first) {
            TCOD_sys_set_fps(30);
        }

        TCOD_console_set_background_color(sample_console, TCOD_black);
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
            TCOD_console_set_background_color(sample_console, TCOD_red);
            TCOD_console_rect(sample_console, 0, 3, 15, 15, false, TCOD_BKGND_SET);
            TCOD_image_blit_rect(circle, sample_console, 0, 3, -1, -1, TCOD_BKGND_MULTIPLY);
            /*** Green channel. ***/
            TCOD_console_set_background_color(sample_console, green);
            TCOD_console_rect(sample_console, 15, 3, 15, 15, false, TCOD_BKGND_SET);
            TCOD_image_blit_rect(circle, sample_console, 15, 3, -1, -1, TCOD_BKGND_MULTIPLY);
            /*** Blue channel. ***/
            TCOD_console_set_background_color(sample_console, blue);
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

    TCOD_image_t img = null;
    TCOD_image_t circle = null;
    TCOD_color_t blue = {0, 0, 255};
    TCOD_color_t green = {0, 255, 0};
}

/// =============
/// Mouse sample.
/// =============
class MouseSample : Sample
{
    this()
    {
        /* Once a string literal has gone through a ternary, passing
         * it to C makes Bad Things happen.
         */
        on = toStringz(" ON");
        off = toStringz("OFF");
    }
    string name() { return "  Mouse support      "; }
    void render(bool first, ref TCOD_key_t key)
    {
        if (first) {
            TCOD_console_set_background_color(sample_console, TCOD_grey);
            TCOD_console_set_foreground_color(sample_console, TCOD_light_yellow);
            TCOD_mouse_move(320, 200);
            TCOD_mouse_show_cursor(true);
            TCOD_sys_set_fps(30);
        }

        TCOD_console_clear(sample_console);
        TCOD_mouse_t mouse = TCOD_mouse_get_status();
        if (mouse.lbutton_pressed) lbut = !lbut;
        if (mouse.rbutton_pressed) rbut = !rbut;
        if (mouse.mbutton_pressed) mbut = !mbut;

       TCOD_console_print_left(sample_console, 1, 1, TCOD_BKGND_NONE,
                               "Mouse position : %4dx%4d\n"
                               "Mouse cell     : %4dx%4d\n"
                               "Mouse movement : %4dx%4d\n"
                               "Left button    : %s (toggle %s)\n"
                               "Right button   : %s (toggle %s)\n"
                               "Middle button  : %s (toggle %s)\n",
                               mouse.x, mouse.y,
                               mouse.cx, mouse.cy,
                               mouse.dx, mouse.dy,
                               mouse.lbutton ? on : off, lbut ? on : off,
                               mouse.rbutton ? on : off, rbut ? on : off,
                               mouse.mbutton ? on : off, mbut ? on : off);
       TCOD_console_print_left(sample_console, 1, 10, TCOD_BKGND_NONE,
                               "1 : Hide cursor\n2 : Show cursor");
       if (key.c == '1') TCOD_mouse_show_cursor(false);
       else if (key.c == '2') TCOD_mouse_show_cursor(true);
    }

    bool lbut = false;
    bool rbut = false;
    bool mbut = false;
    charptr on = null;
    charptr off = null;
}

/// ============
/// Path sample.
/// ============

class PathSample : Sample
{
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
    }

    string name() { return "  Path finding       "; }
    void render(bool first, ref TCOD_key_t key)
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
            TCOD_console_set_foreground_color(sample_console, TCOD_white);
            TCOD_console_put_char(sample_console, dx, dy, '+', TCOD_BKGND_NONE);
            TCOD_console_put_char(sample_console, px, py, '@', TCOD_BKGND_NONE);
            TCOD_console_print_left(sample_console, 1, 1, TCOD_BKGND_NONE,
                                    "IJKL / mouse :\nmove destination");
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
            TCOD_path_compute(path, px, py, dx, dy);
        }
        // Draw the dungeon.
        for (y = 0; y < SAMPLE_SCREEN_HEIGHT; y++) {
            for (x = 0; x < SAMPLE_SCREEN_WIDTH; x++) {
                bool wall = smap[y][x] == '#';
                TCOD_console_set_back(sample_console, x, y,
                                      wall ? dark_wall : dark_ground,
                                      TCOD_BKGND_SET);
            }
        }

        // Draw the path.
        for (int i = 0; i < TCOD_path_size(path); i++) {
            int tmpx, tmpy;
            TCOD_path_get(path, i, &tmpx, &tmpy);
            TCOD_console_set_back(sample_console, tmpx, tmpy, light_ground,
                                  TCOD_BKGND_SET);
        }

        // Move the creature.
        busy -= TCOD_sys_get_last_frame_length();
        if (busy <= 0.0f) {
            busy += 0.2f;
            if (!TCOD_path_is_empty(path)) {
                TCOD_console_put_char(sample_console, px, py, ' ', TCOD_BKGND_NONE);
                TCOD_path_walk(path, &px, &py, true);
                TCOD_console_put_char(sample_console, px, py, '@', TCOD_BKGND_NONE);
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

        if ((key.c == 'I' || key.c == 'i') && dy > 0) {
            // North.
            TCOD_console_put_char(sample_console, dx, dy, oldChar, TCOD_BKGND_NONE);
            dy--;
            destMoved();
        } else if ((key.c == 'K' || key.c == 'k') && dy < SAMPLE_SCREEN_HEIGHT - 1) {
            // South.
            TCOD_console_put_char(sample_console, dx, dy, oldChar, TCOD_BKGND_NONE);
            dy++;
            destMoved();
        } else if ((key.c == 'J' || key.c == 'j') && dx > 0) {
            // West.
            TCOD_console_put_char(sample_console, dx, dy, oldChar, TCOD_BKGND_NONE);
            dx--;
            destMoved();
        } else if ((key.c == 'L' || key.c == 'l') && dx < SAMPLE_SCREEN_WIDTH - 1) {
            // East.
            TCOD_console_put_char(sample_console, dx, dy, oldChar, TCOD_BKGND_NONE);
            dx++;
            destMoved();
        }

        auto mouse = TCOD_mouse_get_status();
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

    int px = 20, py = 10;  // Player position.
    int dx = 24, dy = 1;   // Player destination.
    TCOD_map_t map = null;
    TCOD_color_t dark_wall = {0, 0, 100};
    TCOD_color_t dark_ground = {50, 50, 150};
    TCOD_color_t light_ground = {200, 180, 50};
    TCOD_path_t path = null;
    bool recalculatePath = false;
    float busy = 0.0f;
    int oldChar = ' ';
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
    this()
    {
        on = toStringz("ON ");
        off = toStringz("OFF");
    }

    string name() { return "  Bsp toolkit        "; }
    void render(bool first, ref TCOD_key_t key)
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
        TCOD_console_set_foreground_color(sample_console, TCOD_white);
        TCOD_console_print_left(sample_console, 1, 1, TCOD_BKGND_NONE,
                                "ENTER : rebuild bsp\n"
                                "SPACE : rebuild dungeon\n"
                                "+-: bsp depth %d\n"
                                "*/: room size %d\n"
                                "1: random room size %s",
                                bspDepth, minRoomSize,
                                randomRoom ? on : off);
        if (randomRoom) {
            TCOD_console_print_left(sample_console, 1, 6, TCOD_BKGND_NONE,
                                    "2 : room walls %s", roomWalls ? on : off);
        }
        // Render the level.
        for (int y = 0; y < SAMPLE_SCREEN_HEIGHT; y++) {
            for (int x = 0; x < SAMPLE_SCREEN_WIDTH; x++) {
                bool wall = (map[index(x, y)] == WALL);
                TCOD_console_set_back(sample_console, x, y, wall ? darkWall : darkGround,
                                      TCOD_BKGND_SET);
            }
        }
        if (key.vk == TCODK_ENTER || key.vk == TCODK_KPENTER) {
            generate = true;
        } else if (key.c == ' ') {
            refresh = true;
        } else if (key.c == '+') {
            bspDepth++;
            generate = true;
        } else if (key.c == '-' && bspDepth > 1) {
            bspDepth--;
            generate = true;
        } else if (key.c == '*') {
            minRoomSize++;
            generate = true;
        } else if (key.c == '/' && minRoomSize > 2) {
            minRoomSize--;
            generate = true;
        } else if (key.c == '1' || key.vk == TCODK_1 || key.vk == TCODK_KP1) {
            randomRoom = !randomRoom;
            if (!randomRoom) roomWalls = true;
            refresh = true;
        } else if (key.c == '2' || key.vk == TCODK_2 || key.vk == TCODK_KP2) {
            roomWalls = !roomWalls;
            refresh = true;
        }
    }

    TCOD_bsp_t* bsp = null;
    bool generate = true;
    bool refresh = false;
    TCOD_color_t darkWall = {0, 0, 100};
    TCOD_color_t darkGround = {50, 50, 150};
    int bspDepth = 8;
    charptr on = null;
    charptr off = null;


    ubyte[SAMPLE_SCREEN_WIDTH * SAMPLE_SCREEN_HEIGHT] map = void;
}

void main(string[] args)
{
    int cur_sample = 0;  // Index of the current sample.
    bool first = true;  // First time we render a sample.
    string font = "fonts/celtic_garamond_10x10_gs_tc.png";
    int font_flags = TCOD_FONT_TYPE_GREYSCALE | TCOD_FONT_LAYOUT_TCOD;
    int font_new_flags = 0;
    int nb_char_horiz = 0, nb_char_vertic = 0;
    TCOD_key_t key = {TCODK_NONE, 0};
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
                version (D_Version2) {
                    nb_char_horiz = parse!(int)(args[++argn]);
                    nb_char_vertic = parse!(int)(args[++argn]);
                } else {
                    nb_char_horiz = toInt(args[++argn]);
                    nb_char_vertic = toInt(args[++argn]);
                }
            } catch (ConvError e) {
                nb_char_horiz = 0;
                nb_char_vertic = 0;
            }
        } else if (args[argn] == "-fullscreen") {
            fullscreen = true;
        } else if (args[argn] == "-fullscreen-resolution" && argn + 2 < args.length) {
            try {
                version (D_Version2) {
                    fullscreen_width = parse!(int)(args[++argn]);
                    fullscreen_height = parse!(int)(args[++argn]);
                } else {
                    fullscreen_width = toInt(args[++argn]);
                    fullscreen_height = toInt(args[++argn]);
                }
            } catch (ConvError e) {
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
    TCOD_console_init_root(80, 50, toStringz("libtcod D sample"), fullscreen);

    Sample[] samples;
    populateSamplesList(samples);


    // Initialise the offscreen console for the samples.
    sample_console = TCOD_console_new(SAMPLE_SCREEN_WIDTH, SAMPLE_SCREEN_HEIGHT);
    while (!TCOD_console_is_window_closed()) {
        if (!credits_end) {
            credits_end = TCOD_console_credits_render(60, 42, false);
        }

        // Print the list of samples.
        foreach (i, sample; samples) {
            if (i == cur_sample) {
                // Set colours for currently selected sample.
                TCOD_console_set_foreground_color(null, TCOD_white);
                TCOD_console_set_background_color(null, TCOD_light_blue);
            } else {
                // Set colours for the other samples.
                TCOD_console_set_foreground_color(null, TCOD_grey);
                TCOD_console_set_background_color(null, TCOD_black);
            }
            // Print the sample name.
            TCOD_console_print_left(null, 2, 46 - (samples.length - i),
                                    TCOD_BKGND_SET,
                                    toStringz(sample.name()));
        }

        // Print the help message.
        TCOD_console_set_foreground_color(null, TCOD_grey);
        TCOD_console_print_right(null, 79, 46, TCOD_BKGND_NONE,
                                 "last frame : %3d ms (%3d fps)",
                                 cast(int)(TCOD_sys_get_last_frame_length() * 1000),
                                 TCOD_sys_get_fps());
        TCOD_console_print_right(null, 79, 47, TCOD_BKGND_NONE,
                                 "elapsed : %8dms %4.2fs",
                                 TCOD_sys_elapsed_milli(), TCOD_sys_elapsed_seconds());
        TCOD_console_print_left(null, 2, 47, TCOD_BKGND_NONE,
                                "%c%c : select a sample",
                                TCOD_CHAR_ARROW_N, TCOD_CHAR_ARROW_S);
        TCOD_console_print_left(null, 2, 48, TCOD_BKGND_NONE,
                                "ALT-ENTER : switch to %s",
                                TCOD_console_is_fullscreen() ? toStringz("windowed mode  ")
                                : toStringz("fullscreen mode"));

        samples[cur_sample].render(first, key);
        first = false;

        TCOD_console_blit(sample_console, 0, 0, SAMPLE_SCREEN_WIDTH,
                          SAMPLE_SCREEN_HEIGHT, null, SAMPLE_SCREEN_X,
                          SAMPLE_SCREEN_Y, 1.0f, 1.0f);
        TCOD_console_flush();

        // Did the user hit a key?
        key = TCOD_console_check_for_keypress(TCOD_KEY_PRESSED);
        if (key.vk == TCODK_DOWN) {
            // Down arrow: next sample.
            cur_sample = (cur_sample + 1) % samples.length;
            first = true;
        } else if (key.vk == TCODK_UP) {
            // Up arrow: previous sample.
            cur_sample--;
            if (cur_sample < 0) cur_sample = samples.length - 1;
            first = true;
        } else if (key.vk == TCODK_ENTER && key.lalt) {
            // ALT-ENTER: Toggle fullscreen.
            TCOD_console_set_fullscreen(!TCOD_console_is_fullscreen);
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
