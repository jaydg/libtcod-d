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

module tcod.color;

import tcod.c.types;
import tcod.c.functions;

/**
    The Doryen library uses 32bits colors. Thus, your OS desktop must use 32bits colors.
    A color is defined by its red, green and blue component between 0 and 255.
    You can use the following predefined colors (hover over a color to see its full name and R,G,B values):
    <table style="border: 0;">
    <tr><td></td><th colspan="8">STANDARD COLORS</th></tr>
    <tr><td></td><td>desaturated</td><td>lightest</td><td>lighter</td><td>light</td><td>normal</td><td>dark</td><td>darker</td><td>darkest</td></tr>
    <tr><td>red</td><td title="desaturatedRed: 128,64,64" style="background-color: rgb(128,64,64)"></td><td title="lightestRed: 255,191,191" style="background-color: rgb(255,191,191)"></td><td title="lighterRed: 255,166,166" style="background-color: rgb(255,166,166)"></td><td title="lightRed: 255,115,115" style="background-color: rgb(255,115,115)"></td><td title="red: 255,0,0" style="background-color: rgb(255,0,0)"></td><td title="darkRed: 191,0,0" style="background-color: rgb(191,0,0)"></td><td title="darkerRed: 128,0,0" style="background-color: rgb(128,0,0)"></td><td title="darkestRed: 64,0,0" style="background-color: rgb(64,0,0)"></td></tr>
    <tr><td>flame</td><td title="desaturatedFlame: 128,80,64" style="background-color: rgb(128,80,64)"></td><td title="lightestFlame: 255,207,191" style="background-color: rgb(255,207,191)"></td><td title="lighterFlame: 255,188,166" style="background-color: rgb(255,188,166)"></td><td title="lightFlame: 255,149,115" style="background-color: rgb(255,149,115)"></td><td title="flame: 255,63,0" style="background-color: rgb(255,63,0)"></td><td title="darkFlame: 191,47,0" style="background-color: rgb(191,47,0)"></td><td title="darkerFlame: 128,32,0" style="background-color: rgb(128,32,0)"></td><td title="darkestFlame: 64,16,0" style="background-color: rgb(64,16,0)"></td></tr>
    <tr><td>orange</td><td title="desaturatedOrange: 128,96,64" style="background-color: rgb(128,96,64)"></td><td title="lightestOrange: 255,223,191" style="background-color: rgb(255,223,191)"></td><td title="lighterOrange: 255,210,166" style="background-color: rgb(255,210,166)"></td><td title="lightOrange: 255,185,115" style="background-color: rgb(255,185,115)"></td><td title="orange: 255,127,0" style="background-color: rgb(255,127,0)"></td><td title="darkOrange: 191,95,0" style="background-color: rgb(191,95,0)"></td><td title="darkerOrange: 128,64,0" style="background-color: rgb(128,64,0)"></td><td title="darkestOrange: 64,32,0" style="background-color: rgb(64,32,0)"></td></tr>
    <tr><td>amber</td><td title="desaturatedAmber: 128,112,64" style="background-color: rgb(128,112,64)"></td><td title="lightestAmber: 255,239,191" style="background-color: rgb(255,239,191)"></td><td title="lighterAmber: 255,233,166" style="background-color: rgb(255,233,166)"></td><td title="lightAmber: 255,220,115" style="background-color: rgb(255,220,115)"></td><td title="amber: 255,191,0" style="background-color: rgb(255,191,0)"></td><td title="darkAmber: 191,143,0" style="background-color: rgb(191,143,0)"></td><td title="darkerAmber: 128,96,0" style="background-color: rgb(128,96,0)"></td><td title="darkestAmber: 64,48,0" style="background-color: rgb(64,48,0)"></td></tr>
    <tr><td>yellow</td><td title="desaturatedYellow: 128,128,64" style="background-color: rgb(128,128,64)"></td><td title="lightestYellow: 255,255,191" style="background-color: rgb(255,255,191)"></td><td title="lighterYellow: 255,255,166" style="background-color: rgb(255,255,166)"></td><td title="lightYellow: 255,255,115" style="background-color: rgb(255,255,115)"></td><td title="yellow: 255,255,0" style="background-color: rgb(255,255,0)"></td><td title="darkYellow: 191,191,0" style="background-color: rgb(191,191,0)"></td><td title="darkerYellow: 128,128,0" style="background-color: rgb(128,128,0)"></td><td title="darkestYellow: 64,64,0" style="background-color: rgb(64,64,0)"></td></tr>
    <tr><td>lime</td><td title="desaturatedLime: 112,128,64" style="background-color: rgb(112,128,64)"></td><td title="lightestLime: 239,255,191" style="background-color: rgb(239,255,191)"></td><td title="lighterLime: 233,255,166" style="background-color: rgb(233,255,166)"></td><td title="lightLime: 220,255,115" style="background-color: rgb(220,255,115)"></td><td title="lime: 191,255,0" style="background-color: rgb(191,255,0)"></td><td title="darkLime: 143,191,0" style="background-color: rgb(143,191,0)"></td><td title="darkerLime: 96,128,0" style="background-color: rgb(96,128,0)"></td><td title="darkestLime: 48,64,0" style="background-color: rgb(48,64,0)"></td></tr>
    <tr><td>chartreuse</td><td title="desaturatedChartreuse: 96,128,64" style="background-color: rgb(96,128,64)"></td><td title="lightestChartreuse: 223,255,191" style="background-color: rgb(223,255,191)"></td><td title="lighterChartreuse: 210,255,166" style="background-color: rgb(210,255,166)"></td><td title="lightChartreuse: 185,255,115" style="background-color: rgb(185,255,115)"></td><td title="chartreuse: 127,255,0" style="background-color: rgb(127,255,0)"></td><td title="darkChartreuse: 95,191,0" style="background-color: rgb(95,191,0)"></td><td title="darkerChartreuse: 64,128,0" style="background-color: rgb(64,128,0)"></td><td title="darkestChartreuse: 32,64,0" style="background-color: rgb(32,64,0)"></td></tr>
    <tr><td>green</td><td title="desaturatedGreen: 64,128,64" style="background-color: rgb(64,128,64)"></td><td title="lightestGreen: 191,255,191" style="background-color: rgb(191,255,191)"></td><td title="lighterGreen: 166,255,166" style="background-color: rgb(166,255,166)"></td><td title="lightGreen: 115,255,115" style="background-color: rgb(115,255,115)"></td><td title="green: 0,255,0" style="background-color: rgb(0,255,0)"></td><td title="darkGreen: 0,191,0" style="background-color: rgb(0,191,0)"></td><td title="darkerGreen: 0,128,0" style="background-color: rgb(0,128,0)"></td><td title="darkestGreen: 0,64,0" style="background-color: rgb(0,64,0)"></td></tr>
    <tr><td>sea</td><td title="desaturatedSea: 64,128,96" style="background-color: rgb(64,128,96)"></td><td title="lightestSea: 191,255,223" style="background-color: rgb(191,255,223)"></td><td title="lighterSea: 166,255,210" style="background-color: rgb(166,255,210)"></td><td title="lightSea: 115,255,185" style="background-color: rgb(115,255,185)"></td><td title="sea: 0,255,127" style="background-color: rgb(0,255,127)"></td><td title="darkSea: 0,191,95" style="background-color: rgb(0,191,95)"></td><td title="darkerSea: 0,128,64" style="background-color: rgb(0,128,64)"></td><td title="darkestSea: 0,64,32" style="background-color: rgb(0,64,32)"></td></tr>
    <tr><td>turquoise</td><td title="desaturatedTurquoise: 64,128,112" style="background-color: rgb(64,128,112)"></td><td title="lightestTurquoise: 191,255,239" style="background-color: rgb(191,255,239)"></td><td title="lighterTurquoise: 166,255,233" style="background-color: rgb(166,255,233)"></td><td title="lightTurquoise: 115,255,220" style="background-color: rgb(115,255,220)"></td><td title="turquoise: 0,255,191" style="background-color: rgb(0,255,191)"></td><td title="darkTurquoise: 0,191,143" style="background-color: rgb(0,191,143)"></td><td title="darkerTurquoise: 0,128,96" style="background-color: rgb(0,128,96)"></td><td title="darkestTurquoise: 0,64,48" style="background-color: rgb(0,64,48)"></td></tr>
    <tr><td>cyan</td><td title="desaturatedCyan: 64,128,128" style="background-color: rgb(64,128,128)"></td><td title="lightestCyan: 191,255,255" style="background-color: rgb(191,255,255)"></td><td title="lighterCyan: 166,255,255" style="background-color: rgb(166,255,255)"></td><td title="lightCyan: 115,255,255" style="background-color: rgb(115,255,255)"></td><td title="cyan: 0,255,255" style="background-color: rgb(0,255,255)"></td><td title="darkCyan: 0,191,191" style="background-color: rgb(0,191,191)"></td><td title="darkerCyan: 0,128,128" style="background-color: rgb(0,128,128)"></td><td title="darkestCyan: 0,64,64" style="background-color: rgb(0,64,64)"></td></tr>
    <tr><td>sky</td><td title="desaturatedSky: 64,112,128" style="background-color: rgb(64,112,128)"></td><td title="lightestSky: 191,239,255" style="background-color: rgb(191,239,255)"></td><td title="lighterSky: 166,233,255" style="background-color: rgb(166,233,255)"></td><td title="lightSky: 115,220,255" style="background-color: rgb(115,220,255)"></td><td title="sky: 0,191,255" style="background-color: rgb(0,191,255)"></td><td title="darkSky: 0,143,191" style="background-color: rgb(0,143,191)"></td><td title="darkerSky: 0,96,128" style="background-color: rgb(0,96,128)"></td><td title="darkestSky: 0,48,64" style="background-color: rgb(0,48,64)"></td></tr>
    <tr><td>azure</td><td title="desaturatedAzure: 64,96,128" style="background-color: rgb(64,96,128)"></td><td title="lightestAzure: 191,223,255" style="background-color: rgb(191,223,255)"></td><td title="lighterAzure: 166,210,255" style="background-color: rgb(166,210,255)"></td><td title="lightAzure: 115,185,255" style="background-color: rgb(115,185,255)"></td><td title="azure: 0,127,255" style="background-color: rgb(0,127,255)"></td><td title="darkAzure: 0,95,191" style="background-color: rgb(0,95,191)"></td><td title="darkerAzure: 0,64,128" style="background-color: rgb(0,64,128)"></td><td title="darkestAzure: 0,32,64" style="background-color: rgb(0,32,64)"></td></tr>
    <tr><td>blue</td><td title="desaturatedBlue: 64,64,128" style="background-color: rgb(64,64,128)"></td><td title="lightestBlue: 191,191,255" style="background-color: rgb(191,191,255)"></td><td title="lighterBlue: 166,166,255" style="background-color: rgb(166,166,255)"></td><td title="lightBlue: 115,115,255" style="background-color: rgb(115,115,255)"></td><td title="blue: 0,0,255" style="background-color: rgb(0,0,255)"></td><td title="darkBlue: 0,0,191" style="background-color: rgb(0,0,191)"></td><td title="darkerBlue: 0,0,128" style="background-color: rgb(0,0,128)"></td><td title="darkestBlue: 0,0,64" style="background-color: rgb(0,0,64)"></td></tr>
    <tr><td>han</td><td title="desaturatedHan: 80,64,128" style="background-color: rgb(80,64,128)"></td><td title="lightestHan: 207,191,255" style="background-color: rgb(207,191,255)"></td><td title="lighterHan: 188,166,255" style="background-color: rgb(188,166,255)"></td><td title="lightHan: 149,115,255" style="background-color: rgb(149,115,255)"></td><td title="han: 63,0,255" style="background-color: rgb(63,0,255)"></td><td title="darkHan: 47,0,191" style="background-color: rgb(47,0,191)"></td><td title="darkerHan: 32,0,128" style="background-color: rgb(32,0,128)"></td><td title="darkestHan: 16,0,64" style="background-color: rgb(16,0,64)"></td></tr>
    <tr><td>violet</td><td title="desaturatedViolet: 96,64,128" style="background-color: rgb(96,64,128)"></td><td title="lightestViolet: 223,191,255" style="background-color: rgb(223,191,255)"></td><td title="lighterViolet: 210,166,255" style="background-color: rgb(210,166,255)"></td><td title="lightViolet: 185,115,255" style="background-color: rgb(185,115,255)"></td><td title="violet: 127,0,255" style="background-color: rgb(127,0,255)"></td><td title="darkViolet: 95,0,191" style="background-color: rgb(95,0,191)"></td><td title="darkerViolet: 64,0,128" style="background-color: rgb(64,0,128)"></td><td title="darkestViolet: 32,0,64" style="background-color: rgb(32,0,64)"></td></tr>
    <tr><td>purple</td><td title="desaturatedPurple: 111,64,128" style="background-color: rgb(111,64,128)"></td><td title="lightestPurple: 239,191,255" style="background-color: rgb(239,191,255)"></td><td title="lighterPurple: 233,166,255" style="background-color: rgb(233,166,255)"></td><td title="lightPurple: 220,115,255" style="background-color: rgb(220,115,255)"></td><td title="purple: 191,0,255" style="background-color: rgb(191,0,255)"></td><td title="darkPurple: 143,0,191" style="background-color: rgb(143,0,191)"></td><td title="darkerPurple: 95,0,128" style="background-color: rgb(95,0,128)"></td><td title="darkestPurple: 48,0,64" style="background-color: rgb(48,0,64)"></td></tr>
    <tr><td>fuchsia</td><td title="desaturatedFuchsia: 128,64,128" style="background-color: rgb(128,64,128)"></td><td title="lightestFuchsia: 255,191,255" style="background-color: rgb(255,191,255)"></td><td title="lighterFuchsia: 255,166,255" style="background-color: rgb(255,166,255)"></td><td title="lightFuchsia: 255,115,255" style="background-color: rgb(255,115,255)"></td><td title="fuchsia: 255,0,255" style="background-color: rgb(255,0,255)"></td><td title="darkFuchsia: 191,0,191" style="background-color: rgb(191,0,191)"></td><td title="darkerFuchsia: 128,0,128" style="background-color: rgb(128,0,128)"></td><td title="darkestFuchsia: 64,0,64" style="background-color: rgb(64,0,64)"></td></tr>
    <tr><td>magenta</td><td title="desaturatedMagenta: 128,64,111" style="background-color: rgb(128,64,111)"></td><td title="lightestMagenta: 255,191,239" style="background-color: rgb(255,191,239)"></td><td title="lighterMagenta: 255,166,233" style="background-color: rgb(255,166,233)"></td><td title="lightMagenta: 255,115,220" style="background-color: rgb(255,115,220)"></td><td title="magenta: 255,0,191" style="background-color: rgb(255,0,191)"></td><td title="darkMagenta: 191,0,143" style="background-color: rgb(191,0,143)"></td><td title="darkerMagenta: 128,0,95" style="background-color: rgb(128,0,95)"></td><td title="darkestMagenta: 64,0,48" style="background-color: rgb(64,0,48)"></td></tr>
    <tr><td>pink</td><td title="desaturatedPink: 128,64,96" style="background-color: rgb(128,64,96)"></td><td title="lightestPink: 255,191,223" style="background-color: rgb(255,191,223)"></td><td title="lighterPink: 255,166,210" style="background-color: rgb(255,166,210)"></td><td title="lightPink: 255,115,185" style="background-color: rgb(255,115,185)"></td><td title="pink: 255,0,127" style="background-color: rgb(255,0,127)"></td><td title="darkPink: 191,0,95" style="background-color: rgb(191,0,95)"></td><td title="darkerPink: 128,0,64" style="background-color: rgb(128,0,64)"></td><td title="darkestPink: 64,0,32" style="background-color: rgb(64,0,32)"></td></tr>
    <tr><td>crimson</td><td title="desaturatedCrimson: 128,64,79" style="background-color: rgb(128,64,79)"></td><td title="lightestCrimson: 255,191,207" style="background-color: rgb(255,191,207)"></td><td title="lighterCrimson: 255,166,188" style="background-color: rgb(255,166,188)"></td><td title="lightCrimson: 255,115,149" style="background-color: rgb(255,115,149)"></td><td title="crimson: 255,0,63" style="background-color: rgb(255,0,63)"></td><td title="darkCrimson: 191,0,47" style="background-color: rgb(191,0,47)"></td><td title="darkerCrimson: 128,0,31" style="background-color: rgb(128,0,31)"></td><td title="darkestCrimson: 64,0,16" style="background-color: rgb(64,0,16)"></td></tr>
    <tr><td></td><th colspan="8">METALLIC COLORS</th></tr>
    <tr><td>brass</td><td title="brass: 191,151,96" style="background-color: rgb(191,151,96)"></td></tr>
    <tr><td>copper</td><td title="copper: 196,136,124" style="background-color: rgb(196,136,124)"></td></tr>
    <tr><td>gold</td><td title="gold: 229,191,0" style="background-color: rgb(229,191,0)"></td></tr>
    <tr><td>silver</td><td title="silver: 203,203,203" style="background-color: rgb(203,203,203)"></td></tr>
    <tr><td></td><th colspan="8">MISCELLANEOUS COLORS</th></tr>
    <tr><td>celadon</td><td title="celadon: 172,255,175" style="background-color: rgb(172,255,175)"></td></tr>
    <tr><td>peach</td><td title="peach: 255,159,127" style="background-color: rgb(255,159,127)"></td></tr>
    <tr><td></td><th colspan="8">GREYSCALE & SEPIA</th></tr>
    <tr><td colspan="2">&nbsp;</td><td>lightest</td><td>lighter</td><td>light</td><td>normal</td><td>dark</td><td>darker</td><td>darkest</td></tr>
    <tr><td>grey</td><td>&nbsp;</td><td title="lightestGrey: 223,223,223" style="background-color: rgb(223, 223, 223);"></td><td title="lighterGrey: 191,191,191" style="background-color: rgb(191, 191, 191);"></td><td title="lightGrey: 159,159,159" style="background-color: rgb(159, 159, 159);"></td><td title="grey: 127,127,127" style="background-color: rgb(127, 127, 127);"></td><td title="darkGrey: 95,95,95" style="background-color: rgb(95, 95, 95);"></td><td title="darkerGrey: 63,63,63" style="background-color: rgb(63, 63, 63);"></td><td title="darkestGrey: 31,31,31" style="background-color: rgb(31, 31, 31);"></td></tr>
    <tr><td>sepia</td><td>&nbsp;</td><td title="lightestSepia: 222,211,195" style="background-color: rgb(222, 211, 195);"></td><td title="lighterSepia: 191,171,143" style="background-color: rgb(191, 171, 143);"></td><td title="lightSepia: 158,134,100" style="background-color: rgb(158, 134, 100);"></td><td title="sepia: 127,101,63" style="background-color: rgb(127, 101, 63);"></td><td title="darkSepia: 94,75,47" style="background-color: rgb(94, 75, 47);"></td><td title="darkerSepia: 63,50,31" style="background-color: rgb(63, 50, 31);"></td><td title="darkestSepia: 31,24,15" style="background-color: rgb(31, 24, 15);"></td></tr><tr><td></td><th colspan="8">BLACK AND WHITE</th></tr>
    <tr><td>black</td><td title="black: 0,0,0" style="background-color: rgb(0,0,0)"></td></tr>
    <tr><td>white</td><td title="white: 255,255,255" style="background-color: rgb(255,255,255)"></td></tr>
    </table>
 */

