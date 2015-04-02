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
        AddBio,
        AddCompanions,
        AddIndividual,
        AddQuote,
        AddStudent,
        AddTafsir,
        AddTafsirPage,
        AddTeacher,
        AddWebsite,
        ClearAllBookmarks,
        CopyIndividualsFromSource,
        EditBio,
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
        FetchAllWebsites,
        FetchAyat,
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
        LinkAyatsToTafsir,
        LinkingAyatsToTafsir,
        RemoveBio,
        RemoveBookmark,
        RemoveCompanions,
		RemoveIndividual,
        RemoveQuote,
        RemoveStudent,
        RemoveTafsir,
        RemoveTafsirPage,
        RemoveTeacher,
        RemoveWebsite,
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
        UpdateTafsirLink
    };
};

}

#endif /* QUERYID_H_ */
