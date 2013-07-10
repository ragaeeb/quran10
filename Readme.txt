Quran10: make downloading one long one

sqlite> SELECT COUNT() FROM (select name from sqlite_master where type='table' AND name='bengalix');
sqlite> SELECT COUNT() FROM (select name from sqlite_master where type='table' AND name='bengali');

95, 97 did not work
UPDATE arabic SET text=REPLACE(text, 'BISMILLAH_TEXT', '') WHERE text like 'BISMILLAH_TEXT%' AND verse_id=1 AND surah_id != 1

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