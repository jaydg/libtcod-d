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

module tcod.heightmap;

import tcod.c.functions;
import tcod.c.types;
import tcod.noise;
import tcod.random;

/**
 Heightmap toolkit

 This toolkit allows to create a 2D grid of float values using various
 algorithms. The code using the heightmap toolkit can be automatically
 generated with the heightmap tool (hmtool) included in the libtcod package.

 */
class TCODHeightMap {
public :
    /**
    Heightmap values.
     */
    float[] values;

    @property {
        /// width of heightmap
        int w() {
            return _w;
        }
        /// height of heightmap
        int h() {
            return _h;
        }
     }

    /**
    Creating an empty map.

    As with other modules, you have to create a heightmap object first. Note
    that whereas most other modules use opaque structs, the TCODHeightMap
    values can be freely accessed. The newly created heightmap is filled
    with 0.0 values.

    Example:
    ---
    TCODHeightMap myMap(50, 50);
    ---
    */
    this(int w, int h) {
        this._w = w;
        this._h = h;
        values = new float[w * h];

        values[] = 0.0f;
    }

    /**
    Setting a cell value.

    Once the heightmap has been created, you can do some basic operations on
    the values inside it. You can set a single value :

    Params:
        x = x coordinate of the cell to modify inside the map.
            0 <= x < map width
        y = y coordinate of the cell to modify inside the map.
            0 <= y < map height
        value = The new value of the map cell.
    */
    void setValue(int x, int y, float value) {
        values[x + y * w] = value;
    }

    /**
    Adding a float value to all cells

    Params:
        value = Value to add to every cell.
    */
    void add(float value) {
        TCOD_heightmap_t hm = {w, h, values.ptr};
        TCOD_heightmap_add(&hm, value);
    }

    /**
    Multiplying all values by a float.

    Params:
        value = Every cell's value is multiplied by this value.
    */
    void scale(float value) {
        TCOD_heightmap_t hm = {w, h, values.ptr};
        TCOD_heightmap_scale(&hm, value);
    }

    /**
    Resetting all values to 0.0.
    */
    void clear() {
        TCOD_heightmap_t hm = {w, h, values.ptr};
        TCOD_heightmap_clear(&hm);
    }

    /**
    Clamping all values.

    Params:
        min = Every cell value is clamped between min and max.
              min < max
        max    = Every cell value is clamped between min and max.
    */
    void clamp(float min, float max) {
        TCOD_heightmap_t hm = {w, h, values.ptr};
        TCOD_heightmap_clamp(&hm, min, max);
    }

    /**
    Copying values from another heightmap

    Params:
        source = Each cell value from the source heightmap is copied in this
                 heightmap. The source and destination heightmap must have
                 the same width and height.
    */
    void copy(TCODHeightMap source)  {
        TCOD_heightmap_t hm_source = {source.w, source.h, source.values.ptr};
        TCOD_heightmap_t hm_dest = {w, h, values.ptr};
        TCOD_heightmap_copy(&hm_source, &hm_dest);
    }

    /**
    Normalizing values.

    The whole heightmap is translated and scaled so that the lowest cell value
    becomes min and the highest cell value becomes max.

    Params:
        min = new lowest cell value
              min < max
        max = new maximum cell value
    */
    void normalize(float min=0.0f, float max=1.0f) {
        TCOD_heightmap_t hm={w, h, values.ptr};
        TCOD_heightmap_normalize(&hm, min, max);
    }

    /**
    Doing a lerp operation between two heightmaps.

    For each cell in the destination map, value = a.value + (b.value - a.value) * coef

    Params:
        a = First heightmap in the lerp operation.
        b = Second heightmap in the lerp operation.
        coef = lerp coefficient.

    */
    void lerp(TCODHeightMap a, TCODHeightMap b,float coef) {
        TCOD_heightmap_t hm1 = {a.w, a.h, a.values.ptr};
        TCOD_heightmap_t hm2 = {b.w, b.h, b.values.ptr};
        TCOD_heightmap_t hmres = {w, h, values.ptr};
        TCOD_heightmap_lerp_hm(&hm1, &hm2, &hmres, coef);
    }

    /**
    Adding two heightmaps.

    For each cell in the destination map, value = a.value + b.value

    Params:
        a = First heightmap.
        b = Second heightmap.
    */
    void add(TCODHeightMap a, TCODHeightMap*b) {
        TCOD_heightmap_t hm1 = {a.w, a.h, a.values.ptr};
        TCOD_heightmap_t hm2 = {b.w, b.h, b.values.ptr};
        TCOD_heightmap_t hmres = {w, h, values.ptr};
         TCOD_heightmap_add_hm(&hm1, &hm2, &hmres);
    }

    /**
    Multiplying two heightmaps.

    For each cell in the destination map, value = a.value * b.value.

    Params:
        a = First heightmap.
        b = Second heightmap.
    */
    void multiply(TCODHeightMap a, TCODHeightMap b) {
        TCOD_heightmap_t hm1 = {a.w, a.h, a.values.ptr};
        TCOD_heightmap_t hm2 = {b.w, b.h, b.values.ptr};
        TCOD_heightmap_t hmres = {w, h, values.ptr};
        TCOD_heightmap_multiply_hm(&hm1, &hm2, &hmres);
    }

