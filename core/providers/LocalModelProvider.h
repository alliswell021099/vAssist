#pragma once

#include "LLMProvider.h"

#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QString>
#include <QByteArray>

class LocalModelProvider : public LLMProvider
{
    Q_OBJECT

public:
    explicit LocalModelProvider(QObject *parent = nullptr);
    ~LocalModelProvider() override;

    QString name() const override;
    void sendPrompt(const QString &prompt) override;

    Q_INVOKABLE void setApiBase(const QString &url);
    Q_INVOKABLE QString apiBase() const;

    Q_INVOKABLE void setModelName(const QString &name);
    Q_INVOKABLE QString modelName() const;

    Q_INVOKABLE void setApiKey(const QString &key);
    Q_INVOKABLE QString apiKey() const;

    Q_INVOKABLE void setTemperature(float temp);
    Q_INVOKABLE float temperature() const;

    Q_INVOKABLE void setMaxTokens(int tokens);
    Q_INVOKABLE int maxTokens() const;

    Q_INVOKABLE void setStream(bool enable);
    Q_INVOKABLE bool stream() const;

    Q_INVOKABLE bool testConnection();

signals:
    void connectionTestFinished(bool success, const QString &message);

private slots:
    void onReplyReadyRead();
    void onReplyFinished();
    void onReplyError(QNetworkReply::NetworkError code);
    void onSslErrors(const QList<QSslError> &errors);

private:
    void parseSseChunk(QByteArray &buffer);
    void processSseLine(const QByteArray &line);

    QNetworkAccessManager *m_networkManager;
    QNetworkReply *m_currentReply = nullptr;

    QString m_apiBase = QStringLiteral("http://localhost:11434/v1");
    QString m_modelName = QStringLiteral("qwen2.5:7b");
    QString m_apiKey;
    float m_temperature = 0.7f;
    int m_maxTokens = 512;
    bool m_stream = true;

    QByteArray m_sseBuffer;
    QString m_fullResponse;
};
