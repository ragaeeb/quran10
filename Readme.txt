sqlite3 quran_tafsir_english.db;
CREATE TABLE individuals (id INTEGER PRIMARY KEY, prefix TEXT, name TEXT, kunya TEXT, hidden INTEGER, birth INTEGER, death INTEGER, female INTEGER, displayName TEXT);
CREATE TABLE suites (id INTEGER PRIMARY KEY, author INTEGER REFERENCES individuals(id) ON DELETE CASCADE ON UPDATE CASCADE, translator INTEGER REFERENCES individuals(id) ON DELETE CASCADE ON UPDATE CASCADE, explainer INTEGER REFERENCES individuals(id) ON DELETE CASCADE ON UPDATE CASCADE, title TEXT, description TEXT, reference TEXT, compilation_id INTEGER REFERENCES(compilations) ON DELETE CASCADE ON UPDATE CASCADE);
CREATE TABLE suite_pages (id INTEGER PRIMARY KEY, suite_id INTEGER REFERENCES suites(id) ON DELETE CASCADE, body TEXT, heading TEXT, reference TEXT);
CREATE TABLE explanations (id INTEGER PRIMARY KEY, surah_id INTEGER NOT NULL, from_verse_number INTEGER, to_verse_number INTEGER, suite_page_id INTEGER NOT NULL REFERENCES suite_pages(id) ON DELETE CASCADE ON UPDATE CASCADE, UNIQUE(surah_id, from_verse_number, suite_page_id) ON CONFLICT IGNORE);
CREATE TABLE quotes (id INTEGER PRIMARY KEY, author INTEGER REFERENCES individuals(id) ON DELETE CASCADE ON UPDATE CASCADE, body TEXT, reference TEXT, compilation_id INTEGER REFERENCES compilations(id) ON DELETE CASCADE ON UPDATE CASCADE);
CREATE TABLE companions (id INTEGER PRIMARY KEY REFERENCES individuals(id) ON DELETE CASCADE ON UPDATE CASCADE);
CREATE TABLE biographies (id INTEGER PRIMARY KEY, individual INTEGER REFERENCES individuals(id) ON DELETE CASCADE ON UPDATE CASCADE, bio TEXT, compilation_id INTEGER REFERENCES compilations(id) ON DELETE CASCADE ON UPDATE CASCADE, reference TEXT);
CREATE TABLE tahdeel (id INTEGER PRIMARY KEY, from INTEGER REFERENCES individuals(id) ON DELETE CASCADE ON UPDATE CASCADE, target INTEGER REFERENCES individuals(id) ON DELETE CASCADE ON UPDATE CASCADE, body TEXT, compilation_id INTEGER REFERENCES compilations(id) ON DELETE CASCADE ON UPDATE CASCADE, reference TEXT);
CREATE TABLE rudood (id INTEGER PRIMARY KEY, from INTEGER REFERENCES individuals(id) ON DELETE CASCADE ON UPDATE CASCADE, target INTEGER REFERENCES individuals(id) ON DELETE CASCADE ON UPDATE CASCADE, body TEXT, compilation_id INTEGER REFERENCES compilations(id) ON DELETE CASCADE ON UPDATE CASCADE, reference TEXT);
CREATE TABLE compilations(id INTEGER PRIMARY KEY, name TEXT, summary TEXT);
CREATE TABLE websites(id INTEGER PRIMARY KEY, individual INTEGER REFERENCES individuals(id) ON DELETE CASCADE ON UPDATE CASCADE, uri TEXT);

CREATE INDEX IF NOT EXISTS suites_index ON suites(author,translator,explainer);
CREATE INDEX IF NOT EXISTS suite_pages_index ON suite_pages(suite_id);
CREATE INDEX IF NOT EXISTS quotes_index ON quotes(author);
CREATE INDEX IF NOT EXISTS explanations_index ON explanations(surah_id,from_verse_number,to_verse_number,suite_page_id);
CREATE INDEX IF NOT EXISTS biographies_index ON biographies(individual);
CREATE INDEX IF NOT EXISTS tahdeel_index ON tahdeel(from,target);
CREATE INDEX IF NOT EXISTS rudood_index ON rudood(from,target);
CREATE INDEX IF NOT EXISTS websites_index ON websites(individual);

CREATE INDEX IF NOT EXISTS teachers_index ON explanations(individual, teacher);
CREATE TABLE teachers (individual INTEGER REFERENCES individuals(id) ON DELETE CASCADE, teacher INTEGER REFERENCES individuals(id) ON DELETE CASCADE);