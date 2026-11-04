import { useEffect, useState } from 'react'
import { Link, useParams } from 'react-router-dom'
import { getOrders, updateOrderStatus } from '../services/api'
function OrderDetails() {
  const { orderId } = useParams()

  const [order, setOrder] = useState(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')
  const [newStatus, setNewStatus] = useState('')
  const [updating, setUpdating] = useState(false)
  const [updateError, setUpdateError] = useState('')
  const [successMessage, setSuccessMessage] = useState('')

  useEffect(() => {
    async function loadOrder() {
      try {
        const orders = await getOrders()

        const selectedOrder = orders.find(
          (item) => item.id === Number(orderId)
        )

        if (!selectedOrder) {
          throw new Error('Order not found.')
        }

        setOrder(selectedOrder)
        setNewStatus(selectedOrder.status)
      } catch (err) {
        setError(err.message)
      } finally {
        setLoading(false)
      }
    }

    loadOrder()
  }, [orderId])

  const statusOptions = {
  pending: ['confirmed', 'cancelled'],
  confirmed: ['preparing', 'cancelled'],
  preparing: ['ready', 'cancelled'],
  ready: ['delivered'],
  delivered: [],
  cancelled: [],
}

async function handleStatusUpdate() {
  if (!newStatus || newStatus === order.status) {
    return
  }

  try {
    setUpdating(true)
    setUpdateError('')
    setSuccessMessage('')

    await updateOrderStatus(order.id, newStatus)

    setOrder((previousOrder) => ({
      ...previousOrder,
      status: newStatus,
    }))

    setSuccessMessage('Order status updated successfully!')
  } catch (err) {
    setUpdateError(err.message)
  } finally {
    setUpdating(false)
  }
}

  if (loading) {
    return <main className="dashboard-content">Loading order details...</main>
  }

  if (error) {
    return (
      <main className="dashboard-content">
        <p className="login-error">{error}</p>
        <Link to="/orders">Back to Orders</Link>
      </main>
    )
  }

  return (
    <main className="dashboard-content">
      <div className="page-heading">
        <h2>Order Details #{order.id}</h2>
        <p>Complete information about this customer order.</p>
      </div>

      <Link to="/orders" className="edit-button">
        ← Back to Orders
      </Link>

      <div className="order-details-grid">

        {/* Order Information */}
        <section className="order-detail-card">
          <h3>Order Information</h3>

          <p>
            <strong>Order ID:</strong> #{order.id}
          </p>

          <p>
            <strong>Order Date:</strong>{' '}
            {new Date(order.created_at).toLocaleString()}
          </p>

          <p>
            <strong>Status:</strong>{' '}
            {order.status.charAt(0).toUpperCase() + order.status.slice(1)}
          </p>

          <p>
            <strong>Total Amount:</strong> {order.total_amount} ETB
          </p>
        </section>

        {/* Customer Information */}
        <section className="order-detail-card">
          <h3>Customer Information</h3>

          <p>
            <strong>Name:</strong> {order.customer_name}
          </p>

          <p>
            <strong>Phone:</strong> {order.customer_phone}
          </p>

          <p>
            <strong>Delivery Address:</strong> {order.delivery_address}
          </p>
        </section>

      </div>
      <section className="order-detail-card status-management">
  <h3>Manage Order Status</h3>

  <p>
    <strong>Current Status:</strong>
    <span className={`status-badge status-${order.status}`}>
      {order.status.charAt(0).toUpperCase() + order.status.slice(1)}
    </span>
  </p>

  {statusOptions[order.status].length > 0 ? (
    <div className="status-update-controls">
      <select
        value={newStatus}
        onChange={(e) => setNewStatus(e.target.value)}
      >
        <option value={order.status}>
          Keep Current Status
        </option>

        {statusOptions[order.status].map((status) => (
          <option key={status} value={status}>
            {status.charAt(0).toUpperCase() + status.slice(1)}
          </option>
        ))}
      </select>

      <button
        className="status-update-button"
        onClick={handleStatusUpdate}
        disabled={updating || newStatus === order.status}
      >
        {updating ? 'Updating...' : 'Update Status'}
      </button>
    </div>
  ) : (
    <p>This order has reached its final status.</p>
  )}

  {updateError && (
    <p className="login-error">{updateError}</p>
  )}

  {successMessage && (
    <p className="status-success">{successMessage}</p>
  )}
</section>

      {/* Ordered Food Items */}
      <section className="order-detail-card order-items-section">
        <h3>Ordered Food Items</h3>

        <table>
          <thead>
            <tr>
              <th>Food</th>
              <th>Quantity</th>
              <th>Unit Price</th>
              <th>Subtotal</th>
            </tr>
          </thead>

          <tbody>
            {order.items.map((item) => (
              <tr key={item.id}>
                <td>
                  <div className="order-food-info">
                    {item.food_image_url && (
                      <img
                        src={item.food_image_url}
                        alt={item.food_name}
                      />
                    )}
                    <span>{item.food_name}</span>
                  </div>
                </td>

                <td>{item.quantity}</td>

                <td>{Number(item.unit_price).toFixed(2)} ETB</td>

                <td>
                  {(Number(item.unit_price) * item.quantity).toFixed(2)} ETB
                </td>
              </tr>
            ))}
          </tbody>
        </table>

        <div className="order-grand-total">
          <strong>Grand Total:</strong>
          <strong>{Number(order.total_amount).toFixed(2)} ETB</strong>
        </div>
      </section>
    </main>
  )
}

export default OrderDetails