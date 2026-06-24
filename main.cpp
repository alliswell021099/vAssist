#include "core/agent/AgentKernel.h"
#include "core/providers/ProviderManager.h"
#include "core/providers/MockProvider.h"
#include "core/providers/LocalModelProvider.h"

#include <QCoreApplication>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QtGlobal>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    ProviderManager::instance().registerProvider<MockProvider>();
    ProviderManager::instance().registerProvider<LocalModelProvider>();

    AgentKernel agentKernel;

    QQmlApplicationEngine engine;
    engine.addImportPath(QStringLiteral("qrc:/ui"));
    engine.rootContext()->setContextProperty(QStringLiteral("agentKernel"), &agentKernel);

    const QUrl url(QStringLiteral("qrc:/ui/main.qml"));
#if QT_VERSION >= QT_VERSION_CHECK(6, 4, 0)
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
#endif

    engine.load(url);

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
