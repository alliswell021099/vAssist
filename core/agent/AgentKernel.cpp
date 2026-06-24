#include "AgentKernel.h"

#include "core/providers/MockProvider.h"

#include <QJsonDocument>
#include <QJsonParseError>

AgentKernel::AgentKernel(QObject *parent)
    : QObject(parent)
{
    setProvider(std::make_unique<MockProvider>());
}

void AgentKernel::sendMessage(const QString &msg)
{
    if (!m_provider) {
        emit chatMessageReady(QStringLiteral("system"),
                              QStringLiteral("No LLM provider configured."));
        return;
    }

    m_streamingResponse.clear();
    m_hasStreamingResponse = false;
    m_provider->sendPrompt(msg);
}

void AgentKernel::setProvider(std::unique_ptr<LLMProvider> provider)
{
    if (m_provider) {
        disconnect(m_provider.get(), nullptr, this, nullptr);
    }

    m_provider = std::move(provider);

    if (!m_provider) {
        return;
    }

    connect(m_provider.get(), &LLMProvider::finished,
            this, &AgentKernel::onProviderFinished);
    connect(m_provider.get(), &LLMProvider::errorOccurred,
            this, &AgentKernel::onProviderError);
    connect(m_provider.get(), &LLMProvider::tokenReady,
            this, &AgentKernel::onProviderToken);
}

void AgentKernel::onProviderToken(const QString &token)
{
    m_hasStreamingResponse = true;
    m_streamingResponse += token;
    emit chatTokenReady(token);
}

void AgentKernel::onProviderFinished(const QString &fullResponse)
{
    const bool hadStreamingResponse = m_hasStreamingResponse;
    const QString streamedResponse = m_streamingResponse;
    m_streamingResponse.clear();
    m_hasStreamingResponse = false;

    QJsonParseError parseError;
    const QJsonDocument document = QJsonDocument::fromJson(fullResponse.toUtf8(), &parseError);

    if (parseError.error == QJsonParseError::NoError && document.isObject()) {
        const QJsonObject object = document.object();
        const QString action = object.value(QStringLiteral("action")).toString();

        if (!action.isEmpty()) {
            const QJsonObject args = object.value(QStringLiteral("arguments")).toObject();
            if (hadStreamingResponse) {
                emit chatStreamCancelled();
            }
            emit triggerTool(action, args);
            return;
        }
    }

    if (hadStreamingResponse) {
        emit chatStreamFinished(fullResponse.isEmpty() ? streamedResponse : fullResponse);
        return;
    }

    emit chatMessageReady(QStringLiteral("assistant"), fullResponse);
}

void AgentKernel::onProviderError(const QString &error)
{
    if (m_hasStreamingResponse) {
        m_streamingResponse.clear();
        m_hasStreamingResponse = false;
        emit chatStreamCancelled();
    }

    emit chatMessageReady(QStringLiteral("system"), error);
}
