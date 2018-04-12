module tcod.c.types;

import tcod.c.all;

extern (C):

// --- List ---
alias void* TCOD_list_t;


// --- Colour ---
struct TCOD_color_t {
    ubyte r,g,b;
}

// color names
enum {
    TCOD_COLOR_RED,
    TCOD_COLOR_FLAME,
    TCOD_COLOR_ORANGE,
    TCOD_COLOR_AMBER,
    TCOD_COLOR_YELLOW,
    TCOD_COLOR_LIME,
    TCOD_COLOR_CHARTREUSE,
    TCOD_COLOR_GREEN,
    TCOD_COLOR_SEA,
    TCOD_COLOR_TURQUOISE,
    TCOD_COLOR_CYAN,
    TCOD_COLOR_SKY,
    TCOD_COLOR_AZURE,
    TCOD_COLOR_BLUE,
    TCOD_COLOR_HAN,
    TCOD_COLOR_VIOLET,
    TCOD_COLOR_PURPLE,
    TCOD_COLOR_FUCHSIA,
    TCOD_COLOR_MAGENTA,
    TCOD_COLOR_PINK,
    TCOD_COLOR_CRIMSON,
    TCOD_COLOR_NB,
}

// color levels
enum {
    TCOD_COLOR_DESATURATED,
    TCOD_COLOR_LIGHTEST,
    TCOD_COLOR_LIGHTER,
    TCOD_COLOR_LIGHT,
    TCOD_COLOR_NORMAL,
    TCOD_COLOR_DARK,
    TCOD_COLOR_DARKER,
    TCOD_COLOR_DARKEST,
    TCOD_COLOR_LEVELS,
}

// color array
const TCOD_color_t[TCOD_COLOR_LEVELS][TCOD_COLOR_NB] TCOD_colors;

// grey levels
const TCOD_color_t TCOD_black = TCOD_color_t(0, 0, 0);
const TCOD_color_t TCOD_darkest_grey = TCOD_color_t(31, 31, 31);
const TCOD_color_t TCOD_darkest_gray = TCOD_color_t(31, 31, 31);
const TCOD_color_t TCOD_darker_grey = TCOD_color_t(63, 63, 63);
const TCOD_color_t TCOD_darker_gray = TCOD_color_t(63, 63, 63);
const TCOD_color_t TCOD_dark_grey = TCOD_color_t(95, 95, 95);
const TCOD_color_t TCOD_dark_gray = TCOD_color_t(95, 95, 95);
const TCOD_color_t TCOD_grey = TCOD_color_t(127, 127, 127);
const TCOD_color_t TCOD_gray = TCOD_color_t(127, 127, 127);
const TCOD_color_t TCOD_light_grey = TCOD_color_t(159, 159, 159);
const TCOD_color_t TCOD_light_gray = TCOD_color_t(159, 159, 159);
const TCOD_color_t TCOD_lighter_grey = TCOD_color_t(191, 191, 191);
const TCOD_color_t TCOD_lighter_gray = TCOD_color_t(191, 191, 191);
const TCOD_color_t TCOD_lightest_grey = TCOD_color_t(223, 223, 223);
const TCOD_color_t TCOD_lightest_gray = TCOD_color_t(223, 223, 223);
const TCOD_color_t TCOD_white = TCOD_color_t(255, 255, 255);

/* sepia */
const TCOD_color_t TCOD_darkest_sepia = TCOD_color_t(31, 24, 15);
const TCOD_color_t TCOD_darker_sepia = TCOD_color_t(63, 50, 31);
const TCOD_color_t TCOD_dark_sepia = TCOD_color_t(94, 75, 47);
const TCOD_color_t TCOD_sepia = TCOD_color_t(127, 101, 63);
const TCOD_color_t TCOD_light_sepia = TCOD_color_t(158, 134, 100);
const TCOD_color_t TCOD_lighter_sepia = TCOD_color_t(191, 171, 143);
const TCOD_color_t TCOD_lightest_sepia = TCOD_color_t(222, 211, 195);

// standard colors
const TCOD_color_t TCOD_red = TCOD_color_t(255, 0, 0);
const TCOD_color_t TCOD_flame = TCOD_color_t(255, 63, 0);
const TCOD_color_t TCOD_orange = TCOD_color_t(255, 127, 0);
const TCOD_color_t TCOD_amber = TCOD_color_t(255, 191, 0);
const TCOD_color_t TCOD_yellow = TCOD_color_t(255, 255, 0);
const TCOD_color_t TCOD_lime = TCOD_color_t(191, 255, 0);
const TCOD_color_t TCOD_chartreuse = TCOD_color_t(127, 255, 0);
const TCOD_color_t TCOD_green = TCOD_color_t(0, 255, 0);
const TCOD_color_t TCOD_sea = TCOD_color_t(0, 255, 127);
const TCOD_color_t TCOD_turquoise = TCOD_color_t(0, 255, 191);
const TCOD_color_t TCOD_cyan = TCOD_color_t(0, 255, 255);
const TCOD_color_t TCOD_sky = TCOD_color_t(0, 127, 255);
const TCOD_color_t TCOD_azure = TCOD_color_t(0, 127, 255);
const TCOD_color_t TCOD_blue = TCOD_color_t(0, 0, 255);
const TCOD_color_t TCOD_han = TCOD_color_t(63, 0, 255);
const TCOD_color_t TCOD_violet = TCOD_color_t(127, 0, 255);
const TCOD_color_t TCOD_purple = TCOD_color_t(191, 0, 255);
const TCOD_color_t TCOD_fuchsia = TCOD_color_t(255, 0, 191);
const TCOD_color_t TCOD_magenta = TCOD_color_t(255, 0, 255);
const TCOD_color_t TCOD_pink = TCOD_color_t(255, 0, 127);
const TCOD_color_t TCOD_crimson = TCOD_color_t(255, 0, 63);

