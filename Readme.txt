PlainTextMultiselector
        {
            function getSelectedTextualData()
            {
                var selectedIndices = selectionList()
                var result = ""
                var first
                var last
                
                for (var i = 0; i < selectedIndices.length; i ++) {
                    if (selectedIndices[i].length > 1) {
                        var current = dataModel.data(selectedIndices[i])
                        
                        result += renderItem(current)
                        
                        if (i < selectedIndices.length - 1) {
                            result += "\n"
                        }
                        
                        if (! first) {
                            first = current.verse_id
                        }
                        
                        last = current.verse_id
                    }
                }
                
                if (first && last) {
                    result += qsTr("%1:%2-%3").arg(chapterNumber).arg(first).arg(last)
                    return result;
                } else {
                    return ""
                }
            }
        },





sqlite3 articles_english.db;
CREATE TABLE individuals (id INTEGER PRIMARY KEY, prefix TEXT, name TEXT, kunya TEXT, uri TEXT, hidden INTEGER, biography TEXT);
CREATE TABLE suites (id INTEGER PRIMARY KEY, author INTEGER REFERENCES individuals(id) ON DELETE CASCADE, translator INTEGER REFERENCES individuals(id) ON DELETE CASCADE, explainer INTEGER REFERENCES individuals(id) ON DELETE CASCADE, title TEXT, description TEXT, reference TEXT);
CREATE TABLE suite_pages (id INTEGER PRIMARY KEY, suite_id INTEGER REFERENCES suites(id) ON DELETE CASCADE, body TEXT, surah_id INTEGER, verse_id INTEGER);

sqlite3 articles_arabic.db;
CREATE TABLE individuals (id INTEGER PRIMARY KEY, prefix TEXT, name TEXT, kunya TEXT, uri TEXT, hidden INTEGER, biography TEXT);
CREATE TABLE suites (id INTEGER PRIMARY KEY, author INTEGER REFERENCES individuals(id) ON DELETE CASCADE, translator INTEGER REFERENCES individuals(id) ON DELETE CASCADE, explainer INTEGER REFERENCES individuals(id) ON DELETE CASCADE, title TEXT, description TEXT, reference TEXT);
CREATE TABLE suite_pages (id INTEGER PRIMARY KEY, suite_id INTEGER REFERENCES suites(id) ON DELETE CASCADE, body TEXT, surah_id INTEGER, verse_id INTEGER);

sqlite3 quran_tafsir_english.db
CREATE TABLE explanations (id INTEGER PRIMARY KEY, surah_id INTEGER NOT NULL, from_verse_number INTEGER, to_verse_number INTEGER, suite_page_id INTEGER NOT NULL REFERENCES suite_pages(id) ON DELETE CASCADE, UNIQUE(surah_id, from_verse_number, to_verse_number, suite_page_id) ON CONFLICT IGNORE);

sqlite3 quran_similar.db
CREATE TABLE related (surah_id INTEGER NOT NULL, verse_id INTEGER NOT NULL, other_surah_id INTEGER NOT NULL, other_verse_id INTEGER NOT NULL, UNIQUE(arabic_id, other_id) ON CONFLICT IGNORE);


sqlite3 quran_arabic.db
CREATE TABLE IF NOT EXISTS surahs (id INTEGER PRIMARY KEY, name TEXT);
CREATE TABLE IF NOT EXISTS verses (id INTEGER PRIMARY KEY, surah_id INTEGER REFERENCES surahs(id), verse_number INTEGER, content TEXT, UNIQUE(surah_id,verse_number) ON CONFLICT REPLACE);
CREATE TABLE IF NOT EXISTS surah_metadata (surah_id INTEGER REFERENCES surahs(id), verse_count INTEGER, start INTEGER, type INTEGER, revelation_order INTEGER, rukus INTEGER);
CREATE TABLE IF NOT EXISTS juzs (id INTEGER PRIMARY KEY, surah_id INTEGER REFERENCES surahs(id), verse_number INTEGER, UNIQUE(surah_id,verse_number) ON CONFLICT REPLACE);
CREATE TABLE IF NOT EXISTS hizbs (id INTEGER PRIMARY KEY, surah_id INTEGER REFERENCES surahs(id), verse_number INTEGER, UNIQUE(surah_id,verse_number) ON CONFLICT REPLACE);
CREATE TABLE IF NOT EXISTS manzils (id INTEGER PRIMARY KEY, surah_id INTEGER REFERENCES surahs(id), verse_number INTEGER, UNIQUE(surah_id,verse_number) ON CONFLICT REPLACE);
CREATE TABLE IF NOT EXISTS rukus (surah_id INTEGER REFERENCES surahs(id), verse_number INTEGER, UNIQUE(surah_id,verse_number) ON CONFLICT REPLACE);
CREATE TABLE IF NOT EXISTS sajdas (surah_id INTEGER REFERENCES surahs(id), verse_number INTEGER, type INTEGER, UNIQUE(surah_id,verse_number) ON CONFLICT REPLACE);
CREATE TABLE IF NOT EXISTS mushaf_pages (page_number INTEGER PRIMARY KEY, surah_id INTEGER REFERENCES surahs(id), verse_number INTEGER, UNIQUE(surah_id,verse_number) ON CONFLICT REPLACE);
CREATE TABLE IF NOT EXISTS supplications (surah_id INTEGER REFERENCES surahs(id), verse_number_start INTEGER, verse_number_end INTEGER, UNIQUE(surah_id,verse_number_start) ON CONFLICT REPLACE);
CREATE TABLE IF NOT EXISTS qarees (id INTEGER PRIMARY KEY, name TEXT NOT NULL, bio TEXT, level INTEGER DEFAULT 1);
CREATE TABLE IF NOT EXISTS recitations (qaree_id INTEGER REFERENCES qarees(id) ON DELETE CASCADE, description TEXT, value TEXT NOT NULL);

