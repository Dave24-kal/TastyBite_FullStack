import { useState } from 'react'

function AddFood() {
  const [food, setFood] = useState({
    name: '',
    description: '',
    price: '',
    category: '',
    image_url: '',
  })

  function handleChange(event) {
    const { name, value } = event.target

    setFood({
      ...food,
      [name]: value,
    })
  }

  function handleSubmit(event) {
    event.preventDefault()

    console.log('Food information:', food)

    alert('Food form submitted! API connection comes next.')
  }

  return (
    <main className="dashboard-content">
      <div className="page-heading">
        <h2>Add New Food</h2>
        <p>Add a new food item to your restaurant menu.</p>
      </div>

      <form className="food-form" onSubmit={handleSubmit}>
        <div className="form-group">
          <label>Food Name</label>
          <input
            type="text"
            name="name"
            value={food.name}
            onChange={handleChange}
            placeholder="Enter food name"
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

        <button type="submit" className="submit-button">
          Add Food
        </button>
      </form>
    </main>
  )
}

export default AddFood