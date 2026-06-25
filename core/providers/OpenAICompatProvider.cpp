#include "OpenAICompatProvider.h"

#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QNetworkRequest>
#include <QUrl>

OpenAICompatProvider::OpenAICompatProvider(QObject *parent)
    : LLMProvider(parent)
    , m_networkManager(new QNetworkAccessManager(this))
{
}

OpenAICompatProvider::~OpenAICompatProvider()
{
    if (m_currentReply) {
        m_currentReply->abort();
        m_currentReply = nullptr;
    }
}

QString OpenAICompatProvider::name() const
{
    return QStringLiteral("OpenAI");
}

void OpenAICompatProvider::setApiBase(const QString &url)
{
    m_apiBase = url;
}

QString OpenAICompatProvider::apiBase() const
{
    return m_apiBase;
}

void OpenAICompatProvider::setModelName(const QString &name)
{
    m_modelName = name;
}

QString OpenAICompatProvider::modelName() const
{
    return m_modelName;
}

void OpenAICompatProvider::setApiKey(const QString &key)
{
    m_apiKey = key;
}

QString OpenAICompatProvider::apiKey() const
{
    return m_apiKey;
}

void OpenAICompatProvider::setTemperature(float temp)
{
    m_temperature = temp;
}

float OpenAICompatProvider::temperature() const
{
    return m_temperature;
}

void OpenAICompatProvider::setMaxTokens(int tokens)
{
    m_maxTokens = tokens;
}

int OpenAICompatProvider::maxTokens() const
{
    return m_maxTokens;
}

void OpenAICompatProvider::setStream(bool enable)
{
    m_stream = enable;
}

bool OpenAICompatProvider::stream() const
{
    return m_stream;
}

bool OpenAICompatProvider::testConnection()
{
    QUrl url(m_apiBase + QStringLiteral("/models"));
    QNetworkRequest request(url);

    if (!m_apiKey.isEmpty()) {
        request.setRawHeader("Authorization",
                             "Bearer " + m_apiKey.toUtf8());
    }

    QNetworkReply *reply = m_networkManager->get(request);

    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        const bool ok = reply->error() == QNetworkReply::NoError;
        const QString message = ok
            ? QStringLiteral("连接成功")
            : QStringLiteral("连接失败：%1").arg(reply->errorString());
        emit connectionTestFinished(ok, message);
        reply->deleteLater();
    });

    return true;
}

void OpenAICompatProvider::sendPrompt(const QString &prompt)
{
    if (m_currentReply) {
        m_currentReply->abort();
        m_currentReply = nullptr;
    }

    if (m_modelName.trimmed().isEmpty()) {
        emit errorOccurred(QStringLiteral("No model selected for the active provider."));
        return;
    }

    m_sseBuffer.clear();
    m_fullResponse.clear();

    QUrl url(m_apiBase + QStringLiteral("/chat/completions"));
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    if (!m_apiKey.isEmpty()) {
        request.setRawHeader("Authorization",
                             "Bearer " + m_apiKey.toUtf8());
    }

    QJsonObject messageObj;
    messageObj["role"] = "user";
    messageObj["content"] = prompt;

    QJsonArray messagesArray;
    messagesArray.append(messageObj);

    QJsonObject bodyObj;
    bodyObj["model"] = m_modelName;
    bodyObj["messages"] = messagesArray;
    bodyObj["temperature"] = m_temperature;
    bodyObj["max_tokens"] = m_maxTokens;
    bodyObj["stream"] = m_stream;

    const QJsonDocument doc(bodyObj);
    const QByteArray body = doc.toJson(QJsonDocument::Compact);

    m_currentReply = m_networkManager->post(request, body);

    if (m_stream) {
        connect(m_currentReply, &QNetworkReply::readyRead,
                this, &OpenAICompatProvider::onReplyReadyRead);
    }

    connect(m_currentReply, &QNetworkReply::finished,
            this, &OpenAICompatProvider::onReplyFinished);
    connect(m_currentReply, &QNetworkReply::errorOccurred,
            this, &OpenAICompatProvider::onReplyError);
    connect(m_currentReply, &QNetworkReply::sslErrors,
            this, &OpenAICompatProvider::onSslErrors);
}