struct TCODColor
{
public:
    /// red component
    ubyte r;
    /// green component
    ubyte g;
    /// blue component
    ubyte b;

    /**
    Create your own color from RGB values.

    Example:
    ---
    TCODColor myColor(24, 64, 255);
    ---
    */
    this(ubyte r, ubyte g, ubyte b)
    {
        this.r = r;
        this.g = g;
        this.b = b;
    }

    /**
    Create your own color from HSV values.

    Example:
    ---
    TCODColor myOtherColor(321.0f, 0.7f, 1.0f);
    ---
    */
    this(float h, float s, float v) {
        const TCOD_color_t c = TCOD_color_HSV(h, s, v);
        this.r = c.r;
        this.g = c.g;
        this.b = c.b;
    }

    /**
    Create your own color from another TCODColor.

    Example:
    ---
    TCODColor myCopiedColor(myOtherColor);
    ---
    */
    this(const ref TCODColor col)
    {
        this.r = col.r;
        this.g = col.g;
        this.b = col.b;
    }

    /**
    Compare two colors.

    Example:
    ---
    if (myColor == TCODColor.yellow) { ... }
    if (myColor != TCODColor.white) { ... }
    ---
    */
    bool opEquals()(auto ref const TCODColor c) const
    {
        return (c.r == r && c.g == g && c.b == b);
    }

