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


/*
 !!!! QT грабли!!!!
Чтобы прокручивать таблицу по горизонтали пришлось положить
Rectangle в Rectangle и крутить уде весь второй Rectangle
*/
    // Главная таблица
    Rectangle {
        id: frame
        clip: true
        width: 500
        height: 160
        border.color: "black"
        anchors.centerIn: parent

        Rectangle{
            id: content
            height: frame.height
            width: 600
            x: -hbar.position * width

            ListView {
                id: rowView
                anchors {
                    // top: controlPanel.bottom
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }

                //width: 600
                model: tableModel
                spacing: 0

                property int selectedRow: -1

                delegate: Rectangle {
                    id: rowDelegate
                    width: rowView.width
                    height: 30

                    property int rowIndex: index
                    property bool isSelected: rowView.selectedRow === rowIndex

                    color: isSelected ? "#c0d8f0" : (rowIndex % 2 === 0 ? "#f0f0f0" : "#ffffff")

                    // Иконка в начале строки
                    Rectangle {
                        width: 30
                        height: parent.height
                        color: "transparent"

                        Image {
                            width: 20
                            height: 20
                            anchors.centerIn: parent
                            source: rowDelegate.isSelected ? "qrc:Pic1.png"
                                                           : "qrc:Pic2.png"
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: rowView.selectedRow = rowIndex
                        }
                    }

                    // Ячейки таблицы
                    Row {
                        anchors {
                            left: parent.left
                            leftMargin: 30
                            //right: parent.right
                        }
                        width: 200//вместо right
                        height: parent.height
                        spacing: 0

                        Repeater {
                            model: rowData

                            delegate: Rectangle {
                                id: cellDelegate
                                width: 150//(rowView.width - 30) / rowData.length
                                height: parent.height
                                color: "transparent"

                                property int columnIndex: model.index
                                property int actualRowIndex: rowDelegate.rowIndex
                                property bool editable: tableModel.isCellEditable(actualRowIndex, columnIndex)

                                // Область для выбора строки
                                MouseArea {
                                    anchors.fill: parent
                                    acceptedButtons: Qt.LeftButton
                                    onClicked: {
                                        if (!textInput.visible) {
                                            rowView.selectedRow = rowIndex
                                        }
                                    }
                                    onDoubleClicked: {
                                        if (cellDelegate.editable && !textInput.visible && columnIndex !== 5) {
                                            startEditing()
                                        }
                                    }
                                }

                                // Для 5-й колонки (индекс 4) - изображение и текст
                                Row {
                                    id: imageTextRow
                                    anchors {
                                        verticalCenter: parent.verticalCenter
                                        left: parent.left
                                        leftMargin: 10
                                        right: parent.right
                                    }

                                    spacing: 10
                                    visible: columnIndex === 4 && !textInput.visible

                                    Image {
                                        id: cellIcon
                                        width: 16
                                        height: 16
                                        source: {
                                            var value = parseFloat(modelData);
                                            if (value > 50000) return "qrc:Pic1.png";
                                            if (value > 40000) return "qrc:Pic2.png";
                                            return "qrc:Pic1.png";
                                        }
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Text {
                                        text: modelData
                                        font.pixelSize: 12
                                        anchors.verticalCenter: parent.verticalCenter
                                        leftPadding: 8
                                    }
                                }

                                // Для 6-й колонки (индекс 5) - чекбокс
                                CustomCheckBox {
                                    id: customCheckBox
                                    anchors.centerIn: parent
                                    visible: columnIndex === 5 && !textInput.visible
                                    checked: modelData === "1" || modelData === "true" // Поддержка разных форматов

                                    onToggled: {
                                        tableModel.updateCell(actualRowIndex, columnIndex, checked ? "1" : "0")
                                    }
                                }

                                // Обычный текст для других колонок
                                Text {
                                    id: textDisplay
                                    anchors {
                                        verticalCenter: parent.verticalCenter
                                        left: parent.left
                                        leftMargin: 10
                                        //right: parent.right
                                    }
                                    width: 200
                                    text: modelData
                                    font.pixelSize: 12
                                    elide: Text.ElideRight
                                    visible: (columnIndex !== 4 && columnIndex !== 5) && !textInput.visible
                                }

                                // Поле ввода
                                TextInput {
                                    id: textInput
                                    anchors {
                                        verticalCenter: parent.verticalCenter
                                        left: parent.left
                                        leftMargin: 10
                                        right: parent.right
                                    }
                                    text: modelData
                                    font.pixelSize: 12
                                    visible: false
                                    clip: true
                                    selectByMouse: true

                                    onEditingFinished: finishEditing()
                                    onActiveFocusChanged: if (!activeFocus) finishEditing()
                                }

                                // Правая граница для ячейки
                                Rectangle {
                                    anchors.right: parent.right
                                    width: 1
                                    height: parent.height
                                    color: "#e0e0e0"
                                    visible: columnIndex < rowData.length - 1
                                }

                                function startEditing() {
                                    textInput.text = modelData
                                    textInput.visible = true
                                    textInput.forceActiveFocus()
                                    textInput.selectAll()
                                }

                                function finishEditing() {
                                    if (textInput.visible) {
                                        tableModel.updateCell(actualRowIndex, columnIndex, textInput.text)
                                        textInput.visible = false
                                    }
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
                //        ScrollBar.vertical: ScrollBar {
                //            policy: ScrollBar.AlwaysOn
                //            width: 10
                //        }


            }

        }
        //прокрутка по горизонтали
        ScrollBar {
            id: hbar
            hoverEnabled: true
            active: hovered || pressed
            orientation: Qt.Horizontal
            size: frame.width / content.width
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            // height: 20
        }

    }

}
