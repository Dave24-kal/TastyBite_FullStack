import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { createFood } from '../services/api'

function AddFood() {
  const navigate = useNavigate()

  const [food, setFood] = useState({
    name: '',
    description: '',
    price: '',
    category: '',
    image_url: '',
  })

  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')

  function handleChange(event) {
    const { name, value } = event.target

    setFood({
      ...food,
      [name]: value,
    })
  }

  async function handleSubmit(event) {
    event.preventDefault()

    setError('')
    setLoading(true)

    try {
      const createdFood = await createFood({
        ...food,
        name: food.name.trim(),
        description: food.description.trim(),
        category: food.category.trim(),
      })

      alert(`${createdFood.name} was added successfully!`)

      navigate('/foods')
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  return (
    <main className="dashboard-content">
      <div className="page-heading">
        <h2>Add New Food</h2>
        <p>Add a new food item to your restaurant menu.</p>
      </div>

      <form className="food-form" onSubmit={handleSubmit}>
        {error && (
          <div className="login-error">
            {error}
          </div>
        )}

        <div className="form-group">
          <label>Food Name</label>
          <input
            type="text"
            name="name"
            value={food.name}
            onChange={handleChange}
            placeholder="Enter food name"
            minLength="2"
            required
          />
        </div>

        <div className="form-group">
          <label>Description</label>
          <textarea
            name="description"
            value={food.description}
            onChange={handleChange}
            placeholder="Enter food description"
            minLength="5"
            required
          />
        </div>

        <div className="form-group">
          <label>Price (ETB)</label>
          <input
            type="number"
            name="price"
            value={food.price}
            onChange={handleChange}
            placeholder="Enter price"
            min="0.01"
            step="0.01"
            required
          />
        </div>

        <div className="form-group">
          <label>Category</label>
          <input
            type="text"
            name="category"
            value={food.category}
            onChange={handleChange}
            placeholder="Example: Fast Food"
            minLength="2"
            required
          />
        </div>

        <div className="form-group">
          <label>Image URL</label>
          <input
            type="url"
            name="image_url"
            value={food.image_url}
            onChange={handleChange}
            placeholder="Enter food image URL"
          />
        </div>

        <button
          type="submit"
          className="submit-button"
          disabled={loading}
        >
          {loading ? 'Saving Food...' : 'Add Food'}
        </button>
      </form>
    </main>
  )
}

export default AddFood