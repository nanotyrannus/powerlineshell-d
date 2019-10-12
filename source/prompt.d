module powerlineshell.prompt;

import powerlineshell.segment;
import powerlineshell.config;

Segment promptEnd()
{
    return segment!((out Segment s) {
        s.fg = term_fg;
        s.bg = term_bg;
        return `$`;
    });
}
