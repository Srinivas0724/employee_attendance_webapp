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
    
    <style>
        /* --- 1. RESET & VARS --- */
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        
        :root {
            --primary-navy: #1a3b6e;
            --primary-dark: #122b52;
            --primary-green: #2ecc71;
            --primary-green-dark: #27ae60;
            --bg-light: #f0f2f5;
            --text-dark: #2c3e50;
            --text-grey: #7f8c8d;
            --card-shadow: 0 10px 30px rgba(0,0,0,0.08);
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

        /* --- 4. DASHBOARD GRID --- */
        .content { 
            padding: 40px; 
            max-width: 1400px; 
            margin: 0 auto; 
            width: 100%; 
        }

        .grid-cards { 
            display: grid; 
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); 
            gap: 30px; 
            margin-bottom: 50px; 
        }
        
        .card { 
            background: white; 
            padding: 30px; 
            border-radius: 16px; 
            box-shadow: var(--card-shadow); 
            border-left: 6px solid var(--primary-navy); 
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }
        
        .card:hover { 
            transform: translateY(-8px); 
            box-shadow: 0 15px 35px rgba(0,0,0,0.12); 
        }
        
        /* Card Decoration Circle */
        .card::after {
            content: '';
            position: absolute;
            top: -20px; right: -20px;
            width: 100px; height: 100px;
            border-radius: 50%;
            background: rgba(0,0,0,0.03);
            z-index: 0;
        }

        .card h3 { 
            margin: 0; 
            font-size: 15px; 
            color: var(--text-grey); 
            text-transform: uppercase; 
            font-weight: 700;
            letter-spacing: 0.5px;
            position: relative; z-index: 1;
        }
        
        .card .number { 
            font-size: 48px; 
            font-weight: 800; 
            color: var(--primary-navy); 
            margin: 15px 0;
            line-height: 1;
            position: relative; z-index: 1;
        }
        
        .card .sub-text { 
            font-size: 13px; 
            color: var(--text-dark); 
            font-weight: 500;
            display: flex; align-items: center; gap: 5px;
            position: relative; z-index: 1;
        }

        /* Welcome Section */
        .welcome-section {
            text-align: center;
            margin-top: 60px;
            padding: 40px;
            background: white;
            border-radius: 20px;
            box-shadow: var(--card-shadow);
        }
        .welcome-icon { font-size: 60px; margin-bottom: 15px; display: block; animation: float 3s ease-in-out infinite; }
        .welcome-title { font-size: 24px; color: var(--primary-navy); margin-bottom: 10px; font-weight: 700; }
        .welcome-desc { color: var(--text-grey); max-width: 500px; margin: 0 auto; line-height: 1.6; }

        @keyframes float {
            0% { transform: translateY(0px); }
            50% { transform: translateY(-10px); }
            100% { transform: translateY(0px); }
        }

        /* Loader */
        #loadingOverlay { 
            position: fixed; top: 0; left: 0; width: 100%; height: 100%; 
            background: rgba(255,255,255,0.8); 
            backdrop-filter: blur(5px);
            z-index: 9999; 
            display: flex; justify-content: center; align-items: center; 
            font-size: 24px; color: var(--primary-navy); 
            flex-direction: column; gap: 15px; 
            font-weight: 600;
        }

        @media (max-width: 900px) {
            .sidebar { position: fixed; left: -280px; height: 100%; }
            .sidebar.active { transform: translateX(280px); }
            .content { padding: 20px; }
            .topbar { padding: 0 20px; }
        }
    </style>

    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-auth-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-firestore-compat.js"></script>
