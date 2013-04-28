#include "precompiled.h"

#include "Persistance.h"
#include "Logger.h"

namespace canadainc {

using namespace bb::system;

Persistance::Persistance(QObject* parent) : QObject(parent), m_toast(NULL)
{
}

Persistance::~Persistance()
{
}


QVariant Persistance::getValueFor(const QString &objectName)
{
    QVariant value( m_settings.value(objectName) );

    LOGGER("getValueFor: " << objectName << value);

    return value;
}


void Persistance::copyToClipboard(QString const& text)
{
	Clipboard clipboard;
	clipboard.clear();

	clipboard.insert( "text/plain", text.toUtf8() );

	showToast( tr("Copied: %1 to clipboard").arg(text) );
}


void Persistance::showToast(QString const& text)
{
	if (m_toast == NULL) {
		m_toast = new SystemToast(this);
	}

	m_toast->setBody(text);
	m_toast->show();
}


QString Persistance::convertToUtf8(QString const& text) {
	return QString::fromUtf8( text.toUtf8().constData() );
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


} /* namespace canadainc */
