import bb.cascades 1.0
import com.canadainc.data 1.0

Container
{
    id: root
    
    attachedObjects: [
        QtObject
        {
            id: sampleSearch
            objectName: "Basic Search With 3 Results"
            
            function onDataLoaded(id, data)
            {
                harness.update( sampleSearch, data.length == 3
                && data[0].surah_id == 3 && data[0].verse_id == 8
                && data[1].surah_id == 38 && data[1].verse_id == 9
                && data[2].surah_id == 38 && data[2].verse_id == 35 );
            }
            
            onCreationCompleted: {
                harness.init(sampleSearch);
                helper.searchQuery(sampleSearch, "الوهاب");
            }
        },
        
        QtObject
        {
            id: searchChapter
            objectName: "Search With Restricted Chapter"
            
            function onDataLoaded(id, data)
            {
                harness.update( searchChapter, data.length == 1
                && data[0].surah_id == 3 && data[0].verse_id == 8);
            }
            
            onCreationCompleted: {
                harness.init(searchChapter);
                helper.searchQuery(searchChapter, "الوهاب", 
                3);
            }
        },
        
        QtObject
        {
            id: searchAnds
            objectName: "Search With ANDs"
            
            function onDataLoaded(id, data)
            {
                harness.update( searchAnds, data.length == 1
                && data[0].surah_id == 3 && data[0].verse_id == 8);
            }
            
            onCreationCompleted: {
                harness.init(searchAnds);
                helper.searchQuery(searchChapter, "الوهاب", 
                0, [""]);
            }
        },
        
        QtObject
        {
            id: randomFetch
            objectName: "Fetch Random Ayat"
            
            function onDataLoaded(id, data) {
                harness.update(randomFetch, data.length == 1);
            }
            
            onCreationCompleted: {
                harness.init(randomFetch);
                helper.fetchRandomAyat(randomFetch);
            }
        }
    ]
}