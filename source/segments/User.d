module segments.User;

import std.stdio;
import std.string;
import segments.Segment;

class User : Segment
{

    this(int[string] config)
    {
        segmentText = `\[\033[38;5;%s;48;5;%sm\]`.format(config["bg_1"],
                config["fg_1"]) ~ ` \u `;
    }

    ~this()
    {
    }
}
