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
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
    <title>Employee Dashboard - Synod Bioscience</title>
    
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-auth-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-firestore-compat.js"></script>

    <style>
        /* --- 1. RESET & CORE THEME --- */
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        :root {
            --primary-navy: #1a3b6e;
            --primary-dark: #122b52;
            --primary-green: #2ecc71;
            --bg-light: #f0f2f5;
            --text-dark: #2c3e50;
            --text-grey: #7f8c8d;
            --sidebar-width: 280px;
            --card-shadow: 0 4px 15px rgba(0,0,0,0.05);
        }

        body { display: flex; height: 100vh; background-color: var(--bg-light); overflow: hidden; }

        /* --- 2. SIDEBAR --- */
        .sidebar { 
            width: var(--sidebar-width); 
            background: linear-gradient(180deg, var(--primary-navy) 0%, var(--primary-dark) 100%);
            color: white; 
            display: flex; flex-direction: column; flex-shrink: 0; 
            transition: all 0.3s ease; z-index: 1000;
            box-shadow: 4px 0 20px rgba(0,0,0,0.1);
        }
        .sidebar-header { padding: 30px 20px; text-align: center; border-bottom: 1px solid rgba(255,255,255,0.05); background: rgba(0,0,0,0.1); }
        .sidebar-logo { max-width: 130px; margin-bottom: 15px; filter: brightness(0) invert(1) drop-shadow(0 4px 6px rgba(0,0,0,0.2)); }
        .sidebar-brand { font-size: 13px; font-weight: 600; letter-spacing: 1.5px; text-transform: uppercase; opacity: 0.9; }
        
        .nav-menu { list-style: none; padding: 20px 15px; flex: 1; overflow-y: auto; }
        .nav-item { margin-bottom: 8px; }
        .nav-item a { display: flex; align-items: center; padding: 14px 20px; color: #bdc3c7; text-decoration: none; font-size: 15px; font-weight: 500; border-radius: 10px; transition: all 0.2s; }
        .nav-item a:hover { background: rgba(255,255,255,0.08); color: white; transform: translateX(5px); }
        .nav-item a.active { background: var(--primary-green); color: white; box-shadow: 0 4px 15px rgba(46, 204, 113, 0.4); }
        .nav-icon { margin-right: 15px; font-size: 18px; width: 25px; text-align: center; }
        
        .sidebar-footer { padding: 25px; border-top: 1px solid rgba(255,255,255,0.05); }
        .btn-logout { width: 100%; padding: 14px; background: rgba(231, 76, 60, 0.9); color: white; border: none; border-radius: 10px; font-weight: bold; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 10px; transition: 0.2s; box-shadow: 0 4px 10px rgba(231, 76, 60, 0.3); }
        .btn-logout:hover { background: #c0392b; transform: translateY(-2px); }

        /* --- 3. MAIN CONTENT --- */
        .main-content { flex: 1; display: flex; flex-direction: column; overflow-y: auto; position: relative; }
        .topbar { background: white; height: 70px; display: flex; justify-content: space-between; align-items: center; padding: 0 40px; box-shadow: 0 2px 15px rgba(0,0,0,0.03); position: sticky; top: 0; z-index: 50; }
        .page-title { font-size: 22px; font-weight: 700; color: var(--primary-navy); letter-spacing: -0.5px; }
        .user-profile { display: flex; align-items: center; gap: 15px; background: #f8f9fa; padding: 8px 15px; border-radius: 30px; border: 1px solid #e9ecef; }
        .user-avatar { width: 36px; height: 36px; background: var(--primary-navy); color: white; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: bold; font-size: 14px; }

        .content { padding: 30px 40px; max-width: 1400px; margin: 0 auto; width: 100%; }

        /* --- 4. PROFILE CARDS --- */
        .grid-container { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 25px; }

        .card { background: white; padding: 30px; border-radius: 16px; box-shadow: var(--card-shadow); display: flex; flex-direction: column; border: 1px solid white; position: relative; overflow: hidden; }
        
        /* Profile Header Style */
        .profile-header { display: flex; align-items: center; gap: 20px; margin-bottom: 30px; padding-bottom: 20px; border-bottom: 1px solid #f0f0f0; }
        .profile-pic { width: 80px; height: 80px; background: var(--bg-light); border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 32px; color: var(--text-grey); font-weight: bold; border: 2px solid white; box-shadow: 0 4px 10px rgba(0,0,0,0.1); }
        .profile-text h2 { margin: 0; font-size: 24px; color: var(--primary-navy); font-weight: 700; }
        .profile-text p { margin: 5px 0 0; color: var(--text-grey); font-size: 14px; }
        .status-badge { display: inline-block; padding: 5px 12px; background: #e8f5e9; color: #27ae60; border-radius: 20px; font-size: 11px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; margin-top: 8px; }

        /* Data Rows */
        .info-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 40px; }
        .info-row { padding: 10px 0; border-bottom: 1px solid #f9f9f9; }
        .info-row:last-child { border-bottom: none; }
        .label { font-size: 12px; color: var(--text-grey); font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; display: block; margin-bottom: 4px; }
        .value { font-size: 15px; color: var(--text-dark); font-weight: 600; }

        /* Project Card (Special Style) */
        .project-card { background: linear-gradient(135deg, var(--primary-navy), #2c5aa0); color: white; border: none; }
        .project-card h3 { font-size: 18px; margin: 0 0 20px 0; border-bottom: 1px solid rgba(255,255,255,0.2); padding-bottom: 15px; color: white; }
        .project-card .label { color: rgba(255,255,255,0.7); }
        .project-card .value { color: white; font-size: 18px; font-weight: 700; }

        /* Attendance Card */
        .card-header-simple { font-size: 16px; font-weight: 700; color: var(--primary-navy); border-bottom: 1px solid #f0f0f0; padding-bottom: 15px; margin-bottom: 20px; }
        
        #loadingOverlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: white; z-index: 9999; display: flex; justify-content: center; align-items: center; flex-direction: column; color: var(--primary-navy); font-weight: 600; font-size: 20px; }

        @media (max-width: 1024px) {
            .sidebar { position: fixed; left: -280px; height: 100%; }
            .sidebar.active { transform: translateX(280px); }
            .toggle-btn { display: block; font-size: 24px; cursor: pointer; margin-right: 15px; }
            .content { padding: 20px; }
            .grid-container { grid-template-columns: 1fr; }
            .card[style*="span 2"] { grid-column: span 1 !important; }
        }
        @media (min-width: 1025px) { .toggle-btn { display: none; } }

        /* Mobile Optimizations */

@media (max-width: 768px) {

    /* Hide Sidebar by default on mobile */

    .sidebar {

        display: none; 

        position: fixed;

        z-index: 1000;

        width: 250px;

        height: 100%;

    }



    /* Make Content use full width */

    .main-content {

        margin-left: 0 !important;

        width: 100%;

    }



    /* Show a Hamburger Menu Button (You need to add this button to your HTML) */

    .mobile-menu-btn {

        display: block !important; /* Visible only on mobile */

        font-size: 24px;

        background: none;

        border: none;

        color: white; /* or dark color depending on your header */

        cursor: pointer;

    }

    

    /* Adjust Grid/Cards for Mobile */

    .card-container, .stats-row {

        flex-direction: column; /* Stack items vertically */

    }

}

.table-responsive, .attendance-grid-container {

    display: block;

    width: 100%;

    overflow-x: auto; /* Allows horizontal scrolling */

    -webkit-overflow-scrolling: touch; /* Smooth scroll on iPhones */

}
    </style>
</head>
<body>

    <div id="loadingOverlay">
        <div style="font-size: 50px; margin-bottom: 15px;">👤</div>
        <div>Loading Profile...</div>
    </div>

    <nav class="sidebar" id="sidebar">
        <div class="sidebar-header">
            <img src="synod_logo.png" alt="Logo" class="sidebar-logo">
            <div class="sidebar-brand">EMPLOYEE PORTAL</div>
        </div>
        
        <ul class="nav-menu">
            <li class="nav-item">
                <a href="employee_dashboard.jsp" class="active"><span class="nav-icon">📊</span> Dashboard</a>
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
                <a href="settings.jsp"><span class="nav-icon">⚙️</span> Settings</a>
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
                <div class="page-title">My Dashboard</div>
            </div>
            <div class="user-profile">
                <span id="navEmail">Loading...</span>
                <div class="user-avatar">A</div>
            </div>
        </header>

        <div class="content">
            
            <div class="grid-container">
                
                <div class="card" style="grid-column: span 2;">
                    <div class="profile-header">
                        <div class="profile-pic" id="avatarLetter">U</div>
                        <div class="profile-text">
                            <h2 id="dispName">Loading...</h2>
                            <p id="dispRole">Verifying Role...</p>
                            <span class="status-badge" id="dispStatus">Active Employee</span>
                        </div>
                    </div>

                    <div class="info-grid">
                        <div>
                            <div class="info-row">
                                <span class="label">Email Address</span>
                                <span class="value" id="dispEmail">-</span>
                            </div>
                            <div class="info-row">
                                <span class="label">Phone Number</span>
                                <span class="value" id="dispPhone">-</span>
                            </div>
                        </div>
                        <div>
                            <div class="info-row">
                                <span class="label">Employee ID</span>
                                <span class="value" id="dispEmpId" style="color:var(--primary-navy);">-</span>
                            </div>
                            <div class="info-row">
                                <span class="label">System Access</span>
                                <span class="value" id="dispAccess">-</span>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="card project-card">
                    <h3>🚀 Current Assignment</h3>
                    <div style="margin-top: 20px;">
                        <span class="label">Assigned Project</span>
                        <div class="value" id="dispProject">-</div>
                    </div>
                    <div style="margin-top: 25px;">
                        <span class="label">Job Designation</span>
                        <div class="value" id="dispDesignation">-</div>
                    </div>
                </div>

                <div class="card">
                    <div class="card-header-simple">📅 Today's Status</div>
                    <div style="text-align:center; padding: 25px;">
                        <div style="font-size: 36px; font-weight: 800; color: var(--primary-green);" id="clockInTime">--:--</div>
                        <p style="color:#999; font-size:13px; font-weight:600; margin-top:5px;">Clock In Time</p>
                    </div>
                </div>

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

        // --- 2. AUTH & LOAD ---
        auth.onAuthStateChanged(user => {
            if(user) {
                loadUserProfile(user.email);
            } else {
                window.location.href = "index.html";
            }
        });

        // --- 3. LOAD PROFILE ---
        function loadUserProfile(email) {
            db.collection("users").doc(email).onSnapshot(doc => {
                if(doc.exists) {
                    const d = doc.data();
                    
                    // Helper to clean data
                    const val = (v) => {
                        if(!v) return "Not Set";
                        const s = String(v).trim();
                        if(s === "false" || s === "undefined" || s === "") return "Not Set";
                        return s;
                    };

                    const role = (d.role || "employee").toUpperCase();

                    // Update UI
                    document.getElementById("navEmail").innerText = email;
                    document.getElementById("avatarLetter").innerText = (d.fullName ? d.fullName.charAt(0) : "U").toUpperCase();
                    
                    document.getElementById("dispName").innerText = val(d.fullName);
                    document.getElementById("dispRole").innerText = val(d.designation);
                    
                    document.getElementById("dispEmail").innerText = email;
                    document.getElementById("dispPhone").innerText = val(d.contact || d.phone);
                    document.getElementById("dispEmpId").innerText = val(d.empId);
                    document.getElementById("dispAccess").innerText = role;

                    document.getElementById("dispProject").innerText = val(d.currentProject);
                    document.getElementById("dispDesignation").innerText = val(d.designation);

                    checkAttendance(email);

                    document.getElementById("loadingOverlay").style.display = "none";
                } else {
                    alert("Profile not found. Please contact Admin.");
                }
            });
        }

        // --- 4. CHECK ATTENDANCE ---
        function checkAttendance(email) {
            const today = new Date();
            today.setHours(0,0,0,0);
            
            db.collection("attendance_2025")
                .where("email", "==", email)
                .where("timestamp", ">=", today)
                .where("type", "==", "IN")
                .limit(1)
                .get()
                .then(snap => {
                    if(!snap.empty) {
                        const time = new Date(snap.docs[0].data().timestamp.seconds * 1000);
                        document.getElementById("clockInTime").innerText = time.toLocaleTimeString([], {hour:'2-digit', minute:'2-digit'});
                    } else {
                        document.getElementById("clockInTime").innerText = "Not In";
                        document.getElementById("clockInTime").style.color = "#ccc";
                    }
                });
        }

        function toggleSidebar() { document.getElementById("sidebar").classList.toggle("active"); }
        function logout() { auth.signOut().then(() => window.location.href="index.html"); }
    </script>
</body>
</html>