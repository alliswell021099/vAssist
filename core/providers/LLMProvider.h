#pragma once

#include <QObject>
#include <QString>

class LLMProvider : public QObject
{
    Q_OBJECT

public:
    explicit LLMProvider(QObject *parent = nullptr)
        : QObject(parent)
    {
    }

    ~LLMProvider() override = default;

    virtual void sendPrompt(const QString &prompt) = 0;

signals:
    void tokenReady(const QString &token);
    void errorOccurred(const QString &error);
    void finished(const QString &fullResponse);
};
