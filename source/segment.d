module myApp.segment;

import std.string;

/// Returns ANSI sequence that resets color on
/// subsequent characters.
string reset()
{
    return `\[\e[m\]`;
}

string colorSequence(long fg, long bg)
{
    return `\[\033[38;5;%s;48;5;%sm\]`.format(fg, bg);
}
struct Segment
{
    Segment[] children;
    string text;
    string colorControl;
    string point;
    long fg = 7;
    long bg = 0;
    string toString()
    {
        if (text.length > 0)
        {
            return colorSequence(fg, bg) ~ ` %s `.format(text) ~ point;
        }
        else
        {
            return ``;
        }
    }

}

Segment segment(string function(out Segment s) action)()
{
    Segment s;
    s.text = action(s);
    return s;
}