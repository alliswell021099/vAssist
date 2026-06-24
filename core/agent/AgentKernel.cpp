#include "AgentKernel.h"

#include "core/providers/ProviderManager.h"
#include "core/providers/LocalModelProvider.h"

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

QString AgentKernel::localApiBase() const
{
    auto *local = qobject_cast<LocalModelProvider *>(
        ProviderManager::instance().provider(QStringLiteral("Local")));
    if (!local) {
        return QStringLiteral("http://localhost:11434/v1");
    }
    return local->apiBase();
}

void AgentKernel::setLocalApiBase(const QString &url)
{
    auto *local = qobject_cast<LocalModelProvider *>(
        ProviderManager::instance().provider(QStringLiteral("Local")));
    if (local && local->apiBase() != url) {
        local->setApiBase(url);
        emit localApiBaseChanged(url);
    }
}

QString AgentKernel::localModelName() const
{
    auto *local = qobject_cast<LocalModelProvider *>(
        ProviderManager::instance().provider(QStringLiteral("Local")));
    if (!local) {
        return QStringLiteral("qwen2.5:7b");
    }
    return local->modelName();
}

void AgentKernel::setLocalModelName(const QString &name)
{
    auto *local = qobject_cast<LocalModelProvider *>(
        ProviderManager::instance().provider(QStringLiteral("Local")));
    if (local && local->modelName() != name) {
        local->setModelName(name);
        emit localModelNameChanged(name);
    }
}

QString AgentKernel::localApiKey() const
{
    auto *local = qobject_cast<LocalModelProvider *>(
        ProviderManager::instance().provider(QStringLiteral("Local")));
    if (!local) {
        return QString();
    }
    return local->apiKey();
}

void AgentKernel::setLocalApiKey(const QString &key)
{
    auto *local = qobject_cast<LocalModelProvider *>(
        ProviderManager::instance().provider(QStringLiteral("Local")));
    if (local && local->apiKey() != key) {
        local->setApiKey(key);
        emit localApiKeyChanged(key);
    }
}

void AgentKernel::testLocalConnection()
{
    auto *local = qobject_cast<LocalModelProvider *>(
        ProviderManager::instance().provider(QStringLiteral("Local")));
    if (!local) {
        emit connectionTestResult(false, QStringLiteral("Local provider not found"));
        return;
    }

    static bool connected = false;
    if (!connected) {
        connect(local, &LocalModelProvider::connectionTestFinished,
                this, &AgentKernel::onConnectionTestFinished);
        connected = true;
    }

    local->testConnection();
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
