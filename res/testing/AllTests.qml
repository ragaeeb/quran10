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
                && data[0].surah_id == 3 && data[0].verse_id == 14);
            }
            
            onCreationCompleted: {
                harness.init(searchAnds);
                helper.searchQuery(searchAnds, "life", 
                0, ["gold"]);
            }
        },
        
        QtObject
        {
            id: searchOrs
            objectName: "Search With ORs"
            
            function onDataLoaded(id, data)
            {
                harness.update( searchOrs, data.length == 7
                && data[0].surah_id == 4 && data[0].verse_id == 43);
            }
            
            onCreationCompleted: {
                harness.init(searchOrs);
                helper.searchQuery(searchOrs, "nature", 
                0, ["arouse"], false);
            }
        },
        
        QtObject
        {
            id: fetchAdjacent
            objectName: "Fetch Adjacent Ayat +1"
            
            function onDataLoaded(id, data)
            {
                harness.update( fetchAdjacent, data.length == 1
                && data[0].surah_id == 1 && data[0].verse_id == 2);
            }
            
            onCreationCompleted: {
                harness.init(fetchAdjacent);
                helper.fetchAdjacentAyat(fetchAdjacent, 1, 1, 1);
            }
        },
        
        QtObject
        {
            id: fetchAdjacent2
            objectName: "Fetch Adjacent Ayat -1"
            
            function onDataLoaded(id, data) {
                harness.update( fetchAdjacent2, data.length == 0 );
            }
            
            onCreationCompleted: {
                harness.init(fetchAdjacent2);
                helper.fetchAdjacentAyat(fetchAdjacent2, 1, 1, -1);
            }
        },
        
        QtObject
        {
            id: fetchAdjacent3
            objectName: "Fetch Adjacent Ayat End"
            
            function onDataLoaded(id, data) {
                harness.update( fetchAdjacent3, data.length == 0);
            }
            
            onCreationCompleted: {
                harness.init(fetchAdjacent3);
                helper.fetchAdjacentAyat(fetchAdjacent3, 114, 6, 1);
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