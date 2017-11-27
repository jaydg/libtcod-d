/**
 * Generate the tcod.functions module from a flat list of functions,
 * given on stdin. Output to stdout.
 *
 * This is not particularly general purpose; it makes a lot of
 * assumptions about the function list that it will be given.
 */
module genfunctionsmod;

import std.algorithm : sort;
import std.conv : to;
import std.stdio;
import std.ascii : isWhite;
import std.string;


void main()
{
    string[string] functions;

	foreach (line; stdin.byLine) {
        if (line.emptyOrWhitespace()) continue;

        string[] functionParts = split(to!string(line), " ");
        string functionDefinition = functionParts[0 .. $ - 1].join(" ");
		string functionName = chop(functionParts[$ - 1]);
        if (functionName.length == 0) {
			throw new Exception("Malformed function line.");
		}

        functions[functionName] = functionDefinition;
    }

    stdout.write(`/// This module has been automatically generated.

module tcod.c.functions;

import core.runtime : Runtime;
import std.algorithm.iteration : map;
import std.path : dirName, dirSeparator;
import std.range : array;
import std.string: join, toStringz;

import derelict.util.loader;
import derelict.util.system;

import tcod.c.all;
import tcod.c.types;

extern(C) @nogc nothrow {
`);

    // Okay, first declare the function variables.
    foreach (func; sort(functions.keys)) {
        stdout.writeln("    alias da_", func, " = ", functions[func], ";");
    }

    stdout.write(`}

__gshared {
`);

    foreach (functionName; sort(functions.keys)) {
        stdout.writeln("    da_", functionName, " ", functionName, ";");
    }

    stdout.write(`}

class DerelictTCODLoader : SharedLibLoader {
    this(string libNames) {
        super(libNames);
    }

    ~this() {
        unload();
    }

    override void loadSymbols()
    {
`);

    // Now load the functions from the shared object, asserting each time.
    foreach (functionName; sort(functions.keys)) {
        stdout.writeln("        bindFunc(cast(void**)&", functionName, ", \"", functionName, "\");");
    }

stdout.write(`    }
}

__gshared DerelictTCODLoader DerelictTCOD;

shared static this()
{
    string[] libNames;
    if(Derelict_OS_Windows) {
        libNames = ["libtcod_debug.dll", "libtcod.dll"];
    } else if(Derelict_OS_Linux) {
        libNames = ["libtcod_debug.so", "libtcod.so"];

        // prepend executable path to library names
        string path = dirName(Runtime.args[0]);
        libNames = array(map!(e => path ~ dirSeparator ~ e)(libNames));
    } else
    assert(0, "libtcod-d is not supported on this operating system.");

    DerelictTCOD = new DerelictTCODLoader(join(libNames, ','));
    DerelictTCOD.load();
}
`);
}

/**
 * Returns: true if string `s` is comprised entirely of whitespace
 *          or is completely empty.
 */
bool emptyOrWhitespace(T)(T s)
{
    bool emptyOrWhite = true;
    foreach (c; s) {
        if (!isWhite(c)) {
            emptyOrWhite = false;
            break;
        }
    }

    return emptyOrWhite;
}

unittest
{
    assert(emptyOrWhitespace(""));
    assert(emptyOrWhitespace("   \t\n   \t \n"));
    assert(!emptyOrWhitespace("  a "));
}