// dark colors
const TCOD_color_t TCOD_dark_red = TCOD_color_t(191, 0, 0);
const TCOD_color_t TCOD_dark_flame = TCOD_color_t(191, 47, 0);
const TCOD_color_t TCOD_dark_orange = TCOD_color_t(191, 95, 0);
const TCOD_color_t TCOD_dark_amber = TCOD_color_t(191, 143, 0);
const TCOD_color_t TCOD_dark_yellow = TCOD_color_t(191, 191, 0);
const TCOD_color_t TCOD_dark_lime = TCOD_color_t(143, 191, 0);
const TCOD_color_t TCOD_dark_chartreuse = TCOD_color_t(95, 191, 0);
const TCOD_color_t TCOD_dark_green = TCOD_color_t(0, 191, 0);
const TCOD_color_t TCOD_dark_sea = TCOD_color_t(0, 191, 95);
const TCOD_color_t TCOD_dark_turquoise = TCOD_color_t(0, 191, 143);
const TCOD_color_t TCOD_dark_cyan = TCOD_color_t(0, 191, 191);
const TCOD_color_t TCOD_dark_sky = TCOD_color_t(0, 143, 191);
const TCOD_color_t TCOD_dark_azure = TCOD_color_t(0, 95, 191);
const TCOD_color_t TCOD_dark_blue = TCOD_color_t(0, 0, 191);
const TCOD_color_t TCOD_dark_han = TCOD_color_t(47, 0, 191);
const TCOD_color_t TCOD_dark_violet = TCOD_color_t(95, 0, 191);
const TCOD_color_t TCOD_dark_purple = TCOD_color_t(143, 0, 191);
const TCOD_color_t TCOD_dark_fuchsia = TCOD_color_t(191, 0, 191);
const TCOD_color_t TCOD_dark_magenta = TCOD_color_t(191, 0, 143);
const TCOD_color_t TCOD_dark_pink = TCOD_color_t(191, 0, 95);
const TCOD_color_t TCOD_dark_crimson = TCOD_color_t(191, 0, 47);

// darker colors
const TCOD_color_t TCOD_darker_red = TCOD_color_t(127, 0, 0);
const TCOD_color_t TCOD_darker_flame = TCOD_color_t(127, 31, 0);
const TCOD_color_t TCOD_darker_orange = TCOD_color_t(127, 63, 0);
const TCOD_color_t TCOD_darker_amber = TCOD_color_t(127, 95, 0);
const TCOD_color_t TCOD_darker_yellow = TCOD_color_t(127, 127, 0);
const TCOD_color_t TCOD_darker_lime = TCOD_color_t(95, 127, 0);
const TCOD_color_t TCOD_darker_chartreuse = TCOD_color_t(62, 127, 0);
const TCOD_color_t TCOD_darker_green = TCOD_color_t(0, 127, 0);
const TCOD_color_t TCOD_darker_sea = TCOD_color_t(0, 127, 63);
const TCOD_color_t TCOD_darker_turquoise = TCOD_color_t(0, 127, 95);
const TCOD_color_t TCOD_darker_cyan = TCOD_color_t(0, 127, 127);
const TCOD_color_t TCOD_darker_sky = TCOD_color_t(0, 95, 127);
const TCOD_color_t TCOD_darker_azure = TCOD_color_t(0, 63, 127);
const TCOD_color_t TCOD_darker_blue = TCOD_color_t(0, 0, 127);
const TCOD_color_t TCOD_darker_han = TCOD_color_t(31, 0, 127);
const TCOD_color_t TCOD_darker_violet = TCOD_color_t(63, 0, 127);
const TCOD_color_t TCOD_darker_purple = TCOD_color_t(95, 0, 127);
const TCOD_color_t TCOD_darker_fuchsia = TCOD_color_t(127, 0, 127);
const TCOD_color_t TCOD_darker_magenta = TCOD_color_t(127, 0, 95);
const TCOD_color_t TCOD_darker_pink = TCOD_color_t(127, 0, 63);
const TCOD_color_t TCOD_darker_crimson = TCOD_color_t(127, 0, 31);

