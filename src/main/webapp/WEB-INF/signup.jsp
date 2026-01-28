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
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create Account - Synod Bioscience</title>
    
    <style>
        /* --- 1. General Reset & Typography --- */
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body, html { height: 100%; width: 100%; background-color: #f4f6f8; }

        /* --- 2. Layout: Split Screen --- */
        .container { display: flex; height: 100vh; width: 100%; }

        /* --- 3. Left Side: Branding --- */
        .left-panel {
            flex: 1.2;
            background-color: #e3e6e8;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 40px;
            border-right: 1px solid #d1d5db;
        }
        .left-panel img {
            max-width: 90%;
            max-height: 80%;
            object-fit: contain;
            filter: drop-shadow(0 15px 25px rgba(0,0,0,0.1));
        }

        /* --- 4. Right Side: Signup Form --- */
        .right-panel {
            flex: 1;
            background-color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-direction: column;
            padding: 50px;
            overflow-y: auto; /* Allow scrolling if form is tall */
        }

        .signup-wrapper {
            width: 100%;
            max-width: 450px;
        }

        .header-text { margin-bottom: 30px; text-align: center; }
        .header-text h2 {
            color: #2ecc71; /* Synod Green for "New Account" vibe */
            font-size: 2.2rem;
            font-weight: 800;
            margin-bottom: 10px;
        }
        .header-text p { color: #666; font-size: 1.1rem; }

        /* --- 5. Form Elements --- */
        .form-group { margin-bottom: 20px; }
        .form-group label {
            display: block;
            margin-bottom: 8px;
            color: #444;
            font-weight: 600;
            font-size: 0.95rem;
            text-transform: uppercase;
        }

        .form-input {
            width: 100%;
            padding: 14px;
            border: 2px solid #e1e4e8;
            border-radius: 8px;
            font-size: 1rem;
            transition: border-color 0.3s;
            background: #fdfdfd;
        }
        .form-input:focus {
            outline: none;
            border-color: #2ecc71; /* Green Focus */
            background: #fff;
        }

        /* Submit Button */
        .btn-register {
            width: 100%;
            padding: 16px;
            background-color: #2ecc71; /* Synod Green */
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 1.1rem;
            font-weight: bold;
            cursor: pointer;
            transition: transform 0.2s, background 0.3s;
            margin-top: 10px;
        }
        .btn-register:hover {
            background-color: #27ae60;
            transform: translateY(-2px);
        }

        /* Footer Links */
        .footer-links {
            margin-top: 25px;
            text-align: center;
            font-size: 1rem;
            color: #666;
        }
        .footer-links a {
            color: #1a3b6e;
            text-decoration: none;
            font-weight: 600;
        }
        .footer-links a:hover { text-decoration: underline; }

        /* Error Box */
        .error-msg {
            background-color: #fee2e2;
            color: #991b1b;
            padding: 15px;
            border-radius: 8px;
            font-size: 0.95rem;
            margin-bottom: 20px;
            display: none;
            text-align: center;
            border: 1px solid #fecaca;
        }

        /* Mobile Responsive */
        @media (max-width: 900px) {
            .container { flex-direction: column; height: auto; }
            .left-panel { height: 30vh; padding: 20px; border-right: none; }
            .right-panel { min-height: 70vh; padding: 40px 20px; }
        }
    </style>

    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-auth-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-firestore-compat.js"></script>
</head>
<body>

    <div class="container">
        <div class="left-panel">
            <img src="synod_logo.png" alt="Synod Group Logo">
        </div>

        <div class="right-panel">
            <div class="signup-wrapper">
                
                <div class="header-text">
                    <h2>Join Synod Bioscience</h2>
                    <p>Create your employee profile</p>
                </div>

                <div id="errorMsg" class="error-msg"></div>

                <div class="form-group">
                    <label>Full Name</label>
                    <input type="text" id="fullName" class="form-input" placeholder="e.g. John Doe" required>
                </div>

                <div class="form-group">
                    <label>Mobile Number</label>
                    <input type="text" id="contact" class="form-input" placeholder="+91 98765 43210" required>
                </div>

                <div class="form-group">
                    <label>Email Address</label>
                    <input type="email" id="email" class="form-input" placeholder="name@synodbioscience.com" required>
                </div>

                <div class="form-group">
                    <label>Password (Min 6 chars)</label>
                    <input type="password" id="password" class="form-input" placeholder="••••••••" required>
                </div>

                <button onclick="signUp()" id="signBtn" class="btn-register">Create Account</button>

                <div class="footer-links">
                    Already have an account? <a href="index.html">Login Here</a>
                </div>

            </div>
        </div>
    </div>

    <script>
        // --- FIREBASE CONFIGURATION ---
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

        // --- SIGN UP LOGIC ---
        function signUp() {
            const name = document.getElementById("fullName").value;
            const contact = document.getElementById("contact").value;
            const email = document.getElementById("email").value;
            const pass = document.getElementById("password").value;
            const btn = document.getElementById("signBtn");
            
            // Basic Validation
            if(!name || !contact || !email || !pass) { 
                showError("Please fill in all fields."); 
                return; 
            }
            if(pass.length < 6) { 
                showError("Password must be at least 6 characters long."); 
                return; 
            }

            // Disable button
            btn.innerText = "Creating Account...";
            btn.disabled = true;

            // Create User
            auth.createUserWithEmailAndPassword(email, pass)
            .then((cred) => {
                // Save details to Firestore with 'Pending' status
                return db.collection("users").doc(email).set({
                    fullName: name,
                    email: email,
                    contact: contact,
                    role: "employee",   // Default role
                    status: "Pending",  // Prevents immediate login
                    createdAt: firebase.firestore.FieldValue.serverTimestamp()
                });
            })
            .then(() => {
                // Sign out immediately (security step)
                return auth.signOut();
            })
            .then(() => {
                alert("✅ Registration Successful!\n\nYour account is currently PENDING APPROVAL.\nPlease contact the Administrator to activate your access.");
                window.location.replace("index.html"); // Go back to login screen
            })
            .catch(e => {
                let msg = e.message;
                if(e.code === 'auth/email-already-in-use') msg = "This email is already registered. Please Login.";
                showError(msg);
                btn.innerText = "Create Account";
                btn.disabled = false;
            });
        }

        function showError(msg) {
            const box = document.getElementById("errorMsg");
            box.innerText = "⚠️ " + msg;
            box.style.display = "block";
        }
    </script>
</body>
</html>