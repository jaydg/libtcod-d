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

module tcod.noise;

import tcod.c.functions;
import tcod.c.types;
import tcod.random;

/**
 Noise generator

 This toolkit provides several functions to generate Perlin noise and other
 derived noises. It can handle noise functions from 1 to 4 dimensions.


 Usage example:
 1D noise : the variation of a torch intensity
 2D fbm : heightfield generation or clouds
 3D fbm : animated smoke

 If you don't know what is Perlin noise and derived functions, or what is
 the influence of the different fractal parameters, check the Perlin noise
 sample included with the library.

 <h6>Noise functions relative times</h6>

 For example, in 4D, Perlin noise is 17 times slower than simplex noise.
 <table border="1">
  <tr><td></td><td>1D</td><td>2D</td><td>3D</td><td>4D</td></tr>
  <tr><td>simplex</td><td>1</td><td>1</td><td>1</td><td>1</td></tr>
  <tr><td>Perlin</td><td>1.3</td><td>4</td><td>5</td><td>17</td></tr>
  <tr><td>wavelet</td><td>53</td><td>32</td><td>14</td><td>X</td></tr>
 </table>
 */

struct TCODNoise {
public :
    /**
    Creating a noise generator.

    Those functions initialize a noise generator from a number of dimensions
        (from 1 to 4), some fractal parameters and a random number generator.

    When the hurst and lacunarity parameters are omitted, default values
    (TCOD_NOISE_DEFAULT_HURST = 0.5f and TCOD_NOISE_DEFAULT_LACUNARITY = 2.0f)
    are used.

    Params:
        dimensions = From 1 to 4.
        hurst = For fractional brownian motion and turbulence, the fractal
                Hurst exponent. You can use the default value
                TCOD_NOISE_DEFAULT_HURST (0.5f).
        lacunarity = For fractional brownian motion and turbulence, the
                     fractal lacunarity. You can use the default value
                     TCOD_NOISE_DEFAULT_LACUNARITY (2.0f).
        random = A random number generator obtained with the Mersenne
                    twister toolkit or NULL to use the default random number
                    generator.

    Example:
    ---
    // 1 dimension generator
    TCODNoise noise1d = new TCODNoise(1);
    // 2D noise with a predefined random number generator
    TCODRandom *myRandom = new TCODRandom();
    TCODNoise noise2d = new TCODNoise(2, myRandom);
    // a 3D noise generator with a specific fractal parameters
    TCODNoise noise3d = new TCODNoise(3, 0.7f, 1.4f);
    ---
    */
    this(int dimensions, TCOD_noise_type_t type = TCOD_NOISE_DEFAULT) {
        data = TCOD_noise_new(dimensions, TCOD_NOISE_DEFAULT_HURST, TCOD_NOISE_DEFAULT_LACUNARITY, TCODRandom.getInstance.data);
        TCOD_noise_set_type(data,type);
    }

    /** ditto */
    this(int dimensions, TCODRandom random, TCOD_noise_type_t type = TCOD_NOISE_DEFAULT) {
        data = TCOD_noise_new(dimensions, TCOD_NOISE_DEFAULT_HURST, TCOD_NOISE_DEFAULT_LACUNARITY, random.data);
        TCOD_noise_set_type(data, type);
    }

    /** ditto */
    this(int dimensions, float hurst, float lacunarity, TCOD_noise_type_t type = TCOD_NOISE_DEFAULT) {
        data = TCOD_noise_new(dimensions, hurst, lacunarity, TCODRandom.getInstance.data);
        TCOD_noise_set_type(data, type);
    }

    /** ditto */
    this(int dimensions, float hurst, float lacunarity, TCODRandom random, TCOD_noise_type_t type = TCOD_NOISE_DEFAULT) {
        data = TCOD_noise_new(dimensions, hurst, lacunarity, random.data);
        TCOD_noise_set_type(data, type);
    }

    /**
    To release ressources used by a generator, use those functions :

    Example:
    ---
    // create a generator
    TCODNoise *noise = new TCODNoise(2);
    // use it
    ...
    // destroy it
    delete noise;
    ---
    */
    ~this() {
        TCOD_noise_delete(data);
    }