// darkest colors
const TCOD_color_t TCOD_darkest_red = TCOD_color_t(63, 0, 0);
const TCOD_color_t TCOD_darkest_flame = TCOD_color_t(63, 15, 0);
const TCOD_color_t TCOD_darkest_orange = TCOD_color_t(63, 31, 0);
const TCOD_color_t TCOD_darkest_amber = TCOD_color_t(63, 47, 0);
const TCOD_color_t TCOD_darkest_yellow = TCOD_color_t(63, 63, 0);
const TCOD_color_t TCOD_darkest_lime = TCOD_color_t(47, 63, 0);
const TCOD_color_t TCOD_darkest_chartreuse = TCOD_color_t(31, 63, 0);
const TCOD_color_t TCOD_darkest_green = TCOD_color_t(0, 63, 0);
const TCOD_color_t TCOD_darkest_sea = TCOD_color_t(0, 63, 31);
const TCOD_color_t TCOD_darkest_turquoise = TCOD_color_t(0, 63, 47);
const TCOD_color_t TCOD_darkest_cyan = TCOD_color_t(0, 63, 63);
const TCOD_color_t TCOD_darkest_sky = TCOD_color_t(0, 47, 63);
const TCOD_color_t TCOD_darkest_azure = TCOD_color_t(0, 31, 63);
const TCOD_color_t TCOD_darkest_blue = TCOD_color_t(0, 0, 63);
const TCOD_color_t TCOD_darkest_han = TCOD_color_t(15, 0, 63);
const TCOD_color_t TCOD_darkest_violet = TCOD_color_t(31, 0, 63);
const TCOD_color_t TCOD_darkest_purple = TCOD_color_t(47, 0, 63);
const TCOD_color_t TCOD_darkest_fuchsia = TCOD_color_t(63, 0, 63);
const TCOD_color_t TCOD_darkest_magenta = TCOD_color_t(63, 0, 47);
const TCOD_color_t TCOD_darkest_pink = TCOD_color_t(63, 0, 31);
const TCOD_color_t TCOD_darkest_crimson = TCOD_color_t(63, 0, 15);

// light colors
const TCOD_color_t TCOD_light_red = TCOD_color_t(255, 63, 63);
const TCOD_color_t TCOD_light_flame = TCOD_color_t(255, 111, 63);
const TCOD_color_t TCOD_light_orange = TCOD_color_t(255, 159, 63);
const TCOD_color_t TCOD_light_amber = TCOD_color_t(255, 207, 63);
const TCOD_color_t TCOD_light_yellow = TCOD_color_t(255, 255, 63);
const TCOD_color_t TCOD_light_lime = TCOD_color_t(207, 255, 63);
const TCOD_color_t TCOD_light_chartreuse = TCOD_color_t(159, 255, 63);
const TCOD_color_t TCOD_light_green = TCOD_color_t(63, 255, 159);
const TCOD_color_t TCOD_light_sea = TCOD_color_t(63, 255, 159);
const TCOD_color_t TCOD_light_turquoise = TCOD_color_t(63, 255, 207);
const TCOD_color_t TCOD_light_cyan = TCOD_color_t(63, 255, 255);
const TCOD_color_t TCOD_light_sky = TCOD_color_t(63, 207, 255);
const TCOD_color_t TCOD_light_azure = TCOD_color_t(63, 159, 255);
const TCOD_color_t TCOD_light_blue = TCOD_color_t(63, 63, 255);
const TCOD_color_t TCOD_light_han = TCOD_color_t(111, 63, 255);
const TCOD_color_t TCOD_light_violet = TCOD_color_t(159, 63, 255);
const TCOD_color_t TCOD_light_purple = TCOD_color_t(207, 63, 255);
const TCOD_color_t TCOD_light_fuchsia = TCOD_color_t(255, 63, 255);
const TCOD_color_t TCOD_light_magenta = TCOD_color_t(255, 63, 207);
const TCOD_color_t TCOD_light_pink = TCOD_color_t(255, 63, 159);
const TCOD_color_t TCOD_light_crimson = TCOD_color_t(255, 63, 111);

// lighter colors
const TCOD_color_t TCOD_lighter_red = TCOD_color_t(255, 127, 127);
const TCOD_color_t TCOD_lighter_flame = TCOD_color_t(255, 159, 127);
const TCOD_color_t TCOD_lighter_orange = TCOD_color_t(255, 191, 127);
const TCOD_color_t TCOD_lighter_amber = TCOD_color_t(255, 223, 127);
const TCOD_color_t TCOD_lighter_yellow = TCOD_color_t(255, 255, 127);
const TCOD_color_t TCOD_lighter_lime = TCOD_color_t(223, 255, 127);
const TCOD_color_t TCOD_lighter_chartreuse = TCOD_color_t(191, 255, 127);
const TCOD_color_t TCOD_lighter_green = TCOD_color_t(127, 255, 127);
const TCOD_color_t TCOD_lighter_sea = TCOD_color_t(127, 255, 191);
const TCOD_color_t TCOD_lighter_turquoise = TCOD_color_t(127, 255, 223);
const TCOD_color_t TCOD_lighter_cyan = TCOD_color_t(127, 255, 255);
const TCOD_color_t TCOD_lighter_sky = TCOD_color_t(127, 223, 255);
const TCOD_color_t TCOD_lighter_azure = TCOD_color_t(127, 191, 255);
const TCOD_color_t TCOD_lighter_blue = TCOD_color_t(127, 127, 255);
const TCOD_color_t TCOD_lighter_han = TCOD_color_t(159, 127, 255);
const TCOD_color_t TCOD_lighter_violet = TCOD_color_t(191, 127, 255);
const TCOD_color_t TCOD_lighter_purple = TCOD_color_t(223, 127, 255);
const TCOD_color_t TCOD_lighter_fuchsia = TCOD_color_t(255, 127, 255);
const TCOD_color_t TCOD_lighter_magenta = TCOD_color_t(255, 127, 223);
const TCOD_color_t TCOD_lighter_pink = TCOD_color_t(255, 127, 191);
const TCOD_color_t TCOD_lighter_crimson = TCOD_color_t(255, 127, 159);

