#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QStandardPaths>
#include <QDir>
#include "tablemodel.h"

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

    // Указываем конкретный путь к папке
    QString projectDir = "D:/0_KNX/QML_TableList/TableList";
    QDir().mkpath(projectDir);

    // Путь для CSV файла
    QString csvPath = projectDir + "/employees.csv";

    // Создаем тестовый файл если его нет
    if (!QFile::exists(csvPath)) {
        createTestCSV(csvPath);
    }

    // Создаем модель
    TableModel model;

    // Загружаем данные из файла
    model.loadCSV(csvPath);

    // Устанавливаем редактируемые столбцы
    model.setEditableColumns({1, 3});

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("tableModel", &model);
    engine.rootContext()->setContextProperty("csvPath", csvPath);
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
