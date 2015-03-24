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
        AddCompanions,
        AddIndividual,
        AddQuote,
        AddTafsir,
        AddTafsirPage,
        ClearAllBookmarks,
        CopyIndividualsFromSource,
        EditIndividual,
        EditQuote,
        EditTafsir,
        EditTafsirPage,
        FetchAdjacentAyat,
        FetchAllAyats,
        FetchAllBookmarks,
        FetchAllChapterAyatCount,
        FetchAllChapters,
        FetchAllDuaa,
        FetchAllIndividuals,
        FetchAllQuotes,
        FetchAllRecitations,
        FetchAllTafsir,
        FetchAllTafsirForSuite,
        FetchAyat,
        FetchAyatsForTafsir,
        FetchBio,
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
        FetchTransliteration,
        LinkAyatsToTafsir,
        LinkingAyatsToTafsir,
        RemoveBookmark,
        RemoveCompanions,
		RemoveIndividual,
        RemoveQuote,
        RemoveTafsir,
        RemoveTafsirPage,
        ReplacingIndividual,
        ReplaceIndividual,
        SaveBookmark,
        SaveLastProgress,
        SaveLegacyBookmarks,
        SearchAyats,
        SearchIndividuals,
        SearchQuote,
        SearchTafsir,
        SettingUpBookmarks,
        SetupBookmarks,
        UnlinkAyatsFromTafsir,
    };
};

}

#endif /* QUERYID_H_ */