// lightest colors
const TCOD_color_t TCOD_lightest_red = TCOD_color_t(255, 191, 191);
const TCOD_color_t TCOD_lightest_flame = TCOD_color_t(255, 207, 191);
const TCOD_color_t TCOD_lightest_orange = TCOD_color_t(255, 223, 191);
const TCOD_color_t TCOD_lightest_amber = TCOD_color_t(255, 239, 191);
const TCOD_color_t TCOD_lightest_yellow = TCOD_color_t(255, 255, 191);
const TCOD_color_t TCOD_lightest_lime = TCOD_color_t(239, 255, 191);
const TCOD_color_t TCOD_lightest_chartreuse = TCOD_color_t(223, 255, 191);
const TCOD_color_t TCOD_lightest_green = TCOD_color_t(191, 255, 191);
const TCOD_color_t TCOD_lightest_sea = TCOD_color_t(191, 255, 223);
const TCOD_color_t TCOD_lightest_turquoise = TCOD_color_t(191, 255, 239);
const TCOD_color_t TCOD_lightest_cyan = TCOD_color_t(191, 255, 255);
const TCOD_color_t TCOD_lightest_sky = TCOD_color_t(191, 239, 255);
const TCOD_color_t TCOD_lightest_azure = TCOD_color_t(191, 223, 255);
const TCOD_color_t TCOD_lightest_blue = TCOD_color_t(191, 191, 255);
const TCOD_color_t TCOD_lightest_han = TCOD_color_t(207, 191, 255);
const TCOD_color_t TCOD_lightest_violet = TCOD_color_t(223, 191, 255);
const TCOD_color_t TCOD_lightest_purple = TCOD_color_t(239, 191, 255);
const TCOD_color_t TCOD_lightest_fuchsia = TCOD_color_t(255, 191, 255);
const TCOD_color_t TCOD_lightest_magenta = TCOD_color_t(255, 191, 239);
const TCOD_color_t TCOD_lightest_pink = TCOD_color_t(255, 191, 223);
const TCOD_color_t TCOD_lightest_crimson = TCOD_color_t(255, 191, 207);

// desaturated
const TCOD_color_t TCOD_desaturated_red = TCOD_color_t(127, 63, 63);
const TCOD_color_t TCOD_desaturated_flame = TCOD_color_t(127, 79, 63);
const TCOD_color_t TCOD_desaturated_orange = TCOD_color_t(127, 95, 63);
const TCOD_color_t TCOD_desaturated_amber = TCOD_color_t(127, 111, 63);
const TCOD_color_t TCOD_desaturated_yellow = TCOD_color_t(127, 127, 63);
const TCOD_color_t TCOD_desaturated_lime = TCOD_color_t(111, 127, 63);
const TCOD_color_t TCOD_desaturated_chartreuse = TCOD_color_t(95, 127, 63);
const TCOD_color_t TCOD_desaturated_green = TCOD_color_t(63, 127, 63);
const TCOD_color_t TCOD_desaturated_sea = TCOD_color_t(63, 127, 95);
const TCOD_color_t TCOD_desaturated_turquoise = TCOD_color_t(63, 127, 111);
const TCOD_color_t TCOD_desaturated_cyan = TCOD_color_t(63, 127, 127);
const TCOD_color_t TCOD_desaturated_sky = TCOD_color_t(63, 111, 127);
const TCOD_color_t TCOD_desaturated_azure = TCOD_color_t(63, 95, 127);
const TCOD_color_t TCOD_desaturated_blue = TCOD_color_t(63, 63, 127);
const TCOD_color_t TCOD_desaturated_han = TCOD_color_t(79, 63, 127);
const TCOD_color_t TCOD_desaturated_violet = TCOD_color_t(95, 63, 127);
const TCOD_color_t TCOD_desaturated_purple = TCOD_color_t(111, 63, 127);
const TCOD_color_t TCOD_desaturated_fuchsia = TCOD_color_t(127, 63, 127);
const TCOD_color_t TCOD_desaturated_magenta = TCOD_color_t(127, 63, 111);
const TCOD_color_t TCOD_desaturated_pink = TCOD_color_t(127, 63, 95);
const TCOD_color_t TCOD_desaturated_crimson = TCOD_color_t(127, 63, 79);

// metallic
const TCOD_color_t TCOD_brass = TCOD_color_t(191, 151, 96);
const TCOD_color_t TCOD_copper = TCOD_color_t(197, 136, 124);
const TCOD_color_t TCOD_gold = TCOD_color_t(229, 191, 0);
const TCOD_color_t TCOD_silver = TCOD_color_t(203, 203, 203);

// miscellaneous
const TCOD_color_t TCOD_celadon = TCOD_color_t(172, 255, 175);
const TCOD_color_t TCOD_peach = TCOD_color_t(255, 159, 127);

// --- Console ---

