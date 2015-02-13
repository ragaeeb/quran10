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
        AddIndividual,
        AddTafsir,
        AddTafsirPage,
        ClearAllBookmarks,
        EditIndividual,
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
        FetchAyatsForTafsir,
        FetchChapters,
        FetchJuz,
        FetchPageNumbers,
        FetchRandomAyat,
        FetchSimilarAyatContent,
        FetchSurahHeader,
        FetchTafsirForAyat,
        FetchTafsirForSurah,
        FetchTafsirContent,
        FetchTafsirHeader,
        LinkAyatsToTafsir,
        RemoveBookmark,
        RemoveTafsir,
        RemoveTafsirPage,
        SaveBookmark,
        SearchAyats,
        SearchIndividuals,
        SearchTafsir,
        SettingUpBookmarks,
        SetupBookmarks,
        UnlinkAyatsFromTafsir,
        UpdatePlugins
    };
};

}

#endif /* QUERYID_H_ */
