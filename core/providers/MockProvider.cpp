#include "MockProvider.h"

MockProvider::MockProvider(QObject *parent)
    : LLMProvider(parent)
    , m_streamTimer(new QTimer(this))
{
    m_streamTimer->setInterval(50);
    connect(m_streamTimer, &QTimer::timeout,
            this, &MockProvider::onStreamTick);
}

QString MockProvider::name() const
{
    return QStringLiteral("Mock");
}

void MockProvider::sendPrompt(const QString &prompt)
{
    Q_UNUSED(prompt);

    const QString response = QStringLiteral(
        "你好！我是 Mock 测试助手。\n\n"
        "我可以模拟流式输出效果，用来测试 UI 的逐字显示。\n\n"
        "你可以在设置中切换到本地模型（Ollama）来使用真实的 AI 能力。");

    if (!m_stream) {
        QTimer::singleShot(500, this, [this, response]() {
            emit finished(response);
        });
        return;
    }

    m_streamText = response;
    m_streamIndex = 0;
    m_streamTimer->start();
}

void MockProvider::onStreamTick()
{
    if (m_streamIndex >= m_streamText.size()) {
        m_streamTimer->stop();
        emit finished(m_streamText);
        return;
    }

    const QString token = m_streamText.at(m_streamIndex);
    m_streamIndex++;
    emit tokenReady(token);
}
