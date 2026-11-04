import { useEffect, useState } from 'react'
import {
  getFoods,
  deleteFood,
  updateFoodAvailability,
} from '../services/api'
import { Link } from 'react-router-dom'

function FoodManagement() {
  const [foods, setFoods] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')

  async function handleAvailabilityChange(food) {
  try {
    const updatedFood = await updateFoodAvailability(
      food.id,
      !food.is_available
    )

    setFoods((previousFoods) =>
      previousFoods.map((item) =>
        item.id === food.id ? updatedFood : item
      )
    )
  } catch (err) {
    alert(err.message)
  }
}

  async function handleDelete(food) {
  const confirmed = window.confirm(
    `Are you sure you want to delete "${food.name}"?`
  )

  if (!confirmed) return

  try {
    await deleteFood(food.id)

    setFoods((previousFoods) =>
      previousFoods.filter((item) => item.id !== food.id)
    )

    alert('Food deleted successfully!')
  } catch (err) {
    alert(err.message)
  }
}

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
      <Link to="/foods/add" className="add-food-button">
  + Add New Food
</Link>

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
              <th>Actions</th>
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
  <span
    className={
      food.is_available
        ? 'availability-badge available'
        : 'availability-badge unavailable'
    }
  >
    {food.is_available ? 'Available' : 'Unavailable'}
  </span>

  <button
    className="availability-button"
    onClick={() => handleAvailabilityChange(food)}
  >
    {food.is_available ? 'Mark Unavailable' : 'Make Available'}
  </button>
</td>
                <td className="food-actions">
  <Link to={`/foods/${food.id}/edit`} className="edit-button">
    Edit
  </Link>

  <button
    className="delete-button"
    onClick={() => handleDelete(food)}
  >
    Delete
  </button>
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