    /**
    Choosing a noise type.

    Use this function to define the default algorithm used by the noise
    functions. The default algorithm is simplex. It's much faster than
    Perlin, especially in 4 dimensions. It has a better contrast too.

    Params:
        type = The algorithm to use, either TCOD_NOISE_SIMPLEX,
               TCOD_NOISE_PERLIN or TCOD_NOISE_WAVELET.

    Example:
    ---
    TCODNoise noise1d = new TCODNoise(1);
    noise1d.setType(TCOD_NOISE_PERLIN);
    ---
    */
    void setType (TCOD_noise_type_t type) {
        TCOD_noise_set_type(data, type);
    }

    /**
    This function returns the noise function value between -1.0 and 1.0 at
    given coordinates.

    Params:
        f = An array of coordinates, depending on the generator dimensions
            (between 1 and 4). The same array of coordinates will always
            return the same value.
        type = The algorithm to use. If not defined, use the default one
               (set with setType or TCOD_NOISE_SIMPLEX if not set)

    Example:
    ---
    // 1d noise
    TCODNoise noise1d = new TCODNoise(1);
    float p = 0.5f;
    // get a 1d simplex value
    float value = noise1d.get(&p);
    // 2d noise
    TCODNoise * noise2d = new TCODNoise(2);
    float p[2]={0.5f, 0.7f};
    // get a 2D Perlin value
    float value = noise2d.get(p.ptr, TCOD_NOISE_PERLIN);
    ---
    */
    float get(float *f, TCOD_noise_type_t type = TCOD_NOISE_DEFAULT) {
        if (type == TCOD_NOISE_DEFAULT) {
            return TCOD_noise_get(data, f);
        } else {
            return TCOD_noise_get_ex(data, f, type);
        }
    }

    /**
    Getting fbm noise.

    This function returns the fbm function value between -1.0 and 1.0 at given
    coordinates, using fractal hurst and lacunarity defined when the generator
    has been created.

    Params:
        f = An array of coordinates, depending on the generator dimensions
            (between 1 and 4). The same array of coordinates will always
            return the same value.
        octaves = Number of iterations. Must be < TCOD_NOISE_MAX_OCTAVES = 128
        type = The algorithm to use. If not defined, use the default one (set
               with setType or simplex if not set)

    Example:
    ---
    // 1d fbm
    TCODNoise noise1d = new TCODNoise(1);

    // get a 1d simplex fbm
    float p = 0.5f;
    float value = noise1d.getFbm(&p, 32.0f);

    // 2d fbm
    TCODNoise noise2d = new TCODNoise(2);

    // get a 2d perlin fbm
    float p[2]={0.5f, 0.7f};
    float value = noise2d.getFbm(p.ptr, 32.0f, TCOD_NOISE_PERLIN);
    ---
    */
    float getFbm(float *f, float octaves, TCOD_noise_type_t type = TCOD_NOISE_DEFAULT) {
        if (type == TCOD_NOISE_DEFAULT) {
            return TCOD_noise_get_fbm(data, f, octaves);
        } else {
            return TCOD_noise_get_fbm_ex(data, f, octaves, type);
        }
    }

    /**
    Getting turbulence.

    This function returns the turbulence function value between -1.0 and 1.0
    at given coordinates, using fractal hurst and lacunarity defined when the
    generator has been created.

    Params:
        f = An array of coordinates, depending on the generator dimensions
            (between 1 and 4). The same array of coordinates will always return
            the same value.
        octaves = Number of iterations. Must be < TCOD_NOISE_MAX_OCTAVES = 128
        type = The algorithm to use. If not defined, use the default one (set
               with setType or simplex if not set)

    Example:
    ---
    // 1d fbm
    TCODNoise noise1d = new TCODNoise(1);

    // a 1d simplex turbulence
    float p = 0.5f;
    float value = noise1d.getTurbulence(&p, 32.0f);

    // 2d fbm
    TCODNoise noise2d = new TCODNoise(2);
    // a 2d perlin turbulence
    float p[2] = {0.5f, 0.7f};
    float value = noise2d.getTurbulence(p.ptr, 32.0f, TCOD_NOISE_PERLIN);
    ---
    */
    float getTurbulence(float *f, float octaves, TCOD_noise_type_t type = TCOD_NOISE_DEFAULT) {
        if (type == TCOD_NOISE_DEFAULT) {
            return TCOD_noise_get_turbulence(data, f, octaves);
        } else {
            return TCOD_noise_get_turbulence_ex(data, f, octaves, type);
        }
    }

package :
    TCOD_noise_t data;
}
