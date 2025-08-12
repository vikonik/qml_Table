import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

ApplicationWindow {
    visible: true
    width: 600
    height: 400
    title: "Table App"

    // Главный список (строки)
    ListView {
        id: rowView
        anchors.fill: parent
        model: tableModel
        spacing: 0 // Убрали промежуток между строками

        delegate: Rectangle {
            width: rowView.width
            height: 40
            color: index % 2 === 0 ? "#f0f0f0" : "#ffffff"
            border.color: "#e0e0e0" // Только нижняя граница для строки
            border.width: 0  // Полностью убрали границу

            // Вложенный список (ячейки)
            Row {
                anchors.fill: parent
                spacing: 0 // Убрали промежуток между ячейками

                Repeater {
                    model: rowData

                    delegate: Rectangle {
                        width: rowView.width / rowData.length // Равномерное распределение
                        height: parent.height
                        color: "transparent" // Прозрачный фон

                        Text {
                            anchors.centerIn: parent
                            text: modelData
                            font.pixelSize: 14
                        }

                        // Правая граница для ячейки (кроме последней)
                        Rectangle {
                            anchors.right: parent.right
                            width: 1
                            height: parent.height
                            color: "#e0e0e0"
                            visible: index < rowData.length - 1
                        }
                    }
                }
            }

            // Нижняя граница для строки
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: "#e0e0e0"
            }
        }
    }
}
