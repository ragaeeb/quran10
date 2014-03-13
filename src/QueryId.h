#ifndef QUERYID_H_
#define QUERYID_H_

#include <qobjectdefs.h>

namespace quran {

class QueryId
{
    Q_GADGET
    Q_ENUMS(Type)

public:
    enum Type {
        FetchAllAyats,
        FetchAllDuaa,
        FetchAllSurahs,
        FetchPageNumbers,
        FetchRandomAyat,
        FetchSurahHeader,
        FetchTafsirContent,
        FetchTafsirForAyat,
        FetchTafsirForSurah,
        FetchTafsirIbnKatheerForSurah,
        FetchTafsirIbnKatheerHeader,
        SearchQueryPrimary,
        SearchQueryTranslation
    };
};

}

#endif /* QUERYID_H_ */
