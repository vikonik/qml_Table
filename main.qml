import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

ApplicationWindow {
    visible: true
    width: 800
    height: 600
    title: "Editable CSV Table"

    // Панель управления
    Rectangle {
        id: controlPanel
        width: parent.width
        height: 50
        color: "#f0f0f0"
        border.color: "#d0d0d0"
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.margins: 10

            Button {
                text: "Загрузить CSV"
                onClicked: tableModel.loadCSV(csvPath)
            }

            Button {
                            text: "Сохранить CSV"
                            onClicked: {
                                if (tableModel.saveCSV(csvPath)) {
                                    saveMessage.text = "Файл сохранен!"
                                } else {
                                    saveMessage.text = "Ошибка сохранения!"
                                }
                                saveMessage.visible = true
                                saveTimer.start()
                            }
                        }

            Button {
                text: "Очистить таблицу"
                onClicked: tableModel.clear()
            }

            Text {
                text: "Редактируемые столбцы: " + tableModel.editableColumns
            }
        }
    }
    // Сообщение о сохранении
    Label {
        id: saveMessage
        anchors.centerIn: parent
        visible: false
        font.bold: true
        font.pixelSize: 18
        z: 10
        background: Rectangle {
            color: "#e0e0e0"
            radius: 5
        }
        padding: 10
    }

    // Таймер для скрытия сообщения
    Timer {
        id: saveTimer
        interval: 2000
        onTriggered: saveMessage.visible = false
    }


    // Главная таблица
    ListView {
        id: rowView
        anchors {
            top: controlPanel.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        model: tableModel
        spacing: 0

        property int selectedRow: -1

        delegate: Rectangle {
            id: rowDelegate
            width: rowView.width
            height: 25


            // Сохраняем индекс строки
            property int rowIndex: index

            color: {
                if (rowView.selectedRow === rowIndex)
                    return "#c0d8f0"
                else
                    return rowIndex % 2 === 0 ? "#f0f0f0" : "#ffffff"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: rowView.selectedRow = rowIndex
            }

            Row {
                anchors.fill: parent
                spacing: 0

                Repeater {
                    model: rowData

                    delegate: Rectangle  {
                        id: cellDelegate
                        width: rowView.width / rowData.length
                        height: parent.height
                        color: "transparent"

                        // Используем сохраненные индексы
                        property int columnIndex: model.index
                        property int actualRowIndex: rowDelegate.rowIndex

                        // Проверяем, можно ли редактировать эту ячейку
                        property bool editable: tableModel.isCellEditable(actualRowIndex, columnIndex)

                        // Режим редактирования
                        property bool isEditing: false

                        // Текст или поле ввода
                        Loader {
                            anchors.fill: parent
                            sourceComponent: {
                                if (cellDelegate.isEditing)
                                    return editComponent
                                else
                                    return displayComponent
                            }
                        }

                        // Компонент для отображения текста
                        Component {
                            id: displayComponent
                            Text {
                                anchors {
                                    verticalCenter: parent.verticalCenter
                                    left: parent.left
                                    leftMargin: 10
                                    right: parent.right
                                }
                                text: modelData
                                font.pixelSize: 12
                                elide: Text.ElideRight

                                MouseArea {
                                    anchors.fill: parent
                                    enabled: cellDelegate.editable
                                    onDoubleClicked: {
                                        cellDelegate.isEditing = true
                                    }
                                }
                            }
                        }

                        // Компонент для редактирования
                        Component {
                            id: editComponent
                            TextField {
                                anchors.fill: parent
                                text: modelData
                                font.pixelSize: 12
                                leftPadding: 10

                                Component.onCompleted: forceActiveFocus()

                                onEditingFinished: {
                                    // Сохраняем изменения с правильными индексами
                                    tableModel.updateCell(actualRowIndex, columnIndex, text)
                                    cellDelegate.isEditing = false
                                }

                                onActiveFocusChanged: {
                                    if (!activeFocus) {
                                        cellDelegate.isEditing = false
                                    }
                                }
                            }
                        }

                        // Правая граница для ячейки
                        Rectangle {
                            anchors.right: parent.right
                            width: 1
                            height: parent.height
                            color: "#e0e0e0"
                            visible: columnIndex < rowData.length - 1
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

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AlwaysOn
            width: 10
        }
    }
}
