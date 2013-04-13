CREATE TABLE x (database_id INTEGER, surah_id INTEGER, verse_id INTEGER, ayah_text TEXT);
.mode csv
.import English-Shakir-58.csv x
delete from x where rowid=1;
UPDATE quran SET urdu_ahmed_ali=(SELECT ayah_text FROM x WHERE x.surah_id=quran.surah_id AND x.verse_id=quran.verse_id);
DROP TABLE x;