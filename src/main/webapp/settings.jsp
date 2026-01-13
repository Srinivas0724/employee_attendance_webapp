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
    <title>Settings - Employee Portal</title>
    
    <style>
        /* --- 1. RESET & VARS --- */
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        
        :root {
            --primary-navy: #1a3b6e;
            --primary-dark: #122b52;
            --primary-green: #2ecc71;
            --bg-light: #f0f2f5;
            --text-dark: #2c3e50;
            --text-grey: #7f8c8d;
            --card-shadow: 0 10px 30px rgba(0,0,0,0.05);
            --sidebar-width: 280px;
        }

        body { display: flex; height: 100vh; background-color: var(--bg-light); overflow: hidden; }

        /* --- 2. SIDEBAR --- */
        .sidebar {
            width: var(--sidebar-width);
            background: linear-gradient(180deg, var(--primary-navy) 0%, var(--primary-dark) 100%);
            color: white;
            display: flex;
            flex-direction: column;
            transition: all 0.3s ease;
            flex-shrink: 0;
            z-index: 1000;
            box-shadow: 4px 0 20px rgba(0,0,0,0.1);
        }

        .sidebar-header {
            padding: 30px 20px;
            text-align: center;
            border-bottom: 1px solid rgba(255,255,255,0.05);
            background: rgba(0,0,0,0.1);
        }

        .sidebar-logo {
            max-width: 130px;
            height: auto;
            margin-bottom: 15px;
            filter: brightness(0) invert(1) drop-shadow(0 4px 6px rgba(0,0,0,0.2));
        }
        
        .sidebar-brand { 
            font-size: 13px; 
            opacity: 0.9; 
            letter-spacing: 1.5px; 
            text-transform: uppercase; 
            font-weight: 600;
        }

        .nav-menu {
            list-style: none;
            padding: 20px 15px;
            flex: 1;
            overflow-y: auto;
        }

        .nav-item { margin-bottom: 8px; }

        .nav-item a {
            display: flex;
            align-items: center;
            padding: 14px 20px;
            color: #bdc3c7;
            text-decoration: none;
            font-size: 15px;
            font-weight: 500;
            border-radius: 10px;
            transition: all 0.2s ease;
        }

        .nav-item a:hover {
            background-color: rgba(255,255,255,0.08);
            color: white;
            transform: translateX(5px);
        }

        .nav-item a.active {
            background-color: var(--primary-green);
            color: white;
            box-shadow: 0 4px 15px rgba(46, 204, 113, 0.4);
        }

        .nav-icon { margin-right: 15px; font-size: 18px; width: 25px; text-align: center; }

        .sidebar-footer { padding: 25px; border-top: 1px solid rgba(255,255,255,0.05); }
        .btn-logout {
            width: 100%;
            padding: 14px;
            background-color: rgba(231, 76, 60, 0.9);
            color: white;
            border: none;
            border-radius: 10px;
            cursor: pointer;
            font-weight: bold;
            font-size: 14px;
            display: flex; align-items: center; justify-content: center; gap: 10px;
            transition: all 0.2s;
            box-shadow: 0 4px 10px rgba(231, 76, 60, 0.3);
        }
        .btn-logout:hover { background-color: #c0392b; transform: translateY(-2px); }

        /* --- 3. MAIN CONTENT --- */
        .main-content {
            flex: 1;
            display: flex;
            flex-direction: column;
            overflow-y: auto;
            position: relative;
        }
        
        .topbar {
            background: white;
            height: 70px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 0 40px;
            box-shadow: 0 2px 15px rgba(0,0,0,0.03);
            position: sticky; top: 0; z-index: 100;
        }
        
        .page-title { 
            font-size: 22px; 
            font-weight: 700; 
            color: var(--primary-navy); 
            letter-spacing: -0.5px;
        }

        .user-profile { 
            display: flex; 
            align-items: center; 
            gap: 15px; 
            background: #f8f9fa;
            padding: 8px 15px;
            border-radius: 30px;
            border: 1px solid #e9ecef;
        }
        
        .user-email { font-size: 13px; color: var(--text-dark); font-weight: 600; }
        .user-avatar { 
            width: 36px; height: 36px; 
            background: var(--primary-navy); 
            color: white;
            border-radius: 50%; 
            display: flex; align-items: center; justify-content: center; 
            font-weight: bold; font-size: 14px;
        }

        /* --- 4. SETTINGS CONTENT --- */
        .content { 
            padding: 40px; 
            max-width: 900px; 
            margin: 0 auto; 
            width: 100%; 
            display: flex; 
            flex-direction: column; 
            gap: 30px; 
        }

        /* Cards */
        .card { 
            background: white; 
            padding: 30px; 
            border-radius: 16px; 
            box-shadow: var(--card-shadow); 
            border-top: 4px solid transparent;
        }
        
        .card-profile { border-top-color: var(--primary-navy); }
        .card-security { border-top-color: #f39c12; }
        .card-email { border-top-color: #e74c3c; }

        .card-title { 
            margin: 0 0 20px 0; 
            font-size: 18px; 
            font-weight: 700; 
            color: var(--primary-navy); 
            border-bottom: 1px solid #f1f1f1; 
            padding-bottom: 15px; 
        }

        /* Profile Image */
        .profile-section { display: flex; align-items: center; gap: 30px; }
        
        .profile-preview { 
            width: 110px; height: 110px; 
            border-radius: 50%; 
            border: 4px solid #f8f9fa; 
            object-fit: cover; 
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }
        .file-upload-wrapper { flex: 1; }

        /* Inputs */
        label { 
            display: block; font-size: 13px; font-weight: 600; color: var(--text-dark); 
            margin-bottom: 8px; margin-top: 20px; text-transform: uppercase; letter-spacing: 0.5px;
        }
        
        input { 
            width: 100%; padding: 14px; 
            border: 1px solid #e0e0e0; border-radius: 8px; 
            font-size: 14px; transition: all 0.3s; 
            background: #fdfdfd;
        }
        
        input:focus { 
            border-color: var(--primary-navy); outline: none; background: white; 
            box-shadow: 0 0 0 3px rgba(26, 59, 110, 0.1);
        }
        
        /* File Input */
        input[type="file"] { 
            padding: 10px; background: #f8f9fa; 
            border: 2px dashed #d1d5db; cursor: pointer;
        }
        input[type="file"]:hover { border-color: var(--primary-navy); background: #f0f4f8; }

        /* Buttons */
        .btn-action { 
            margin-top: 25px; width: 100%; padding: 14px; border: none; 
            border-radius: 8px; font-weight: 700; cursor: pointer; font-size: 14px; 
            transition: all 0.2s; color: white; 
        }
        
        .btn-blue { background: var(--primary-navy); box-shadow: 0 4px 10px rgba(26, 59, 110, 0.3); }
        .btn-blue:hover { background: #132c52; transform: translateY(-2px); }
        
        .btn-green { background: var(--primary-green); box-shadow: 0 4px 10px rgba(46, 204, 113, 0.3); }
        .btn-green:hover { background: #27ae60; transform: translateY(-2px); }
        
        .btn-red { background: #e74c3c; box-shadow: 0 4px 10px rgba(231, 76, 60, 0.3); }
        .btn-red:hover { background: #c0392b; transform: translateY(-2px); }

        .info-box { 
            background: #fff8e1; color: #b45309; padding: 15px; 
            border-radius: 8px; font-size: 13px; margin-bottom: 20px; 
            border: 1px solid #fcd34d; font-weight: 500;
        }

        /* Loader */
        #loadingOverlay { 
            position: fixed; top: 0; left: 0; width: 100%; height: 100%; 
            background: rgba(255,255,255,0.9); backdrop-filter: blur(5px);
            z-index: 9999; display: flex; justify-content: center; align-items: center; 
            font-size: 24px; color: var(--primary-navy); flex-direction: column; gap: 15px; font-weight: 600;
        }

        @media (max-width: 900px) {
            .sidebar { position: fixed; left: -280px; height: 100%; }
            .sidebar.active { transform: translateX(280px); }
            .toggle-btn { display: block; font-size: 24px; cursor: pointer; margin-right: 15px; }
            .content { padding: 20px; }
            .topbar { padding: 0 20px; }
            .profile-section { flex-direction: column; text-align: center; }
        }
    </style>

    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-auth-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-firestore-compat.js"></script>
</head>
<body>

    <div id="loadingOverlay">
        <div style="font-size: 50px;">⚙️</div>
        <div>Loading Settings...</div>
    </div>

    <nav class="sidebar" id="sidebar">
        <div class="sidebar-header">
            <img src="synod_logo.png" alt="Synod Logo" class="sidebar-logo">
            <div class="sidebar-brand">EMPLOYEE PORTAL</div>
        </div>

        <ul class="nav-menu">
            <li class="nav-item">
                <a href="employee_dashboard.jsp"><span class="nav-icon">📊</span> Dashboard</a>
            </li>
            <li class="nav-item">
                <a href="mark_attendance.jsp"><span class="nav-icon">📍</span> Mark Attendance</a>
            </li>
            <li class="nav-item">
                <a href="employee_tasks.jsp"><span class="nav-icon">📝</span> Assigned Tasks</a>
            </li>
            <li class="nav-item">
                <a href="attendance_history.jsp"><span class="nav-icon">🕒</span> History</a>
            </li>
            <li class="nav-item">
                <a href="employee_expenses.jsp"><span class="nav-icon">💸</span> My Expenses</a>
            </li>
            <li class="nav-item">
                <a href="salary.jsp"><span class="nav-icon">💰</span> My Salary</a>
            </li>
            <li class="nav-item">
                <a href="settings.jsp" class="active"><span class="nav-icon">⚙️</span> Settings</a>
            </li>
        </ul>

        <div class="sidebar-footer">
            <button onclick="logout()" class="btn-logout"><span>🚪</span> Sign Out</button>
        </div>
    </nav>

    <div class="main-content">
        <header class="topbar">
            <div style="display:flex; align-items:center;">
                <div class="toggle-btn" onclick="toggleSidebar()">☰</div>
                <div class="page-title">Account Configuration</div>
            </div>
            <div class="user-profile">
                <span id="headerEmail" class="user-email">Loading...</span>
                <div class="user-avatar">E</div>
            </div>
        </header>

        <div class="content">
            
            <div class="card card-profile">
                <h3 class="card-title">📷 Profile Picture</h3>
                <div class="profile-section">
                    <img id="profileImg" class="profile-preview" src="https://via.placeholder.com/150?text=User" alt="Profile">
                    <div class="file-upload-wrapper">
                        <label style="margin-top:0;">Update Photo</label>
                        <input type="file" id="fileInput" accept="image/*">
                        <button class="btn-action btn-blue" onclick="uploadPic()">Save New Picture</button>
                    </div>
                </div>
            </div>

            <div class="card card-security">
                <h3 class="card-title">🔐 Security Settings</h3>
                <label>New Password</label>
                <input type="password" id="newPass" placeholder="Enter new password (min. 6 chars)">
                
                <button class="btn-action btn-green" onclick="changePassword()">Update Password</button>
            </div>

            <div class="card card-email">
                <h3 class="card-title">✉️ Update Email</h3>
                <div class="info-box">
                    ⚠️ <b>Warning:</b> Changing your email address is a sensitive action. You will be logged out immediately and must sign in with the new email.
                </div>
                
                <label>Current Email</label>
                <input type="text" id="currentEmailDisplay" disabled style="background:#e9ecef; color:#666; cursor:not-allowed;">
                
                <label>New Email Address</label>
                <input type="email" id="newEmail" placeholder="Enter new email address">
                
                <button class="btn-action btn-red" onclick="changeEmail()">Update Email Address</button>
            </div>

        </div>
    </div>

    <script>
        // --- 1. CONFIG ---
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

        // --- 2. AUTH CHECK ---
        auth.onAuthStateChanged(user => {
            if (user) {
                document.getElementById("headerEmail").innerText = user.email;
                document.getElementById("currentEmailDisplay").value = user.email;
                document.getElementById("loadingOverlay").style.display = "none";
                loadProfile(user.email);
            } else {
                window.location.replace("index.html");
            }
        });

        function toggleSidebar() {
            document.getElementById("sidebar").classList.toggle("active");
        }

        // --- 3. LOAD PROFILE ---
        function loadProfile(email) {
            db.collection("users").doc(email).get().then(doc => {
                if (doc.exists) {
                    const data = doc.data();
                    if (data.profileImage) {
                        document.getElementById("profileImg").src = data.profileImage;
                    }
                }
            });
        }

        // --- 4. UPLOAD PIC (Client-Side Resize) ---
        function uploadPic() {
            const user = auth.currentUser;
            const file = document.getElementById("fileInput").files[0];

            if (!file) { alert("Please select an image file first."); return; }

            const imgObj = new Image();
            const reader = new FileReader();

            reader.onload = e => { imgObj.src = e.target.result; };

            imgObj.onload = () => {
                const canvas = document.createElement("canvas");
                const SIZE = 300; 

                canvas.width = SIZE;
                canvas.height = SIZE;

                const ctx = canvas.getContext("2d");
                ctx.drawImage(imgObj, 0, 0, SIZE, SIZE);

                const compressedBase64 = canvas.toDataURL("image/jpeg", 0.7);

                db.collection("users").doc(user.email).set({
                    profileImage: compressedBase64
                }, { merge: true }).then(() => {
                    document.getElementById("profileImg").src = compressedBase64;
                    alert("✅ Profile picture updated successfully!");
                }).catch(err => alert("Error: " + err.message));
            };

            reader.readAsDataURL(file);
        }

        // --- 5. CHANGE PASSWORD ---
        function changePassword() {
            const newPass = document.getElementById("newPass").value;
            const user = auth.currentUser;

            if (newPass.length < 6) { alert("Password must be at least 6 characters."); return; }

            user.updatePassword(newPass).then(() => {
                alert("✅ Password updated successfully!");
                document.getElementById("newPass").value = "";
            }).catch(error => {
                if (error.code === 'auth/requires-recent-login') {
                    alert("⚠️ Security Alert: Please Logout and Login again to perform this action.");
                    logout();
                } else {
                    alert("Error: " + error.message);
                }
            });
        }

        // --- 6. CHANGE EMAIL ---
        function changeEmail() {
            const user = auth.currentUser;
            const newEmail = document.getElementById("newEmail").value;
            const oldEmail = user.email;

            if (!newEmail) { alert("Enter a new email address."); return; }

            if(!confirm("Are you sure? You will need to login again immediately.")) return;

            user.updateEmail(newEmail)
                .then(() => {
                    // Migrate Data (Old Email Doc -> New Email Doc)
                    const oldDocRef = db.collection("users").doc(oldEmail);
                    const newDocRef = db.collection("users").doc(newEmail);

                    return oldDocRef.get().then(snap => {
                        if (snap.exists) {
                            return newDocRef.set(snap.data()).then(() => oldDocRef.delete());
                        }
                    });
                })
                .then(() => {
                    alert("✅ Email updated! Redirecting to login...");
                    logout();
                })
                .catch(err => {
                    if (err.code === 'auth/requires-recent-login') {
                        alert("⚠️ Security Alert: Please Logout and Login again to perform this action.");
                        logout();
                    } else {
                        alert("Error: " + err.message);
                    }
                });
        }

        function logout(){ auth.signOut().then(() => window.location.href = "index.html"); }
    </script>
</body>
</html>