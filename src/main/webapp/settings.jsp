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
    <title>Account Settings - Synod Bioscience</title>
    
    <style>
        /* --- 1. RESET & VARS --- */
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        
        :root {
            --primary-navy: #1a3b6e;
            --primary-green: #2ecc71;
            --bg-light: #f4f6f9;
            --text-dark: #333;
            --text-grey: #666;
            --sidebar-width: 260px;
            --border-color: #eee;
        }

        body { display: flex; height: 100vh; background-color: var(--bg-light); overflow: hidden; }

        /* --- 2. SIDEBAR --- */
        .sidebar {
            width: var(--sidebar-width);
            background-color: var(--primary-navy);
            color: white;
            display: flex;
            flex-direction: column;
            transition: transform 0.3s ease-in-out;
            flex-shrink: 0;
            z-index: 1000;
        }

        .sidebar-header {
            padding: 20px;
            background-color: rgba(0,0,0,0.1);
            text-align: center;
            border-bottom: 1px solid rgba(255,255,255,0.1);
        }

        .sidebar-logo {
            max-width: 140px;
            height: auto;
            margin-bottom: 10px;
            filter: brightness(0) invert(1);
        }
        
        .sidebar-brand { font-size: 14px; opacity: 0.8; letter-spacing: 1px; text-transform: uppercase; }

        .nav-menu {
            list-style: none;
            padding: 20px 0;
            flex: 1;
            overflow-y: auto;
        }

        .nav-item a {
            display: flex;
            align-items: center;
            padding: 15px 25px;
            color: #bdc3c7;
            text-decoration: none;
            font-size: 15px;
            transition: all 0.3s;
            border-left: 4px solid transparent;
        }

        .nav-item a:hover, .nav-item a.active {
            background-color: rgba(255,255,255,0.05);
            color: white;
            border-left-color: var(--primary-green);
        }

        .nav-icon { margin-right: 15px; font-size: 18px; width: 25px; text-align: center; }

        .sidebar-footer { padding: 20px; border-top: 1px solid rgba(255,255,255,0.1); }
        .btn-logout {
            width: 100%;
            padding: 12px;
            background-color: rgba(231, 76, 60, 0.8);
            color: white;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-weight: bold;
            transition: 0.3s;
            display: flex; align-items: center; justify-content: center; gap: 10px;
        }
        .btn-logout:hover { background-color: #c0392b; }

        /* --- 3. MAIN CONTENT --- */
        .main-content {
            flex: 1;
            display: flex;
            flex-direction: column;
            overflow-y: auto;
            position: relative;
        }

        /* Top Bar */
        .topbar {
            background: white;
            height: 60px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 0 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
            position: sticky; top: 0; z-index: 100;
        }

        .toggle-btn { display: none; font-size: 24px; cursor: pointer; color: var(--primary-navy); margin-right: 15px; }
        .page-title { font-size: 18px; font-weight: bold; color: var(--primary-navy); }
        .user-profile { font-size: 14px; color: var(--text-grey); display: flex; align-items: center; gap: 10px; }
        .user-avatar { width: 35px; height: 35px; background: #e0e0e0; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: bold; color: var(--primary-navy); }

        /* --- 4. SETTINGS CONTENT --- */
        .content { padding: 30px; max-width: 800px; margin: 0 auto; width: 100%; display: flex; flex-direction: column; gap: 25px; }

        .card { background: white; padding: 25px; border-radius: 10px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); border: 1px solid #f1f1f1; }
        
        .card-title { margin: 0 0 20px 0; font-size: 18px; font-weight: bold; color: var(--primary-navy); border-bottom: 2px solid #f8f9fa; padding-bottom: 10px; display: flex; align-items: center; gap: 10px; }

        /* Profile Image */
        .profile-section { display: flex; align-items: center; gap: 20px; flex-wrap: wrap; }
        .profile-preview { width: 100px; height: 100px; border-radius: 50%; border: 3px solid #eee; object-fit: cover; }
        .file-upload-wrapper { flex: 1; }
        
        input[type="file"] { padding: 10px; background: #f8f9fa; border-radius: 6px; width: 100%; border: 1px dashed #ccc; cursor: pointer; }
        
        /* Inputs */
        label { display: block; font-size: 13px; font-weight: 600; color: #555; margin-bottom: 8px; margin-top: 15px; }
        input[type="password"], input[type="email"] { width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 6px; font-size: 14px; transition: 0.3s; box-sizing: border-box; }
        input:focus { border-color: var(--primary-navy); outline: none; }

        /* Buttons */
        .btn-action { margin-top: 20px; width: 100%; padding: 12px; border: none; border-radius: 6px; font-weight: bold; cursor: pointer; font-size: 14px; transition: 0.2s; color: white; }
        
        .btn-blue { background: var(--primary-navy); }
        .btn-blue:hover { background: #132c52; }
        
        .btn-green { background: var(--primary-green); }
        .btn-green:hover { background: #27ae60; }
        
        .btn-red { background: #e74c3c; }
        .btn-red:hover { background: #c0392b; }

        .info-box { background: #fff3cd; color: #856404; padding: 10px; border-radius: 4px; font-size: 13px; margin-bottom: 15px; border: 1px solid #ffeeba; }

        /* Loader */
        #loadingOverlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: white; z-index: 9999; display: flex; justify-content: center; align-items: center; font-size: 24px; color: #333; flex-direction: column; gap: 10px; }

        /* Mobile Responsive */
        @media (max-width: 900px) {
            .sidebar { position: fixed; left: -260px; height: 100%; width: 260px; }
            .sidebar.active { transform: translateX(260px); }
            .toggle-btn { display: block; }
            .profile-section { flex-direction: column; text-align: center; }
        }
    </style>

    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-auth-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-firestore-compat.js"></script>
</head>
<body>

    <div id="loadingOverlay">
        <div style="font-size: 40px; margin-bottom: 10px;">⚙️</div>
        <div>Loading Settings...</div>
    </div>

    <nav class="sidebar" id="sidebar">
        <div class="sidebar-header">
            <img src="synod_logo.png" alt="Synod Logo" class="sidebar-logo">
            <div class="sidebar-brand">EMPLOYEE PORTAL</div>
        </div>

        <ul class="nav-menu">
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
                <span id="headerEmail">Loading...</span>
                <div class="user-avatar">E</div>
            </div>
        </header>

        <div class="content">
            
            <div class="card">
                <h3 class="card-title">📷 Profile Picture</h3>
                <div class="profile-section">
                    <img id="profileImg" class="profile-preview" src="https://via.placeholder.com/100?text=User" alt="Profile">
                    <div class="file-upload-wrapper">
                        <label style="margin-top:0;">Update Photo</label>
                        <input type="file" id="fileInput" accept="image/*">
                        <button class="btn-action btn-blue" onclick="uploadPic()">Save New Picture</button>
                    </div>
                </div>
            </div>

            <div class="card">
                <h3 class="card-title">🔐 Security Settings</h3>
                <label>New Password</label>
                <input type="password" id="newPass" placeholder="Enter new password (min. 6 chars)">
                
                <button class="btn-action btn-green" onclick="changePassword()">Update Password</button>
            </div>

            <div class="card">
                <h3 class="card-title">✉️ Update Email</h3>
                <div class="info-box">
                    ⚠️ Changing your email address will require you to log in again immediately.
                </div>
                
                <label>Current Email</label>
                <input type="text" id="currentEmailDisplay" disabled style="background:#f8f9fa; color:#666;">
                
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