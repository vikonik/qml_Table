#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QStandardPaths>
#include <QDir>
#include "TableModel.h"

// Создаем тестовый CSV файл
void createTestCSV(const QString &filePath) {
    QFile file(filePath);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        qWarning() << "Cannot create test CSV file";
        return;
    }

    QTextStream out(&file);
    out << "ID,Name,Age,Department,Salary\n";

    // Генерируем 30 тестовых строк
    for (int i = 1; i <= 30; ++i) {
        out << QString("%1,Employee %2,%3,Department %4,%5\n")
            .arg(i)
            .arg(i)
            .arg(20 + (i % 20))
            .arg(1 + (i % 5))
            .arg(30000 + (i * 1000));
    }

    file.close();
    qDebug() << "Created test CSV file:" << filePath;
}

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);

    // Путь для CSV файла
    QString csvPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir().mkpath(csvPath);
    csvPath += "/employees.csv";

    // Создаем тестовый файл если его нет
    if (!QFile::exists(csvPath)) {
        createTestCSV(csvPath);
    }

    // Создаем модель
    TableModel model;

    // Устанавливаем редактируемые столбцы (например, 1 и 3)
    model.setEditableColumns({1, 3}); // Name и Department

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("tableModel", &model);
    engine.rootContext()->setContextProperty("csvPath", csvPath);
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
