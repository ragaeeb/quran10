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
        AddQuote,
        AddTafsir,
        AddTafsirPage,
        ClearAllBookmarks,
        EditIndividual,
        EditQuote,
        EditTafsir,
        EditTafsirPage,
        FetchAllAyats,
        FetchAllBookmarks,
        FetchAllChapters,
        FetchAllDuaa,
        FetchAllQuotes,
        FetchAllRecitations,
        FetchAllTafsir,
        FetchAllTafsirForSuite,
        FetchAyat,
        FetchAyatsForTafsir,
        FetchChapters,
        FetchJuz,
        FetchLastProgress,
        FetchPageNumbers,
        FetchQuote,
        FetchRandomAyat,
        FetchRandomQuote,
        FetchSimilarAyatContent,
        FetchSurahHeader,
        FetchTafsirContent,
        FetchTafsirCountForAyat,
        FetchTafsirForAyat,
        FetchTafsirForSurah,
        FetchTafsirHeader,
        LinkAyatsToTafsir,
        RemoveBookmark,
        RemoveQuote,
        RemoveTafsir,
        RemoveTafsirPage,
        SaveBookmark,
        SaveLastProgress,
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