sqlite3 quran_english.db
CREATE TABLE IF NOT EXISTS surahs (id INTEGER PRIMARY KEY, transliteration TEXT, translation TEXT);
CREATE TABLE IF NOT EXISTS verses (id INTEGER PRIMARY KEY, surah_id INTEGER REFERENCES surahs(id), verse_number INTEGER, content TEXT, UNIQUE(surah_id,verse_number) ON CONFLICT REPLACE);

Quran10: make downloading one long one

sqlite> SELECT COUNT() FROM (select name from sqlite_master where type='table' AND name='bengalix');
sqlite> SELECT COUNT() FROM (select name from sqlite_master where type='table' AND name='bengali');

95, 97 did not work
UPDATE arabic SET text=REPLACE(text, 'BISMILLAH_TEXT', '') WHERE text like 'BISMILLAH_TEXT%' AND verse_id=1 AND surah_id != 1 AND surah_id != 9

---------------

sed -i "" 's/,//g' *.txt;
sed -i "" 's/|/,/g' *.txt;

< ar.muyassar.txt tail -n +0 | tail -r | tail -n +14 | tail -r >temp.txt
mv temp.txt ar.muyassar.txt

< bn.hoque.txt tail -n +0 | tail -r | tail -n +14 | tail -r >temp.txt
mv temp.txt bn.hoque.txt

< de.bubenheim.txt tail -n +0 | tail -r | tail -n +14 | tail -r >temp.txt
mv temp.txt de.bubenheim.txt

< en.hilali.txt tail -n +0 | tail -r | tail -n +14 | tail -r >temp.txt
mv temp.txt en.hilali.txt

< en.transliteration.txt tail -n +0 | tail -r | tail -n +14 | tail -r >temp.txt
mv temp.txt en.transliteration.txt

< es.cortes.txt tail -n +0 | tail -r | tail -n +14 | tail -r >temp.txt
mv temp.txt es.cortes.txt

< fr.hamidullah.txt tail -n +0 | tail -r | tail -n +14 | tail -r >temp.txt
mv temp.txt fr.hamidullah.txt

< id.indonesian.txt tail -n +0 | tail -r | tail -n +14 | tail -r >temp.txt
mv temp.txt id.indonesian.txt

< ms.basmeih.txt tail -n +0 | tail -r | tail -n +14 | tail -r >temp.txt
mv temp.txt ms.basmeih.txt

< ru.kuliev.txt tail -n +0 | tail -r | tail -n +14 | tail -r >temp.txt
mv temp.txt ru.kuliev.txt

< th.thai.txt tail -n +0 | tail -r | tail -n +14 | tail -r >temp.txt
mv temp.txt th.thai.txt

< tr.diyanet.txt tail -n +0 | tail -r | tail -n +14 | tail -r >temp.txt
mv temp.txt tr.diyanet.txt

< ur.jalandhry.txt tail -n +0 | tail -r | tail -n +14 | tail -r >temp.txt
mv temp.txt ur.jalandhry.txt

< zh.majian.txt tail -n +0 | tail -r | tail -n +14 | tail -r >temp.txt
mv temp.txt zh.majian.txt

sqlite3 quran.db
.mode csv

CREATE TABLE arabic (surah_id INTEGER, verse_id INTEGER, text TEXT);
.import quran-uthmani.txt arabic
CREATE INDEX 'fk_arabic_surah_id' ON 'arabic' ('surah_id' ASC);
CREATE INDEX 'fk_arabic_verse_id' ON 'arabic' ('verse_id' ASC);
CREATE INDEX 'fk_arabic_text' ON 'arabic' ('text' ASC);

CREATE TABLE transliteration (surah_id INTEGER, verse_id INTEGER, text TEXT);
.import translated.txt transliteration
CREATE INDEX 'fk_transliteration_surah_id' ON 'transliteration' ('surah_id' ASC);
CREATE INDEX 'fk_transliteration_verse_id' ON 'transliteration' ('verse_id' ASC);

