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
module tcod.random;

import tcod.c.functions;
import tcod.c.types;

/**
 Pseudorandom number generator

 This toolkit is an implementation of two fast and high quality pseudorandom
 number generators:
 * a Mersenne twister generator,
 * a Complementary-Multiply-With-Carry generator.

 CMWC is faster than MT (see table below) and has a much better period (1039460
 vs. 106001). It is the default algo since libtcod 1.5.0.

Relative performances in two independent tests (lower is better) :
<table class="param">
    <tr>
      <th>Algorithm</th>
      <th>Numbers generated</th>
      <th>Perf (1)</th>
      <th>Perf (2)</th>
    </tr>
    <tr>
      <td>MT</td>
      <td>integer</td>
      <td>62</td>
      <td>50</td>
    </tr>
    <tr>
      <td>MT</td>
      <td>float</td>
      <td>54</td>
      <td>45</td>
    </tr>
    <tr>
      <td>CMWC</td>
      <td>integer</td>
      <td>21</td>
      <td>34</td>
    </tr>
    <tr>
      <td>CMWC</td>
      <td>float</td>
      <td>32</td>
      <td>27</td>
    </tr>
</table>
 */

class TCODRandom {
public :
    /**
    Creating a generator

    Default generator
    The simplest way to get random number is to use the default generator.
    The first time you get this generator, it is initialized by calling
    getInstance. Then, on successive calls, this function returns the
    same generator (singleton pattern).
    */
    static TCODRandom getInstance() {
        if (this.instance is null) {
            instance = new TCODRandom(TCOD_RNG_CMWC, true);
        }
        return instance;
    }

    /**
    Generators with random seeds.

    You can also create as many generators as you want with a random seed
    (the number of seconds since Jan 1 1970 at the time the constructor
    is called). Warning ! If you call this function several times in the
    same second, it will return the same generator.

    Params:
        algo = The PRNG algorithm the generator should be using.
               Possible values are:
               * TCOD_RNG_MT for Mersenne Twister,
               * TCOD_RNG_CMWC for Complementary Multiply-With-Carry.
    */
    this(TCOD_random_algo_t algo = TCOD_RNG_CMWC, bool allocate = true) {
        if (allocate) data = TCOD_random_new(algo);
    }

    /**
    Generators with user defined seeds.

    Finally, you can create generators with a specific seed. Those allow you
    to get a reproducible set of random numbers. You can for example save a
    dungeon in a file by saving only the seed used for its generation
    (provided you have a determinist generation algorithm).

    Params:
        seed = The 32 bits seed used to initialize the generator. Two
               generators created with the same seed will generate the same
               set of pseudorandom numbers.
        algo = The PRNG algorithm the generator should be using.


    Example:
    ---
    // default generator
    TCODRandom default = TCODRandom::getInstance();
    // another random generator
    TCODRandom myRandom = new TCODRandom();
    // a random generator with a specific seed
    TCODRandom myDeterministRandom = new TCODRandom(0xdeadbeef);
    ---
    */
    this(uint seed, TCOD_random_algo_t algo = TCOD_RNG_CMWC) {
        data = TCOD_random_new_from_seed(algo, seed);
    }

    /**
    Destroying a RNG

    To release ressources used by a generator, use this function.
    NB : do not delete the default random generator!
    ---
    // create a generator
    TCODRandom rnd = new TCODRandom();

    // destroy it
    delete rnd;
    ---
    */
    ~this() {
        TCOD_random_delete(data);
    }

