#include "ProviderSettings.h"
#include <QStandardPaths>
#include <QDir>
#include <QFile>
#include <QJsonDocument>
#include <QDateTime>
#include <QDebug>

namespace {
ProviderConfig createMockProviderConfig()
{
    ProviderConfig mock;
    mock.id = QStringLiteral("mock");
    mock.name = QStringLiteral("MockProvider");
    mock.baseUrl = QString();
    mock.apiKey = QString();
    mock.apiFormat = QStringLiteral("mock");
    mock.models = {QStringLiteral("MockProvider")};
    mock.activeModel = QStringLiteral("MockProvider");
    mock.isPreset = true;
    return mock;
}
}

ProviderSettings::ProviderSettings(QObject *parent)
    : QObject(parent)
{
    load();
}

QString ProviderSettings::configFilePath() const
{
    const QString configDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir().mkpath(configDir);
    return configDir + "/providers.json";
}

void ProviderSettings::ensureDefaults()
{
    if (!m_providers.isEmpty()) {
        return;
    }

    const ProviderConfig mock = createMockProviderConfig();
    m_providers.append(mock);

    ProviderConfig ollama;
    ollama.id = "ollama";
    ollama.name = "Ollama";
    ollama.baseUrl = "http://localhost:11434/v1";
    ollama.apiKey = "";
    ollama.apiFormat = "openai";
    ollama.models = {"qwen2.5:7b", "llama3:8b", "gemma2:9b"};
    ollama.activeModel = "qwen2.5:7b";
    ollama.isPreset = false;
    m_providers.append(ollama);

    ProviderConfig deepseek;
    deepseek.id = "deepseek";
    deepseek.name = "DeepSeek";
    deepseek.baseUrl = "https://api.deepseek.com/v1";
    deepseek.apiKey = "";
    deepseek.apiFormat = "openai";
    deepseek.models = {"deepseek-v4-flash", "deepseek-v4-pro", "deepseek-chat", "deepseek-reasoner"};
    deepseek.activeModel = "deepseek-v4-flash";
    deepseek.isPreset = false;
    m_providers.append(deepseek);

    m_activeProviderId = mock.id;
    m_activeModel = mock.activeModel;
}

QVariantList ProviderSettings::providers() const
{
    QVariantList list;
    for (const auto &p : m_providers) {
        QVariantMap map;
        map["id"] = p.id;
        map["name"] = p.name;
        map["baseUrl"] = p.baseUrl;
        map["apiKey"] = p.apiKey;
        map["apiFormat"] = p.apiFormat;
        map["isPreset"] = p.isPreset;
        map["activeModel"] = p.activeModel;
        list.append(map);
    }
    return list;
}

QVariantList ProviderSettings::modelsForProvider(const QString &providerId) const
{
    QVariantList list;
    for (const auto &p : m_providers) {
        if (p.id == providerId) {
            for (const auto &m : p.models) {
                list.append(m);
            }
            break;
        }
    }
    return list;
}

void ProviderSettings::addProvider(const QString &name, const QString &baseUrl,
                                   const QString &apiKey, const QString &apiFormat)
{
    ProviderConfig provider;
    provider.id = QString("custom_%1").arg(QDateTime::currentMSecsSinceEpoch());
    provider.name = name;
    provider.baseUrl = baseUrl;
    provider.apiKey = apiKey;
    provider.apiFormat = apiFormat;
    provider.isPreset = false;
    m_providers.append(provider);
    save();
    emit providersChanged();
}

void ProviderSettings::updateProvider(const QString &providerId, const QString &name,
                                      const QString &baseUrl, const QString &apiKey,
                                      const QString &apiFormat)
{
    for (auto &p : m_providers) {
        if (p.id == providerId) {
            p.name = name;
            p.baseUrl = baseUrl;
            p.apiKey = apiKey;
            p.apiFormat = apiFormat;
            save();
            emit providersChanged();
            break;
        }
    }
}

void ProviderSettings::deleteProvider(const QString &providerId)
{
    for (auto it = m_providers.begin(); it != m_providers.end(); ++it) {
        if (it->id == providerId && !it->isPreset) {
            m_providers.erase(it);
            if (m_activeProviderId == providerId && !m_providers.isEmpty()) {
                m_activeProviderId = m_providers.first().id;
                m_activeModel = m_providers.first().activeModel;
                emit activeProviderIdChanged();
                emit activeModelChanged();
            }
            save();
            emit providersChanged();
            break;
        }
    }
}

void ProviderSettings::addModel(const QString &providerId, const QString &modelName)
{
    for (auto &p : m_providers) {
        if (p.id == providerId) {
            if (!p.models.contains(modelName)) {
                p.models.append(modelName);
                save();
                emit providersChanged();
            }
            break;
        }
    }
}

void ProviderSettings::deleteModel(const QString &providerId, const QString &modelName)
{
    for (auto &p : m_providers) {
        if (p.id == providerId) {
            p.models.removeOne(modelName);
            if (p.models.isEmpty()) {
                p.activeModel.clear();
                if (m_activeProviderId == providerId) {
                    m_activeModel.clear();
                    emit activeModelChanged();
                }
            } else if (p.activeModel == modelName || !p.models.contains(p.activeModel)) {
                p.activeModel = p.models.first();
                if (m_activeProviderId == providerId) {
                    m_activeModel = p.activeModel;
                    emit activeModelChanged();
                }
            }
            save();
            emit providersChanged();
            break;
        }
    }
}

