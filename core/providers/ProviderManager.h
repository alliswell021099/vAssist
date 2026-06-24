#pragma once

#include "LLMProvider.h"

#include <QMap>
#include <QString>
#include <QStringList>

#include <memory>
#include <type_traits>

class ProviderManager
{
public:
    static ProviderManager &instance()
    {
        static ProviderManager inst;
        return inst;
    }

    ~ProviderManager() = default;

    template<typename T>
    void registerProvider()
    {
        static_assert(std::is_base_of<LLMProvider, T>::value,
                      "T must inherit from LLMProvider");

        auto *provider = new T();
        const QString name = provider->name();
        if (m_providers.contains(name)) {
            delete provider;
            return;
        }
        m_providers[name] = provider;
    }

    LLMProvider *provider(const QString &name) const
    {
        auto it = m_providers.find(name);
        if (it != m_providers.end()) {
            return it.value();
        }
        return nullptr;
    }

    QStringList providerNames() const
    {
        return m_providers.keys();
    }

    bool hasProvider(const QString &name) const
    {
        return m_providers.contains(name);
    }

private:
    ProviderManager() = default;
    ProviderManager(const ProviderManager &) = delete;
    ProviderManager &operator=(const ProviderManager &) = delete;

    QMap<QString, LLMProvider *> m_providers;
};
