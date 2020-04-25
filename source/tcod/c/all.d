/*
 * libtcod 1.5.0
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

module tcod.c.all;

extern (C):

// base types
alias ubyte uint8;
alias byte int8;
alias ushort uint16;
alias short int16;
alias uint uint32;
alias int int32;

const int TCOD_HEXVERSION = 0x010607;
const string TCOD_STRVERSION = "1.6.7";
const int TCOD_TECHVERSION = 0x01060700;
charptr TCOD_STRVERSIONNAME = "libtcod 1.6.7";

/******************************************
 utility macros
 ******************************************/
pure T MAX(T)(T a, T b) { return (a < b) ? b : a; }
pure T MIN(T)(T a, T b) { return (a > b) ? b : a; }
pure T ABS(T)(T a) { return (a < 0) ? -a : a; }
pure T CLAMP(T)(T a, T b, T x) { return (x < a) ? a : ((x > b) ? b : x); }
pure T LERP(T)(T a, T b, T x) { return (a + x * (b - a)); }

alias const(char)* charptr;
version (Posix) {
    alias const(dchar)* wchar_tptr;
    alias dchar wchar_t;
}
version (Windows) {
    alias const(wchar)* wchar_tptr;
    alias wchar wchar_t;
}

public import tcod.c.types;
public import tcod.c.functions;