    /**
    Add hills

    This function adds a hill (a half spheroid) at given position. If
    height == radius or -radius, the hill is a half-sphere.

    Params:
        x = x coordinate of the center of the hill.
            0 <= x < map width
        y = y coordinate of the center of the hill.
            0 <= y < map height
        radius = The hill radius.
        height = The hill height.
    */
    void addHill(float x, float y, float radius, float height) {
        TCOD_heightmap_t hm = {w, h, values.ptr};
        TCOD_heightmap_add_hill(&hm, x, y, radius, height);
    }


    /**
    Dig hills

    This function takes the highest value (if height > 0) or the lowest (if
    height < 0) between the map and the hill. It's main goal is to carve things
     in maps (like rivers) by digging hills along a curve.

    Params:
        x = x coordinate of the center of the hill.
            0 <= x < map width
        y = y coordinate of the center of the hill.
            0 <= y < map height
        radius = The hill radius.
        height = The hill height. Can be < 0 or > 0
    */
    void digHill(float x, float y, float radius, float height) {
        TCOD_heightmap_t hm = {w, h, values.ptr};
        TCOD_heightmap_dig_hill(&hm, x, y, radius, height);
    }

    /**
    Simulate rain erosion.

    This function simulates the effect of rain drops on the terrain, resulting
    in erosion patterns.

    Params:
        nbDrops = Number of rain drops to simulate. Should be at least width * height.
        erosionCoef = Amount of ground eroded on the drop's path.
        sedimentationCoef = Amount of ground deposited when the drops stops to flow
        rnd = RNG to use, NULL for default generator.
    */
    void rainErosion(int nbDrops,float erosionCoef,float sedimentationCoef,TCODRandom rnd) {
        TCOD_heightmap_t hm={w, h, values.ptr};
        TCOD_heightmap_rain_erosion(&hm, nbDrops, erosionCoef, sedimentationCoef, rnd.data);
    }

    /**
    Do a generic transformation.

    This function allows you to apply a generic transformation on the map, so
    that each resulting cell value is the weighted sum of several neighbour
    cells. This can be used to smooth/sharpen the map. See examples below for
    a simple horizontal smoothing kernel: replace value(x, y) with 0.33 *
    value(x - 1, y) + 0.33 * value(x, y) + 0.33 * value(x + 1, y). To do this,
    you need a kernel of size 3 (the sum involves 3 surrounding cells).
    The dx,dy array will contain:

    dx=-1,dy = 0 for cell x-1,y
    dx=1,dy=0 for cell x+1,y
    dx=0,dy=0 for current cell (x,y)
    The weight array will contain 0.33 for each cell.

    The coordinates are relative to the current cell (0,0) is current cell,
    (-1,0) is west cell, (0,-1) is north cell, (1,0) is east cell, (0,1) is
    south cell, ...

    Params:
        kernelSize = Number of neighbour cells involved.
        dx = Array of kernelSize cells x coordinates.
        dy = Array of kernelSize cells y coordinates.
        weight = Array of kernelSize cells weight. The value of each neighbour cell is scaled by its corresponding weight
        minLevel = The transformation is only applied to cells which value is >= minLevel.
        maxLevel = The transformation is only applied to cells which value is <= maxLevel.

    Example:
    ---
    int dx [] = {-1,1,0};
    int dy[] = {0,0,0};
    float weight[] = {0.33f, 0.33f, 0.33f};
    heightmap.kernelTransform(3, dx, dy, weight, 0.0f, 1.0f);
    ---
    */
    void kernelTransform(int kernelSize, const int *dx, const int *dy, const float *weight, float minLevel, float maxLevel) {
        TCOD_heightmap_t hm = {w, h, values.ptr};
        TCOD_heightmap_kernel_transform(&hm, kernelSize, dx, dy, weight, minLevel, maxLevel);
    }

    /** ditto */
    void kernelTransform(int kernelSize, const int[] dx, const int[] dy, const float[] weight, float minLevel, float maxLevel) {
        kernelTransform(kernelSize, dx.ptr, dy.ptr, weight.ptr, minLevel, maxLevel);
    }

    /**
    Add a Voronoi diagram.

    This function adds values from a Voronoi diagram to the map.

    Params:
        nbPoints = Number of Voronoi sites.
        nbCoef = The diagram value is calculated from the nbCoef closest sites.
        coef = The distance to each site is scaled by the corresponding coef.
               Closest site: coef[0], second closest site: coef[1], ...
        rnd = RNG to use, null for default generator.
    */
    void addVoronoi(int nbPoints, int nbCoef, float *coef, TCODRandom rnd){
        TCOD_heightmap_t hm = {w, h, values.ptr};
        TCOD_heightmap_add_voronoi(&hm, nbPoints, nbCoef, coef, rnd.data);
    }