    /**
    Setting the default RNG distribution

    Random numbers can be obtained using several different distributions.
    Linear is default, but if you wish to use one of the available Gaussian
    distributions, you can use this function to tell libtcod which is your
    preferred distribution. All random number getters will then use that
    distribution automatically to fetch your random numbers.

    The distributions available are as follows:
    $(DL
        $(DT TCOD_DISTRIBUTION_LINEAR)
        $(DD This is the default distribution. It will return a number from a
           range min-max. The numbers will be evenly distributed, ie, each
           number from the range has the exact same chance of being selected.)
        $(DT TCOD_DISTRIBUTION_GAUSSIAN)
        $(DD This distribution does not have minimum and maximum values. Instead,
           a mean and a standard deviation are used. The mean is the central
           value. It will appear with the greatest frequency. The farther away
           from the mean, the less the probability of appearing the possible
           results have. Although extreme values are possible, 99.7% of the
           results will be within the radius of 3 standard deviations from
           the mean. So, if the mean is 0 and the standard deviation is 5,
           the numbers will mostly fall in the (-15,15) range.)
        $(DT TCOD_DISTRIBUTION_GAUSSIAN_RANGE)
        $(DD This one takes minimum and maximum values. Under the hood, it
           computes the mean (which falls right between the minimum and maximum)
           and the standard deviation and applies a standard Gaussian
           distribution to the values. The difference is that the result is
           always guaranteed to be in the min-max range)
        $(DT TCOD_DISTRIBUTION_GAUSSIAN_INVERSE)
        $(DD Essentially, this is the same as TCOD_DISTRIBUTION_GAUSSIAN. The
           difference is that the values near +3 and -3 standard deviations
           from the mean have the highest possibility of appearing, while the
           mean has the lowest.)
        $(DT TCOD_DISTRIBUTION_GAUSSIAN_RANGE_INVERSE)
        $(DD Essentially, this is the same as TCOD_DISTRIBUTION_GAUSSIAN_RANGE,
           but the min and max values have the greatest probability of
           appearing, while the values between them, the lowest.)
    )

        There exist functions to also specify both a min-max range AND a custom
        mean, which can be any value (possibly either min or max, but it can
        even be outside that range). In case such a function is used, the
        distributions will trigger a slitly different behaviour:

        $(UL
          $(LI TCOD_DISTRIBUTION_LINEAR)
          $(LI TCOD_DISTRIBUTION_GAUSSIAN)
          $(LI TCOD_DISTRIBUTION_GAUSSIAN_RANGE)
        )

        In these cases, the selected mean will have the highest probability
        of appearing.

        $(UL
          $(LI TCOD_DISTRIBUTION_GAUSSIAN_INVERSE)
          $(LI TCOD_DISTRIBUTION_GAUSSIAN_RANGE_INVERSE))
        In these cases, the selected mean will appear with the lowest frequency.

        Params:
            distribution = The distribution constant from the available set:
            <ul>
                <li>TCOD_DISTRIBUTION_LINEAR</li>
                <li>TCOD_DISTRIBUTION_GAUSSIAN</li>
                <li>TCOD_DISTRIBUTION_GAUSSIAN_RANGE</li>
                <li>TCOD_DISTRIBUTION_GAUSSIAN_INVERSE</li>
                <li>TCOD_DISTRIBUTION_GAUSSIAN_RANGE_INVERSE</li>
            </ul>
    */
    void setDistribution (TCOD_distribution_t distribution) {
        TCOD_random_set_distribution(data,distribution);
    }

    /**
    Getting an integer.

    Once you obtained a generator (using one of those methods), you can get
    random numbers using the following functions, using either the explicit
    or simplified API where applicable.

    Params:
        min = Start of range of values returned.
        max = End of range of values returned. Each time you call this function,
              you get a number between (including) min and max
        mean = This is used to set a custom mean, ie, not min+((max-min)/2).
               It can even be outside of the min-max range. Using a mean will
               force the use of a weighted (Gaussian) distribution, even if
               linear is set.
    */
    int getInt (int min, int max, int mean = 0) {
        return (mean <= 0) ? TCOD_random_get_int(data,min,max) : TCOD_random_get_int_mean(data,min,max,mean);
    }

    /** ditto */
    int get (int min, int max, int mean = 0) {
        return (mean <= 0) ? TCOD_random_get_int(data,min,max) : TCOD_random_get_int_mean(data,min,max,mean);
    }