QString ProviderSettings::activeProviderId() const
{
    return m_activeProviderId;
}

void ProviderSettings::setActiveProviderId(const QString &id)
{
    if (m_activeProviderId == id) return;
    m_activeProviderId = id;
    for (const auto &p : m_providers) {
        if (p.id == id) {
            if (p.models.isEmpty()) {
                m_activeModel.clear();
            } else if (p.activeModel.isEmpty() || !p.models.contains(p.activeModel)) {
                m_activeModel = p.models.first();
            } else {
                m_activeModel = p.activeModel;
            }
            emit activeModelChanged();
            break;
        }
    }
    save();
    emit activeProviderIdChanged();
}

QString ProviderSettings::activeModel() const
{
    return m_activeModel;
}

void ProviderSettings::setActiveModel(const QString &model)
{
    if (m_activeModel == model) return;
    m_activeModel = model;
    for (auto &p : m_providers) {
        if (p.id == m_activeProviderId) {
            p.activeModel = model;
            break;
        }
    }
    save();
    emit activeModelChanged();
}

void ProviderSettings::setProviderActiveModel(const QString &providerId, const QString &model)
{
    for (auto &p : m_providers) {
        if (p.id != providerId) {
            continue;
        }

        if (!p.models.contains(model)) {
            return;
        }

        if (p.activeModel == model) {
            return;
        }

        p.activeModel = model;

        const bool currentProviderChanged = m_activeProviderId == providerId && m_activeModel != model;
        if (currentProviderChanged) {
            m_activeModel = model;
        }

        save();

        if (currentProviderChanged) {
            emit activeModelChanged();
        }
        emit providersChanged();
        return;
    }
}

QVariantMap ProviderSettings::activeProviderConfig() const
{
    QVariantMap map;
    for (const auto &p : m_providers) {
        if (p.id == m_activeProviderId) {
            map["id"] = p.id;
            map["name"] = p.name;
            map["baseUrl"] = p.baseUrl;
            map["apiKey"] = p.apiKey;
            map["apiFormat"] = p.apiFormat;
            map["model"] = m_activeModel;
            break;
        }
    }
    return map;
}

void ProviderSettings::save()
{
    QJsonObject root;
    root["activeProviderId"] = m_activeProviderId;
    root["activeModel"] = m_activeModel;

    QJsonArray arr;
    for (const auto &p : m_providers) {
        arr.append(providerToJson(p));
    }
    root["providers"] = arr;

    QJsonDocument doc(root);
    QFile file(configFilePath());
    if (file.open(QIODevice::WriteOnly)) {
        file.write(doc.toJson());
        file.close();
    }
}

void ProviderSettings::load()
{
    QFile file(configFilePath());
    if (!file.open(QIODevice::ReadOnly)) {
        ensureDefaults();
        save();
        return;
    }

    const QByteArray data = file.readAll();
    file.close();

    const QJsonDocument doc = QJsonDocument::fromJson(data);
    if (!doc.isObject()) {
        ensureDefaults();
        save();
        return;
    }

    const QJsonObject root = doc.object();
    m_activeProviderId = root.value("activeProviderId").toString();
    m_activeModel = root.value("activeModel").toString();

    const QJsonArray arr = root.value("providers").toArray();
    for (const auto &v : arr) {
        m_providers.append(providerFromJson(v.toObject()));
    }

    bool changed = false;
    bool hasMockProvider = false;
    bool hasActiveProvider = false;
    for (const auto &provider : m_providers) {
        if (provider.id == QStringLiteral("mock")) {
            hasMockProvider = true;
        }
        if (provider.id == m_activeProviderId) {
            hasActiveProvider = true;
        }
    }

    if (!hasMockProvider) {
        m_providers.prepend(createMockProviderConfig());
        changed = true;
    }

    if (m_providers.isEmpty()) {
        ensureDefaults();
        changed = true;
    }

    if (!hasActiveProvider && !m_providers.isEmpty()) {
        m_activeProviderId = m_providers.first().id;
        m_activeModel = m_providers.first().activeModel;
        changed = true;
    }

    if (changed) {
        save();
    }
}

QJsonObject ProviderSettings::providerToJson(const ProviderConfig &provider) const
{
    QJsonObject obj;
    obj["id"] = provider.id;
    obj["name"] = provider.name;
    obj["baseUrl"] = provider.baseUrl;
    obj["apiKey"] = provider.apiKey;
    obj["apiFormat"] = provider.apiFormat;
    obj["isPreset"] = provider.isPreset;
    obj["activeModel"] = provider.activeModel;

    QJsonArray modelsArr;
    for (const auto &m : provider.models) {
        modelsArr.append(m);
    }
    obj["models"] = modelsArr;

    return obj;
}

ProviderConfig ProviderSettings::providerFromJson(const QJsonObject &obj) const
{
    ProviderConfig p;
    p.id = obj.value("id").toString();
    p.name = obj.value("name").toString();
    p.baseUrl = obj.value("baseUrl").toString();
    p.apiKey = obj.value("apiKey").toString();
    p.apiFormat = obj.value("apiFormat").toString("openai");
    p.isPreset = p.id.compare(QStringLiteral("mock"), Qt::CaseInsensitive) == 0
        && obj.value("isPreset").toBool(false);
    p.activeModel = obj.value("activeModel").toString();

    const QJsonArray arr = obj.value("models").toArray();
    for (const auto &v : arr) {
        p.models.append(v.toString());
    }

    return p;
}
