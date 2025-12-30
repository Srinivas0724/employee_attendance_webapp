<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
  response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
  response.setHeader("Pragma", "no-cache");
  response.setDateHeader("Expires", 0);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Sign Up - emPower</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        body { font-family: 'Segoe UI', sans-serif; background: #f4f6f9; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; }
        .card { background: white; padding: 40px; border-radius: 12px; width: 100%; max-width: 400px; text-align: center; box-shadow: 0 5px 20px rgba(0,0,0,0.1); }
        .brand { font-size: 26px; font-weight: 700; color: #2c3e50; margin-bottom: 5px; display: block; }
        .subtitle { color: #7f8c8d; font-size: 14px; margin-bottom: 25px; display: block; }
        
        input { width: 100%; padding: 12px 15px; margin: 8px 0; border: 1px solid #dfe6e9; border-radius: 6px; box-sizing: border-box; font-size: 14px; transition: 0.3s; }
        input:focus { border-color: #3498db; outline: none; }
        
        button { width: 100%; padding: 12px; background: #27ae60; color: white; border: none; border-radius: 6px; cursor: pointer; margin-top: 15px; font-size: 16px; font-weight: 600; transition: 0.3s; }
        button:hover { background: #219150; transform: translateY(-1px); }
        
        .links { margin-top: 20px; font-size: 14px; }
        a { color: #3498db; text-decoration: none; font-weight: 500; }
        a:hover { text-decoration: underline; }
        
        #errorMsg { background: #ffe6e6; color: #c0392b; padding: 10px; border-radius: 4px; font-size: 13px; margin-top: 15px; display: none; text-align: left; }
    </style>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-auth-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-firestore-compat.js"></script>
</head>
<body>
    <div class="card">
        <span class="brand">🚀 emPower</span>
        <span class="subtitle">Create your employee account</span>
        
        <input type="text" id="fullName" placeholder="Full Name" required>
        <input type="text" id="contact" placeholder="Mobile Number" required>
        <input type="email" id="email" placeholder="Email Address" required>
        <input type="password" id="password" placeholder="Password (Min 6 chars)" required>
      
        <button onclick="signUp()" id="signBtn">Create Account</button>
        <div id="errorMsg"></div>
        
        <div class="links">
            <a href="login.jsp">Already have an account? Login</a>
        </div>
    </div>

    <script>
        const firebaseConfig = { apiKey: "AIzaSyCV5tKJMLOVcXiZUyuJZhLWOOSD96gsmP0", authDomain: "attendencewebapp-4215b.firebaseapp.com", projectId: "attendencewebapp-4215b" };
        if (!firebase.apps.length) firebase.initializeApp(firebaseConfig);
        const auth = firebase.auth();
        const db = firebase.firestore();

        function signUp() {
            const name = document.getElementById("fullName").value;
            const contact = document.getElementById("contact").value;
            const email = document.getElementById("email").value;
            const pass = document.getElementById("password").value;
            const btn = document.getElementById("signBtn");
            const errBox = document.getElementById("errorMsg");

            if(!name || !contact || !email || !pass) { showError("Please fill all fields"); return; }
            if(pass.length < 6) { showError("Password must be at least 6 characters"); return; }

            btn.innerText = "Creating...";
            btn.disabled = true;

            auth.createUserWithEmailAndPassword(email, pass)
            .then((cred) => {
                // SAVE USER AS 'PENDING'
                return db.collection("users").doc(email).set({
                    fullName: name,
                    email: email,
                    contact: contact,
                    role: "employee",   // Default role
                    status: "Pending",  // <--- KEY FIX: User cannot login yet
                    createdAt: firebase.firestore.FieldValue.serverTimestamp()
                });
            })
            .then(() => {
                // FORCE LOGOUT so they can't enter dashboard
                return auth.signOut();
            })
            .then(() => {
                alert("✅ Registration Successful!\n\nYour account is PENDING APPROVAL.\nPlease ask the Admin to approve your account.");
                window.location.replace("login.jsp");
            })
            .catch(e => {
                let msg = e.message;
                if(e.code === 'auth/email-already-in-use') msg = "Email already exists. Please ask Admin to reactivate your account.";
                showError(msg);
                btn.innerText = "Create Account";
                btn.disabled = false;
            });
        }

        function showError(msg) {
            const box = document.getElementById("errorMsg");
            box.innerText = msg;
            box.style.display = "block";
        }
    </script>
</body>
</html>