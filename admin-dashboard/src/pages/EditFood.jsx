import { useEffect, useState } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import { getFoods, updateFood } from '../services/api'

function EditFood() {
  const { foodId } = useParams()
  const navigate = useNavigate()

  const [food, setFood] = useState({
    name: '',
    description: '',
    price: '',
    category: '',
    image_url: '',
  })

  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState('')

  // Load the existing food information
  useEffect(() => {
    async function loadFood() {
      try {
        const foods = await getFoods()

        const existingFood = foods.find(
          (item) => item.id === Number(foodId)
        )

        if (!existingFood) {
          throw new Error('Food not found.')
        }

        setFood({
          name: existingFood.name,
          description: existingFood.description,
          price: existingFood.price,
          category: existingFood.category,
          image_url: existingFood.image_url || '',
        })
      } catch (err) {
        setError(err.message)
      } finally {
        setLoading(false)
      }
    }

    loadFood()
  }, [foodId])

  function handleChange(event) {
    const { name, value } = event.target

    setFood((previousFood) => ({
      ...previousFood,
      [name]: value,
    }))
  }

  async function handleSubmit(event) {
    event.preventDefault()

    setError('')
    setSaving(true)

    try {
      await updateFood(foodId, {
        ...food,
        name: food.name.trim(),
        description: food.description.trim(),
        category: food.category.trim(),
      })

      alert('Food updated successfully!')

      navigate('/foods')
    } catch (err) {
      setError(err.message)
    } finally {
      setSaving(false)
    }
  }

  if (loading) {
    return <main className="dashboard-content">Loading food...</main>
  }

  if (error && !food.name) {
    return (
      <main className="dashboard-content">
        <p className="login-error">{error}</p>
        <button onClick={() => navigate('/foods')}>
          Back to Food Management
        </button>
      </main>
    )
  }

  return (
    <main className="dashboard-content">
      <div className="page-heading">
        <h2>Edit Food</h2>
        <p>Update the information of this food item.</p>
      </div>

      <form className="food-form" onSubmit={handleSubmit}>
        {error && (
          <div className="login-error">{error}</div>
        )}

        <div className="form-group">
          <label>Food Name</label>
          <input
            type="text"
            name="name"
            value={food.name}
            onChange={handleChange}
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
          disabled={saving}
        >
          {saving ? 'Updating Food...' : 'Update Food'}
        </button>
      </form>
    </main>
  )
}

export default EditFood