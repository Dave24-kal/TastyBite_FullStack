import { Navigate, Outlet } from 'react-router-dom'

function ProtectedRoute() {
  const token = sessionStorage.getItem('admin_token')
  const savedUser = sessionStorage.getItem('admin_user')

  let user = null

  try {
    user = savedUser ? JSON.parse(savedUser) : null
  } catch {
    user = null
  }

  const isAdmin = token && user && user.role === 'admin'

  if (!isAdmin) {
    return <Navigate to="/login" replace />
  }

  return <Outlet />
}

export default ProtectedRoute