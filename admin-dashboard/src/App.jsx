import { BrowserRouter, Routes, Route } from 'react-router-dom'

import './App.css'
import AddFood from './pages/AddFood'

import Sidebar from './components/layout/Sidebar'
import Header from './components/layout/Header'
import Dashboard from './pages/Dashboard'
import FoodManagement from './pages/FoodManagement'

function App() {
  return (
    <BrowserRouter>
      <div className="app-layout">
        <Sidebar />

        <div className="main-area">
          <Header />

          <Routes>
            <Route path="/" element={<Dashboard />} />
            <Route path="/foods" element={<FoodManagement />} />
            <Route path="/foods/add" element={<AddFood />} />
          </Routes>
        </div>
      </div>
    </BrowserRouter>
  )
}

export default App