    /**
    Multiply two colors.

    Example:
    ---
    TCODColor myDarkishRed = TCODColor.darkGrey * TCODColor.lightRed;
    ---
    */
    TCODColor opBinary(string op : "*")(const TCODColor a) const
    {
        TCODColor ret;
        ret.r = cast(ubyte)((cast(int) r) * a.r / 255);
        ret.g = cast(ubyte)((cast(int) g) * a.g / 255);
        ret.b = cast(ubyte)((cast(int) b) * a.b / 255);
        return ret;
    }

    /**
    Multiply a color by a float.

    Example:
    ---
    TCODColor myDarkishRed = TCODColor.lightRed * 0.5f;
    ---
    */
    TCODColor opBinary(string op : "*")(float value) const
    {
        int _r = cast(int)(this.r * value);
        int _g = cast(int)(this.g * value);
        int _b = cast(int)(this.b * value);
        r = CLAMP(0, 255, _r);
        g = CLAMP(0, 255, _g);
        b = CLAMP(0, 255, _b);

        return TCODColor(cast(ubyte) _r, cast(ubyte) _g, cast(ubyte) _b);
    }

    /**
    Add two colors.

    Example:
    ---
    TCODColor myLightishRed = TCODColor.red + TCODColor.darkGrey;
    ---
    */
    TCODColor opBinary(string op : "+")(const ref TCODColor a) const
    {
        int _r = cast(int)(this.r) + a.r;
        int _g = cast(int)(this.g) + a.g;
        int _b = cast(int)(this.b) + a.b;
        r = MIN(255, _r);
        g = MIN(255, _g);
        b = MIN(255, _b);

        return TCODColor(cast(ubyte) _r, cast(ubyte) _g, cast(ubyte) _b);
    }

