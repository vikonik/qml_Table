import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.3

ApplicationWindow {
    visible: true
    width: 800
    height: 600
    title: "Editable CSV Table"

    // Диалоговые окна
    FileDialog {
        id: openFileDialog
        title: "Выберите CSV файл"
        folder: shortcuts.documents
        nameFilters: ["CSV files (*.csv)", "All files (*)"]
        onAccepted: {
            currentFilePath = openFileDialog.fileUrl.toString().replace("file:///", "")
            tableModel.loadCSV(currentFilePath)
        }
    }

    FileDialog {
        id: saveFileDialog
        title: "Сохранить CSV файл"
        folder: shortcuts.documents
        nameFilters: ["CSV files (*.csv)"]
        selectExisting: false
        onAccepted: {
            var newPath = saveFileDialog.fileUrl.toString().replace("file:///", "")
            if (tableModel.saveCSV(newPath)) {
                currentFilePath = newPath
                showMessage("Файл сохранен: " + newPath)
            } else {
                showMessage("Ошибка сохранения!")
            }
        }
    }

    // Функция для показа сообщений
    function showMessage(text) {
        messageLabel.text = text
        messageLabel.visible = true
        messageTimer.start()
    }

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
            spacing: 10

            // Группа файловых операций
            ColumnLayout {
                RowLayout {
                    Button {
                        text: "Открыть..."
                        onClicked: openFileDialog.open()
                    }

                    Button {
                        text: "Сохранить"
                        onClicked: {
                            if (tableModel.saveCSV(currentFilePath)) {
                                showMessage("Файл сохранен: " + currentFilePath)
                            } else {
                                showMessage("Ошибка сохранения!")
                            }
                        }
                    }

                    Button {
                        text: "Сохранить как..."
                        onClicked: saveFileDialog.open()
                    }
                }

                Text {
                    text: "Текущий файл: " + currentFilePath
                    font.pixelSize: 10
                    elide: Text.ElideMiddle
                    Layout.fillWidth: true
                }
            }

            // Группа действий с данными
            ColumnLayout {
                Button {
                    text: "Загрузить данные"
                    onClicked: tableModel.loadCSV(currentFilePath)
                }

                Button {
                    text: "Очистить таблицу"
                    onClicked: tableModel.clear()
                }
            }

            // Информация
            ColumnLayout {
                Text {
                    text: "Редактируемые столбцы: " + tableModel.editableColumns
                }

                Text {
                    text: "Строк: " + tableModel.rowCount
                }
            }
        }
    }

    // Сообщение
    Label {
        id: messageLabel
        anchors.centerIn: parent
        visible: false
        font.bold: true
        font.pixelSize: 18
        z: 10
        background: Rectangle {
            color: "#e0e0e0"
            radius: 10
            opacity: 0.9
        }
        padding: 15
    }

    Timer {
        id: messageTimer
        interval: 3000
        onTriggered: messageLabel.visible = false
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
            height: 30 // Увеличиваем высоту строки

            // Сохраняем индекс строки
            property int rowIndex: index
            property bool isSelected: rowView.selectedRow === rowIndex

            color: isSelected ? "#c0d8f0" : (rowIndex % 2 === 0 ? "#f0f0f0" : "#ffffff")

            Row {
                anchors.fill: parent
                spacing: 5

                // Иконка в начале строки
                Rectangle {
                    width: 25
                    height: parent.height
                    color: "transparent"

                    Image {
                        width: 20
                        height: 20
                        anchors.centerIn: parent
                        source: rowDelegate.isSelected ? "qrc:Pic1.png"
                                                      : "qrc:Pic2.png"
                    }
                }

                // Ячейки таблицы
                Repeater {
                    model: rowData

                    delegate: Rectangle {
                        id: cellDelegate
                        width: (rowView.width - 30) / rowData.length // Учитываем ширину иконки
                        height: parent.height
                        color: "transparent"

                        property int columnIndex: model.index
                        property int actualRowIndex: rowDelegate.rowIndex
                        property bool editable: tableModel.isCellEditable(actualRowIndex, columnIndex)

                        // Отображение текста
                        Text {
                            id: textDisplay
                            anchors {
                                verticalCenter: parent.verticalCenter
                                left: parent.left
                                leftMargin: 5
                                right: parent.right
                            }
                            text: modelData
                            font.pixelSize: 12
                            elide: Text.ElideRight
                            visible: true
                        }

                        // Поле ввода
                        TextInput {
                            id: textInput
                            anchors {
                                verticalCenter: parent.verticalCenter
                                left: parent.left
                                leftMargin: 5
                                right: parent.right
                            }
                            text: modelData
                            font.pixelSize: 12
                            visible: false
                            clip: true
                            selectByMouse: true

                            onEditingFinished: {
                                tableModel.updateCell(actualRowIndex, columnIndex, text)
                                visible = false
                                textDisplay.visible = true
                            }

                            onActiveFocusChanged: {
                                if (!activeFocus) {
                                    tableModel.updateCell(actualRowIndex, columnIndex, text)
                                    visible = false
                                    textDisplay.visible = true
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            enabled: cellDelegate.editable
                            onDoubleClicked: {
                                textInput.text = textDisplay.text
                                textInput.visible = true
                                textDisplay.visible = false
                                textInput.forceActiveFocus()
                                textInput.selectAll()
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

            MouseArea {
                anchors.fill: parent
                onClicked: rowView.selectedRow = rowIndex
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
