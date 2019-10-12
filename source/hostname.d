module powerlineshell.hostname;

import powerlineshell.config;
import powerlineshell.segment;

import std.socket;

Segment hostnameSegment()
{
    return segment!((out Segment s) {
        s.fg = fg_2;
        s.bg = bg_2;
        return Socket.hostName;
    });
}
