module powerlineshell.user;

import powerlineshell.config;
import powerlineshell.segment;

Segment userSegment()
{
    return segment!((out Segment s) { 
        s.fg = fg_1; 
        s.bg = bg_1; 
        return `\u`; }
    );
}