alias int TCOD_keycode_t;
enum : TCOD_keycode_t {
    TCODK_NONE,
    TCODK_ESCAPE,
    TCODK_BACKSPACE,
    TCODK_TAB,
    TCODK_ENTER,
    TCODK_SHIFT,
    TCODK_CONTROL,
    TCODK_ALT,
    TCODK_PAUSE,
    TCODK_CAPSLOCK,
    TCODK_PAGEUP,
    TCODK_PAGEDOWN,
    TCODK_END,
    TCODK_HOME,
    TCODK_UP,
    TCODK_LEFT,
    TCODK_RIGHT,
    TCODK_DOWN,
    TCODK_PRINTSCREEN,
    TCODK_INSERT,
    TCODK_DELETE,
    TCODK_LWIN,
    TCODK_RWIN,
    TCODK_APPS,
    TCODK_0,
    TCODK_1,
    TCODK_2,
    TCODK_3,
    TCODK_4,
    TCODK_5,
    TCODK_6,
    TCODK_7,
    TCODK_8,
    TCODK_9,
    TCODK_KP0,
    TCODK_KP1,
    TCODK_KP2,
    TCODK_KP3,
    TCODK_KP4,
    TCODK_KP5,
    TCODK_KP6,
    TCODK_KP7,
    TCODK_KP8,
    TCODK_KP9,
    TCODK_KPADD,
    TCODK_KPSUB,
    TCODK_KPDIV,
    TCODK_KPMUL,
    TCODK_KPDEC,
    TCODK_KPENTER,
    TCODK_F1,
    TCODK_F2,
    TCODK_F3,
    TCODK_F4,
    TCODK_F5,
    TCODK_F6,
    TCODK_F7,
    TCODK_F8,
    TCODK_F9,
    TCODK_F10,
    TCODK_F11,
    TCODK_F12,
    TCODK_NUMLOCK,
    TCODK_SCROLLLOCK,
    TCODK_SPACE,
    TCODK_CHAR
}

/* key data : special code or character */
struct TCOD_key_t {
    TCOD_keycode_t vk; /*  key code */
    char c; /* character if vk == TCODK_CHAR else 0 */
    bool pressed;
    bool lalt;
    bool lctrl;
    bool ralt;
    bool rctrl;
    bool shift;
}

enum {
    // single walls
    TCOD_CHAR_HLINE=196,
    TCOD_CHAR_VLINE=179,
    TCOD_CHAR_NE=191,
    TCOD_CHAR_NW=218,
    TCOD_CHAR_SE=217,
    TCOD_CHAR_SW=192,
    TCOD_CHAR_TEEW=180,
    TCOD_CHAR_TEEE=195,
    TCOD_CHAR_TEEN=193,
    TCOD_CHAR_TEES=194,
    TCOD_CHAR_CROSS=197,
    // double walls
    TCOD_CHAR_DHLINE=205,
    TCOD_CHAR_DVLINE=186,
    TCOD_CHAR_DNE=187,
    TCOD_CHAR_DNW=201,
    TCOD_CHAR_DSE=188,
    TCOD_CHAR_DSW=200,
    TCOD_CHAR_DTEEW=185,
    TCOD_CHAR_DTEEE=204,
    TCOD_CHAR_DTEEN=202,
    TCOD_CHAR_DTEES=203,
    TCOD_CHAR_DCROSS=206,
    // blocks
    TCOD_CHAR_BLOCK1=176,
    TCOD_CHAR_BLOCK2=177,
    TCOD_CHAR_BLOCK3=178,
    // arrows
    TCOD_CHAR_ARROW_N=24,
    TCOD_CHAR_ARROW_S=25,
    TCOD_CHAR_ARROW_E=26,
    TCOD_CHAR_ARROW_W=27,
    // arrows without tail
    TCOD_CHAR_ARROW2_N=30,
    TCOD_CHAR_ARROW2_S=31,
    TCOD_CHAR_ARROW2_E=16,
    TCOD_CHAR_ARROW2_W=17,
    // double arrows
    TCOD_CHAR_DARROW_H=29,
    TCOD_CHAR_DARROW_V=18,
    // GUI stuff
    TCOD_CHAR_CHECKBOX_UNSET=224,
    TCOD_CHAR_CHECKBOX_SET=225,
    TCOD_CHAR_RADIO_UNSET=9,
    TCOD_CHAR_RADIO_SET=10,
    // sub-pixel resolution kit
    TCOD_CHAR_SUBP_NW=226,
    TCOD_CHAR_SUBP_NE=227,
    TCOD_CHAR_SUBP_N=228,
    TCOD_CHAR_SUBP_SE=229,
    TCOD_CHAR_SUBP_DIAG=230,
    TCOD_CHAR_SUBP_E=231,
    TCOD_CHAR_SUBP_SW=232,
    /* miscellaneous */
    TCOD_CHAR_SMILIE = 1,
    TCOD_CHAR_SMILIE_INV = 2,
    TCOD_CHAR_HEART = 3,
    TCOD_CHAR_DIAMOND = 4,
    TCOD_CHAR_CLUB = 5,
    TCOD_CHAR_SPADE = 6,
    TCOD_CHAR_BULLET = 7,
    TCOD_CHAR_BULLET_INV = 8,
    TCOD_CHAR_MALE = 11,
    TCOD_CHAR_FEMALE = 12,
    TCOD_CHAR_NOTE = 13,
    TCOD_CHAR_NOTE_DOUBLE = 14,
    TCOD_CHAR_LIGHT = 15,
    TCOD_CHAR_EXCLAM_DOUBLE = 19,
    TCOD_CHAR_PILCROW = 20,
    TCOD_CHAR_SECTION = 21,
    TCOD_CHAR_POUND = 156,
    TCOD_CHAR_MULTIPLICATION = 158,
    TCOD_CHAR_FUNCTION = 159,
    TCOD_CHAR_RESERVED = 169,
    TCOD_CHAR_HALF = 171,
    TCOD_CHAR_ONE_QUARTER = 172,
    TCOD_CHAR_COPYRIGHT = 184,
    TCOD_CHAR_CENT = 189,
    TCOD_CHAR_YEN = 190,
    TCOD_CHAR_CURRENCY = 207,
    TCOD_CHAR_THREE_QUARTERS = 243,
    TCOD_CHAR_DIVISION = 246,
    TCOD_CHAR_GRADE = 248,
    TCOD_CHAR_UMLAUT = 249,
    TCOD_CHAR_POW1 = 251,
    TCOD_CHAR_POW3 = 252,
    TCOD_CHAR_POW2 = 253,
    TCOD_CHAR_BULLET_SQUARE = 254,
}

