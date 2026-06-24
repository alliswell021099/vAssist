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
    Q_PROPERTY(QString apiBase READ apiBase WRITE setApiBase NOTIFY apiBaseChanged)
    Q_PROPERTY(QString modelName READ modelName WRITE setModelName NOTIFY modelNameChanged)
    Q_PROPERTY(QString apiKey READ apiKey WRITE setApiKey NOTIFY apiKeyChanged)

public:
    explicit AgentKernel(QObject *parent = nullptr);

    Q_INVOKABLE void sendMessage(const QString &msg);

    Q_INVOKABLE QString currentProviderName() const;
    Q_INVOKABLE QStringList providerNames() const;

    Q_INVOKABLE bool switchProvider(const QString &name);

    Q_INVOKABLE QString apiBase() const;
    Q_INVOKABLE void setApiBase(const QString &url);

    Q_INVOKABLE QString modelName() const;
    Q_INVOKABLE void setModelName(const QString &name);

    Q_INVOKABLE QString apiKey() const;
    Q_INVOKABLE void setApiKey(const QString &key);

    Q_INVOKABLE void testConnection();

signals:
    void chatMessageReady(const QString &sender, const QString &text);
    void chatTokenReady(const QString &token);
    void chatStreamFinished(const QString &fullResponse);
    void chatStreamCancelled();
    void triggerTool(const QString &action, const QJsonObject &args);

    void currentProviderNameChanged(const QString &name);
    void providerNamesChanged(const QStringList &names);
    void apiBaseChanged(const QString &url);
    void modelNameChanged(const QString &name);
    void apiKeyChanged(const QString &key);
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
