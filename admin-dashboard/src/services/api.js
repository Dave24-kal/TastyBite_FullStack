const API_BASE_URL = 'http://127.0.0.1:8000'

export async function getFoods() {
  const response = await fetch(`${API_BASE_URL}/foods/`)

  if (!response.ok) {
    throw new Error('Failed to fetch foods')
  }

  return await response.json()
}
export async function adminLogin(email, password) {
  const response = await fetch(`${API_BASE_URL}/auth/login`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      email,
      password,
    }),
  })

  const data = await response.json()

  if (!response.ok) {
    throw new Error(data.detail || 'Login failed')
  }

  if (data.user.role !== 'admin') {
    throw new Error('Access denied. Administrator account required.')
  }

  sessionStorage.setItem('admin_token', data.access_token)
  sessionStorage.setItem('admin_user', JSON.stringify(data.user))

  return data.user
}
export async function createFood(food) {
  const token = sessionStorage.getItem('admin_token')

  if (!token) {
    throw new Error('Please sign in as an administrator.')
  }

  const response = await fetch(`${API_BASE_URL}/foods/`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify({
      ...food,
      price: Number(food.price),
      image_url: food.image_url.trim() || null,
      is_available: true,
    }),
  })

  const data = await response.json()

  if (!response.ok) {
    const message = Array.isArray(data.detail)
      ? data.detail.map((error) => error.msg).join(', ')
      : data.detail || 'Failed to create food.'

    throw new Error(message)
  }

  return data
}
export async function updateFood(foodId, food) {
  const token = sessionStorage.getItem('admin_token')

  if (!token) {
    throw new Error('Please sign in as an administrator.')
  }

  const response = await fetch(`${API_BASE_URL}/foods/${foodId}`, {
    method: 'PATCH',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify({
      ...food,
      price: Number(food.price),
      image_url: food.image_url.trim() || null,
    }),
  })

  const data = await response.json()

  if (!response.ok) {
    const message = Array.isArray(data.detail)
      ? data.detail.map((error) => error.msg).join(', ')
      : data.detail || 'Failed to update food.'

    throw new Error(message)
  }

  return data
}