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

module tcod.bresenham;

import tcod.c.functions;

/**
 */
extern (C) alias line_listener = bool function(int x, int y);

/**
    Line drawing toolkit

    This toolkit is a very simple and lightweight implementation of the
    bresenham line drawing algorithm. It allows you to follow straight
    paths on your map very easily.
 */
class TCODLine {
public :
    /**
    Initializing the line

    First, you have to initialize the toolkit with your starting and ending coordinates.

    Params:
        xFrom = x coordinate of the line's starting point.
        yFrom = y coordinate of the line's starting point.
        xTo = x coordinate of the line's ending point.
        yTo = y coordinate of the line's ending point.
    */
    static void init(int xFrom, int yFrom, int xTo, int yTo) {
        TCOD_line_init(xFrom, yFrom, xTo, yTo);
    }

    /**
    Walking the line

    You can then step through each cell with this function. It returns true
    when you reach the line's ending point.

    Params:
        xCur = the x coordinate of the next cell on the line are stored here when the function returns
        yCur = the y coordinate of the next cell on the line are stored here when the function returns

    Example:
    ---
    // Going from point 5, 8 to point 13, 4
    int x = 5, y = 8;
    TCODLine.init(x, y, 13, 4);
    do {
        // update cell x, y
    } while (!TCODLine.step(&x, &y));
    ---
    */
    static bool step(int *xCur, int *yCur) {
        return TCOD_line_step(xCur, yCur) != 0;
    }

    /**
    Callback-based function

    The function returns false if the line has been interrupted by the callback
    (it returned false before the last point).

    Params:
        xFrom = x coordinate of the line's starting point.
        yFrom = y coordinate of the line's starting point.
        xTo = x coordinate of the line's ending point.
        yTo	= y coordinate of the line's ending point.
        listener = Callback called for each line's point. The function stops if the callback returns false.

    Example:
    ---
    // Going from point 5,8 to point 13,4
    class MyLineListener : public TCODLineListener {
        public:
        bool putPoint (int x, int y) {
            writefln ("%d %d", x, y);
            return true;
        }
    };

    MyLineListener myListener;
    TCODLine.line(5,8,13,4, &myListener);
    ---
    */
    static bool line(int xFrom, int yFrom, int xTo, int yTo, line_listener *listener);
}
