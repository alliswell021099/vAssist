#pragma once

#include <QJsonObject>
#include <QObject>
#include <QString>
#include <QStringList>

#include "core/providers/LLMProvider.h"
#include "core/settings/ProviderSettings.h"

class AgentKernel : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString currentProviderName READ currentProviderName NOTIFY currentProviderNameChanged)
    Q_PROPERTY(QStringList providerNames READ providerNames NOTIFY providerNamesChanged)
    Q_PROPERTY(ProviderSettings* providerSettings READ providerSettings CONSTANT)

public:
    explicit AgentKernel(QObject *parent = nullptr);

    Q_INVOKABLE void sendMessage(const QString &msg);

    Q_INVOKABLE QString currentProviderName() const;
    Q_INVOKABLE QStringList providerNames() const;

    Q_INVOKABLE bool switchProvider(const QString &name);

    Q_INVOKABLE void testConnection();

    ProviderSettings* providerSettings() const { return m_providerSettings; }

signals:
    void chatMessageReady(const QString &sender, const QString &text);
    void chatTokenReady(const QString &token);
    void chatStreamFinished(const QString &fullResponse);
    void chatStreamCancelled();
    void triggerTool(const QString &action, const QJsonObject &args);

    void currentProviderNameChanged(const QString &name);
    void providerNamesChanged(const QStringList &names);
    void connectionTestResult(bool success, const QString &message);

private slots:
    void onProviderToken(const QString &token);
    void onProviderFinished(const QString &fullResponse);
    void onProviderError(const QString &error);
    void onConnectionTestFinished(bool success, const QString &message);
    void onActiveProviderChanged();

private:
    void setActiveProvider(LLMProvider *provider);
    void applyActiveProviderConfig();

    LLMProvider *m_activeProvider = nullptr;
    QString m_streamingResponse;
    bool m_hasStreamingResponse = false;
    QString m_currentProviderName;
    ProviderSettings *m_providerSettings = nullptr;
};
