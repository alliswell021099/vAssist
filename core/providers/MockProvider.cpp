#include "MockProvider.h"

#include <QTimer>

MockProvider::MockProvider(QObject *parent)
    : LLMProvider(parent)
{
}

void MockProvider::sendPrompt(const QString &prompt)
{
    Q_UNUSED(prompt);

    QTimer::singleShot(1000, this, [this]() {
        const QString response = QStringLiteral(
            R"({"action": "download", "arguments": {"url": "https://test.com/video"}})");
        emit finished(response);
    });
}
