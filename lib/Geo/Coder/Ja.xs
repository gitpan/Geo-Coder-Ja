#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#define NEED_newCONSTSUB
#define NEED_newRV_noinc
#include "ppport.h"
#include "geocoder.h"
#include "gcjlib.h"

static void
init_constants()
{
    HV *stash;
    stash = gv_stashpv("Geo::Coder::Ja", 1);
    newCONSTSUB(stash, "DB_AUTO",   newSViv(DB_AUTO));
    newCONSTSUB(stash, "DB_GYOSEI", newSViv(DB_GYOSEI));
    newCONSTSUB(stash, "DB_CHO",    newSViv(DB_CHO));
    newCONSTSUB(stash, "DB_AZA",    newSViv(DB_AZA));
    newCONSTSUB(stash, "DB_GAIKU",  newSViv(DB_GAIKU));
    newCONSTSUB(stash, "DB_JUKYO",  newSViv(DB_JUKYO));
}

MODULE = Geo::Coder::Ja		PACKAGE = Geo::Coder::Ja		

BOOT:
    init_constants();

PROTOTYPES: ENABLE

SV *
load(self, dbpath, load_level)
        SV *self;
        int load_level;
        char *dbpath;
    PREINIT:
        int nret;
    CODE:
        nret = gcjDbLoad(dbpath, load_level);
        if (nret < 0) {
            croak("Can't load address database nret=%d", nret);
        }
        RETVAL = newSViv(nret);
    OUTPUT:
        RETVAL

SV *
set_encoding(self, encoding)
        SV *self;
        char *encoding;
    PREINIT:
        int nret;
    CODE:
        nret = gcjSetArgEncoding(encoding);
        if (nret < 0) {
            croak("Set encoding error : nret= %d", nret);
        }
        RETVAL = newSVpv(encoding, 0);
    OUTPUT:
        RETVAL

SV*
xs_geocode(self, location)
        SV *self;
        char *location;
    PREINIT:
        SV *sv;
        HV *hv;
        int nret, match_length, match_level;
        char kanji[STRMAX + 1], kana[STRMAX + 1];
        double latitude, longitude;
        ADR_CODE adr_code;
    CODE:
        match_length = gcjAdrStr2Code(location, &adr_code);
        if (match_length > 0) {
            match_level = gcjAdrCode2Str(&adr_code, kanji, STRMAX, kana, STRMAX);
            if (match_level > 0) {
                nret = gcjAdrCode2Point(&adr_code, &latitude, &longitude);
                if (nret == 0) {
                    hv = newHV();
                    hv_store(hv, "latitude", 8, newSVnv(latitude), 0);
                    hv_store(hv, "longitude", 9, newSVnv(longitude), 0);
                    hv_store(hv, "address", 7, newSVpv(kanji, 0), 0);
                    hv_store(hv, "address_kana", 12, newSVpv(kana, 0), 0);
                    sv = newRV_noinc((SV *) hv);
                    RETVAL = sv;
                } else {
                    RETVAL = &PL_sv_undef;
                }
            } else {
                croak("matched but error when convert to string.");
            }
        } else {
            RETVAL = &PL_sv_undef;
        }
    OUTPUT:
        RETVAL

void
DESTROY(self)
        SV *self;
    CODE:
        gcjDbEnd();

