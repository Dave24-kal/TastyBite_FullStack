import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { getOrders } from '../services/api'

function RecentOrders() {
  const [orders, setOrders] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')

  useEffect(() => {
    async function loadRecentOrders() {
      try {
        const data = await getOrders()

        // Display only the five most recent orders.
        setOrders(data.slice(0, 5))
      } catch (err) {
        setError(err.message)
      } finally {
        setLoading(false)
      }
    }

    loadRecentOrders()
  }, [])

  return (
    <section className="recent-orders">
      <h2>Recent Orders</h2>

      {loading && <p>Loading recent orders...</p>}

      {error && <p className="login-error">{error}</p>}

      {!loading && !error && (
        <>
          <table>
            <thead>
              <tr>
                <th>Order ID</th>
                <th>Customer</th>
                <th>Date</th>
                <th>Amount</th>
                <th>Status</th>
                <th>Action</th>
              </tr>
            </thead>

            <tbody>
              {orders.map((order) => (
                <tr key={order.id}>
                  <td>#{order.id}</td>

                  <td>{order.customer_name}</td>

                  <td>
                    {new Date(order.created_at).toLocaleDateString()}
                  </td>

                  <td>
                    {Number(order.total_amount).toFixed(2)} ETB
                  </td>

                  <td>
                    <span className={`status-badge status-${order.status}`}>
                      {order.status.charAt(0).toUpperCase() +
                        order.status.slice(1)}
                    </span>
                  </td>

                  <td>
                    <Link
                      to={`/orders/${order.id}`}
                      className="edit-button"
                    >
                      View
                    </Link>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>

          {orders.length === 0 && (
            <p>No orders available yet.</p>
          )}
        </>
      )}

      <div className="view-all-orders">
        <Link to="/orders">View All Orders →</Link>
      </div>
    </section>
  )
}

export default RecentOrders