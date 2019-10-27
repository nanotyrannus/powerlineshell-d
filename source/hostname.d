module powerlineshell.hostname;

import powerlineshell.config;
import powerlineshell.segment;

import std.process;
import std.socket;
import std.string;

Segment hostnameSegment()
{
    return segment!((out Segment s) {
        string result;
        s.fg = fg_2;
        s.bg = bg_2;

        result = Socket.hostName;
        return result;
    });
}

Segment virtualEnvironmentSegment()
{
    return segment!((out Segment s) {
        string result;
        if (auto var = environment.get("VIRTUAL_ENV"))
        {
            s.fg = python_fg;
            s.bg = python_bg;
            result ~= "🐍 (" ~ var.strip.split('/')[$ - 1] ~ ")";
        }

        if (auto var = environment.get("CONDA_PROMPT_MODIFIER"))
        {   
            s.fg = conda_fg;
            s.bg = conda_bg;
            result = "🐍" ~ var.strip();
        }
        return result;
    });
}
