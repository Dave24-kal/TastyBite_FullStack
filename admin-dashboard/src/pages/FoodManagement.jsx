import { useEffect, useState } from 'react'
import { getFoods } from '../services/api'

function FoodManagement() {
  const [foods, setFoods] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')

  useEffect(() => {
    async function loadFoods() {
      try {
        const data = await getFoods()
        setFoods(data)
      } catch (err) {
        setError(err.message)
      } finally {
        setLoading(false)
      }
    }

    loadFoods()
  }, [])

  if (loading) {
    return <main className="dashboard-content">Loading foods...</main>
  }

  if (error) {
    return <main className="dashboard-content">Error: {error}</main>
  }

  return (
    <main className="dashboard-content">
      <div className="page-heading">
        <h2>Food Management</h2>
        <p>Manage the foods available in your restaurant.</p>
      </div>

      <div className="recent-orders">
        <h2>Available Foods ({foods.length})</h2>

        <table>
          <thead>
            <tr>
              <th>ID</th>
              <th>Food Name</th>
              <th>Category</th>
              <th>Price</th>
              <th>Availability</th>
            </tr>
          </thead>

          <tbody>
            {foods.map((food) => (
              <tr key={food.id}>
                <td>{food.id}</td>
                <td>{food.name}</td>
                <td>{food.category}</td>
                <td>{food.price} ETB</td>
                <td>
                  {food.is_available ? 'Available' : 'Unavailable'}
                </td>
              </tr>
            ))}
          </tbody>
        </table>

        {foods.length === 0 && <p>No foods found.</p>}
      </div>
    </main>
  )
}

export default FoodManagement