const API_BASE_URL = 'http://127.0.0.1:8000'

export async function getFoods() {
  const response = await fetch(`${API_BASE_URL}/foods/`)

  if (!response.ok) {
    throw new Error('Failed to fetch foods')
  }

  return await response.json()
}