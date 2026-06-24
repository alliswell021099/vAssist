#pragma once

#include "LLMProvider.h"

#include <QString>
#include <QTimer>

class MockProvider : public LLMProvider
{
    Q_OBJECT

public:
    explicit MockProvider(QObject *parent = nullptr);

    QString name() const override;
    void sendPrompt(const QString &prompt) override;

    void setStream(bool enable) { m_stream = enable; }
    bool stream() const { return m_stream; }

private slots:
    void onStreamTick();

private:
    bool m_stream = true;
    QTimer *m_streamTimer;
    QString m_streamText;
    int m_streamIndex = 0;
};
