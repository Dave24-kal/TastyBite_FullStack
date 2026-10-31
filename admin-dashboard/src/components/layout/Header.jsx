import { useNavigate } from 'react-router-dom'

function Header() {
  const navigate = useNavigate()

  // Get the logged-in administrator
  const savedUser = sessionStorage.getItem('admin_user')
  const admin = savedUser ? JSON.parse(savedUser) : null

  // Logout function
  function handleLogout() {
    sessionStorage.removeItem('admin_token')
    sessionStorage.removeItem('admin_user')

    navigate('/login', { replace: true })
  }

  return (
    <header className="top-header">
      <div>
        <h3>Dashboard</h3>
        <p>Welcome back, {admin?.full_name || 'Administrator'}!</p>
      </div>

      <div className="admin-profile">
        <div className="admin-avatar">
          {admin?.full_name?.charAt(0).toUpperCase() || 'A'}
        </div>

        <div className="admin-info">
          <strong>{admin?.full_name || 'Administrator'}</strong>
          <span>Admin</span>
        </div>

        <button className="logout-button" onClick={handleLogout}>
          Logout
        </button>
      </div>
    </header>
  )
}

export default Header