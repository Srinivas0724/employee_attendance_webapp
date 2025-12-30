<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
  // FORCE NO CACHE
  response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
  response.setHeader("Pragma", "no-cache");
  response.setDateHeader("Expires", 0);
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Login - emPower</title>
<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-auth-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-firestore-compat.js"></script>

<script type="text/javascript">
    // 1. THE TRAP: Pushes user forward if they try to go back
    function preventBack() { window.history.forward(); }
    setTimeout("preventBack()", 0);
    window.onunload = function () { null };
</script>
<style>
    body { font-family: "Segoe UI", sans-serif; background: #f4f6f9; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; }
    .login-card { background: white; padding: 40px; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1); width: 350px; text-align: center; }
    input { width: 100%; padding: 12px; margin-bottom: 15px; border: 1px solid #ddd; border-radius: 4px; box-sizing: border-box; }
    button { width: 100%; padding: 12px; background: #007bff; color: white; border: none; border-radius: 4px; cursor: pointer; font-size: 16px; transition: 0.3s; }
    button:hover { background: #0056b3; }
    .error { color: red; margin-bottom: 15px; font-size: 14px; display: none; background: #ffe6e6; padding: 10px; border-radius: 4px;}
    
    /* Loading text for auto-redirect */
    #loadingStatus { display:none; color: #666; font-size: 14px; margin-bottom: 15px; }
</style>
</head>
<body>

<div class="login-card">
    <h2>emPower Login V3</h2>
    
    <div id="loadingStatus">⌛ Checking session...</div>
    <div id="errorMsg" class="error"></div>
    
    <div id="loginForm">
        <input type="email" id="email" placeholder="Enter email" required>
        <input type="password" id="password" placeholder="Enter password" required>
        <button onclick="login()">Sign In</button>
        <br><br>
        <a href="signup.jsp" style="text-decoration:none; color:#007bff;">Create New Account</a>
    </div>
</div>

<script>
// 1. Initialize Firebase
const firebaseConfig = { apiKey: "AIzaSyCV5tKJMLOVcXiZUyuJZhLWOOSD96gsmP0", authDomain: "attendencewebapp-4215b.firebaseapp.com", projectId: "attendencewebapp-4215b" };
if (!firebase.apps.length) firebase.initializeApp(firebaseConfig);
const auth = firebase.auth();
const db = firebase.firestore();

// 2. AUTO-REDIRECT: Check if user is already logged in
document.getElementById("loadingStatus").style.display = "block";
document.getElementById("loginForm").style.opacity = "0.5";

auth.onAuthStateChanged(user => {
    if (user) {
        // User is logged in -> Check Role & Redirect
        checkRoleAndRedirect(user);
    } else {
        // User is NOT logged in -> Show Form
        document.getElementById("loadingStatus").style.display = "none";
        document.getElementById("loginForm").style.opacity = "1";
    }
});

// 3. LOGIN FUNCTION
function login() {
    const email = document.getElementById("email").value;
    const pass = document.getElementById("password").value;
    const errorBox = document.getElementById("errorMsg");
    const btn = document.querySelector("button");

    if(!email || !pass) {
        errorBox.innerText = "Please enter email and password.";
        errorBox.style.display = "block";
        return;
    }

    btn.innerText = "Checking...";
    btn.disabled = true;

    auth.signInWithEmailAndPassword(email, pass)
    .then((userCredential) => {
        // Login Success -> Now Check Role
        checkRoleAndRedirect(userCredential.user);
    })
    .catch((error) => {
        btn.innerText = "Sign In";
        btn.disabled = false;
        errorBox.innerText = "Invalid Login: " + error.message;
        errorBox.style.display = "block";
    });
}

// 4. ROLE CHECKER (Separates Admin from Employee)
function checkRoleAndRedirect(user) {
    const status = document.getElementById("loadingStatus");
    status.innerText = "Verifying Role...";
    status.style.display = "block";

    db.collection("users").doc(user.email).get()
    .then((doc) => {
        if (doc.exists) {
            const role = doc.data().role;
            
            if (role === "admin") {
                // GO TO ADMIN DASHBOARD
                window.location.replace("admin_dashboard.jsp");
            } else {
                // GO TO EMPLOYEE DASHBOARD
                window.location.replace("mark_attendance.jsp");
            }
        } else {
            // Fallback (Default to employee if no role found)
            window.location.replace("mark_attendance.jsp");
        }
    })
    .catch((error) => {
        console.error("Role Check Error", error);
        // If DB fails, fallback to employee page so they aren't stuck
        window.location.replace("mark_attendance.jsp");
    });
}
</script>
</body>
</html>