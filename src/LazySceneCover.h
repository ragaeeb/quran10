#ifndef LAZYSCENECOVER_H_
#define LAZYSCENECOVER_H_

#include <QObject>

namespace canadainc {

class LazySceneCover : public QObject
{
	Q_OBJECT

private slots:
	void onThumbnail();

public:
	LazySceneCover(QString const& sceneCoverQml);
	virtual ~LazySceneCover();
};

} /* namespace canadainc */
#endif /* LAZYSCENECOVER_H_ */
