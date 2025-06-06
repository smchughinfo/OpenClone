// Fetch user data on page load
async function loadUserData() {
  try {
    const response = await fetch('/api/user');
    const userData = await response.json();
    if (userData.isLoggedIn) {
      document.getElementById("loginStatus").innerHTML = "Logged In";
    } else {
      document.getElementById("loginStatus").innerHTML = "Logged Out";;
    }
    console.log(userData);
  } catch (error) {
    console.error('Error loading user data:', error);
  }
}

// Call on page load
document.addEventListener('DOMContentLoaded', loadUserData);