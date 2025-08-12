#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "tablemodel.h"

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);

    // Создаем и наполняем модель
    TableModel model;
    model.addRow({"ID", "Name", "Age"});
    model.addRow({1, "John Doe", 30});
    model.addRow({2, "Jane Smith", 25});
    model.addRow({3, "Bob Johnson", 40});
    model.addRow({1, "John Doe", 30});
    model.addRow({2, "Jane Smith", 25});
    model.addRow({3, "Bob Johnson", 40});
    model.addRow({1, "John Doe", 30});
    model.addRow({2, "Jane Smith", 25});
    model.addRow({3, "Bob Johnson", 40});
    model.addRow({1, "John Doe", 30});
    model.addRow({2, "Jane Smith", 25});
    model.addRow({3, "Bob Johnson", 40});

    QQmlApplicationEngine engine;

    // Регистрируем модель как контекстное свойство
    engine.rootContext()->setContextProperty("tableModel", &model);

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    // Проверка ошибок загрузки QML
    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
