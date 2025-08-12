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
        spacing: 0

        // Свойство для хранения индекса выделенной строки
        property int selectedRow: -1

        delegate: Rectangle {
            id: rowDelegate
            width: rowView.width
            height: 40

            // Цвет фона: выделенная строка или чередование
            color: {
                if (rowView.selectedRow === index)
                    return "#c0d8f0" // цвет выделения
                else
                    return index % 2 === 0 ? "#f0f0f0" : "#ffffff"
            }

            // Обработка щелчка мыши для выделения
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    rowView.selectedRow = index
                }
            }

            // Вложенный список (ячейки)
            Row {
                anchors.fill: parent
                spacing: 0

                Repeater {
                    model: rowData

                    delegate: Rectangle {
                        width: rowView.width / rowData.length
                        height: parent.height
                        color: "transparent"

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

    // Кнопка для сброса выделения (опционально)
    Button {
        anchors {
            bottom: parent.bottom
            right: parent.right
            margins: 10
        }
        text: "Сбросить выделение"
        onClicked: rowView.selectedRow = -1
    }
}
