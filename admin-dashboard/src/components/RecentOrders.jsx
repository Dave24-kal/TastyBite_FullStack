function RecentOrders() {
  const orders = [
    {
      id: 1,
      customer: 'Abebe Kebede',
      date: 'Oct 30, 2026',
      amount: '500 ETB',
      status: 'Pending',
    },
    {
      id: 2,
      customer: 'Mekdes Alemu',
      date: 'Oct 29, 2026',
      amount: '750 ETB',
      status: 'Preparing',
    },
    {
      id: 3,
      customer: 'Dawit Tadesse',
      date: 'Oct 29, 2026',
      amount: '350 ETB',
      status: 'Delivered',
    },
  ]

  return (
    <section className="recent-orders">
      <h2>Recent Orders</h2>

      <table>
        <thead>
          <tr>
            <th>Order ID</th>
            <th>Customer</th>
            <th>Date</th>
            <th>Amount</th>
            <th>Status</th>
          </tr>
        </thead>

        <tbody>
          {orders.map((order) => (
            <tr key={order.id}>
              <td>#{order.id}</td>
              <td>{order.customer}</td>
              <td>{order.date}</td>
              <td>{order.amount}</td>
              <td>
                <span className={`status-badge status-${order.status.toLowerCase()}`}>
                  {order.status}
                </span>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </section>
  )
}

export default RecentOrders