import { Link } from 'react-router-dom'
import { useEffect, useState } from 'react'
import { getOrders } from '../services/api'

function OrderManagement() {
  const [orders, setOrders] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')

  // Search and filter states
  const [searchTerm, setSearchTerm] = useState('')
  const [statusFilter, setStatusFilter] = useState('all')

  useEffect(() => {
    async function loadOrders() {
      try {
        const data = await getOrders()
        setOrders(data)
      } catch (err) {
        setError(err.message)
      } finally {
        setLoading(false)
      }
    }

    loadOrders()
  }, [])

  // Filter orders using search and status
  const filteredOrders = orders.filter((order) => {
    const search = searchTerm.toLowerCase()

    const matchesSearch =
      order.id.toString().includes(search) ||
      order.customer_name.toLowerCase().includes(search)

    const matchesStatus =
      statusFilter === 'all' || order.status === statusFilter

    return matchesSearch && matchesStatus
  })

  function clearFilters() {
    setSearchTerm('')
    setStatusFilter('all')
  }

  if (loading) {
    return <main className="dashboard-content">Loading orders...</main>
  }

  if (error) {
    return <main className="dashboard-content">Error: {error}</main>
  }

  return (
    <main className="dashboard-content">
      <div className="page-heading">
        <h2>Order Management</h2>
        <p>View and manage customer orders.</p>
      </div>

      <div className="recent-orders">

        <h2>All Orders ({filteredOrders.length})</h2>

        {/* Search and filter controls */}
        <div className="order-filters">

          <input
            type="text"
            placeholder="Search by order ID or customer name..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />

          <select
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value)}
          >
            <option value="all">All Statuses</option>
            <option value="pending">Pending</option>
            <option value="confirmed">Confirmed</option>
            <option value="preparing">Preparing</option>
            <option value="ready">Ready</option>
            <option value="delivered">Delivered</option>
            <option value="cancelled">Cancelled</option>
          </select>

          <button
            className="clear-filter-button"
            onClick={clearFilters}
          >
            Clear Filters
          </button>

        </div>

        <table>
          <thead>
            <tr>
              <th>Order ID</th>
              <th>Customer</th>
              <th>Phone</th>
              <th>Total Amount</th>
              <th>Status</th>
              <th>Order Date</th>
              <th>Actions</th>
            </tr>
          </thead>

          <tbody>
            {filteredOrders.map((order) => (
              <tr key={order.id}>
                <td>#{order.id}</td>

                <td>{order.customer_name}</td>

                <td>{order.customer_phone}</td>

                <td>{order.total_amount} ETB</td>

                <td>
                  <span className={`status-badge status-${order.status}`}>
                    {order.status.charAt(0).toUpperCase() +
                      order.status.slice(1)}
                  </span>
                </td>

                <td>
                  {new Date(order.created_at).toLocaleString()}
                </td>

                <td>
                  <Link
                    to={`/orders/${order.id}`}
                    className="edit-button"
                  >
                    View Details
                  </Link>
                </td>
              </tr>
            ))}
          </tbody>
        </table>

        {filteredOrders.length === 0 && (
          <p>No matching orders found.</p>
        )}

      </div>
    </main>
  )
}

export default OrderManagement