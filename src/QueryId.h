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
        ClearAllBookmarks,
        FetchAdjacentAyat,
        FetchAllAyats,
        FetchAllBookmarks,
        FetchAllChapterAyatCount,
        FetchAllChapters,
        FetchAllDuaa,
        FetchAllIndividuals,
        FetchAllLocations,
        FetchAllOrigins,
        FetchAllQuotes,
        FetchAllRecitations,
        FetchAllTafsir,
        FetchAllTafsirForSuite,
        FetchAllWebsites,
        FetchAyat,
        FetchAyats,
        FetchAyatsForTafsir,
        FetchBio,
        FetchChapters,
        FetchJuz,
        FetchLastProgress,
        FetchIndividualData,
        FetchPageNumbers,
        FetchQuote,
        FetchRandomAyat,
        FetchRandomQuote,
        FetchSimilarAyatContent,
        FetchStudents,
        FetchSurahHeader,
        FetchTafsirContent,
        FetchTafsirCountForAyat,
        FetchTafsirForAyat,
        FetchTafsirForSurah,
        FetchTafsirHeader,
        FetchTeachers,
        FetchTransliteration,
        RemoveBookmark,
        SaveBookmark,
        SaveLastProgress,
        SaveLegacyBookmarks,
        SearchAyats,
        SettingUpBookmarks,
        SettingUpTafsir,
        SetupBookmarks,
        SetupTafsir
    };
};

}

#endif /* QUERYID_H_ */