    /**
    Subtract two colors.

    Example:
    ---
    TCODColor myRedish = TCODColor.red - TCODColor.darkGrey;
    ---
	*/
    TCODColor opBinary(string op : "-")(const ref TCODColor a) const
    {
        int _r = cast(int)(this.r) - a.r;
        int _g = cast(int)(this.g) - a.g;
        int _b = cast(int)(this.b) - a.b;
        r = MAX(0, _r);
        g = MAX(0, _g);
        b = MAX(0, _b);

        return TCODColor(cast(ubyte) _r, cast(ubyte) _g, cast(ubyte) _b);
    }

    /**
    Interpolate between two colors

    Params:
        coef = should be between 0.0 and 1.0 but you can as well use other values

    Example:
    ---
    TCODColor myColor = TCODColor.lerp (TCODColor.darkGrey, TCODColor.lightRed, coef);
    ---
    */
    static TCODColor lerp(const ref TCODColor a, const ref TCODColor b, float coef)
    {
        ubyte _r = cast(ubyte)(a.r + (b.r - a.r) * coef);
        ubyte _g = cast(ubyte)(a.g + (b.g - a.g) * coef);
        ubyte _b = cast(ubyte)(a.b + (b.b - a.b) * coef);

        return TCODColor(_r, _g, _b);
    }

