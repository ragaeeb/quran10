#include "precompiled.h"

#include "Persistance.h"
#include "Logger.h">

namespace canadainc {

using namespace bb::system;

Persistance::Persistance(QObject* parent) : QObject(parent), m_toast(NULL)
{
}

Persistance::~Persistance()
{
}


void Persistance::showToast(QString const& text, QString const& buttonLabel)
{
	if (m_toast == NULL) {
		m_toast = new SystemToast(this);
		connect( m_toast, SIGNAL( finished(bb::system::SystemUiResult::Type) ), this, SLOT( finished(bb::system::SystemUiResult::Type) ) );
	}

	if ( !buttonLabel.isNull() ) {
		m_toast->button()->setLabel( tr("OK") );
	}

	m_toast->setBody(text);
	m_toast->show();
}


void Persistance::copyToClipboard(QString const& text)
{
	Clipboard clipboard;
	clipboard.clear();

	clipboard.insert( "text/plain", convertToUtf8(text) );

	showToast( tr("Copied: %1 to clipboard").arg(text) );
}


void Persistance::finished(bb::system::SystemUiResult::Type value)
{
	LOGGER("Toast finished()");
	emit toastFinished(value == SystemUiResult::ButtonSelection);
}


QByteArray Persistance::convertToUtf8(QString const& text) {
	return text.toUtf8();
}


QVariant Persistance::getValueFor(const QString &objectName)
{
    QVariant value( m_settings.value(objectName) );

    LOGGER("getValueFor: " << objectName << value);

    return value;
}


void Persistance::saveValueFor(const QString &objectName, const QVariant &inputValue)
{
	LOGGER("saveValueFor: " << objectName << inputValue);

	if ( m_settings.value(objectName) != inputValue ) {
		m_settings.setValue(objectName, inputValue);
		emit settingChanged(objectName);
	} else {
		LOGGER("Duplicate value, ignoring");
	}
}


void Persistance::remove(QString const& key) {
	m_settings.remove(key);
}


void Persistance::clear() {
	m_settings.clear();
}


} /* namespace canadainc */
