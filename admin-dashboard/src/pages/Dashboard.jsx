import { useEffect, useState } from 'react'
import RecentOrders from '../components/RecentOrders'
import { getDashboardStats } from '../services/api'

function Dashboard() {
  const [stats, setStats] = useState(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')

  useEffect(() => {
    async function loadDashboardStats() {
      try {
        const data = await getDashboardStats()
        setStats(data)
      } catch (err) {
        setError(err.message)
      } finally {
        setLoading(false)
      }
    }

    loadDashboardStats()
  }, [])

  return (
    <main className="dashboard-content">
      <div className="page-heading">
        <h2>Dashboard Overview</h2>
        <p>Here's what's happening with your restaurant today.</p>
      </div>

      {error && <p className="login-error">{error}</p>}

      <div className="stats-grid">

        <div className="stat-card">
          <span>Total Orders</span>
          <h2>{loading ? '...' : stats?.total_orders ?? 0}</h2>
          <p>All customer orders</p>
        </div>

        <RecentOrders />

        <div className="stat-card">
          <span>Total Customers</span>
          <h2>{loading ? '...' : stats?.total_customers ?? 0}</h2>
          <p>Registered customers</p>
        </div>

        <div className="stat-card">
          <span>Available Foods</span>
          <h2>{loading ? '...' : stats?.available_foods ?? 0}</h2>
          <p>Currently available foods</p>
        </div>

        <div className="stat-card">
          <span>Pending Orders</span>
          <h2>{loading ? '...' : stats?.pending_orders ?? 0}</h2>
          <p>Orders awaiting confirmation</p>
        </div>

      </div>
    </main>
  )
}

export default Dashboard