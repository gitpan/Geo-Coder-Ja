use strict;
use warnings;

use Test::More;
use Geo::Coder::Ja qw(:all);

unless ($ENV{GEOCODER_JA_DBPATH}) {
    Test::More->import(skip_all => "no dbpath set, skipped.");
    exit;
}

plan tests => 12;

my $geocoder;
eval { 
    $geocoder = Geo::Coder::Ja->new(
        dbpath     => $ENV{GEOCODER_JA_DBPATH},
        encoding   => 'EUC-JP',
        load_level => DB_CHO,
    );
};

isa_ok($geocoder, 'Geo::Coder::Ja', 'isa');
is($@, '', 'init');

is($geocoder->encoding, 'EUC-JP', 'encoding');

my $location = $geocoder->geocode(location => '��ë��');
is($location->{latitude}, 35.66075, 'latitude');
is($location->{longitude}, 139.701305277778, 'longitude');
is($location->{address}, '����Խ�ë��', 'address');
is($location->{address_kana}, '�Ȥ����礦�Ȥ��֤䤯', 'address_kana');

$location = $geocoder->geocode(postcode => '0986758');
is($location->{latitude}, 45.4133611111111, 'latitude');
is($location->{longitude}, 141.677, 'longitude');
is($location->{address}, '�̳�ƻ�����', 'address');
is($location->{address_kana}, '�ۤä����ɤ���ä��ʤ���', 'address_kana');

$geocoder->encoding('UTF-8');
is($geocoder->encoding, 'UTF-8', 'set_encoding');