    /**
    Define a color by its hue, saturation and value.

    After this function is called, the r, g, b fields of the color
    are calculated according to the h, s, v parameters.
    Params:
        h = Color hue in the HSV space
            0.0 <= h < 360.0
        s = Color saturation in the HSV space
            0.0 <= s <= 1.0
        v = Color value in the HSV space
            0.0 <= v <= 1.0
    */
    void setHSV(float h, float s, float v) {
        TCOD_color_t c;

        TCOD_color_set_HSV(&c, h, s, v);
        this.r = c.r;
        this.g = c.g;
        this.b = c.b;
    }

    /**
    Define a color's hue.

    Params:
        h = Color hue in the HSV space
    */
    void setHue(float h) {
        TCOD_color_t c = {r, g, b};
        TCOD_color_set_hue (&c, h);

        this.r = c.r;
        this.g = c.g;
        this.b = c.b;
    }

    /**
    Define a color's saturation.

    Params:
        s = Color saturation in the HSV space
    */
    void setSaturation(float s) {
        TCOD_color_t c = {r, g, b};
        TCOD_color_set_saturation (&c, s);

        this.r = c.r;
        this.g = c.g;
        this.b = c.b;
    }

    /**
    Define a color's value.

    Params:
        v = Color value in the HSV space
    */
    void setValue(float v) {
        TCOD_color_t c = {r, g, b};
        TCOD_color_set_value (&c, v);

        this.r = c.r;
        this.g = c.g;
        this.b = c.b;
    }

    /**
    Get a color hue, saturation and value components.

    Params:
        h = Color hue in the HSV space
            0.0 <= h < 360.0
        s = Color saturation in the HSV space
            0.0 <= s <= 1.0
        v = Color value in the HSV space
            0.0 <= v <= 1.0
    */
    void getHSV(float* h, float* s, float* v) {
        TCOD_color_t c={r, g, b};
        TCOD_color_get_HSV(c, h, s, v);
    }

    /**
    Get a color's hue.
    */
    float getHue(){
        TCOD_color_t c = {r, g, b};
        return TCOD_color_get_hue(c);
    }

    /**
    Get a color's saturation.
    */
    float getSaturation() {
        TCOD_color_t c = {r, g, b};
        return TCOD_color_get_saturation(c);
    }

    /**
    Get a color's value.
    */
    float getValue() {
        TCOD_color_t c = {r, g, b};
        return TCOD_color_get_value(c);
    }

    /**
    Shift a color's hue up or down.

    The hue shift value is the number of grades the color's hue will be
    shifted. The value can be negative for shift left, or positive for
    shift right.

    Resulting values H < 0 and H >= 360 are handled automatically.

    Params:
        hshift = The hue shift value
    */
    void shiftHue(float hshift) {
        TCOD_color_t c = { r, g, b };
        TCOD_color_shift_hue (&c, hshift);

        this.r = c.r;
        this.g = c.g;
        this.b = c.b;
    }

    /**
    Scale a color's saturation and value

    Params:
        sscale = saturation multiplier (1.0f for no change)
        vscale = value multiplier (1.0f for no change)
    */
    void scaleHSV(float sscale, float vscale);

