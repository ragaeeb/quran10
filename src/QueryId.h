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
        AddLocation,
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
        EditLocation,
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
        LinkAyatsToTafsir,
        LinkingAyatsToTafsir,
        RemoveBio,
        RemoveBookmark,
        RemoveCompanions,
		RemoveIndividual,
        RemoveLocation,
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
