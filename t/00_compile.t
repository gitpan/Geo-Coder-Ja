use strict;
use warnings;

use Test::More tests => 4;

BEGIN {
    use_ok('Geo::Coder::Ja', ':all');
}

can_ok('Geo::Coder::Ja', 'load');
can_ok('Geo::Coder::Ja', 'set_encoding');
can_ok('Geo::Coder::Ja', 'xs_geocode');
