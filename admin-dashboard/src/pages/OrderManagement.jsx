import { useEffect, useState } from 'react'
import { getOrders } from '../services/api'

function OrderManagement() {
  const [orders, setOrders] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')

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
        <h2>All Orders ({orders.length})</h2>

        <table>
          <thead>
            <tr>
              <th>Order ID</th>
              <th>Customer</th>
              <th>Phone</th>
              <th>Total Amount</th>
              <th>Status</th>
              <th>Order Date</th>
            </tr>
          </thead>

          <tbody>
            {orders.map((order) => (
              <tr key={order.id}>
                <td>#{order.id}</td>
                <td>{order.customer_name}</td>
                <td>{order.customer_phone}</td>
                <td>{order.total_amount} ETB</td>
                <td>{order.status}</td>
                <td>
                  {new Date(order.created_at).toLocaleString()}
                </td>
              </tr>
            ))}
          </tbody>
        </table>

        {orders.length === 0 && <p>No orders found.</p>}
      </div>
    </main>
  )
}

export default OrderManagement