void OpenAICompatProvider::onReplyReadyRead()
{
    if (!m_currentReply) {
        return;
    }

    const QByteArray data = m_currentReply->readAll();
    m_sseBuffer.append(data);

    parseSseChunk(m_sseBuffer);
}

void OpenAICompatProvider::parseSseChunk(QByteArray &buffer)
{
    int lineStart = 0;

    while (lineStart < buffer.size()) {
        int lineEnd = buffer.indexOf('\n', lineStart);
        if (lineEnd == -1) {
            break;
        }

        QByteArray line = buffer.mid(lineStart, lineEnd - lineStart);

        if (line.endsWith('\r')) {
            line.chop(1);
        }

        lineStart = lineEnd + 1;

        if (line.isEmpty()) {
            continue;
        }

        processSseLine(line);
    }

    if (lineStart > 0) {
        buffer = buffer.mid(lineStart);
    }
}

void OpenAICompatProvider::processSseLine(const QByteArray &line)
{
    if (!line.startsWith("data: ")) {
        return;
    }

    const QByteArray data = line.mid(6);

    if (data == "[DONE]") {
        return;
    }

    const QJsonDocument doc = QJsonDocument::fromJson(data);
    if (!doc.isObject()) {
        return;
    }

    const QJsonObject obj = doc.object();
    const QJsonArray choices = obj.value("choices").toArray();

    if (choices.isEmpty()) {
        return;
    }

    const QJsonObject choice = choices.first().toObject();
    const QJsonObject delta = choice.value("delta").toObject();
    const QString content = delta.value("content").toString();

    if (content.isEmpty()) {
        return;
    }

    m_fullResponse += content;
    emit tokenReady(content);
}

void OpenAICompatProvider::onReplyFinished()
{
    if (!m_currentReply) {
        return;
    }

    QNetworkReply *reply = m_currentReply;
    m_currentReply = nullptr;

    if (reply->error() != QNetworkReply::NoError) {
        const int httpStatus = reply->attribute(
            QNetworkRequest::HttpStatusCodeAttribute).toInt();
        const QString errorStr = reply->errorString();

        QByteArray body = reply->readAll();
        if (body.isEmpty() && !m_sseBuffer.isEmpty()) {
            body = m_sseBuffer;
        }

        QString message = QStringLiteral("网络错误：%1").arg(errorStr);
        if (httpStatus > 0) {
            message += QStringLiteral(" (HTTP %1)").arg(httpStatus);
        }
        if (!body.isEmpty()) {
            message += QStringLiteral("\n%1").arg(QString::fromUtf8(body.left(500)));
        }

        emit errorOccurred(message);
        reply->deleteLater();
        return;
    }

    if (!m_stream) {
        const QByteArray data = reply->readAll();
        const QJsonDocument doc = QJsonDocument::fromJson(data);

        if (!doc.isObject()) {
            emit errorOccurred(QStringLiteral("响应解析失败"));
            reply->deleteLater();
            return;
        }

        const QJsonObject obj = doc.object();
        const QJsonArray choices = obj.value("choices").toArray();

        if (choices.isEmpty()) {
            emit errorOccurred(QStringLiteral("响应中没有 choices"));
            reply->deleteLater();
            return;
        }

        const QJsonObject choice = choices.first().toObject();
        const QJsonObject message = choice.value("message").toObject();
        const QString content = message.value("content").toString();

        emit finished(content);
    } else {
        if (!m_sseBuffer.isEmpty()) {
            parseSseChunk(m_sseBuffer);
        }
        emit finished(m_fullResponse);
    }

    reply->deleteLater();
}

void OpenAICompatProvider::onReplyError(QNetworkReply::NetworkError code)
{
    Q_UNUSED(code);
}

void OpenAICompatProvider::onSslErrors(const QList<QSslError> &errors)
{
    Q_UNUSED(errors);
    if (!m_currentReply) {
        return;
    }
    m_currentReply->ignoreSslErrors();
}