alias int TCOD_colctrl_t;
enum : TCOD_colctrl_t {
    TCOD_COLCTRL_1 = 1,
    TCOD_COLCTRL_2,
    TCOD_COLCTRL_3,
    TCOD_COLCTRL_4,
    TCOD_COLCTRL_5,
    TCOD_COLCTRL_NUMBER=5,
    TCOD_COLCTRL_FORE_RGB,
    TCOD_COLCTRL_BACK_RGB,
    TCOD_COLCTRL_STOP
}

alias int TCOD_bkgnd_flag_t;
enum : TCOD_bkgnd_flag_t {
    TCOD_BKGND_NONE,
    TCOD_BKGND_SET,
    TCOD_BKGND_MULTIPLY,
    TCOD_BKGND_LIGHTEN,
    TCOD_BKGND_DARKEN,
    TCOD_BKGND_SCREEN,
    TCOD_BKGND_COLOR_DODGE,
    TCOD_BKGND_COLOR_BURN,
    TCOD_BKGND_ADD,
    TCOD_BKGND_ADDA,
    TCOD_BKGND_BURN,
    TCOD_BKGND_OVERLAY,
    TCOD_BKGND_ALPH,
    TCOD_BKGND_DEFAULT
}

pure TCOD_bkgnd_flag_t TCOD_BKGND_ALPHA(T)(T alpha)
{
    return (TCOD_BKGND_ALPH | (cast(ubyte)(alpha * 255) << 8));
}

pure TCOD_bkgnd_flag_t TCOD_BKGND_ADDALPHA(T)(T alpha)
{
    return (TCOD_BKGND_ADDA | (cast(ubyte)(alpha * 255) << 8));
}

enum {
    TCOD_KEY_PRESSED=1,
    TCOD_KEY_RELEASED=2,
}

// custom font flags
enum {
    TCOD_FONT_LAYOUT_ASCII_INCOL=1,
    TCOD_FONT_LAYOUT_ASCII_INROW=2,
    TCOD_FONT_TYPE_GREYSCALE=4,
    TCOD_FONT_TYPE_GRAYSCALE=4,
    TCOD_FONT_LAYOUT_TCOD=8,
}

alias int TCOD_renderer_t;
enum : TCOD_renderer_t {
    TCOD_RENDERER_GLSL,
    TCOD_RENDERER_OPENGL,
    TCOD_RENDERER_SDL,
}

alias int TCOD_alignment_t;
enum : TCOD_alignment_t {
    TCOD_LEFT,
    TCOD_RIGHT,
    TCOD_CENTER,
}

alias void* TCOD_console_t;

// --- Image. ---
alias void* TCOD_image_t;

// --- Sys. ---

alias int TCOD_event_t;

enum : TCOD_event_t {
    TCOD_EVENT_KEY_PRESS = 1,
    TCOD_EVENT_KEY_RELEASE = 2,
    TCOD_EVENT_KEY = TCOD_EVENT_KEY_PRESS | TCOD_EVENT_KEY_RELEASE,
    TCOD_EVENT_MOUSE_MOVE = 4,
    TCOD_EVENT_MOUSE_PRESS = 8,
    TCOD_EVENT_MOUSE_RELEASE = 16,
    TCOD_EVENT_MOUSE = TCOD_EVENT_MOUSE_MOVE | TCOD_EVENT_MOUSE_PRESS | TCOD_EVENT_MOUSE_RELEASE,
    TCOD_EVENT_ANY = TCOD_EVENT_KEY | TCOD_EVENT_MOUSE,
}

alias void* TCOD_thread_t;
alias void* TCOD_semaphore_t;
alias void* TCOD_mutex_t;
alias void* TCOD_cond_t;
alias void* TCOD_library_t;

alias void function(void* sdl_surface) SDL_renderer_t;

