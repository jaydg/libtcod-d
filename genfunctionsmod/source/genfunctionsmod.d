/**
 * Generate the tcod.functions module from a flat list of functions,
 * given on stdin. Output to stdout.
 *
 * This is not particularly general purpose; it makes a lot of
 * assumptions about the function list that it will be given.
 */
module genfunctionsmod;

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

    stdout.writeln(`/// This module has been automatically generated.
module tcod.c.functions;

version(Posix) {
    import core.sys.posix.dlfcn;
} else {
    import core.runtime;
    import std.c.windows.windows;
}

import std.string: toStringz;

import tcod.c.all;
import tcod.c.types;
`);

    // Okay, first declare the function variables.
	stdout.writeln("extern(C) @nogc nothrow {");
    foreach (functionName, functionDefinition; functions) {
        stdout.writeln("\t alias da_", functionName, " = ", functionDefinition, ";");
    }
    stdout.writeln("}\n");

	stdout.writeln("__gshared {");
    foreach (functionName; functions.byKey()) {
        stdout.writeln("\t da_", functionName, " ", functionName, ";");
    }
    stdout.writeln("}");

    stdout.writeln(`
private __gshared void* gTCODhandle;

private T getSymbol(T = void*)(string symbolName)
{
    version(Posix) {
        return cast(T)dlsym(gTCODhandle, symbolName.toStringz);
    } else {
        return cast(T)GetProcAddress(cast(HMODULE)gTCODhandle, symbolName.toStringz);
    }
}

static ~this() {
    version(Posix) {
        dlclose(gTCODhandle);
    } else {
        Runtime.unloadLibrary(gTCODhandle);
    }
}

static this() {
    version (Posix) {
        gTCODhandle = dlopen("./libtcod_debug.so".toStringz, RTLD_NOW);
        if (!gTCODhandle) {
            gTCODhandle = dlopen("./libtcod.so".toStringz, RTLD_NOW);
        }
    } else {
        gTCODhandle = Runtime.loadLibrary("libtcod_debug.dll");
        if (!gTCODhandle) {
            gTCODhandle = Runtime.loadLibrary("libtcod.dll");
        }
    }

    assert(gTCODhandle);
`);

    // Now load the functions from the shared object, asserting each time.
    foreach (functionName; functions.byKey()) {
        stdout.writeln("    ", functionName, " = getSymbol!(typeof(", functionName, "))(\"", functionName, "\");");
        stdout.writeln("    assert(", functionName, ");");
    }

    stdout.writeln("}\n");
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