    /**
    Getting a float.

    To get a random floating point number, using either the explicit or
    simplified API where applicable.

    Params:
        min = Start of range of values returned.
        max = End of range of values returned. Each time you call this function,
              you get a number between (including) min and max.
        mean = This is used to set a custom mean, i.e., not min + ((max - min) / 2).
               It can even be outside of the min-max range. Using a mean will
               force the use of a weighted (Gaussian) distribution, even if
               linear is set.

    Example:
    ---
    // default generator
    TCODRandom default = TCODRandom.getInstance();
    int aRandomIntBetween0And1000 = default.getInt(0,1000);
    int anotherRandomInt = default.get(0,1000);
    // another random generator
    TCODRandom myRandom = new TCODRandom();
    float aRandomFloatBetween0And1000 = myRandom.getFloat(0.0f,1000.0f);
    float anotherRandomFloat = myRandom.get(0.0f,1000.0f);
    ---
    */
    float getFloat (float min, float max, float mean = 0.0f) {
        return (mean <= 0) ? TCOD_random_get_float(data,min,max) : TCOD_random_get_float_mean(data,min,max,mean);
    }

    /** ditto */
    float get (float min, float max, float mean = 0.0f) {
        return (mean <= 0.0f) ? TCOD_random_get_float(data,min,max) : TCOD_random_get_float_mean(data,min,max,mean);
    }

    /**
    Getting a double.

    To get a random double precision floating point number, using either the
    explicit or simplified API where applicable.

    Params:
        min = Start of range of values returned.
        max = End of range of values returned. Each time you call this
              function, you get a number between (including) min and max
        mean = This is used to set a custom mean, ie, not min+((max-min)/2).
               It can even be outside of the min-max range. Using a mean will
               force the use of a weighted (Gaussian) distribution, even if
               linear is set.

    Example:
    ---
    // default generator
    TCODRandom default = TCODRandom.getInstance;
    int aRandomIntBetween0And1000 = default. getInt(0, 1000);
    int anotherRandomInt = default.get(0, 1000);

    // another random generator
    TCODRandom myRandom = new TCODRandom();
    float aRandomFloatBetween0And1000 = myRandom.getFloat(0.0f, 1000.0f);
    float anotherRandomFloat = myRandom.get(0.0f, 1000.0f);
    ---
    */
    double getDouble (double min, double max, double mean = 0.0) {
        return (mean <= 0) ? TCOD_random_get_double(data,min,max) : TCOD_random_get_double_mean(data,min,max,mean);
    }

    /** ditto */
    double get(double min, double max, double mean = 0.0f) {
        return (mean <= 0.0) ? TCOD_random_get_double(data,min,max) : TCOD_random_get_double_mean(data,min,max,mean);
    }

    /**
    Saving a RNG state.
    */
    TCODRandom save() {
        TCODRandom ret = new TCODRandom((cast(mersenne_data_t *)data).algo, false);
        ret.data = TCOD_random_save(data);
        return ret;
    }
    /**
    Restoring a saved state makes it possible to get the same serie of numbers
    several times with a single generator.


    Example:
    ---
    // default generator
    TCODRandom default = TCODRandom.getInstance();

    // save the state
    TCODRandom backup = default.save();

    // get a random number (or several)
    int number1 = default.getInt(0, 1000);

    // restore the state
    default.restore(backup);

    // get a random number
    int number2 = default.getInt(0, 1000);
    // => number1 == number2
    ---
    */
    void restore(TCODRandom backup) {
        TCOD_random_restore(data, data);
    }

    //dice
    TCOD_dice_t dice (const char* s) {
        return TCOD_random_dice_new(s);
    }

    int diceRoll (TCOD_dice_t dice) {
        return TCOD_random_dice_roll(data,dice);
    }

    int diceRoll (const char* s) {
        return TCOD_random_dice_roll(data, TCOD_random_dice_new(s));
    }

package :
    TCOD_random_t data;

private:
    static TCODRandom instance = null;

    /* from libtcod_int.h */
    extern (C) struct mersenne_data_t {
        /* algorithm identifier */
        TCOD_random_algo_t algo;
        /* distribution */
        TCOD_distribution_t distribution;
        /* Mersenne Twister stuff */
        uint[624] mt;
        int cur_mt;
        /* Complementary-Multiply-With-Carry stuff */
        /* shared with Generalised Feedback Shift Register */
        uint[4096] Q, c;
        int cur;
    }
}
