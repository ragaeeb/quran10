#ifndef PERSISTANCE_H_
#define PERSISTANCE_H_

#include <QObject>
#include <QSettings>

namespace bb {
	namespace system {
		class SystemToast;
	}
}

namespace canadainc {

class Persistance : public QObject
{
	Q_OBJECT

	QSettings m_settings;
	bb::system::SystemToast* m_toast;

signals:
	void settingChanged(QString const& key);

public:
	Persistance(QObject* parent=NULL);
	virtual ~Persistance();

    Q_INVOKABLE QVariant getValueFor(QString const& objectName);
    Q_INVOKABLE void saveValueFor(QString const& objectName, QVariant const& inputValue);
    Q_INVOKABLE void copyToClipboard(QString const& text);
    Q_INVOKABLE void showToast(QString const& text);
    Q_INVOKABLE static QString convertToUtf8(QString const& text);
};

} /* namespace canadainc */
#endif /* PERSISTANCE_H_ */
