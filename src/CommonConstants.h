#ifndef COMMONCONSTANTS_H_
#define COMMONCONSTANTS_H_

#include <QUrl>

#define ARABIC_KEY "arabic"
#define ASSET_YELLOW_DELETE "asset:///images/toast/yellow_delete.png"
#define KEY_CHAPTER_ID "surah_id"
#define KEY_JOIN_LETTERS "overlayAyatImages"
#define KEY_OUTPUT_FOLDER "output"
#define KEY_PRIMARY_SIZE "primarySize"
#define KEY_SURAH_ID "surahId"
#define KEY_TAFSIR "tafsir"
#define KEY_TRANSLATION "translation"
#define KEY_TRANSLATION_SIZE "translationFontSize"
#define KEY_TRANSLITERATION "transliteration"
#define KEY_VERSE_ID "verse_id"
#define KEY_VERSE_NUMBER "verseId"
#define NOT_APP_DIR(path) path != QDir::homePath()
#define READ_WRITE_EXEC QFile::Permissions(QFile::WriteUser|QFile::WriteOther|QFile::WriteGroup|QFile::WriteOwner|QFile::ReadOwner|QFile::ReadUser|QFile::ReadOther|QFile::ReadGroup|QFile::ExeGroup|QFile::ExeOther|QFile::ExeOwner|QFile::ExeUser)

namespace quran {

}

#endif /* COMMONCONSTANTS_H_ */