// --- Mersenne. ---
alias void* TCOD_random_t;
alias int TCOD_random_algo_t;
enum : TCOD_random_algo_t
{
    TCOD_RNG_MT,
    TCOD_RNG_CMWC,
}

alias int TCOD_distribution_t;
enum : TCOD_distribution_t
{
    TCOD_DISTRIBUTION_LINEAR,
    TCOD_DISTRIBUTION_GAUSSIAN,
    TCOD_DISTRIBUTION_GAUSSIAN_RANGE,
    TCOD_DISTRIBUTION_GAUSSIAN_INVERSE,
    TCOD_DISTRIBUTION_GAUSSIAN_RANGE_INVERSE,
}

// --- Mouse. ---
struct TCOD_mouse_t {
    int x,y; /* absolute position */
    int dx,dy; /* movement since last update in pixels */
    int cx,cy; /* cell coordinates in the root console */
    int dcx,dcy; /* movement since last update in console cells */
    bool lbutton;
    bool rbutton;
    bool mbutton;
    bool lbutton_pressed;
    bool rbutton_pressed;
    bool mbutton_pressed;
    bool wheel_up;
    bool wheel_down;
}

// --- Bresenham. ---
alias bool function(int x, int y) TCOD_line_listener_t;

struct TCOD_bresenham_data_t {
    int stepx;
    int stepy;
    int e;
    int deltax;
    int deltay;
    int origx;
    int origy;
    int destx;
    int desty;
}

// --- BSP. ---
struct TCOD_bsp_t {
    TCOD_tree_t tree; /* pseudo oop : bsp inherit tree */
    int x,y,w,h; /* node position & size */
    int position; /* position of splitting */
    ubyte level; /* level in the tree */
    bool horizontal; /* horizontal splitting ? */
}

alias bool function(TCOD_bsp_t* node, void* userData) TCOD_bsp_callback_t;

// --- Noise. ---
alias void* TCOD_noise_t;

const int TCOD_NOISE_MAX_OCTAVES = 128;
const int TCOD_NOISE_MAX_DIMENSIONS = 4;
const float TCOD_NOISE_DEFAULT_HURST = 0.5f;
const float TCOD_NOISE_DEFAULT_LACUNARITY = 2.0f;

alias int TCOD_noise_type_t;
enum : TCOD_noise_type_t {
    TCOD_NOISE_PERLIN = 1,
    TCOD_NOISE_SIMPLEX = 2,
    TCOD_NOISE_WAVELET = 4,
    TCOD_NOISE_DEFAULT = 0,
}

// --- FOV. ---
alias void* TCOD_map_t;

// FOV_BASIC : http://roguebasin.roguelikedevelopment.org/index.php?title=Ray_casting
// FOV_DIAMOND : http://www.geocities.com/temerra/los_rays.html
// FOV_SHADOW : http://roguebasin.roguelikedevelopment.org/index.php?title=FOV_using_recursive_shadowcasting
// FOV_PERMISSIVE : http://roguebasin.roguelikedevelopment.org/index.php?title=Precise_Permissive_Field_of_View
// FOV_RESTRICTIVE : Mingos' Restrictive Precise Angle Shadowcasting (contribution by Mingos)

alias int TCOD_fov_algorithm_t;
enum : TCOD_fov_algorithm_t {
    FOV_BASIC,
    FOV_DIAMOND,
    FOV_SHADOW,
    FOV_PERMISSIVE_0,
    FOV_PERMISSIVE_1,
    FOV_PERMISSIVE_2,
    FOV_PERMISSIVE_3,
    FOV_PERMISSIVE_4,
    FOV_PERMISSIVE_5,
    FOV_PERMISSIVE_6,
    FOV_PERMISSIVE_7,
    FOV_PERMISSIVE_8,
    FOV_RESTRICTIVE,
    NB_FOV_ALGORITHMS
}

TCOD_fov_algorithm_t FOV_PERMISSIVE(int x) { return FOV_PERMISSIVE_0 + x; }

// --- Path. ---
alias float function(int xFrom, int yFrom, int xTo, int yTo, void* user_data) TCOD_path_func_t;
alias void *TCOD_path_t;
alias void* TCOD_dijkstra_t;

// --- Lex. ---
const int TCOD_LEX_FLAG_NOCASE = 1;
const int TCOD_LEX_FLAG_NESTING_COMMENT = 2;
const int TCOD_LEX_FLAG_TOKENIZE_COMMENTS = 4;

const int TCOD_LEX_ERROR = -1;
const int TCOD_LEX_UNKNOWN = 0;
const int TCOD_LEX_SYMBOL = 1;
const int TCOD_LEX_KEYWORD = 2;
const int TCOD_LEX_IDEN = 3;
const int TCOD_LEX_STRING = 4;
const int TCOD_LEX_INTEGER = 5;
const int TCOD_LEX_FLOAT = 6;
const int TCOD_LEX_CHAR = 7;
const int TCOD_LEX_EOF = 8;
const int TCOD_LEX_COMMENT = 9;

const int TCOD_LEX_MAX_SYMBOLS = 100;
const int TCOD_LEX_SYMBOL_SIZE = 5;
const int TCOD_LEX_MAX_KEYWORDS = 100;
const int TCOD_LEX_KEYWORD_SIZE = 20;