    /**
    Generate a smooth color map.

    You can define a color map from an array of color keys. Colors will be interpolated between the keys.
    0 -> black
    4 -> red
    8 -> white

    Result:
        <table>
        <tr><td class="code"><pre>map[0]</pre></td><td style="background-color: rgb(0, 0, 0); color: rgb(255, 255, 255); width: 50px;" align="center">&nbsp;</td><td>black</td></tr>
        <tr><td class="code"><pre>map[1]</pre></td><td style="background-color: rgb(63, 0, 0); color: rgb(255, 255, 255); width: 50px;" align="center">&nbsp;</td></tr>
        <tr><td class="code"><pre>map[2]</pre></td><td style="background-color: rgb(127, 0, 0); color: rgb(255, 255, 255); width: 50px;" align="center">&nbsp;</td></tr>
        <tr><td class="code"><pre>map[3]</pre></td><td style="background-color: rgb(191, 0, 0); color: rgb(255, 255, 255); width: 50px;" align="center">&nbsp;</td></tr>
        <tr><td class="code"><pre>map[4]</pre></td><td style="background-color: rgb(255, 0, 0); color: rgb(255, 255, 255); width: 50px;" align="center">&nbsp;</td><td>red</td></tr>
        <tr><td class="code"><pre>map[5]</pre></td><td style="background-color: rgb(255, 63, 63); color: rgb(255, 255, 255); width: 50px;" align="center">&nbsp;</td></tr>
        <tr><td class="code"><pre>map[6]</pre></td><td style="background-color: rgb(255, 127, 127); color: rgb(255, 255, 255); width: 50px;" align="center">&nbsp;</td></tr>

        <tr><td class="code"><pre>map[7]</pre></td><td style="background-color: rgb(255, 191, 191); color: rgb(255, 255, 255); width: 50px;" align="center">&nbsp;</td></tr>
        <tr><td class="code"><pre>map[8]</pre></td><td style="background-color: rgb(255, 255, 255); color: rgb(255, 255, 255); width: 50px;" align="center">&nbsp;</td><td>white</td></tr>
        </table>

    Params:
        map = An array of colors to be filled by the function.
        nbKey = Number of color keys.
        keyColor = Array of nbKey colors containing the color of each key.
        keyIndex = Array of nbKey integers containing the index of each key.
                   If you want to fill the map array, keyIndex[0] must be 0
                   and keyIndex[nbKey-1] is the number of elements in map
                   minus 1 but you can also use the function to fill only
                   a part of the map array.

    Example:
    ---
    int idx[] = {0, 4, 8}; // indexes of the keys
    TCODColor[] col = { TCODColor(0,0,0), TCODColor(255,0,0), TCODColor(255,255,255) }; // colors : black, red, white
    TCODColor[9] map;
    TCODColor.genMap(map, 3, col, idx);
    ---
    */
    static void genMap(TCODColor* map, const int nbKey, const TCODColor* keyColor, const int* keyIndex)
    {
        for (int segment; segment < nbKey - 1; segment++)
        {
            int idxStart = keyIndex[segment];
            int idxEnd = keyIndex[segment + 1];

            for (int idx = idxStart; idx <= idxEnd; idx++)
            {
                map[idx] = TCODColor.lerp(keyColor[segment], keyColor[segment + 1],
                        cast(float)(idx - idxStart) / (idxEnd - idxStart));
            }
        }
    }

    /** ditto */
    static void genMap(TCODColor[] map, const int nbKey, const TCODColor[] keyColor, const int[] keyIndex)
    {
        genMap(map.ptr, nbKey, keyColor.ptr, keyIndex.ptr);
    }

    /// color array.
    static const TCODColor[TCOD_COLOR_NB][TCOD_COLOR_LEVELS] colors;

    // grey levels
    static const TCODColor black = TCODColor(0, 0, 0);
    static const TCODColor darkestGrey = TCODColor(31, 31, 31);
    static const TCODColor darkerGrey = TCODColor(63, 63, 63);
    static const TCODColor darkGrey = TCODColor(95, 95, 95);
    static const TCODColor grey = TCODColor(127, 127, 127);
    static const TCODColor lightGrey = TCODColor(159, 159, 159);
    static const TCODColor lighterGrey = TCODColor(191, 191, 191);
    static const TCODColor lightestGrey = TCODColor(223, 223, 223);
    static const TCODColor white = TCODColor(255, 255, 255);

    // sepia
    static const TCODColor darkestSepia = TCODColor(31, 24, 15);
    static const TCODColor darkerSepia = TCODColor(63, 50, 31);
    static const TCODColor darkSepia = TCODColor(94, 75, 47);
    static const TCODColor sepia = TCODColor(127, 101, 63);
    static const TCODColor lightSepia = TCODColor(158, 134, 100);
    static const TCODColor lighterSepia = TCODColor(191, 171, 143);
    static const TCODColor lightestSepia = TCODColor(222, 211, 195);

    // standard colors
    static const TCODColor red = TCODColor(255,0,0);
    static const TCODColor flame = TCODColor(255,63,0);
    static const TCODColor orange = TCODColor(255,127,0);
    static const TCODColor amber = TCODColor(255,191,0);
    static const TCODColor yellow = TCODColor(255,255,0);
    static const TCODColor lime = TCODColor(191,255,0);
    static const TCODColor chartreuse = TCODColor(127,255,0);
    static const TCODColor green = TCODColor(0,255,0);
    static const TCODColor sea = TCODColor(0,255,127);
    static const TCODColor turquoise = TCODColor(0,255,191);
    static const TCODColor cyan = TCODColor(0,255,255);
    static const TCODColor sky = TCODColor(0,191,255);
    static const TCODColor azure = TCODColor(0,127,255);
    static const TCODColor blue = TCODColor(0,0,255);
    static const TCODColor han = TCODColor(63,0,255);
    static const TCODColor violet = TCODColor(127,0,255);
    static const TCODColor purple = TCODColor(191,0,255);
    static const TCODColor fuchsia = TCODColor(255,0,255);
    static const TCODColor magenta = TCODColor(255,0,191);
    static const TCODColor pink = TCODColor(255,0,127);
    static const TCODColor crimson = TCODColor(255,0,63);

