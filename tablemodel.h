#include <QAbstractListModel>
#include <QList>
#include <QVariant>
#include <QFile>
#include <QTextStream>
#include <QDebug>

class TableModel : public QAbstractListModel {
    Q_OBJECT
    Q_PROPERTY(QVariantList editableColumns READ editableColumns WRITE setEditableColumns NOTIFY editableColumnsChanged)

public:
    explicit TableModel(QObject *parent = nullptr);

    // Роли для доступа к данным
    enum Roles {
        RowDataRole = Qt::UserRole + 1
    };

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    bool setData(const QModelIndex &index, const QVariant &value, int role) override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void loadCSV(const QString &filePath);
    Q_INVOKABLE void addRow(const QList<QVariant> &row);
    Q_INVOKABLE void clear();

    // Для редактируемых столбцов
    QVariantList editableColumns() const;
    void setEditableColumns(const QVariantList &columns);

    Q_INVOKABLE bool isCellEditable(int row, int column) const;
    Q_INVOKABLE void updateCell(int row, int column, const QVariant &value);
    // Добавляем метод сохранения
    Q_INVOKABLE bool saveCSV(const QString &filePath);
    // Переименованный метод, чтобы избежать конфликта
    void setModelData(const QList<QList<QVariant>> &newData);

    Q_INVOKABLE QString getRowIcon(int row, bool isSelected) const;
signals:
    void editableColumnsChanged();

private:
    QList<QList<QVariant>> m_data;
    QList<int> m_editableColumns; // Индексы редактируемых столбцов
};