CREATE TABLE bengali (surah_id INTEGER, verse_id INTEGER, text TEXT);
.import bn.hoque.txt bengali
CREATE INDEX 'fk_bengali_surah_id' ON 'bengali' ('surah_id' ASC);
CREATE INDEX 'fk_bengali_verse_id' ON 'bengali' ('verse_id' ASC);

CREATE TABLE german (surah_id INTEGER, verse_id INTEGER, text TEXT);
.import de.bubenheim.txt german
CREATE INDEX 'fk_german_surah_id' ON 'german' ('surah_id' ASC);
CREATE INDEX 'fk_german_verse_id' ON 'german' ('verse_id' ASC);

CREATE TABLE english (surah_id INTEGER, verse_id INTEGER, text TEXT);
.import en.hilali.txt english
CREATE INDEX 'fk_english_surah_id' ON 'english' ('surah_id' ASC);
CREATE INDEX 'fk_english_text' ON 'english' ('text' ASC);
CREATE INDEX 'fk_english_verse_id' ON 'english' ('verse_id' ASC);

CREATE TABLE transliteration (surah_id INTEGER, verse_id INTEGER, text TEXT);
.import en.transliteration.txt transliteration
CREATE INDEX 'fk_transliteration_surah_id' ON 'transliteration' ('surah_id' ASC);
CREATE INDEX 'fk_transliteration_verse_id' ON 'transliteration' ('verse_id' ASC);

CREATE TABLE spanish (surah_id INTEGER, verse_id INTEGER, text TEXT);
.import es.cortes.txt spanish
CREATE INDEX 'fk_spanish_surah_id' ON 'spanish' ('surah_id' ASC);
CREATE INDEX 'fk_spanish_verse_id' ON 'spanish' ('verse_id' ASC);

CREATE TABLE french (surah_id INTEGER, verse_id INTEGER, text TEXT);
.import fr.hamidullah.txt french
CREATE INDEX 'fk_french_surah_id' ON 'french' ('surah_id' ASC);
CREATE INDEX 'fk_french_verse_id' ON 'french' ('verse_id' ASC);

CREATE TABLE indonesian (surah_id INTEGER, verse_id INTEGER, text TEXT);
.import id.indonesian.txt indonesian
CREATE INDEX 'fk_indonesian_surah_id' ON 'indo' ('surah_id' ASC);
CREATE INDEX 'fk_indonesian_verse_id' ON 'indo' ('verse_id' ASC);

CREATE TABLE malay (surah_id INTEGER, verse_id INTEGER, text TEXT);
.import ms.basmeih.txt malay
CREATE INDEX 'fk_malay_surah_id' ON 'malay' ('surah_id' ASC);
CREATE INDEX 'fk_malay_verse_id' ON 'malay' ('verse_id' ASC);

CREATE TABLE russian (surah_id INTEGER, verse_id INTEGER, text TEXT);
.import ru.kuliev.txt russian
CREATE INDEX 'fk_russian_surah_id' ON 'russian' ('surah_id' ASC);
CREATE INDEX 'fk_russian_verse_id' ON 'russian' ('verse_id' ASC);

CREATE TABLE thai (surah_id INTEGER, verse_id INTEGER, text TEXT);
.import th.thai.txt thai
CREATE INDEX 'fk_thai_surah_id' ON 'thai' ('surah_id' ASC);
CREATE INDEX 'fk_thai_verse_id' ON 'thai' ('verse_id' ASC);

CREATE TABLE turkish (surah_id INTEGER, verse_id INTEGER, text TEXT);
.import tr.vakfi.txt turkish
CREATE INDEX 'fk_turkish_surah_id' ON 'turkish' ('surah_id' ASC);
CREATE INDEX 'fk_turkish_verse_id' ON 'turkish' ('verse_id' ASC);

CREATE TABLE urdu (surah_id INTEGER, verse_id INTEGER, text TEXT);
.import ur.jalandhry.txt urdu
CREATE INDEX 'fk_urdu_surah_id' ON 'urdu' ('surah_id' ASC);
CREATE INDEX 'fk_urdu_verse_id' ON 'urdu' ('verse_id' ASC);

CREATE TABLE chinese (surah_id INTEGER, verse_id INTEGER, text TEXT);
.import zh.majian.txt chinese
CREATE INDEX 'fk_chinese_surah_id' ON 'chinese' ('surah_id' ASC);
CREATE INDEX 'fk_chinese_verse_id' ON 'chinese' ('verse_id' ASC);

vacuum;



CREATE TABLE arabic (database_id INTEGER, surah_id INTEGER, verse_id INTEGER, text TEXT);
.mode csv
.import Arabic-(Original-Book)-1.csv arabic
delete from arabic where rowid=1;