struct TCOD_lex_t {
    int file_line, token_type, token_int_val, token_idx;
    float token_float_val;
    char *tok;
    int toklen;
    char lastStringDelim;
    char *pos;
    char *buf;
    char *filename;
    char *last_javadoc_comment;
    // private stuff
    int nb_symbols, nb_keywords, flags;
    char[TCOD_LEX_SYMBOL_SIZE][TCOD_LEX_MAX_SYMBOLS] symbols;
    char[TCOD_LEX_KEYWORD_SIZE][TCOD_LEX_MAX_KEYWORDS] keywords;
    charptr simpleCmt;
    charptr cmtStart, cmtStop, javadocCmtStart;
    charptr stringDelim;
    bool javadoc_read;
    bool allocBuf;
    bool savept; // is this object a savepoint (no free in destructor)
}


// --- Parser. ---
/* generic type */
alias int TCOD_value_type_t;
enum : TCOD_value_type_t {
    TCOD_TYPE_NONE,
    TCOD_TYPE_BOOL,
    TCOD_TYPE_CHAR,
    TCOD_TYPE_INT,
    TCOD_TYPE_FLOAT,
    TCOD_TYPE_STRING,
    TCOD_TYPE_COLOR,
    TCOD_TYPE_DICE,
    TCOD_TYPE_VALUELIST00,
    TCOD_TYPE_VALUELIST01,
    TCOD_TYPE_VALUELIST02,
    TCOD_TYPE_VALUELIST03,
    TCOD_TYPE_VALUELIST04,
    TCOD_TYPE_VALUELIST05,
    TCOD_TYPE_VALUELIST06,
    TCOD_TYPE_VALUELIST07,
    TCOD_TYPE_VALUELIST08,
    TCOD_TYPE_VALUELIST09,
    TCOD_TYPE_VALUELIST10,
    TCOD_TYPE_VALUELIST11,
    TCOD_TYPE_VALUELIST12,
    TCOD_TYPE_VALUELIST13,
    TCOD_TYPE_VALUELIST14,
    TCOD_TYPE_VALUELIST15,
    TCOD_TYPE_CUSTOM00,
    TCOD_TYPE_CUSTOM01,
    TCOD_TYPE_CUSTOM02,
    TCOD_TYPE_CUSTOM03,
    TCOD_TYPE_CUSTOM04,
    TCOD_TYPE_CUSTOM05,
    TCOD_TYPE_CUSTOM06,
    TCOD_TYPE_CUSTOM07,
    TCOD_TYPE_CUSTOM08,
    TCOD_TYPE_CUSTOM09,
    TCOD_TYPE_CUSTOM10,
    TCOD_TYPE_CUSTOM11,
    TCOD_TYPE_CUSTOM12,
    TCOD_TYPE_CUSTOM13,
    TCOD_TYPE_CUSTOM14,
    TCOD_TYPE_CUSTOM15,
    TCOD_TYPE_LIST=1024
}

/* dice roll */
struct TCOD_dice_t {
    int nb_dices;
    int nb_faces;
    float multiplier;
    float addsub;
}

/* generic value */
union TCOD_value_t {
    bool b;
    char c;
    int i;
    float f;
    char *s;
    TCOD_color_t col;
    TCOD_dice_t dice;
    TCOD_list_t list;
    void *custom;
}

/* parser structures */
alias void *TCOD_parser_struct_t;

/* parser listener */
struct TCOD_parser_listener_t {
    bool function(TCOD_parser_struct_t str, charptr name) new_struct;
    bool function(charptr name) new_flag;
    bool function(charptr propname, TCOD_value_type_t type, TCOD_value_t value) new_property;
    bool function(TCOD_parser_struct_t str, charptr name) end_struct;
    void function(charptr msg) error;
}

/* a custom type parser */
alias TCOD_value_t function(TCOD_lex_t* lex, TCOD_parser_listener_t* listener, TCOD_parser_struct_t str, charptr propname) TCOD_parser_custom_t;

/* the parser */
alias void *TCOD_parser_t;

/* parser internals (may be used by custom type parsers) */
/* parser structures */
struct TCOD_struct_int_t {
    charptr name; /* entity type name */
    /* list of flags */
    TCOD_list_t flags;
    /* list of properties (name, type, mandatory) */
    TCOD_list_t props;
    /* list of value lists */
    TCOD_list_t lists;
    /* list of sub-structures */
    TCOD_list_t structs;
}

/* the parser */
struct TCOD_parser_int_t {
    /* list of structures */
    TCOD_list_t structs;
    /* list of custom type parsers */
    TCOD_parser_custom_t[16] customs;
    /* fatal error occured */
    bool fatal;
    // list of properties if default listener is used
    TCOD_list_t props;
}


// --- Tree. ---
struct TCOD_tree_t {
    TCOD_tree_t *next;
    TCOD_tree_t *father;
    TCOD_tree_t *sons;
}


// --- Heightmap. ---
struct TCOD_heightmap_t {
    int w,h;
    float *values;
}


// --- Zip. ---
alias void* TCOD_zip_t;


// --- Namegen. ---
alias void* TCOD_namegen_t;


// --- Txtfield. ---
alias void* TCOD_text_t;
