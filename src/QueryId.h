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
        AddTafsir,
        AddTafsirPage,
        ClearAllBookmarks,
        EditTafsir,
        EditTafsirPage,
        FetchAllAyats,
        FetchAllBookmarks,
        FetchAllChapters,
        FetchAllDuaa,
        FetchAllRecitations,
        FetchAllTafsir,
        FetchAllTafsirForSuite,
        FetchAyat,
        FetchChapters,
        FetchPageNumbers,
        FetchRandomAyat,
        FetchSimilarAyat,
        FetchSimilarAyatContent,
        FetchSurahHeader,
        FetchTafsirForAyat,
        FetchTafsirForSurah,
        FetchTafsirIbnKatheerForSurah,
        FetchTafsirIbnKatheerHeader,
        FetchTafsirContent,
        FetchTafsirHeader,
        LinkingAyats,
        LinkAyats,
        LinkAyatsToTafsir,
        RemoveBookmark,
        RemoveTafsir,
        RemoveTafsirPage,
        SaveBookmark,
        SearchAyats,
        SearchTafsir,
        SettingUpBookmarks,
        SetupBookmarks,
        UpdatePlugins
    };
};

}

#endif /* QUERYID_H_ */