    // dark colors
    static const TCODColor darkRed = TCODColor(191,0,0);
    static const TCODColor darkFlame = TCODColor(191,47,0);
    static const TCODColor darkOrange = TCODColor(191,95,0);
    static const TCODColor darkAmber = TCODColor(191,143,0);
    static const TCODColor darkYellow = TCODColor(191,191,0);
    static const TCODColor darkLime = TCODColor(143,191,0);
    static const TCODColor darkChartreuse = TCODColor(95,191,0);
    static const TCODColor darkGreen = TCODColor(0,191,0);
    static const TCODColor darkSea = TCODColor(0,191,95);
    static const TCODColor darkTurquoise = TCODColor(0,191,143);
    static const TCODColor darkCyan = TCODColor(0,191,191);
    static const TCODColor darkSky = TCODColor(0,143,191);
    static const TCODColor darkAzure = TCODColor(0,95,191);
    static const TCODColor darkBlue = TCODColor(0,0,191);
    static const TCODColor darkHan = TCODColor(47,0,191);
    static const TCODColor darkViolet = TCODColor(95,0,191);
    static const TCODColor darkPurple = TCODColor(143,0,191);
    static const TCODColor darkFuchsia = TCODColor(191,0,191);
    static const TCODColor darkMagenta = TCODColor(191,0,143);
    static const TCODColor darkPink = TCODColor(191,0,95);
    static const TCODColor darkCrimson = TCODColor(191,0,47);

    // darker colors
    static const TCODColor darkerRed = TCODColor(127,0,0);
    static const TCODColor darkerFlame = TCODColor(127,31,0);
    static const TCODColor darkerOrange = TCODColor(127,63,0);
    static const TCODColor darkerAmber = TCODColor(127,95,0);
    static const TCODColor darkerYellow = TCODColor(127,127,0);
    static const TCODColor darkerLime = TCODColor(95,127,0);
    static const TCODColor darkerChartreuse = TCODColor(63,127,0);
    static const TCODColor darkerGreen = TCODColor(0,127,0);
    static const TCODColor darkerSea = TCODColor(0,127,63);
    static const TCODColor darkerTurquoise = TCODColor(0,127,95);
    static const TCODColor darkerCyan = TCODColor(0,127,127);
    static const TCODColor darkerSky = TCODColor(0,95,127);
    static const TCODColor darkerAzure = TCODColor(0,63,127);
    static const TCODColor darkerBlue = TCODColor(0,0,127);
    static const TCODColor darkerHan = TCODColor(31,0,127);
    static const TCODColor darkerViolet = TCODColor(63,0,127);
    static const TCODColor darkerPurple = TCODColor(95,0,127);
    static const TCODColor darkerFuchsia = TCODColor(127,0,127);
    static const TCODColor darkerMagenta = TCODColor(127,0,95);
    static const TCODColor darkerPink = TCODColor(127,0,63);
    static const TCODColor darkerCrimson = TCODColor(127,0,31);

    // darkest colors
    static const TCODColor darkestRed = TCODColor(63,0,0);
    static const TCODColor darkestFlame = TCODColor(63,15,0);
    static const TCODColor darkestOrange = TCODColor(63,31,0);
    static const TCODColor darkestAmber = TCODColor(63,47,0);
    static const TCODColor darkestYellow = TCODColor(63,63,0);
    static const TCODColor darkestLime = TCODColor(47,63,0);
    static const TCODColor darkestChartreuse = TCODColor(31,63,0);
    static const TCODColor darkestGreen = TCODColor(0,63,0);
    static const TCODColor darkestSea = TCODColor(0,63,31);
    static const TCODColor darkestTurquoise = TCODColor(0,63,47);
    static const TCODColor darkestCyan = TCODColor(0,63,63);
    static const TCODColor darkestSky = TCODColor(0,47,63);
    static const TCODColor darkestAzure = TCODColor(0,31,63);
    static const TCODColor darkestBlue = TCODColor(0,0,63);
    static const TCODColor darkestHan = TCODColor(15,0,63);
    static const TCODColor darkestViolet = TCODColor(31,0,63);
    static const TCODColor darkestPurple = TCODColor(47,0,63);
    static const TCODColor darkestFuchsia = TCODColor(63,0,63);
    static const TCODColor darkestMagenta = TCODColor(63,0,47);
    static const TCODColor darkestPink = TCODColor(63,0,31);
    static const TCODColor darkestCrimson = TCODColor(63,0,15);

    // light colors
    static const TCODColor lightRed = TCODColor(255,63,63);
    static const TCODColor lightFlame = TCODColor(255,111,63);
    static const TCODColor lightOrange = TCODColor(255,159,63);
    static const TCODColor lightAmber = TCODColor(255,207,63);
    static const TCODColor lightYellow = TCODColor(255,255,63);
    static const TCODColor lightLime = TCODColor(207,255,63);
    static const TCODColor lightChartreuse = TCODColor(159,255,63);
    static const TCODColor lightGreen = TCODColor(63,255,63);
    static const TCODColor lightSea = TCODColor(63,255,159);
    static const TCODColor lightTurquoise = TCODColor(63,255,207);
    static const TCODColor lightCyan = TCODColor(63,255,255);
    static const TCODColor lightSky = TCODColor(63,207,255);
    static const TCODColor lightAzure = TCODColor(63,159,255);
    static const TCODColor lightBlue = TCODColor(63,63,255);
    static const TCODColor lightHan = TCODColor(111,63,255);
    static const TCODColor lightViolet = TCODColor(159,63,255);
    static const TCODColor lightPurple = TCODColor(207,63,255);
    static const TCODColor lightFuchsia = TCODColor(255,63,255);
    static const TCODColor lightMagenta = TCODColor(255,63,207);
    static const TCODColor lightPink = TCODColor(255,63,159);
    static const TCODColor lightCrimson = TCODColor(255,63,111);

