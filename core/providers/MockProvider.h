#pragma once

#include "LLMProvider.h"

class MockProvider : public LLMProvider
{
    Q_OBJECT

public:
    explicit MockProvider(QObject *parent = nullptr);

    void sendPrompt(const QString &prompt) override;
};