</head>
<body>

    <div id="loadingOverlay">
        <div style="font-size: 50px;">📊</div>
        <div>Initializing Dashboard...</div>
    </div>

    <nav class="sidebar" id="sidebar">
        <div class="sidebar-header">
            <img src="synod_logo.png" alt="Synod Logo" class="sidebar-logo">
            <div class="sidebar-brand">MANAGER PORTAL</div>
        </div>

        <ul class="nav-menu">
            <li class="nav-item">
                <a href="manager_dashboard.jsp" class="active"><span class="nav-icon">📊</span> Overview</a>
            </li>
            <li class="nav-item">
                <a href="manager_mark_attendance.jsp"><span class="nav-icon">📍</span> My Attendance</a>
            </li>
            <li class="nav-item">
                <a href="manager_manage_employees.jsp"><span class="nav-icon">👥</span> Assign Tasks</a>
            </li>
            <li class="nav-item">
                <a href="manager_task_monitoring.jsp"><span class="nav-icon">📝</span> Task Monitoring</a>
            </li>
            <li class="nav-item">
                <a href="manager_report.jsp"><span class="nav-icon">📅</span> View Attendance</a>
            </li>
            <li class="nav-item">
                <a href="manager_settings.jsp"><span class="nav-icon">⚙️</span> My Settings</a>
            </li>
        </ul>

        <div class="sidebar-footer">
            <button onclick="logout()" class="btn-logout"><span>🚪</span> Sign Out</button>
        </div>
    </nav>

    <div class="main-content">
        <header class="topbar">
            <div class="page-title">Manager Overview</div>
            <div class="user-profile">
                <span id="userEmail" class="user-email">Loading...</span>
                <div class="user-avatar">M</div>
            </div>
        </header>

        <div class="content">
            
            <div class="grid-cards">
                <div class="card" style="border-left-color: #3498db;">
                    <h3>Total Employees</h3>
                    <div class="number" id="empCount">-</div>
                    <div class="sub-text">
                        <span style="color:#3498db;">●</span> Active Staff Members
                    </div>
                </div>

                <div class="card" style="border-left-color: #2ecc71;">
                    <h3>Present Today</h3>
                    <div class="number" id="presentCount">-</div>
                    <div class="sub-text">
                        <span style="color:#2ecc71;">●</span> Checked In
                    </div>
                </div>

                <div class="card" style="border-left-color: #f39c12;">
                    <h3>Pending Tasks</h3>
                    <div class="number" id="taskCount">-</div>
                    <div class="sub-text">
                        <span style="color:#f39c12;">●</span> Need Review
                    </div>
                </div>
            </div>
            
            <div class="welcome-section">
                <span class="welcome-icon">👋</span>
                <div class="welcome-title">Welcome back, Manager!</div>
                <div class="welcome-desc">
                    Use the sidebar to manage your team effectively. You can track attendance, assign tasks, and monitor project progress all from one place.
                </div>
            </div>

        </div>
    </div>

    <script>
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

        auth.onAuthStateChanged(user => {
            if(user) {
                db.collection("users").doc(user.email).get().then(doc => {
                    const role = doc.data().role;
                    // Allow both Admin AND Manager here
                    if(role !== 'admin' && role !== 'manager') {
                        window.location.href = "index.html";
                    } else {
                        document.getElementById("userEmail").innerText = user.email;
                        document.getElementById("loadingOverlay").style.display = "none";
                        loadStats();
                    }
                });
            } else {
                window.location.href = "index.html";
            }
        });

        function loadStats() {
            // Count Employees
            db.collection("users").where("role", "==", "employee").get().then(snap => {
                animateValue("empCount", 0, snap.size, 1000);
            });

            // Count Pending Tasks
            db.collection("tasks").where("status", "==", "IN_PROGRESS").get().then(snap => {
                animateValue("taskCount", 0, snap.size, 1000);
            });
            
            // Count Present Today
            const today = new Date(); today.setHours(0,0,0,0);
            db.collection("attendance_2025").where("timestamp", ">=", today).get().then(snap => {
                // Using a Set to count unique emails to avoid double counting multiple punches
                const uniqueAttendees = new Set();
                snap.forEach(doc => uniqueAttendees.add(doc.data().email));
                animateValue("presentCount", 0, uniqueAttendees.size, 1000);
            });
        }

        // Simple number animation utility
        function animateValue(id, start, end, duration) {
            const obj = document.getElementById(id);
            if (start === end) { obj.innerText = end; return; }
            let range = end - start;
            let current = start;
            let increment = end > start ? 1 : -1;
            let stepTime = Math.abs(Math.floor(duration / range));
            let timer = setInterval(function() {
                current += increment;
                obj.innerText = current;
                if (current == end) {
                    clearInterval(timer);
                }
            }, stepTime);
        }

        function logout() { auth.signOut().then(() => window.location.href = "index.html"); }
    </script>
</body>
</html>