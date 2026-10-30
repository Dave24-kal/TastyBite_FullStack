function Header() {
  return (
    <header className="top-header">
      <div>
        <h3>Dashboard</h3>
        <p>Welcome back, Administrator!</p>
      </div>

      <div className="admin-profile">
        <div className="admin-avatar">A</div>

        <div>
          <strong>Administrator</strong>
          <span>Admin</span>
        </div>
      </div>
    </header>
  )
}

export default Header