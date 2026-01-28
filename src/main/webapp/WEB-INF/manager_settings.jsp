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
    <title>Manager Settings - Synod Bioscience</title>
    
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

        /* --- 4. PAGE CONTENT --- */
        .content { padding: 40px; max-width: 1200px; margin: 0 auto; width: 100%; display: flex; flex-direction: column; gap: 30px; }

        /* Cards */
        .card { 
            background: white; 
            padding: 30px; 
            border-radius: 16px; 
            box-shadow: var(--card-shadow); 
            border-top: 4px solid transparent; 
        }
        
        .card h3 { 
            margin-top: 0; 
            color: var(--primary-navy); 
            border-bottom: 1px solid #f1f1f1; 
            padding-bottom: 15px; 
            margin-bottom: 25px; 
            font-size: 18px; 
            font-weight: 700; 
        }

        /* Card Borders */
        .card-shifts { border-top-color: #3498db; }
        .card-security { border-top-color: #f39c12; }
        .card-users { border-top-color: #2ecc71; }

        /* Grid Layout */
        .grid-row { display: grid; grid-template-columns: 1.2fr 0.8fr; gap: 30px; }

        /* Forms */
        label { 
            font-weight: 600; font-size: 13px; color: var(--text-dark); 
            display: block; margin-bottom: 8px; margin-top: 20px; text-transform: uppercase; letter-spacing: 0.5px;
        }
        
        input, select { 
            width: 100%; padding: 12px 15px; 
            border: 1px solid #e0e0e0; border-radius: 8px; 
            box-sizing: border-box; font-size: 14px; 
            transition: all 0.3s; background: #fdfdfd;
        }
        
        input:focus, select:focus { 
            border-color: var(--primary-navy); outline: none; background: white; 
            box-shadow: 0 0 0 3px rgba(26, 59, 110, 0.1);
        }

        /* Buttons */
        button.action-btn { 
            margin-top: 25px; padding: 12px; width: 100%; color: white; border: none; 
            border-radius: 8px; font-weight: 600; cursor: pointer; transition: all 0.2s; 
            font-size: 14px; 
        }
        
        .btn-blue { background: #3498db; box-shadow: 0 4px 10px rgba(52, 152, 219, 0.3); }
        .btn-blue:hover { background: #2980b9; transform: translateY(-2px); }
        
        .btn-green { background: var(--primary-green); box-shadow: 0 4px 10px rgba(46, 204, 113, 0.3); }
        .btn-green:hover { background: #27ae60; transform: translateY(-2px); }
        
        .btn-red { background: #e74c3c; box-shadow: 0 4px 10px rgba(231, 76, 60, 0.3); }
        .btn-red:hover { background: #c0392b; transform: translateY(-2px); }

        /* User List Style */
        .user-list-item { 
            display: flex; justify-content: space-between; align-items: center; 
            padding: 15px 10px; border-bottom: 1px solid #f1f1f1; 
            transition: background 0.2s; cursor: default;
        }
        .user-list-item:hover { background: #fcfcfc; }
        .user-list-item:last-child { border-bottom: none; }
        
        .user-info { display: flex; flex-direction: column; gap: 3px; }
        .user-info b { color: var(--text-dark); font-size: 14px; font-weight: 600; }
        .user-info span { font-size: 12px; color: var(--text-grey); }
        
        .user-actions { display: flex; align-items: center; gap: 10px; }

        /* Toggle Button */
        .btn-toggle {
            padding: 6px 12px; border: none; border-radius: 6px;
            font-size: 11px; font-weight: 700; color: white;
            cursor: pointer; text-transform: uppercase; transition: all 0.2s;
        }
        .btn-disable { background-color: #e74c3c; } 
        .btn-disable:hover { background-color: #c0392b; }
        .btn-enable { background-color: #2ecc71; } 
        .btn-enable:hover { background-color: #27ae60; }

        #loadingOverlay { 
            position: fixed; top: 0; left: 0; width: 100%; height: 100%; 
            background: rgba(255,255,255,0.8); backdrop-filter: blur(5px);
            z-index: 9999; display: flex; justify-content: center; align-items: center; 
            font-size: 24px; color: var(--primary-navy); flex-direction: column; gap: 15px; font-weight: 600;
        }

        /* Responsive */
        @media (max-width: 900px) {
            .sidebar { position: fixed; left: -280px; height: 100%; }
            .sidebar.active { transform: translateX(280px); }
            .content { padding: 20px; }
            .topbar { padding: 0 20px; }
            .toggle-btn { display: block; font-size: 24px; cursor: pointer; margin-right: 15px; }
            .grid-row { grid-template-columns: 1fr; }
        }
        @media (min-width: 901px) { .toggle-btn { display: none; } }
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

    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-auth-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-firestore-compat.js"></script>
</head>
<body>

    <div id="loadingOverlay">
        <div style="font-size: 50px;">⚙️</div>
        <div>Loading Manager Settings...</div>
    </div>

    <nav class="sidebar" id="sidebar">
        <div class="sidebar-header">
            <img src="synod_logo.png" alt="Synod Logo" class="sidebar-logo">
            <div class="sidebar-brand">MANAGER PORTAL</div>
        </div>

        <ul class="nav-menu">
            <li class="nav-item"><a href="manager_dashboard.jsp"><span class="nav-icon">📊</span> Overview</a></li>
            <li class="nav-item"><a href="manager_mark_attendance.jsp"><span class="nav-icon">📍</span> My Attendance</a></li>
            <li class="nav-item"><a href="manager_manage_employees.jsp"><span class="nav-icon">👥</span> Assign Tasks</a></li>
            <li class="nav-item"><a href="manager_task_monitoring.jsp"><span class="nav-icon">📝</span> Task Monitoring</a></li>
            <li class="nav-item"><a href="manager_report.jsp"><span class="nav-icon">📅</span> View Attendance</a></li>
            <li class="nav-item"><a href="manager_list_of_employees.jsp"><span class="nav-icon">📋</span> Directory</a></li>
            <li class="nav-item"><a href="manager_settings.jsp" class="active"><span class="nav-icon">⚙️</span> My Settings</a></li>
        </ul>

        <div class="sidebar-footer">
            <button onclick="logout()" class="btn-logout"><span>🚪</span> Sign Out</button>
        </div>
    </nav>

    <div class="main-content">
        <header class="topbar">
            <div style="display:flex; align-items:center;">
                <div class="toggle-btn" onclick="toggleSidebar()">☰</div>
                <div class="page-title">Manager Configuration</div>
            </div>
            <div class="user-profile">
                <span id="mgrEmail" class="user-email">Loading...</span>
                <div class="user-avatar">M</div>
            </div>
        </header>

        <div class="content">

            <div class="grid-row">
                
                <div class="card card-shifts">
                    <h3>⏰ Manage Employee Shifts</h3>
                    <p style="color:var(--text-grey); font-size:13px; margin-bottom:20px; line-height:1.5;">
                        Select an employee to edit their daily start timings. 
                        <br>Format: HH:MM (24-hour). Type "OFF" for holidays.
                    </p>
                    
                    <select id="shiftEmpSelect" onchange="loadShifts()">
                        <option value="">-- Select Employee --</option>
                    </select>

                    <div id="shiftInputs" style="display:none; margin-top:25px;">
                        <div style="display:grid; grid-template-columns: repeat(auto-fit, minmax(80px, 1fr)); gap:15px;">
                            <div><label style="margin-top:0;">Mon</label><input type="text" id="shift_Mon" placeholder="09:30"></div>
                            <div><label style="margin-top:0;">Tue</label><input type="text" id="shift_Tue" placeholder="09:30"></div>
                            <div><label style="margin-top:0;">Wed</label><input type="text" id="shift_Wed" placeholder="09:30"></div>
                            <div><label style="margin-top:0;">Thu</label><input type="text" id="shift_Thu" placeholder="09:30"></div>
                            <div><label style="margin-top:0;">Fri</label><input type="text" id="shift_Fri" placeholder="09:30"></div>
                            <div><label style="margin-top:0;">Sat</label><input type="text" id="shift_Sat" placeholder="09:30"></div>
                            <div><label style="margin-top:0;">Sun</label><input type="text" id="shift_Sun" placeholder="OFF"></div>
                        </div>
                        <button class="action-btn btn-blue" onclick="saveShifts()">💾 Save Shifts</button>
                    </div>
                </div>

                <div class="card card-security">
                    <h3>🔐 Change My Password</h3>
                    <label>New Password</label>
                    <input type="password" id="newPass" placeholder="Enter new password">
                    
                    <label>Confirm Password</label>
                    <input type="password" id="confirmPass" placeholder="Re-enter password">
                    
                    <button class="action-btn btn-green" onclick="changeManagerPass()">Update Password</button>
                </div>

            </div>

            <div class="card card-users">
                <h3>👥 Employee Access Control</h3>
                <p style="color:var(--text-grey); font-size:13px; margin-bottom:20px;">
                    Disable access for employees only. You cannot modify Admin or other Manager accounts.
                </p>
                
                <div id="usersList" style="max-height: 400px; overflow-y: auto; border:1px solid #e9ecef; border-radius:10px;">
                    <div style="text-align:center; padding:30px; color:#999;">Loading users...</div>
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
            if (user) {
                db.collection("users").doc(user.email).get().then(doc => {
                    const role = doc.data().role;
                    if (role !== 'manager' && role !== 'admin') {
                        window.location.href = "login.jsp";
                        return;
                    } 
                    document.getElementById("mgrEmail").innerText = user.email;
                    document.getElementById("loadingOverlay").style.display = "none";
                    loadEmployeeList();
                });
            } else {
                window.location.replace("index.html");
            }
        });

        function loadEmployeeList() {
            const select = document.getElementById("shiftEmpSelect");
            const listDiv = document.getElementById("usersList");
            
            listDiv.innerHTML = "";
            select.innerHTML = '<option value="">-- Select Employee --</option>';

            db.collection("users").get().then(snap => {
                let foundUsers = false;
                snap.forEach(doc => {
                    const data = doc.data();
                    const email = doc.id;
                    const role = data.role || "employee";
                    const status = data.status || "Active";
                    
                    if(role === 'employee') {
                        foundUsers = true;
                        
                        const opt = document.createElement("option");
                        opt.value = email;
                        opt.innerText = data.fullName + " (" + email + ")";
                        select.appendChild(opt);

                        let btnHtml = "";
                        if(status === 'Disabled') {
                            btnHtml = "<button class='btn-toggle btn-enable' onclick=\"toggleUserStatus('" + email + "', 'Active')\">Enable</button>";
                        } else {
                            btnHtml = "<button class='btn-toggle btn-disable' onclick=\"toggleUserStatus('" + email + "', 'Disabled')\">Disable</button>";
                        }

                        const row = document.createElement("div");
                        row.className = "user-list-item";
                        row.innerHTML = 
                            "<div class='user-info'><b>" + (data.fullName || "Unknown") + "</b><span>" + email + "</span></div>" +
                            "<div class='user-actions'>" + btnHtml + "</div>";
                        
                        listDiv.appendChild(row);
                    }
                });

                if(!foundUsers) {
                    listDiv.innerHTML = "<div style='text-align:center; padding:30px; color:#999;'>No employees assigned.</div>";
                }
            });
        }

        function toggleUserStatus(email, newStatus) {
            let action = (newStatus === 'Active') ? "ENABLE" : "DISABLE";
            if(!confirm("Are you sure you want to " + action + " this user account?")) return;

            db.collection("users").doc(email).update({
                status: newStatus
            }).then(() => {
                alert("✅ Account Updated.");
                loadEmployeeList(); 
            }).catch(e => alert("Error: " + e.message));
        }

        function loadShifts() {
            const email = document.getElementById("shiftEmpSelect").value;
            const container = document.getElementById("shiftInputs");
            
            if(!email) {
                container.style.display = "none";
                return;
            }

            container.style.display = "block";
            
            db.collection("users").doc(email).get().then(doc => {
                if(doc.exists) {
                    const s = doc.data().shiftTimings || {};
                    document.getElementById("shift_Mon").value = s.Mon || "09:30";
                    document.getElementById("shift_Tue").value = s.Tue || "09:30";
                    document.getElementById("shift_Wed").value = s.Wed || "09:30";
                    document.getElementById("shift_Thu").value = s.Thu || "09:30";
                    document.getElementById("shift_Fri").value = s.Fri || "09:30";
                    document.getElementById("shift_Sat").value = s.Sat || "09:30";
                    document.getElementById("shift_Sun").value = s.Sun || "OFF";
                }
            });
        }

        function saveShifts() {
            const email = document.getElementById("shiftEmpSelect").value;
            if(!email) return;

            const shifts = {
                Mon: document.getElementById("shift_Mon").value,
                Tue: document.getElementById("shift_Tue").value,
                Wed: document.getElementById("shift_Wed").value,
                Thu: document.getElementById("shift_Thu").value,
                Fri: document.getElementById("shift_Fri").value,
                Sat: document.getElementById("shift_Sat").value,
                Sun: document.getElementById("shift_Sun").value
            };

            db.collection("users").doc(email).update({
                shiftTimings: shifts
            }).then(() => {
                alert("✅ Shift Timings Updated!");
            });
        }

        function changeManagerPass() {
            const p1 = document.getElementById("newPass").value;
            const p2 = document.getElementById("confirmPass").value;
            
            if(p1.length < 6) { alert("Password too short."); return; }
            if(p1 !== p2) { alert("Passwords do not match."); return; }

            auth.currentUser.updatePassword(p1).then(() => {
                alert("Password Updated! Please login again.");
                logout();
            }).catch(e => {
                if(e.code === 'auth/requires-recent-login') {
                    alert("Please Logout and Login again to change password.");
                    logout();
                } else {
                    alert("Error: " + e.message);
                }
            });
        }

        function logout(){ auth.signOut().then(() => window.location.href = "index.html"); }
        function toggleSidebar() { document.getElementById("sidebar").classList.toggle("open"); }
    </script>
</body>
</html>