import { BrowserRouter, Routes, Route, Outlet } from 'react-router-dom'

import './App.css'

import Sidebar from './components/layout/Sidebar'
import Header from './components/layout/Header'
import Dashboard from './pages/Dashboard'
import FoodManagement from './pages/FoodManagement'
import AddFood from './pages/AddFood'
import AdminLogin from './pages/AdminLogin'
import ProtectedRoute from './components/ProtectedRoute'

function AdminLayout() {
  return (
    <div className="app-layout">
      <Sidebar />

      <div className="main-area">
        <Header />
        <Outlet />
      </div>
    </div>
  )
}

function App() {
  return (
    <BrowserRouter>
      <Routes>
        {/* Public login page */}
        <Route path="/login" element={<AdminLogin />} />

        {/* Protected administrator pages */}
        <Route element={<ProtectedRoute />}>
          <Route path="/" element={<AdminLayout />}>
            <Route index element={<Dashboard />} />
            <Route path="foods" element={<FoodManagement />} />
            <Route path="foods/add" element={<AddFood />} />
          </Route>
        </Route>
      </Routes>
    </BrowserRouter>
  )
}

export default App