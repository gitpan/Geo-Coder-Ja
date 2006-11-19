use strict;
use warnings;

use Test::More;
use Geo::Coder::Ja qw(:all);

unless ($ENV{GEOCODER_JA_DBPATH}) {
    Test::More->import(skip_all => "no dbpath set, skipped.");
    exit;
}

plan tests => 8;

my $geocoder;
eval { 
    $geocoder = Geo::Coder::Ja->new(
        dbpath     => $ENV{GEOCODER_JA_DBPATH},
        encoding   => 'UTF-8',
        load_level => DB_GYOSEI,
    );
};

isa_ok($geocoder, 'Geo::Coder::Ja', 'isa');
is(sprintf('%s', @$), '', 'init');

is($geocoder->encoding, 'UTF-8', 'encoding');

my $location = $geocoder->geocode('渋谷区');
is($location->{latitude}, 35.66075, 'latitude');
is($location->{longitude}, 139.701305277778, 'longitude');
is($location->{address}, '東京都渋谷区', 'address');
is($location->{address_kana}, 'とうきょうとしぶやく', 'address_kana');

$geocoder->encoding('EUC-JP');
is($geocoder->encoding, 'EUC-JP', 'set_encoding');
