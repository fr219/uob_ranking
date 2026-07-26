// Check if user is logged in
function checkAuth(requiredRole = null) {
  const token = localStorage.getItem('token');
  const user = JSON.parse(localStorage.getItem('user') || '{}');
  
  if (!token) {
    window.location.href = '/client/pages/login.html';
    return false;
  }
  
  if (requiredRole && user.role !== requiredRole) {
    window.location.href = '/client/pages/error.html?code=403';
    return false;
  }
  
  return true;
}

// Logout function
async function logout() {
  try {
    await apiCall('/api/auth/logout', { method: 'POST' });
  } catch (e) {
    console.error('Logout error:', e);
  }
  localStorage.removeItem('token');
  localStorage.removeItem('user');
  window.location.href = '/client/pages/login.html';
}

window.checkAuth = checkAuth;
window.logout = logout;