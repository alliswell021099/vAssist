#pragma once

#include <QJsonObject>
#include <QObject>
#include <QString>

#include <memory>

#include "core/providers/LLMProvider.h"

class AgentKernel : public QObject
{
    Q_OBJECT

public:
    explicit AgentKernel(QObject *parent = nullptr);

    Q_INVOKABLE void sendMessage(const QString &msg);

signals:
    void chatMessageReady(const QString &sender, const QString &text);
    void chatTokenReady(const QString &token);
    void chatStreamFinished(const QString &fullResponse);
    void chatStreamCancelled();
    void triggerTool(const QString &action, const QJsonObject &args);

private slots:
    void onProviderToken(const QString &token);
    void onProviderFinished(const QString &fullResponse);
    void onProviderError(const QString &error);

private:
    void setProvider(std::unique_ptr<LLMProvider> provider);

    std::unique_ptr<LLMProvider> m_provider;
    QString m_streamingResponse;
    bool m_hasStreamingResponse = false;
};