    // lighter colors
    static const TCODColor lighterRed = TCODColor(255,127,127);
    static const TCODColor lighterFlame = TCODColor(255,159,127);
    static const TCODColor lighterOrange = TCODColor(255,191,127);
    static const TCODColor lighterAmber = TCODColor(255,223,127);
    static const TCODColor lighterYellow = TCODColor(255,255,127);
    static const TCODColor lighterLime = TCODColor(223,255,127);
    static const TCODColor lighterChartreuse = TCODColor(191,255,127);
    static const TCODColor lighterGreen = TCODColor(127,255,127);
    static const TCODColor lighterSea = TCODColor(127,255,191);
    static const TCODColor lighterTurquoise = TCODColor(127,255,223);
    static const TCODColor lighterCyan = TCODColor(127,255,255);
    static const TCODColor lighterSky = TCODColor(127,223,255);
    static const TCODColor lighterAzure = TCODColor(127,191,255);
    static const TCODColor lighterBlue = TCODColor(127,127,255);
    static const TCODColor lighterHan = TCODColor(159,127,255);
    static const TCODColor lighterViolet = TCODColor(191,127,255);
    static const TCODColor lighterPurple = TCODColor(223,127,255);
    static const TCODColor lighterFuchsia = TCODColor(255,127,255);
    static const TCODColor lighterMagenta = TCODColor(255,127,223);
    static const TCODColor lighterPink = TCODColor(255,127,191);
    static const TCODColor lighterCrimson = TCODColor(255,127,159);

    // lightest colors
    static const TCODColor lightestRed = TCODColor(255, 191, 191);
    static const TCODColor lightestFlame = TCODColor(255,207,191);
    static const TCODColor lightestOrange = TCODColor(255,223,191);
    static const TCODColor lightestAmber = TCODColor(255,239,191);
    static const TCODColor lightestYellow = TCODColor(255,255,191);
    static const TCODColor lightestLime = TCODColor(239,255,191);
    static const TCODColor lightestChartreuse = TCODColor(223,255,191);
    static const TCODColor lightestGreen = TCODColor(191,255,191);
    static const TCODColor lightestSea = TCODColor(191,255,223);
    static const TCODColor lightestTurquoise = TCODColor(191,255,239);
    static const TCODColor lightestCyan = TCODColor(191,255,255);
    static const TCODColor lightestSky = TCODColor(191,239,255);
    static const TCODColor lightestAzure = TCODColor(191,223,255);
    static const TCODColor lightestBlue = TCODColor(191,191,255);
    static const TCODColor lightestHan = TCODColor(207,191,255);
    static const TCODColor lightestViolet = TCODColor(223,191,255);
    static const TCODColor lightestPurple = TCODColor(239,191,255);
    static const TCODColor lightestFuchsia = TCODColor(255,191,255);
    static const TCODColor lightestMagenta = TCODColor(255,191,239);
    static const TCODColor lightestPink = TCODColor(255,191,223);
    static const TCODColor lightestCrimson = TCODColor(255,191,207);

    // desaturated colors
    static const TCODColor desaturatedRed = TCODColor(127, 63, 63);
    static const TCODColor desaturatedFlame = TCODColor(127, 79, 63);
    static const TCODColor desaturatedOrange = TCODColor(127, 95, 63);
    static const TCODColor desaturatedAmber = TCODColor(127, 111, 63);
    static const TCODColor desaturatedYellow = TCODColor(127, 127, 63);
    static const TCODColor desaturatedLime = TCODColor(111, 127, 63);
    static const TCODColor desaturatedChartreuse = TCODColor(95, 127, 63);
    static const TCODColor desaturatedGreen = TCODColor(63, 127, 63);
    static const TCODColor desaturatedSea = TCODColor(63, 127, 95);
    static const TCODColor desaturatedTurquoise = TCODColor(63, 127, 111);
    static const TCODColor desaturatedCyan = TCODColor(63, 127, 127);
    static const TCODColor desaturatedSky = TCODColor(63, 111, 127);
    static const TCODColor desaturatedAzure = TCODColor(63, 95, 127);
    static const TCODColor desaturatedBlue = TCODColor(63, 63, 127);
    static const TCODColor desaturatedHan = TCODColor(79, 63, 127);
    static const TCODColor desaturatedViolet = TCODColor(95, 63, 127);
    static const TCODColor desaturatedPurple = TCODColor(111, 63, 127);
    static const TCODColor desaturatedFuchsia = TCODColor(127, 63, 127);
    static const TCODColor desaturatedMagenta = TCODColor(127, 63, 111);
    static const TCODColor desaturatedPink = TCODColor(127, 63, 95);
    static const TCODColor desaturatedCrimson = TCODColor(127, 63, 79);

    // metallic
    static const TCODColor brass = TCODColor(191,151,96);
    static const TCODColor copper = TCODColor(197,136,124);
    static const TCODColor gold = TCODColor(229,191,0);
    static const TCODColor silver = TCODColor(203,203,203);

    // miscellaneous
    static const TCODColor celadon = TCODColor(172,255,175);
    static const TCODColor peach = TCODColor(255,159,127);
}
