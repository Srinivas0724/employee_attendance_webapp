<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>AKA Attendance - Login</title>
    <style>
        body { font-family: 'Segoe UI', sans-serif; background-color: #e9ecef; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; }
        .login-box { background: white; padding: 40px; border-radius: 10px; box-shadow: 0 4px 15px rgba(0,0,0,0.1); width: 300px; text-align: center; }
        input { width: 100%; padding: 12px; margin: 10px 0; border: 1px solid #ddd; border-radius: 4px; box-sizing: border-box; }
        button { width: 100%; padding: 12px; background-color: #007bff; color: white; border: none; border-radius: 4px; cursor: pointer; font-size: 16px; }
        button:hover { background-color: #0056b3; }
        .error { color: red; margin-top: 10px; font-size: 14px; display: none; }
    </style>

    <script src="https://www.gstatic.com/firebasejs/9.0.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.0.0/firebase-auth-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.0.0/firebase-firestore-compat.js"></script>
</head>
<body>

    <div class="login-box">
        <h2>System Login</h2>
        <input type="email" id="email" placeholder="admin@gmail.com" required>
        <input type="password" id="password" placeholder="Password" required>
        <button onclick="handleLogin()">Sign In</button>
        <div id="error-msg" class="error"></div>
    </div>

    <script>
        // --- YOUR FIREBASE CONFIG ---
        const firebaseConfig = {
            apiKey: "AIzaSyCV5tKJMLOVcXiZUyuJZhLWOOSD96gsmP0",
            authDomain: "attendencewebapp-4215b.firebaseapp.com",
            projectId: "attendencewebapp-4215b",
            storageBucket: "attendencewebapp-4215b.firebasestorage.app",
            messagingSenderId: "97124588288",
            appId: "1:97124588288:web:08507eaacdc6155ad1b1e5"
        };

        // Initialize
        firebase.initializeApp(firebaseConfig);
        const auth = firebase.auth();
        const db = firebase.firestore();

        function handleLogin() {
            const email = document.getElementById("email").value;
            const pass = document.getElementById("password").value;
            const errorDiv = document.getElementById("error-msg");

            errorDiv.style.display = "none";

            if (!email || !pass) {
                errorDiv.innerText = "Please enter email and password.";
                errorDiv.style.display = "block";
                return;
            }

            console.log("Step 1: Authenticating...");

            // 1. Check Password
            auth.signInWithEmailAndPassword(email, pass)
                .then((userCredential) => {
                    console.log("Password correct. Step 2: Checking Role...");
                    checkRole(email); // We pass EMAIL, not UID
                })
                .catch((error) => {
                    console.error(error);
                    errorDiv.innerText = "Login Failed: " + error.message;
                    errorDiv.style.display = "block";
                });
        }

        function checkRole(emailKey) {
            // 2. Check Firestore Database
            // Important: We look for the document named "admin@gmail.com"
            db.collection("users").doc(emailKey).get()
                .then((doc) => {
                    if (doc.exists) {
                        const data = doc.data();
                        
                        // Check if Active
                        if (data.isActive !== true) {
                            alert("Your account is disabled.");
                            return;
                        }

                        // Check Role and Redirect
                        if (data.role === "admin") {
                            window.location.href = "admin_dashboard.jsp";
                        } else {
                            window.location.href = "mark_attendance.jsp";
                        }
                    } else {
                        console.error("No database record found for " + emailKey);
                        alert("Login Error: User profile missing in database.");
                    }
                })
                .catch((error) => {
                    console.error("DB Error:", error);
                    alert("Database connection failed.");
                });
        }
    </script>

</body>
</html>