    /**
    Add a fbm.

    This function adds values from a simplex fbm function to the map. The
    noise coordinate for map cell (x,y) are (x + addx) * mulx / width ,
    (y + addy)*muly / height. Those values allow you to scale and translate
    the noise function over the heightmap.

    Params:
        noise = The 2D noise to use.
        octaves = Number of octaves in the fbm sum.
        delta = The value added to the heightmap is delta + noise * scale.
        scale = The value added to the heightmap is delta + noise * scale.
        noise = is between -1.0 and 1.0
    */
    void addFbm(TCODNoise noise, float mulx, float muly, float addx, float addy, float octaves, float delta, float scale) {
        TCOD_heightmap_t hm = {w, h, values.ptr};
        TCOD_heightmap_add_fbm(&hm, noise.data, mulx, muly, addx, addy, octaves, delta, scale);
    }

    /**
    Scale with a fbm.

    This function works exactly as the previous one, but it multiplies the
    resulting value instead of adding it to the heightmap.
    */
    void scaleFbm(TCODNoise noise, float mulx, float muly, float addx, float addy, float octaves, float delta, float scale) {
        TCOD_heightmap_t hm = {w, h, values.ptr};
        TCOD_heightmap_scale_fbm(&hm, noise.data, mulx, muly, addx, addy, octaves, delta, scale);
    }

    /**
    Dig along a Bezier curve.

    This function carve a path along a cubic Bezier curve using the digHill
    function. Could be used for roads/rivers/... Both radius and depth can
    vary linearly along the path.

    Params:
        px = array of x coordinates of the 4 Bezier control points.
        py = array of y coordinates of the 4 Bezier control points.
        startRadius = The path radius in map cells at point P0. Might be < 1.0
        startDepth = The path depth at point P0.
        endRadius = The path radius in map cells at point P3. Might be < 1.0
        endDepth = The path depth at point P3.
    */
    void digBezier(int[4] px, int[4] py, float startRadius, float startDepth, float endRadius, float endDepth) {
        TCOD_heightmap_t hm = {w, h, values.ptr};
        TCOD_heightmap_dig_bezier(&hm, px, py, startRadius, startDepth, endRadius, endDepth);
    }

    /**
    Get the value of a cell.

    This function returns the height value of a map cell.

    Params:
        x = x coordinate of the map cell.
            0 <= x < map width
        y = y coordinate of the map cell.
            0 <= y < map height
    */
    float getValue(int x, int y) {
        return values[x + y * w];
    }

    /**
    Interpolate the height.
    This function returns the interpolated height at non integer coordinates.

    Params:
        y = x coordinate of the map cell.
            0 <= x < map width
        y = y coordinate of the map cell.
            0 <= y < map height
    */
    float getInterpolatedValue(float x, float y) {
        TCOD_heightmap_t hm = {w, h, values.ptr};
        return TCOD_heightmap_get_interpolated_value(&hm, x, y);
    }

    /**
    Get the map slope.

    This function returns the slope between 0 and PI/2 at given coordinates.

    Params:
        x = x coordinate of the map cell.
            0 <= x < map width
        y = y coordinate of the map cell.
            0 <= y < map height
    */
    float getSlope(int x, int y) {
        TCOD_heightmap_t hm = {w, h, values.ptr};
        return TCOD_heightmap_get_slope(&hm, x, y);
    }

    /**
    Get the map normal.

    This function returns the map normal at given coordinates.

    Params:
        x = x coordinate of the map cell.
            0 <= x < map width
        y = y coordinate of the map cell.
            0 <= y < map height
        n = The function stores the normalized normal vector in this array.
        waterLevel = The map height is clamped at waterLevel so that the sea is flat.
    */
    void getNormal(float x, float y,float[3] n, float waterLevel=0.0f) {
        TCOD_heightmap_t hm = {w, h, values.ptr};
        return TCOD_heightmap_get_normal(&hm, x, y, n, waterLevel);
    }

    /**
    Count the map cells inside a height range.

    This function returns the number of map cells which value is between min and max.

    Params:
        min = Only cells which value is >=min and <= max are counted.
        max = Only cells which value is >=min and <= max are counted.
    */
    int countCells(float min,float max) {
        TCOD_heightmap_t hm = {w, h, values.ptr};
        return TCOD_heightmap_count_cells(&hm, min, max);
    }

    /**
    Check if the map is an island.

    This function checks if the cells on the map border are below a certain height.

    Params:
        waterLevel = Return true only if no border cell is > waterLevel.
    */
    bool hasLandOnBorder(float waterLevel) {
        TCOD_heightmap_t hm={w, h, values.ptr};
        return TCOD_heightmap_has_land_on_border(&hm, waterLevel) != 0;
    }

    /**
    Get the map min and max values.

    This function calculates the min and max of all values inside the map.

    Params:
        min = The min and max values are returned in these variables.
        max = The min and max values are returned in these variables.
    */
    void getMinMax(float *min, float *max)  {
        TCOD_heightmap_t hm = {w, h, values.ptr};
        TCOD_heightmap_get_minmax(&hm, min, max);
    }

    void islandify(float seaLevel,TCODRandom *rnd) {
        TCOD_heightmap_t hm = {w, h, values.ptr};
        return TCOD_heightmap_islandify(&hm, seaLevel, rnd.data);
    }

private :
    int _w, _h;
}
