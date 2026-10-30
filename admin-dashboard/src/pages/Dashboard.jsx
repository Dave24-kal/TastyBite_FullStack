import RecentOrders from '../components/RecentOrders'

function Dashboard() {
  return (
    <main className="dashboard-content">
      <div className="page-heading">
        <h2>Dashboard Overview</h2>
        <p>Here's what's happening with your restaurant today.</p>
      </div>

      <div className="stats-grid">

        <div className="stat-card">
          <span>Total Orders</span>
          <h2>120</h2>
          <p>All customer orders</p>

        </div>
        <RecentOrders />

        <div className="stat-card">
          <span>Total Customers</span>
          <h2>85</h2>
          <p>Registered customers</p>
        </div>

        <div className="stat-card">
          <span>Available Foods</span>
          <h2>25</h2>
          <p>Currently available foods</p>
        </div>

        <div className="stat-card">
          <span>Pending Orders</span>
          <h2>12</h2>
          <p>Orders awaiting confirmation</p>
        </div>

      </div>
    </main>
  )
}

export default Dashboard