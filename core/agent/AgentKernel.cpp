#include "AgentKernel.h"

#include "core/providers/ProviderManager.h"
#include "core/providers/OpenAICompatProvider.h"
#include "core/settings/ProviderSettings.h"

#include <QJsonDocument>
#include <QJsonParseError>

AgentKernel::AgentKernel(QObject *parent)
    : QObject(parent)
{
    m_providerSettings = new ProviderSettings(this);
    connect(m_providerSettings, &ProviderSettings::activeProviderIdChanged,
            this, &AgentKernel::onActiveProviderChanged);
    connect(m_providerSettings, &ProviderSettings::activeModelChanged,
            this, &AgentKernel::onActiveProviderChanged);

    switchProvider(QStringLiteral("Mock"));
    onActiveProviderChanged();
}

void AgentKernel::onActiveProviderChanged()
{
    applyActiveProviderConfig();
}

void AgentKernel::applyActiveProviderConfig()
{
    if (!m_providerSettings) return;

    const auto config = m_providerSettings->activeProviderConfig();
    if (config.isEmpty()) return;

    if (config["apiFormat"].toString() == QStringLiteral("mock")) {
        switchProvider(QStringLiteral("Mock"));
        return;
    }

    auto *provider = qobject_cast<OpenAICompatProvider *>(
        ProviderManager::instance().provider(QStringLiteral("OpenAI")));
    if (!provider) return;

    provider->setApiBase(config["baseUrl"].toString());
    provider->setModelName(config["model"].toString());
    provider->setApiKey(config["apiKey"].toString());
    switchProvider(QStringLiteral("OpenAI"));
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
