/**
 * Generate the tcod.functions module from a flat list of functions,
 * given on stdin. Output to stdout.
 *
 * This is not particularly general purpose; it makes a lot of
 * assumptions about the function list that it will be given.
 */
module genfunctionsmod;

import std.stdio;
import std.ascii : isWhite;
import std.string;


void main()
{
    stdout.writeln("/// This module has been automatically generated.");
    stdout.writeln("module tcod.c.functions;\n");

    stdout.writeln("version(Posix) {");
    stdout.writeln("    import core.sys.posix.dlfcn;");
    stdout.writeln("} else {");
    stdout.writeln("    import core.runtime;");
    stdout.writeln("    import std.c.windows.windows;");
    stdout.writeln("}\n");

    stdout.writeln("import std.string: toStringz;\n");

    stdout.writeln("import tcod.c.all;");
    stdout.writeln("import tcod.c.types;\n");

    stdout.writeln("extern (C):\n");

    string[] functions;
    foreach (line; stdin.byLine) {
        if (line.emptyOrWhitespace()) continue;
        functions ~= line.idup;
    }

    // Okay, first declare the function variables.
    foreach (functionLine; functions) {
        stdout.writeln("__gshared ", functionLine);
    }
    stdout.writeln();

    stdout.writeln("extern (D):\n");

    stdout.writeln("private __gshared void* gTCODhandle;");
    stdout.writeln();

    stdout.writeln("private T getSymbol(T = void*)(string symbolName)");
    stdout.writeln("{");
    stdout.writeln("    version(Posix) {");
    stdout.writeln("        return cast(T)dlsym(gTCODhandle, symbolName.toStringz);");
    stdout.writeln("    } else {");
    stdout.writeln("        return cast(T)GetProcAddress(cast(HMODULE)gTCODhandle, symbolName.toStringz);");
    stdout.writeln("    }");
    stdout.writeln("}");

    stdout.writeln("static ~this()\n{");
    stdout.writeln("    version(Posix) {");
    stdout.writeln("        dlclose(gTCODhandle);");
    stdout.writeln("    } else {");
    stdout.writeln("        Runtime.unloadLibrary(gTCODhandle);");
    stdout.writeln("    }");
    stdout.writeln("}\n");

    stdout.writeln("static this()\n{");
    stdout.writeln("    version (Posix) {");
    stdout.writeln(`        gTCODhandle = dlopen("./libtcod_debug.so".toStringz, RTLD_NOW);`);
    stdout.writeln(`        if (!gTCODhandle) {`);
    stdout.writeln(`            gTCODhandle = dlopen("./libtcod.so".toStringz, RTLD_NOW);`);
    stdout.writeln(`        }`);
    stdout.writeln("    } else {");
    stdout.writeln(`        gTCODhandle = Runtime.loadLibrary("libtcod_debug.dll");`);
    stdout.writeln(`        if (!gTCODhandle) {`);
    stdout.writeln(`            gTCODhandle = Runtime.loadLibrary("libtcod.dll");`);
    stdout.writeln(`        }`);
    stdout.writeln("    }");
    stdout.writeln("    assert(gTCODhandle);\n");

    // Now load the functions from the shared object, asserting each time.
    foreach (functionLine; functions) {
        string[] functionParts = split(functionLine, " ");
        string functionName = "";

        foreach (functionPart; functionParts) {
            if (functionPart.length >= 4 && functionPart[0 .. 4] == "TCOD" && functionPart[$ - 1] == ';') {
                functionName = functionPart[0 .. $ - 1];  // Remove trailing semicolon.
                break;
            }
        }
        if (functionName.length == 0) throw new Exception("Malformed function line.");

        stdout.writeln("    ", functionName, " = cast(typeof(", functionName, ")) getSymbol(\"", functionName, "\");");
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
