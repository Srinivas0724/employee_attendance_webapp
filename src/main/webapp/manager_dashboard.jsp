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
    <title>Manager Dashboard - Synod Bioscience</title>
    
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
            --card-shadow: 0 4px 20px rgba(0,0,0,0.05);
        }

        body { display: flex; height: 100vh; background-color: var(--bg-light); overflow: hidden; }

        /* --- 2. SIDEBAR (Exact Match) --- */
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

        /* --- 4. GRID SYSTEM --- */
        .grid-container { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 25px; margin-bottom: 30px; }
        
        /* Large Card (Profile) */
        .card-profile { 
            background: white; padding: 30px; border-radius: 16px; 
            box-shadow: var(--card-shadow); border: 1px solid white;
            grid-column: span 2; display: flex; flex-direction: column; gap: 20px;
        }
        
        .profile-header { display: flex; align-items: center; gap: 25px; padding-bottom: 20px; border-bottom: 1px solid #f0f0f0; }
        .profile-pic { width: 80px; height: 80px; background: var(--bg-light); border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 32px; color: var(--text-grey); font-weight: bold; border: 3px solid white; box-shadow: 0 4px 10px rgba(0,0,0,0.1); }
        .profile-text h2 { margin: 0; font-size: 24px; color: var(--primary-navy); font-weight: 700; }
        .status-badge { display: inline-block; padding: 6px 12px; background: #e3f2fd; color: #1a3b6e; border-radius: 20px; font-size: 11px; font-weight: 700; text-transform: uppercase; margin-top: 8px; }

        .info-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 40px; }
        .info-row { padding: 10px 0; border-bottom: 1px solid #f9f9f9; }
        .label { font-size: 11px; color: var(--text-grey); font-weight: 700; text-transform: uppercase; display: block; margin-bottom: 4px; }
        .value { font-size: 15px; color: var(--text-dark); font-weight: 600; }

        /* Project Card (Blue Gradient) */
        .card-project { 
            background: linear-gradient(135deg, var(--primary-navy), #2980b9); 
            color: white; padding: 30px; border-radius: 16px; 
            box-shadow: 0 10px 30px rgba(26, 59, 110, 0.3);
            display: flex; flex-direction: column; justify-content: center;
        }
        .card-project h3 { margin: 0 0 20px 0; font-size: 16px; font-weight: 700; border-bottom: 1px solid rgba(255,255,255,0.2); padding-bottom: 10px; }
        .card-project .label { color: rgba(255,255,255,0.7); }
        .card-project .value { color: white; font-size: 18px; }

        /* Stats Card (Small) */
        .card-stat { 
            background: white; padding: 25px; border-radius: 16px; 
            box-shadow: var(--card-shadow); text-align: center; 
            border-left: 5px solid var(--primary-navy);
            transition: transform 0.2s;
        }
        .card-stat:hover { transform: translateY(-5px); }
        .stat-num { font-size: 42px; font-weight: 800; color: var(--primary-navy); margin-bottom: 5px; line-height: 1; }
        .stat-lbl { font-size: 12px; font-weight: 700; color: var(--text-grey); text-transform: uppercase; }

        /* Colors for Stats */
        .bor-blue { border-left-color: #3498db; }
        .bor-green { border-left-color: #2ecc71; }
        .bor-orange { border-left-color: #f39c12; }
        .txt-blue { color: #3498db; }
        .txt-green { color: #2ecc71; }
        .txt-orange { color: #f39c12; }

        #loadingOverlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: white; z-index: 9999; display: flex; flex-direction: column; justify-content: center; align-items: center; color: var(--primary-navy); font-weight: 600; font-size: 20px; }

        @media (max-width: 1024px) {
            .sidebar { position: fixed; left: -280px; height: 100%; }
            .sidebar.active { transform: translateX(280px); }
            .content { padding: 20px; }
            .grid-container { grid-template-columns: 1fr; }
            .card-profile { grid-column: span 1; }
            .toggle-btn { display: block; font-size: 24px; cursor: pointer; margin-right: 15px; }
        }
        @media (min-width: 1025px) { .toggle-btn { display: none; } }
    </style>
</head>
<body>

    <div id="loadingOverlay">
        <div style="font-size: 50px; margin-bottom: 15px;">📊</div>
        <div>Loading Dashboard...</div>
    </div>

    <nav class="sidebar" id="sidebar">
        <div class="sidebar-header">
            <img src="synod_logo.png" alt="Logo" class="sidebar-logo">
            <div class="sidebar-brand">MANAGER PORTAL</div>
        </div>
        <ul class="nav-menu">
            <li class="nav-item"><a href="manager_dashboard.jsp" class="active"><span class="nav-icon">📊</span> Overview</a></li>
            <li class="nav-item"><a href="mark_attendance.jsp"><span class="nav-icon">📍</span> My Attendance</a></li>
            <li class="nav-item"><a href="manage_employees.jsp"><span class="nav-icon">👥</span> Assign Tasks</a></li>
            <li class="nav-item"><a href="admin_task_monitoring.jsp"><span class="nav-icon">📝</span> Task Monitoring</a></li>
            <li class="nav-item"><a href="reports.jsp"><span class="nav-icon">📅</span> View Attendance</a></li>
            <li class="nav-item"><a href="list_of_employees.jsp"><span class="nav-icon">📋</span> Directory</a></li>
            <li class="nav-item"><a href="settings.jsp"><span class="nav-icon">⚙️</span> My Settings</a></li>
        </ul>
        <div class="sidebar-footer">
            <button onclick="logout()" class="btn-logout"><span>🚪</span> Sign Out</button>
        </div>
    </nav>

    <div class="main-content">
        <header class="topbar">
            <div style="display:flex; align-items:center;">
                <div class="toggle-btn" onclick="toggleSidebar()">☰</div>
                <div class="page-title">Manager Dashboard</div>
            </div>
            <div class="user-profile">
                <span id="navEmail">Loading...</span>
                <div class="user-avatar">M</div>
            </div>
        </header>

        <div class="content">
            
            <div class="grid-container">
                <div class="card-profile">
                    <div class="profile-header">
                        <div class="profile-pic" id="avatarLetter">M</div>
                        <div>
                            <h2 id="dispName">Loading...</h2>
                            <span class="status-badge">Manager</span>
                        </div>
                    </div>
                    <div class="info-grid">
                        <div>
                            <div class="info-row"><span class="label">Email Address</span><span class="value" id="dispEmail">-</span></div>
                            <div class="info-row"><span class="label">Phone Number</span><span class="value" id="dispPhone">-</span></div>
                        </div>
                        <div>
                            <div class="info-row"><span class="label">Employee ID</span><span class="value" id="dispEmpId" style="color:var(--primary-navy);">-</span></div>
                            <div class="info-row"><span class="label">Job Role</span><span class="value" id="dispRole">-</span></div>
                        </div>
                    </div>
                </div>

                <div class="card-project">
                    <h3>🚀 My Assignment</h3>
                    <div style="margin-bottom: 20px;">
                        <span class="label">Current Project</span>
                        <div class="value" id="dispProject">-</div>
                    </div>
                    <div>
                        <span class="label">Designation</span>
                        <div class="value" id="dispDesignation">-</div>
                    </div>
                </div>
            </div>

            <div class="grid-container" style="grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));">
                
                <div class="card-stat bor-blue">
                    <div class="stat-num txt-blue" id="empCount">-</div>
                    <div class="stat-lbl">Team Members</div>
                </div>

                <div class="card-stat bor-green">
                    <div class="stat-num txt-green" id="presentCount">-</div>
                    <div class="stat-lbl">Present Today</div>
                </div>

                <div class="card-stat bor-orange">
                    <div class="stat-num txt-orange" id="taskCount">-</div>
                    <div class="stat-lbl">Pending Tasks</div>
                </div>

            </div>

        </div>
    </div>

    <script>
        // CONFIG
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

        // AUTH & LOAD
        auth.onAuthStateChanged(user => {
            if(user) {
                db.collection("users").doc(user.email).get().then(doc => {
                    const d = doc.data();
                    const role = d.role;
                    if(role !== 'admin' && role !== 'manager') {
                        window.location.href = "index.html";
                    } else {
                        loadProfile(user.email, d);
                        loadStats();
                        document.getElementById("loadingOverlay").style.display = "none";
                    }
                });
            } else {
                window.location.href = "index.html";
            }
        });

        // 1. PROFILE LOAD
        function loadProfile(email, d) {
            const val = (v) => (v && v !== "false" && v !== "undefined" && v !== "") ? v : "Not Set";

            document.getElementById("navEmail").innerText = email;
            document.getElementById("avatarLetter").innerText = (d.fullName ? d.fullName.charAt(0) : "M").toUpperCase();
            
            document.getElementById("dispName").innerText = val(d.fullName);
            document.getElementById("dispRole").innerText = val(d.designation);
            document.getElementById("dispEmail").innerText = email;
            document.getElementById("dispPhone").innerText = val(d.contact || d.phone);
            document.getElementById("dispEmpId").innerText = val(d.empId);
            
            document.getElementById("dispProject").innerText = val(d.currentProject);
            document.getElementById("dispDesignation").innerText = val(d.designation);
        }

        // 2. STATS LOAD
        function loadStats() {
            db.collection("users").where("role", "==", "employee").get().then(snap => {
                animateValue("empCount", 0, snap.size, 800);
            });

            db.collection("tasks").where("status", "==", "IN_PROGRESS").get().then(snap => {
                animateValue("taskCount", 0, snap.size, 800);
            });
            
            const today = new Date(); today.setHours(0,0,0,0);
            db.collection("attendance_2025").where("timestamp", ">=", today).get().then(snap => {
                const unique = new Set();
                snap.forEach(doc => unique.add(doc.data().email));
                animateValue("presentCount", 0, unique.size, 800);
            });
        }

        function animateValue(id, start, end, duration) {
            if (start === end) { document.getElementById(id).innerText = end; return; }
            const obj = document.getElementById(id);
            let range = end - start;
            let current = start;
            let increment = end > start ? 1 : -1;
            let stepTime = Math.abs(Math.floor(duration / range));
            let timer = setInterval(function() {
                current += increment;
                obj.innerText = current;
                if (current == end) clearInterval(timer);
            }, stepTime);
        }

        function toggleSidebar() { document.getElementById("sidebar").classList.toggle("active"); }
        function logout() { auth.signOut().then(() => window.location.href = "index.html"); }
    </script>
</body>
</html>