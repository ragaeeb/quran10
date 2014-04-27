#ifndef QURANCOLLECTOR_H_
#define QURANCOLLECTOR_H_

#include "AppLogFetcher.h"

#define CARD_LOG_FILE QString("%1/logs/card.log").arg( QDir::currentPath() )

namespace quran {

using namespace canadainc;

class QuranCollector : public LogCollector
{
public:
    QuranCollector();
    QString appName() const;
    QByteArray compressFiles();
    ~QuranCollector();
};

} /* namespace quran */

#endif /* QURANCOLLECTOR_H_ */
