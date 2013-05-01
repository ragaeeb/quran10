#ifndef PERSISTANCE_H_
#define PERSISTANCE_H_

#include <QObject>
#include <QSettings>

#include <bb/system/SystemUiResult>

namespace bb {
	namespace system {
		class SystemToast;
	}
}

namespace canadainc {

#define INIT_SETTING(a,b) if ( m_persistance.getValueFor(a).isNull() ) m_persistance.saveValueFor(a,b);

/**
 * @version 1.00 System toast with OK button and signal emitted.
 */
class Persistance : public QObject
{
	Q_OBJECT

	QSettings m_settings;
	bb::system::SystemToast* m_toast;

private slots:
	void finished(bb::system::SystemUiResult::Type value);

signals:
	void settingChanged(QString const& key);
	void toastFinished(bool buttonTriggered=false);

public:
	Persistance(QObject* parent=NULL);
	virtual ~Persistance();

    Q_INVOKABLE QVariant getValueFor(QString const& objectName);
    Q_INVOKABLE void saveValueFor(QString const& objectName, QVariant const& inputValue);
    Q_INVOKABLE void remove(QString const& key);
    Q_INVOKABLE void clear();
    Q_INVOKABLE void copyToClipboard(QString const& text);
    Q_INVOKABLE void showToast(QString const& text, QString const& buttonLabel=QString());
    Q_INVOKABLE static QByteArray convertToUtf8(QString const& text);
};

} /* namespace canadainc */
#endif /* PERSISTANCE_H_ */
