#pragma once

#include <QJsonObject>
#include <QObject>
#include <QString>
#include <QStringList>

#include "core/providers/LLMProvider.h"

class AgentKernel : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString currentProviderName READ currentProviderName NOTIFY currentProviderNameChanged)
    Q_PROPERTY(QStringList providerNames READ providerNames NOTIFY providerNamesChanged)
    Q_PROPERTY(QString localApiBase READ localApiBase WRITE setLocalApiBase NOTIFY localApiBaseChanged)
    Q_PROPERTY(QString localModelName READ localModelName WRITE setLocalModelName NOTIFY localModelNameChanged)
    Q_PROPERTY(QString localApiKey READ localApiKey WRITE setLocalApiKey NOTIFY localApiKeyChanged)

public:
    explicit AgentKernel(QObject *parent = nullptr);

    Q_INVOKABLE void sendMessage(const QString &msg);

    Q_INVOKABLE QString currentProviderName() const;
    Q_INVOKABLE QStringList providerNames() const;

    Q_INVOKABLE bool switchProvider(const QString &name);

    Q_INVOKABLE QString localApiBase() const;
    Q_INVOKABLE void setLocalApiBase(const QString &url);

    Q_INVOKABLE QString localModelName() const;
    Q_INVOKABLE void setLocalModelName(const QString &name);

    Q_INVOKABLE QString localApiKey() const;
    Q_INVOKABLE void setLocalApiKey(const QString &key);

    Q_INVOKABLE void testLocalConnection();

signals:
    void chatMessageReady(const QString &sender, const QString &text);
    void chatTokenReady(const QString &token);
    void chatStreamFinished(const QString &fullResponse);
    void chatStreamCancelled();
    void triggerTool(const QString &action, const QJsonObject &args);

    void currentProviderNameChanged(const QString &name);
    void providerNamesChanged(const QStringList &names);
    void localApiBaseChanged(const QString &url);
    void localModelNameChanged(const QString &name);
    void localApiKeyChanged(const QString &key);
    void connectionTestResult(bool success, const QString &message);

private slots:
    void onProviderToken(const QString &token);
    void onProviderFinished(const QString &fullResponse);
    void onProviderError(const QString &error);
    void onConnectionTestFinished(bool success, const QString &message);

private:
    void setActiveProvider(LLMProvider *provider);

    LLMProvider *m_activeProvider = nullptr;
    QString m_streamingResponse;
    bool m_hasStreamingResponse = false;
    QString m_currentProviderName;
};
