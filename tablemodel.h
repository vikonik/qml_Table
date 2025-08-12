#include <QAbstractListModel>
#include <QList>
#include <QVariant>

class TableModel : public QAbstractListModel {
    Q_OBJECT
public:
    explicit TableModel(QObject *parent = nullptr);

    // Роли для доступа к данным
    enum Roles {
        RowDataRole = Qt::UserRole + 1
    };

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    void addRow(const QList<QVariant> &row);
    void setData(const QList<QList<QVariant>> &newData);

private:
    QList<QList<QVariant>> m_data; // Список списков данных
};
