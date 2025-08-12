#include "tablemodel.h"

TableModel::TableModel(QObject *parent) : QAbstractListModel(parent) {}

int TableModel::rowCount(const QModelIndex &parent) const {
    return parent.isValid() ? 0 : m_data.size();
}

QVariant TableModel::data(const QModelIndex &index, int role) const {
    if (!index.isValid() || index.row() >= m_data.size())
        return QVariant();

    if (role == RowDataRole)
        return QVariant::fromValue(m_data[index.row()]);

    return QVariant();
}

QHash<int, QByteArray> TableModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[RowDataRole] = "rowData";
    return roles;
}

void TableModel::addRow(const QList<QVariant> &row) {
    beginInsertRows(QModelIndex(), m_data.size(), m_data.size());
    m_data.append(row);
    endInsertRows();
}

void TableModel::setData(const QList<QList<QVariant>> &newData) {
    beginResetModel();
    m_data = newData;
    endResetModel();
}
