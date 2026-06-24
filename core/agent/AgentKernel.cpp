#include "AgentKernel.h"

#include "core/providers/ProviderManager.h"
#include "core/providers/OpenAICompatProvider.h"

#include <QJsonDocument>
#include <QJsonParseError>

AgentKernel::AgentKernel(QObject *parent)
    : QObject(parent)
{
    switchProvider(QStringLiteral("Mock"));
}

void AgentKernel::sendMessage(const QString &msg)
{
    if (!m_activeProvider) {
        emit chatMessageReady(QStringLiteral("system"),
                              QStringLiteral("No LLM provider configured."));
        return;
    }

    m_streamingResponse.clear();
    m_hasStreamingResponse = false;
    m_activeProvider->sendPrompt(msg);
}

QString AgentKernel::currentProviderName() const
{
    return m_currentProviderName;
}

QStringList AgentKernel::providerNames() const
{
    return ProviderManager::instance().providerNames();
}

bool AgentKernel::switchProvider(const QString &name)
{
    LLMProvider *provider = ProviderManager::instance().provider(name);
    if (!provider) {
        return false;
    }

    setActiveProvider(provider);
    m_currentProviderName = name;
    emit currentProviderNameChanged(name);
    return true;
}

QString AgentKernel::apiBase() const
{
    auto *provider = qobject_cast<OpenAICompatProvider *>(
        ProviderManager::instance().provider(QStringLiteral("OpenAI")));
    if (!provider) {
        return QStringLiteral("http://localhost:11434/v1");
    }
    return provider->apiBase();
}

void AgentKernel::setApiBase(const QString &url)
{
    auto *provider = qobject_cast<OpenAICompatProvider *>(
        ProviderManager::instance().provider(QStringLiteral("OpenAI")));
    if (provider && provider->apiBase() != url) {
        provider->setApiBase(url);
        emit apiBaseChanged(url);
    }
}

QString AgentKernel::modelName() const
{
    auto *provider = qobject_cast<OpenAICompatProvider *>(
        ProviderManager::instance().provider(QStringLiteral("OpenAI")));
    if (!provider) {
        return QStringLiteral("qwen2.5:7b");
    }
    return provider->modelName();
}

void AgentKernel::setModelName(const QString &name)
{
    auto *provider = qobject_cast<OpenAICompatProvider *>(
        ProviderManager::instance().provider(QStringLiteral("OpenAI")));
    if (provider && provider->modelName() != name) {
        provider->setModelName(name);
        emit modelNameChanged(name);
    }
}

QString AgentKernel::apiKey() const
{
    LLMProvider *p = ProviderManager::instance().provider(QStringLiteral("OpenAI"));
    if (!p) {
        return QString();
    }

    auto *provider = qobject_cast<OpenAICompatProvider *>(p);
    if (!provider) {
        return QString();
    }

    return provider->apiKey();
}

void AgentKernel::setApiKey(const QString &key)
{
    auto *provider = qobject_cast<OpenAICompatProvider *>(
        ProviderManager::instance().provider(QStringLiteral("OpenAI")));
    if (provider && provider->apiKey() != key) {
        provider->setApiKey(key);
        emit apiKeyChanged(key);
    }
}

void AgentKernel::testConnection()
{
    auto *provider = qobject_cast<OpenAICompatProvider *>(
        ProviderManager::instance().provider(QStringLiteral("OpenAI")));
    if (!provider) {
        emit connectionTestResult(false, QStringLiteral("OpenAI provider not found"));
        return;
    }

    static bool connected = false;
    if (!connected) {
        connect(provider, &OpenAICompatProvider::connectionTestFinished,
                this, &AgentKernel::onConnectionTestFinished);
        connected = true;
    }

    provider->testConnection();
}

void AgentKernel::onConnectionTestFinished(bool success, const QString &message)
{
    emit connectionTestResult(success, message);
}

void AgentKernel::setActiveProvider(LLMProvider *provider)
{
    if (m_activeProvider) {
        disconnect(m_activeProvider, nullptr, this, nullptr);
    }

    m_activeProvider = provider;

    if (!m_activeProvider) {
        return;
    }

    connect(m_activeProvider, &LLMProvider::finished,
            this, &AgentKernel::onProviderFinished);
    connect(m_activeProvider, &LLMProvider::errorOccurred,
            this, &AgentKernel::onProviderError);
    connect(m_activeProvider, &LLMProvider::tokenReady,
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
