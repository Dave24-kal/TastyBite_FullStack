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