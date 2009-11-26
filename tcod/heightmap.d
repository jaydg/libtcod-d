/*
* libtcod 1.4.1
* Copyright (c) 2008,2009 J.C.Wilk
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions are met:
*     * Redistributions of source code must retain the above copyright
*       notice, this list of conditions and the following disclaimer.
*     * Redistributions in binary form must reproduce the above copyright
*       notice, this list of conditions and the following disclaimer in the
*       documentation and/or other materials provided with the distribution.
*     * The name of J.C.Wilk may not be used to endorse or promote products
*       derived from this software without specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY J.C.WILK ``AS IS'' AND ANY
* EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
* DISCLAIMED. IN NO EVENT SHALL J.C.WILK BE LIABLE FOR ANY
* DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
* ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

module tcod.heightmap;

import tcod.mersenne;
import tcod.noise;

extern (C):


struct TCOD_heightmap_t {
	int w,h;
	float *values;
} 

 TCOD_heightmap_t *TCOD_heightmap_new(int w,int h);
 void TCOD_heightmap_delete(TCOD_heightmap_t *hm);

 float TCOD_heightmap_get_value( TCOD_heightmap_t *hm, int x, int y);
 float TCOD_heightmap_get_interpolated_value( TCOD_heightmap_t *hm, float x, float y);
 void TCOD_heightmap_set_value(TCOD_heightmap_t *hm, int x, int y, float value);
 float TCOD_heightmap_get_slope( TCOD_heightmap_t *hm, int x, int y);
 void TCOD_heightmap_get_normal( TCOD_heightmap_t *hm, float x, float y, float n[3], float waterLevel);
 int TCOD_heightmap_count_cells( TCOD_heightmap_t *hm, float min, float max);
 bool TCOD_heightmap_has_land_on_border( TCOD_heightmap_t *hm, float waterLevel);
 void TCOD_heightmap_get_minmax( TCOD_heightmap_t *hm, float *min, float *max);

 void TCOD_heightmap_copy( TCOD_heightmap_t *hm_source,TCOD_heightmap_t *hm_dest);
 void TCOD_heightmap_add(TCOD_heightmap_t *hm, float value);
 void TCOD_heightmap_scale(TCOD_heightmap_t *hm, float value);
 void TCOD_heightmap_clamp(TCOD_heightmap_t *hm, float min, float max);
 void TCOD_heightmap_normalize(TCOD_heightmap_t *hm, float min, float max);
 void TCOD_heightmap_clear(TCOD_heightmap_t *hm);
 void TCOD_heightmap_lerp_hm( TCOD_heightmap_t *hm1,  TCOD_heightmap_t *hm2, TCOD_heightmap_t *hmres, float coef);
 void TCOD_heightmap_add_hm( TCOD_heightmap_t *hm1,  TCOD_heightmap_t *hm2, TCOD_heightmap_t *hmres);
 void TCOD_heightmap_multiply_hm( TCOD_heightmap_t *hm1,  TCOD_heightmap_t *hm2, TCOD_heightmap_t *hmres);

 void TCOD_heightmap_add_hill(TCOD_heightmap_t *hm, float hx, float hy, float hradius, float hheight);
 void TCOD_heightmap_dig_hill(TCOD_heightmap_t *hm, float hx, float hy, float hradius, float hheight);
 void TCOD_heightmap_dig_bezier(TCOD_heightmap_t *hm, int px[4], int py[4], float startRadius, float startDepth, float endRadius, float endDepth);
 void TCOD_heightmap_rain_erosion(TCOD_heightmap_t *hm, int nbDrops,float erosionCoef,float sedimentationCoef,TCOD_random_t rnd);
// void TCOD_heightmap_heat_erosion(TCOD_heightmap_t *hm, int nbPass,float minSlope,float erosionCoef,float sedimentationCoef,TCOD_random_t rnd);
 void TCOD_heightmap_kernel_transform(TCOD_heightmap_t *hm, int kernelsize, int *dx, int *dy, float *weight, float minLevel,float maxLevel);
 void TCOD_heightmap_add_voronoi(TCOD_heightmap_t *hm, int nbPoints, int nbCoef, float *coef,TCOD_random_t rnd);
// void TCOD_heightmap_mid_point_deplacement(TCOD_heightmap_t *hm, TCOD_random_t rnd);
 void TCOD_heightmap_add_fbm(TCOD_heightmap_t *hm, TCOD_noise_t noise,float mulx, float muly, float addx, float addy, float octaves, float delta, float scale); 
 void TCOD_heightmap_scale_fbm(TCOD_heightmap_t *hm, TCOD_noise_t noise,float mulx, float muly, float addx, float addy, float octaves, float delta, float scale); 
 void TCOD_heightmap_islandify(TCOD_heightmap_t *hm, float seaLevel,TCOD_random_t rnd);

