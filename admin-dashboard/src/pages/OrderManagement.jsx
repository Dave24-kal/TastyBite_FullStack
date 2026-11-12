import { Link } from 'react-router-dom'
import { useEffect, useState } from 'react'
import { getOrders } from '../services/api'

function OrderManagement() {
  const [orders, setOrders] = useState([])
  const [loading, setLoading] = useState(true)
  const [refreshing, setRefreshing] = useState(false)
  const [error, setError] = useState('')

  // Search and filter states
  const [searchTerm, setSearchTerm] = useState('')
  const [statusFilter, setStatusFilter] = useState('all')

  const [currentPage, setCurrentPage] = useState(1)
  const ordersPerPage = 10

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
  // Refresh orders from the backend
const handleRefresh = async () => {
  try {
    setRefreshing(true)
    setError('')

    const data = await getOrders()

    setOrders(data)
  } catch (err) {
    setError(err.message)
  } finally {
    setRefreshing(false)
  }
}

  const filteredOrders = orders.filter((order) => {
    const search = searchTerm.toLowerCase()

    const matchesSearch =
      order.id.toString().includes(search) ||
      order.customer_name.toLowerCase().includes(search)

    const matchesStatus =
      statusFilter === 'all' || order.status === statusFilter

    return matchesSearch && matchesStatus
  })
  // Calculate the positions of orders on the current page
const indexOfLastOrder = currentPage * ordersPerPage

const indexOfFirstOrder = indexOfLastOrder - ordersPerPage

// Get only the orders belonging to the current page
const currentOrders = filteredOrders.slice(
  indexOfFirstOrder,
  indexOfLastOrder
)

// Calculate the total number of pages
const totalPages = Math.ceil(filteredOrders.length / ordersPerPage)

  function clearFilters() {
  setSearchTerm('')
  setStatusFilter('all')
  setCurrentPage(1)
}
  // Move to the next page
const nextPage = () => {
  if (currentPage < totalPages) {
    setCurrentPage(currentPage + 1)
  }
}

// Move to the previous page
const previousPage = () => {
  if (currentPage > 1) {
    setCurrentPage(currentPage - 1)
  }
}

  if (loading) {
    return <main className="dashboard-content">Loading orders...</main>
  }

  if (error) {
    return <main className="dashboard-content">Error: {error}</main>
  }

  return (
    <main className="dashboard-content">
      <div className="page-heading order-page-heading">
  <div>
    <h2>Order Management</h2>
    <p>View and manage customer orders.</p>
  </div>

  <button
    className="refresh-button"
    onClick={handleRefresh}
    disabled={refreshing}
  >
    {refreshing ? 'Refreshing...' : 'Refresh Orders'}
  </button>
</div>

      <div className="recent-orders">

        <h2>All Orders ({filteredOrders.length})</h2>

        {/* Search and filter controls */}
        <div className="order-filters">

          <input
            type="text"
            placeholder="Search by order ID or customer name..."
            value={searchTerm}
            onChange={(e) => {
  setSearchTerm(e.target.value)
  setCurrentPage(1)
}}
          />

          <select
            value={statusFilter}
            onChange={(e) => {
  setStatusFilter(e.target.value)
  setCurrentPage(1)
}}
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
            {currentOrders.map((order) => (
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
        {/* Pagination Controls */}
{filteredOrders.length > 0 && (
  <div className="pagination">

    <button
      onClick={previousPage}
      disabled={currentPage === 1}
    >
      Previous
    </button>

    <span>
      Page {currentPage} of {totalPages}
    </span>

    <button
      onClick={nextPage}
      disabled={currentPage === totalPages}
    >
      Next
    </button>

  </div>
)}

      </div>
    </main>
  )
}

export default OrderManagement