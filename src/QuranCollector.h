#ifndef QURANCOLLECTOR_H_
#define QURANCOLLECTOR_H_

#include "AppLogFetcher.h"

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
