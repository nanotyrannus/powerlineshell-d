import std.stdio;
import std.string;
import std.array;
import std.socket;
import std.process;

enum int[string] config = [
    "background" : 180,
    "foreground" : 120
];

void main(string[] args)
{
    string separator = "";
    string terminator = `\[\e[m\]` ~ `\[\033[38;5;%sm\]%s`.format(config["background"],separator);
    string[] segments;
    segments ~= `\[\033[38;5;%s;48;5;%sm\]`.format(config["background"], config["foreground"]) ~ ` %s `.format(environment["USER"]);
    segments ~= `\[\033[38;5;%s;48;5;%sm\]%s`.format(config["foreground"], config["background"], separator);
    segments ~= ` %s `.format(Socket.hostName());
    string result = segments.join();
    result ~= terminator;
    result.writeln();
    //`\[\e[31;40m\]\u@\h>\[\e[m\]`.writeln();
}
