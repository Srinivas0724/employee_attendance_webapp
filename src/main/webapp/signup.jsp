<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Sign Up - emPower</title>
    <style>
        body { font-family: 'Segoe UI', sans-serif; background: #f4f6f9; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; }
        .card { background: white; padding: 40px; border-radius: 10px; width: 100%; max-width: 400px; text-align: center; box-shadow: 0 4px 15px rgba(0,0,0,0.1); }
        input, textarea { width: 100%; padding: 12px; margin: 8px 0; border: 1px solid #ddd; border-radius: 5px; box-sizing: border-box; }
        button { width: 100%; padding: 12px; background: #28a745; color: white; border: none; border-radius: 5px; cursor: pointer; margin-top: 15px; font-size: 16px; }
        .brand { font-size: 24px; font-weight: bold; color: #333; display: block; margin-bottom: 20px; }
        a { color: #007bff; text-decoration: none; font-size: 14px; }
    </style>
    <script src="https://www.gstatic.com/firebasejs/9.0.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.0.0/firebase-auth-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.0.0/firebase-firestore-compat.js"></script>
</head>
<body>
    <div class="card">
        <span class="brand">🚀 Join emPower</span>
        
        <input type="text" id="fullName" placeholder="Full Name" required>
        <input type="text" id="contact" placeholder="Contact Number" required>
        
        <input type="email" id="email" placeholder="Gmail Address" required>
        <input type="password" id="password" placeholder="Set Password (Min 6 chars)" required>
        
        <button onclick="signUp()">Submit & Login</button>
        <p id="errorMsg" style="color:red; font-size:13px; display:none;"></p>
        
        <br>
        <a href="login.jsp">Already have an account? Login</a>
    </div>

    <script>
        // --- PASTE FIREBASE CONFIG HERE ---
        const firebaseConfig = {
            apiKey: "AIzaSyCV5tKJMLOVcXiZUyuJZhLWOOSD96gsmP0",
            authDomain: "attendencewebapp-4215b.firebaseapp.com",
            projectId: "attendencewebapp-4215b",
        };
        if (!firebase.apps.length) firebase.initializeApp(firebaseConfig);
        const auth = firebase.auth();
        const db = firebase.firestore();

        function signUp() {
            const name = document.getElementById("fullName").value;
            const contact = document.getElementById("contact").value;
            
            const email = document.getElementById("email").value;
            const pass = document.getElementById("password").value;

            if(pass.length < 6) { alert("Password too short!"); return; }

            auth.createUserWithEmailAndPassword(email, pass).then((cred) => {
                cred.user.updateProfile({ displayName: name });
                
                // Save extra details to Firestore
                db.collection("users").doc(cred.user.uid).set({
                    name: name,
                    email: email,
                    contact: contact,
                   
                }).then(() => {
                    alert("Account Created! Please Login.");
                    window.location.href = "login.jsp";
                });
            }).catch(e => document.getElementById("errorMsg").innerText = e.message);
        }
    </script>
</body>
</html>