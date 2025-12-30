<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
  response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
  response.setHeader("Pragma", "no-cache");
  response.setDateHeader("Expires", 0);
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Login - emPower</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<style>
/* GLOBAL & LOGIN STYLES */
body { margin:0; padding:0; font-family:"Segoe UI", sans-serif; background:#eef2f5; display:flex; justify-content:center; align-items:center; height:100vh; }

.login-card { background: white; padding: 40px; border-radius: 12px; box-shadow: 0 5px 20px rgba(0,0,0,0.1); width: 100%; max-width: 380px; text-align: center; }
.login-card h2 { margin-top: 0; color: #2c3e50; margin-bottom: 5px; }
.login-card p { color: #7f8c8d; font-size: 14px; margin-bottom: 25px; margin-top: 0; }

input { width: 100%; padding: 12px 15px; margin-bottom: 15px; border: 1px solid #dfe6e9; border-radius: 6px; box-sizing: border-box; font-size: 14px; transition: 0.3s; }
input:focus { border-color: #3498db; outline: none; }

button { width: 100%; padding: 12px; background: #3498db; color: white; border: none; border-radius: 6px; font-size: 16px; font-weight: 600; cursor: pointer; transition: 0.3s; }
button:hover { background: #2980b9; transform: translateY(-1px); }

.links { margin-top: 20px; font-size: 14px; }
.links a { color: #3498db; text-decoration: none; font-weight: 500; }
.links a:hover { text-decoration: underline; }

#errorMsg { background: #ffe6e6; color: #c0392b; padding: 12px; border-radius: 6px; font-size: 13px; margin-bottom: 20px; display: none; text-align: left; border-left: 4px solid #c0392b; }
</style>

<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-auth-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-firestore-compat.js"></script>
</head>

<body>

<div class="login-card">
    <h2>Welcome Back</h2>
    <p>Sign in to your dashboard</p>

    <div id="errorMsg"></div>

    <input type="email" id="email" placeholder="Email Address" required>
    <input type="password" id="password" placeholder="Password" required>
    
    <button onclick="login()" id="loginBtn">Login</button>

    <div class="links">
        <a href="signup.jsp">Register new account</a>
    </div>
</div>

<script>
const firebaseConfig = { apiKey: "AIzaSyCV5tKJMLOVcXiZUyuJZhLWOOSD96gsmP0", authDomain: "attendencewebapp-4215b.firebaseapp.com", projectId: "attendencewebapp-4215b" };
if (!firebase.apps.length) firebase.initializeApp(firebaseConfig);
const auth = firebase.auth();
const db = firebase.firestore();

function login() {
    const email = document.getElementById("email").value;
    const pass = document.getElementById("password").value;
    const btn = document.getElementById("loginBtn");
    
    if(!email || !pass) { showError("Please enter both email and password."); return; }

    btn.innerText = "Verifying...";
    btn.disabled = true;

    auth.signInWithEmailAndPassword(email, pass)
    .then((userCredential) => {
        // 2. CHECK DATABASE STATUS
        db.collection("users").doc(email).get().then((doc) => {
            if (doc.exists) {
                const data = doc.data();
                
                // CHECK 1: PENDING
                if(data.status === 'Pending') {
                    auth.signOut();
                    showError("⏳ <b>Account Pending.</b><br>Please wait for Admin approval.");
                    resetBtn();
                    return;
                }

                // CHECK 2: DISABLED
                if(data.status === 'Disabled') {
                    auth.signOut();
                    showError("🚫 <b>Access Denied.</b><br>Your account has been disabled by Admin.");
                    resetBtn();
                    return;
                }

                // SUCCESS: Redirect based on Role
                if(data.role === 'admin') {
                    window.location.href = "admin_dashboard.jsp";
                } else {
                    window.location.href = "mark_attendance.jsp";
                }

            } else {
                // Auth exists but No DB Record (Should not happen unless manually deleted)
                auth.signOut();
                showError("❌ Account profile missing.");
                resetBtn();
            }
        });
    })
    .catch((error) => {
        let msg = "Invalid Email or Password.";
        if(error.code === 'auth/user-not-found') msg = "No user found with this email.";
        showError(msg);
        resetBtn();
    });
}

function resetBtn() {
    const btn = document.getElementById("loginBtn");
    btn.innerText = "Login";
    btn.disabled = false;
}

function showError(msg) {
    const box = document.getElementById("errorMsg");
    box.innerHTML = msg;
    box.style.display = "block";
}
</script>
</body>
</html>