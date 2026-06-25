#ifndef PROVIDERSETTINGS_H
#define PROVIDERSETTINGS_H

#include <QObject>
#include <QJsonObject>
#include <QJsonArray>
#include <QStringList>

struct ProviderConfig {
    QString id;
    QString name;
    QString baseUrl;
    QString apiKey;
    QString apiFormat;
    QStringList models;
    QString activeModel;
    bool isPreset = false;
};

class ProviderSettings : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString activeProviderId READ activeProviderId WRITE setActiveProviderId NOTIFY activeProviderIdChanged)
    Q_PROPERTY(QString activeModel READ activeModel WRITE setActiveModel NOTIFY activeModelChanged)

public:
    explicit ProviderSettings(QObject *parent = nullptr);

    Q_INVOKABLE QVariantList providers() const;
    Q_INVOKABLE QVariantList modelsForProvider(const QString &providerId) const;

    Q_INVOKABLE void addProvider(const QString &name, const QString &baseUrl,
                                 const QString &apiKey, const QString &apiFormat);
    Q_INVOKABLE void updateProvider(const QString &providerId, const QString &name,
                                    const QString &baseUrl, const QString &apiKey,
                                    const QString &apiFormat);
    Q_INVOKABLE void deleteProvider(const QString &providerId);

    Q_INVOKABLE void addModel(const QString &providerId, const QString &modelName);
    Q_INVOKABLE void deleteModel(const QString &providerId, const QString &modelName);

    Q_INVOKABLE QString activeProviderId() const;
    Q_INVOKABLE void setActiveProviderId(const QString &id);

    Q_INVOKABLE QString activeModel() const;
    Q_INVOKABLE void setActiveModel(const QString &model);
    Q_INVOKABLE void setProviderActiveModel(const QString &providerId, const QString &model);

    Q_INVOKABLE QVariantMap activeProviderConfig() const;

    Q_INVOKABLE void save();
    Q_INVOKABLE void load();

signals:
    void providersChanged();
    void activeProviderIdChanged();
    void activeModelChanged();

private:
    QString configFilePath() const;
    void ensureDefaults();
    QJsonObject providerToJson(const ProviderConfig &provider) const;
    ProviderConfig providerFromJson(const QJsonObject &obj) const;

    QList<ProviderConfig> m_providers;
    QString m_activeProviderId;
    QString m_activeModel;
};

#endif // PROVIDERSETTINGS_H
