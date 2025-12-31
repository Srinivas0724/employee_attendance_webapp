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
/* GLOBAL STYLES */
body { margin:0; padding:0; font-family:"Segoe UI", sans-serif; background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%); display:flex; justify-content:center; align-items:center; height:100vh; }

/* CARD DESIGN */
.login-card { 
    background: white; 
    padding: 40px; 
    border-radius: 12px; 
    box-shadow: 0 10px 25px rgba(0,0,0,0.1); 
    width: 100%; 
    max-width: 380px; 
    text-align: center; 
    position: relative;
}

.brand { font-size: 24px; font-weight: bold; color: #2c3e50; margin-bottom: 5px; display: block; }
.subtitle { color: #7f8c8d; font-size: 14px; margin-bottom: 30px; display: block; }

/* INPUTS */
.input-group { position: relative; margin-bottom: 15px; }
input { width: 100%; padding: 12px 15px; border: 1px solid #dfe6e9; border-radius: 6px; box-sizing: border-box; font-size: 14px; transition: 0.3s; background: #fafafa; }
input:focus { border-color: #3498db; background: #fff; outline: none; box-shadow: 0 0 0 3px rgba(52, 152, 219, 0.1); }

/* PASSWORD TOGGLE */
.toggle-password { position: absolute; right: 15px; top: 13px; cursor: pointer; color: #aaa; font-size: 14px; user-select: none; }
.toggle-password:hover { color: #3498db; }

/* BUTTONS */
button { width: 100%; padding: 12px; background: #3498db; color: white; border: none; border-radius: 6px; font-size: 16px; font-weight: 600; cursor: pointer; transition: 0.3s; margin-top: 10px; }
button:hover { background: #2980b9; transform: translateY(-1px); }
button:disabled { background: #95a5a6; cursor: not-allowed; transform: none; }

/* LINKS */
.links { margin-top: 20px; font-size: 13px; display: flex; justify-content: space-between; }
.links a { color: #3498db; text-decoration: none; font-weight: 500; cursor: pointer; }
.links a:hover { text-decoration: underline; }

/* ERROR MESSAGE */
#errorMsg { background: #fee2e2; color: #b91c1c; padding: 12px; border-radius: 6px; font-size: 13px; margin-bottom: 20px; display: none; text-align: left; border-left: 4px solid #b91c1c; }

/* SPINNER */
.spinner { display: inline-block; width: 12px; height: 12px; border: 2px solid rgba(255,255,255,0.3); border-radius: 50%; border-top-color: #fff; animation: spin 1s ease-in-out infinite; margin-right: 8px; }
@keyframes spin { to { transform: rotate(360deg); } }
</style>

<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-auth-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-firestore-compat.js"></script>
</head>

<body>

<div class="login-card">
    <span class="brand">🚀 Synod Bioscience</span>
    <span class="subtitle">Sign in to your dashboard</span>

    <div id="errorMsg"></div>

    <form onsubmit="event.preventDefault(); login();">
        <div class="input-group">
            <input type="email" id="email" placeholder="Email Address" required>
        </div>
        
        <div class="input-group">
            <input type="password" id="password" placeholder="Password" required>
            <span class="toggle-password" onclick="togglePass()">👁️</span>
        </div>
        
        <button type="submit" id="loginBtn">Login</button>
    </form>

    <div class="links">
        <a onclick="forgotPassword()">Forgot Password?</a>
        <a href="signup.jsp">Create Account</a>
    </div>
</div>

<script>
// --- ⚠️ CONFIG: CONNECTING TO YOUR NEW PROJECT ---
const firebaseConfig = {
  apiKey: "AIzaSyBzdM77WwTSkxvF0lsxf2WLNLhjuGyNvQQ",
  authDomain: "attendancewebapp-ef02a.firebaseapp.com",
  projectId: "attendancewebapp-ef02a",
  storageBucket: "attendancewebapp-ef02a.firebasestorage.app",
  messagingSenderId: "734213881030",
  appId: "1:734213881030:web:bfdcee5a2ff293f87e6bc7"
};

if (!firebase.apps.length) firebase.initializeApp(firebaseConfig);
const auth = firebase.auth();
const db = firebase.firestore();

// 1. LOGIN LOGIC
function login() {
    const email = document.getElementById("email").value;
    const pass = document.getElementById("password").value;
    const btn = document.getElementById("loginBtn");
    
    if(!email || !pass) { showError("Please enter both email and password."); return; }

    // Loading State
    btn.innerHTML = '<div class="spinner"></div> Verifying...';
    btn.disabled = true;

    auth.signInWithEmailAndPassword(email, pass)
    .then((userCredential) => {
        // Check Firestore for Role & Status
        db.collection("users").doc(email).get().then((doc) => {
            if (doc.exists) {
                const data = doc.data();
                
                // CHECK 1: PENDING
                if(data.status === 'Pending') {
                    auth.signOut();
                    showError("⏳ <b>Account Pending.</b><br>Please ask Admin to approve your account.");
                    resetBtn();
                    return;
                }

                // CHECK 2: DISABLED
                if(data.status === 'Disabled') {
                    auth.signOut();
                    showError("🚫 <b>Access Denied.</b><br>Your account has been disabled.");
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
                auth.signOut();
                showError("❌ User profile not found in database.");
                resetBtn();
            }
        });
    })
    .catch((error) => {
        let msg = "Invalid Email or Password.";
        if(error.code === 'auth/user-not-found') msg = "No user found with this email.";
        if(error.code === 'auth/wrong-password') msg = "Incorrect password.";
        if(error.code === 'auth/too-many-requests') msg = "Too many attempts. Try again later.";
        showError(msg);
        resetBtn();
    });
}

// 2. FORGOT PASSWORD LOGIC
function forgotPassword() {
    const email = document.getElementById("email").value;
    if(!email) {
        showError("⚠️ Please enter your <b>Email Address</b> in the box above, then click 'Forgot Password' again.");
        return;
    }
    
    if(confirm("Send password reset link to " + email + "?")) {
        auth.sendPasswordResetEmail(email)
            .then(() => {
                alert("✅ Reset link sent! Check your inbox.");
            })
            .catch(error => {
                showError("Error: " + error.message);
            });
    }
}

// 3. SHOW/HIDE PASSWORD
function togglePass() {
    const passInput = document.getElementById("password");
    const icon = document.querySelector(".toggle-password");
    if(passInput.type === "password") {
        passInput.type = "text";
        icon.innerText = "🙈"; // Monkey covering eyes
    } else {
        passInput.type = "password";
        icon.innerText = "👁️"; // Eye
    }
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