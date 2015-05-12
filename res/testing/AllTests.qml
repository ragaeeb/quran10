import bb.cascades 1.0
import com.canadainc.data 1.0

Container
{
    id: root
    
    attachedObjects: [
        QtObject
        {
            objectName: "Basic Search With 3 Results"
            
            function onDataLoaded(id, data)
            {
                harness.assert( this, [3, data.length, 3, data[0].surah_id, 8, data[0].verse_id, 38, data[1].surah_id == 38, 9, data[1].verse_id, 38, data[2].surah_id, 35, data[2].verse_id]);
            }
            
            function run()
            {
                helper.searchQuery(this, "الوهاب");
            }
        },
        
        QtObject
        {
            objectName: "Search With Restricted Chapter"
            
            function onDataLoaded(id, data)
            {
                harness.assert( this, [1, data.length, 3, data[0].surah_id, 8, data[0].verse_id]);
            }
            
            function run()
            {
                helper.searchQuery(this, "الوهاب", 
                3);
            }
        },
        
        QtObject
        {
            objectName: "Search With ANDs"
            
            function onDataLoaded(id, data)
            {
                harness.assert( this, [1, data.length, 3, data[0].surah_id, 14, data[0].verse_id]);
            }
            
            function run()
            {
                helper.searchQuery(this, "life", 0, ["gold"]);
            }
        },
        
        QtObject
        {
            objectName: "Search With ORs"
            
            function onDataLoaded(id, data)
            {
                harness.assert( this, [7, data.length, 4, data[0].surah_id, 43, data[0].verse_id]);
            }
            
            function run()
            {
                helper.searchQuery(this, "nature", 0, ["arouse"], false);
            }
        },
        
        QtObject
        {
            objectName: "Fetch Adjacent Ayat +1"
            
            function onDataLoaded(id, data)
            {
                harness.assert( this, [1, data.length, 1, data[0].surah_id, 2, data[0].verse_id]);
            }
            
            function run() {
                helper.fetchAdjacentAyat(this, 1, 1, 1);
            }
        },
        
        QtObject
        {
            objectName: "Fetch Adjacent Ayat -1"
            
            function onDataLoaded(id, data) {
                harness.assert( this, 0, data.length);
            }
            
            function run()
            {
                helper.fetchAdjacentAyat(this, 1, 1, -1);
            }
        },
        
        QtObject
        {
            objectName: "Fetch Adjacent Ayat End"
            
            function onDataLoaded(id, data) {
                harness.assert(this, 0, data.length);
            }
            
            function run()
            {
                helper.fetchAdjacentAyat(this, 114, 6, 1);
            }
        },
        
        QtObject
        {
            objectName: "Fetch Random Ayat"
            
            function onDataLoaded(id, data) {
                harness.assert(this, 1, data.length);
            }
            
            function run() {
                helper.fetchRandomAyat(this);
            }
        },
        
        QtObject
        {
            objectName: "Fetch All Ayats"
            
            function onDataLoaded(id, data) {
                harness.assert(this, 7, data.length);
            }
            
            function run() {
                helper.fetchAllAyats(this, 1);
            }
        },
        
        QtObject
        {
            objectName: "Fetch All Ayats For Surah 1-2"
            
            function onDataLoaded(id, data) {
                harness.assert(this, 7+286, data.length);
            }
            
            function run() {
                helper.fetchAllAyats(this, 1, 2);
            }
        },
        
        QtObject
        {
            objectName: "Fetch All Ayat Counts For Chapter"
            
            function onDataLoaded(id, data) {
                harness.assert(this, [114, data.length, 286, data[1].verse_count]);
            }
            
            function run() {
                helper.fetchAllChapterAyatCount(this);
            }
        },
        
        QtObject
        {
            objectName: "Fetch All Chapters With Juzs"
            
            function onDataLoaded(id, data) {
                harness.assert(this, 116, data.length);
            }
            
            function run() {
                helper.fetchAllChapters(this);
            }
        },
        
        QtObject
        {
            objectName: "Fetch Supplications"
            
            function onDataLoaded(id, data) {
                harness.assert(this, 55, data.length);
            }
            
            function run() {
                helper.fetchAllDuaa(this);
            }
        },
        
        QtObject
        {
            objectName: "Fetch Qarees"
            
            function onDataLoaded(id, data) {
                harness.assert(this, 42, data.length);
            }
            
            function run() {
                helper.fetchAllQarees(this);
            }
        },
        
        QtObject
        {
            objectName: "Fetch All Quotes"
            
            function onDataLoaded(id, data) {
                harness.assert(this, true);
            }
            
            function run() {
                helper.fetchAllQuotes(this);
            }
        },
        
        QtObject
        {
            objectName: "Fetch All Tafsir"
            
            function onDataLoaded(id, data) {
                harness.assert(this, true);
            }
            
            function run() {
                helper.fetchAllTafsir(this);
            }
        },
        
        QtObject
        {
            objectName: "Fetch All Tafsir For Ayat"
            
            function onDataLoaded(id, data) {
                harness.assert(this, true);
            }
            
            function run() {
                helper.fetchAllTafsirForAyat(this, 1, 2);
            }
        },
        
        QtObject
        {
            objectName: "Fetch All Tafsir For Chapter"
            
            function onDataLoaded(id, data) {
                harness.assert(this, true);
            }
            
            function run() {
                helper.fetchAllTafsirForChapter(this, 1);
            }
        },
        
        QtObject
        {
            objectName: "Fetch All Pages For Suite"
            
            function onDataLoaded(id, data) {
                harness.assert(this, true);
            }
            
            function run() {
                helper.fetchAllTafsirForSuite(this, 1);
            }
        },
        
        QtObject
        {
            objectName: "Fetch Ayat"
            
            function onDataLoaded(id, data) {
                harness.assert(this, [1, data[0].surah_id, 1, data[0].verse_id]);
            }
            
            function run() {
                helper.fetchAyat(this, 1, 1);
            }
        },
        
        QtObject
        {
            objectName: "Fetch Ayats"
            
            function onDataLoaded(id, data) {
                harness.assert(this, [1, data.length, 4, data[0].surah_id, 5, data[0].verse_id]);
            }
            
            function run() {
                helper.fetchAyats(this, [{'chapter': 4, 'fromVerse': 5}, {'chapter': 10, 'fromVerse': 2}]);
            }
        },
        
        QtObject
        {
            objectName: "Fetch Ayats For Tafsir"
            
            function onDataLoaded(id, data) {
                harness.assert(this, true);
            }
            
            function run() {
                helper.fetchAyatsForTafsir(this, 1);
            }
        },
        
        QtObject
        {
            objectName: "Fetch Biography"
            
            function onDataLoaded(id, data) {
                harness.assert(this, true);
            }
            
            function run() {
                helper.fetchBio(this, 1);
            }
        },
        
        QtObject
        {
            objectName: "Fetch Chapter With Juz"
            
            function onDataLoaded(id, data) {
                harness.assert(this, 2, data.length);
            }
            
            function run() {
                helper.fetchChapter(this, 2, true);
            }
        },
        
        QtObject
        {
            objectName: "Fetch Chapter Without Juz"
            
            function onDataLoaded(id, data) {
                harness.assert(this, 1, data.length);
            }
            
            function run() {
                helper.fetchChapter(this, 2);
            }
        },
        
        QtObject
        {
            objectName: "Fetch Chapter By Translated Name"
            
            function onDataLoaded(id, data) {
                harness.assert(this, [1, data.length, 1, data[0].surah_id]);
            }
            
            function run() {
                helper.fetchChapters(this, "Faat");
            }
        },
        
        QtObject
        {
            objectName: "Fetch Chapter By Arabic Name"
            
            function onDataLoaded(id, data) {
                harness.assert(this, [1, data.length, 1, data[0].surah_id]);
            }
            
            function run() {
                helper.fetchChapters(this, "الفاتح");
            }
        },
        
        QtObject
        {
            objectName: "Fetch Juz Info"
            
            function onDataLoaded(id, data) {
                harness.assert(this, [2, data.length, 1, data[0].surah_id, 2, data[1].surah_id]);
            }
            
            function run() {
                helper.fetchJuzInfo(this, 1);
            }
        },
        
        QtObject
        {
            objectName: "Fetch Page Numbers"
            
            function onDataLoaded(id, data) {
                harness.assert(this, [97, data.length, 1, data[0].surah_id, 1, data[0].page_number, 604, data[96].page_number, 112, data[96].surah_id]);
            }
            
            function run() {
                helper.fetchPageNumbers(this);
            }
        },
        
        QtObject
        {
            objectName: "Fetch Quote"
            
            function onDataLoaded(id, data) {
                harness.assert(this, true);
            }
            
            function run() {
                helper.fetchQuote(this, 1);
            }
        },
        
        QtObject
        {
            objectName: "Fetch Random Quote"
            
            function onDataLoaded(id, data) {
                harness.assert(this, true);
            }
            
            function run() {
                helper.fetchRandomQuote(this, 1);
            }
        },
        
        QtObject
        {
            objectName: "Fetch Similar Ayat Content"
            
            function onDataLoaded(id, data) {
                harness.assert(this, [5, data.length, 1, data[0].surah_id, 3, data[0].verse_id, 59, data[4].surah_id, 22, data[4].verse_id]);
            }
            
            function run() {
                helper.fetchSimilarAyatContent(this, 1, 1);
            }
        },
        
        QtObject
        {
            objectName: "Fetch Surah Header"
            
            function onDataLoaded(id, data) {
                harness.assert(this, [1, data.length, true, data[0].name.length > 0]);
            }
            
            function run() {
                helper.fetchSurahHeader(this, 2);
            }
        },
        
        QtObject
        {
            objectName: "Fetch Tafsir Content"
            
            function onDataLoaded(id, data) {
                harness.assert(this, true);
            }
            
            function run() {
                helper.fetchTafsirContent(this, 2);
            }
        },
        
        QtObject
        {
            objectName: "Fetch Tafsir Count For Ayat"
            
            function onDataLoaded(id, data) {
                harness.assert(this, true);
            }
            
            function run() {
                helper.fetchTafsirCountForAyat(this, 2, 3);
            }
        },
        
        QtObject
        {
            objectName: "Fetch Transliteration"
            
            function onDataLoaded(id, data) {
                harness.assert(this, true, data[0].html.length > 0);
            }
            
            function run()
            {
                if (helper.showTranslation) {
                    helper.fetchTransliteration(this, 2, 3);
                } else {
                    harness.assert(this, true);
                }
            }
        },
        
        // ----------- TAFSIR DATABASE TESTS
        
        QtObject
        {
            id: createLocation
            property variant locationId
            objectName: "Create Location"
            
            function onDataLoaded(id, data) {
                harness.assert(this, true);
            }
            
            function run() {
                locationId = tafsirHelper.addLocation(this, "XYZ", 45.12, -45.12);
            }
        },
        
        QtObject
        {
            id: createPerson
            property variant individualId
            property variant studentId
            property variant teacherId
            property int count
            objectName: "Create Individual"
            
            function onDataLoaded(id, data)
            {
                if (id == QueryId.AddIndividual) {
                    ++count;
                }
            }
            
            onCountChanged: {
                if (count == 3) {
                    harness.assert(this, true);
                }
            }
            
            function run()
            {
                count = 0;
                
                individualId = tafsirHelper.createIndividual(this, "Imam", "X", "K", "D", -3, 50, createLocation.locationId.toString(), true);
                teacherId = tafsirHelper.createIndividual(this, "Hafidh", "X1", "K1", "D1", 5, 50, "", false);
                studentId = tafsirHelper.createIndividual(this, "Shaykh", "X2", "K2", "D2", -3, 50, "", false);
            }
        },
        
        QtObject
        {
            objectName: "Edit Location"
            
            function onDataLoaded(id, data) {
                harness.assert(this, true);
            }
            
            function run() {
                tafsirHelper.editLocation(this, createLocation.locationId, "XYZ2");
            }
        },
        
        QtObject
        {
            objectName: "Get Location"
            
            function onDataLoaded(id, data) {
                harness.assert(this, 1, data.length);
            }
            
            function run() {
                tafsirHelper.fetchAllLocations(this, "XYZ2");
            }
        },
        
        QtObject
        {
            objectName: "Remove Location"
            
            function onDataLoaded(id, data) {
                harness.assert(this, true);
            }
            
            function run() {
                tafsirHelper.removeLocation(this, createLocation.locationId);
            }
        },
        
        QtObject
        {
            objectName: "Edit Individual"
            
            function onDataLoaded(id, data) {
                harness.assert(this, true);
            }
            
            function run() {
                individualId = tafsirHelper.editIndividual(this, createPerson.individualId, "Shaykh", "Y", "K", "D", -4, 51, "", true);
            }
        },
        
        QtObject
        {
            objectName: "Fetch Individual Data"
            
            function onDataLoaded(id, data)
            {
                var result = data[0];
                
                harness.assert(this, [1, data.length,
                    "Shaykh", result.prefix,
                    "Y", result.name,
                    "K", result.kunya,
                    "D", result.displayName,
                    -4, result.birth,
                    51, result.death,
                    null, result.location,
                    1, result.is_companion]);
            }
            
            function run() {
                individualId = tafsirHelper.fetchIndividualData(this, createPerson.individualId);
            }
        },
        
        QtObject
        {
            objectName: "Remove Individual"
            
            function onDataLoaded(id, data) {
                harness.assert(this, true);
            }
            
            function run() {
                tafsirHelper.removeIndividual(this, createPerson.individualId);
            }
        }
    ]
}