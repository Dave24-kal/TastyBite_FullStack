import { NavLink } from 'react-router-dom'

function Sidebar() {
  return (
    <aside className="sidebar">
      <div className="sidebar-brand">
        <h2>TastyBite</h2>
        <span>ADMIN PANEL</span>
      </div>

      <nav className="sidebar-nav">
  <p className="nav-heading">MENU</p>

  <NavLink to="/" end className="nav-link">
    Overview
  </NavLink>

  <NavLink to="/foods" className="nav-link">
    Food Management
  </NavLink>

  <a href="#" className="nav-link">Orders</a>

  <a href="#" className="nav-link">Customers</a>

  <p className="nav-heading">OTHER</p>

  <a href="#" className="nav-link">Settings</a>
</nav>
    </aside>
  )
}

export default Sidebar