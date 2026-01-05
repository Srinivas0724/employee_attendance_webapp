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
    <title>System Settings - Synod Bioscience</title>
    
    <style>
        /* --- 1. RESET & VARS (NEW THEME) --- */
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        
        :root {
            --primary-navy: #1a3b6e;
            --primary-green: #2ecc71;
            --bg-light: #f4f6f9;
            --text-dark: #333;
            --text-grey: #666;
            --sidebar-width: 260px;
        }

        body { display: flex; height: 100vh; background-color: var(--bg-light); overflow: hidden; }

        /* --- 2. SIDEBAR --- */
        .sidebar {
            width: var(--sidebar-width);
            background-color: var(--primary-navy);
            color: white;
            display: flex;
            flex-direction: column;
            transition: width 0.3s;
            flex-shrink: 0;
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
        }

        /* Top Bar */
        .topbar {
            background: white;
            height: 60px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 0 30px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
            position: sticky; top: 0; z-index: 100;
        }

        .page-title { font-size: 20px; font-weight: bold; color: var(--primary-navy); }
        .user-profile { font-size: 14px; color: var(--text-grey); display: flex; align-items: center; gap: 10px; }
        .user-avatar { width: 35px; height: 35px; background: #e0e0e0; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: bold; color: var(--primary-navy); }

        /* --- 4. PAGE CONTENT --- */
        .content { padding: 30px; max-width: 1200px; margin: 0 auto; width: 100%; display: flex; flex-direction: column; gap: 25px; }

        /* Cards */
        .card { background: white; padding: 30px; border-radius: 10px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); border-top: 4px solid transparent; }
        .card h3 { margin-top: 0; color: var(--primary-navy); border-bottom: 2px solid #f4f6f9; padding-bottom: 15px; margin-bottom: 20px; font-size: 18px; font-weight: bold; }

        /* Card Borders */
        .card-shifts { border-top-color: #3498db; }
        .card-system { border-top-color: #9b59b6; }
        .card-security { border-top-color: #f39c12; }
        .card-users { border-top-color: #2ecc71; }

        /* Grid */
        .grid-row { display: grid; grid-template-columns: repeat(auto-fit, minmax(350px, 1fr)); gap: 25px; }

        /* Forms */
        label { font-weight: 600; font-size: 13px; color: #555; display: block; margin-bottom: 8px; margin-top: 15px; text-transform: uppercase; }
        input, select { width: 100%; padding: 12px; border: 2px solid #f1f1f1; border-radius: 6px; box-sizing: border-box; font-size: 14px; transition: all 0.3s; }
        input:focus, select:focus { border-color: var(--primary-navy); outline: none; background: #fff; }

        /* Buttons */
        button.action-btn { margin-top: 20px; padding: 12px; border: none; border-radius: 6px; cursor: pointer; font-size: 14px; font-weight: 600; transition: background 0.3s; width: 100%; color: white; }
        
        .btn-blue { background: #3498db; }
        .btn-blue:hover { background: #2980b9; }
        
        .btn-green { background: var(--primary-green); }
        .btn-green:hover { background: #27ae60; }
        
        .btn-red { background: #e74c3c; }
        .btn-red:hover { background: #c0392b; }

        /* User List Style */
        .user-list-item { 
            display: flex; justify-content: space-between; align-items: center; 
            padding: 15px; border-bottom: 1px solid #f1f1f1; 
            transition: background 0.2s;
        }
        .user-list-item:hover { background: #fdfdfd; }
        
        .user-info { display: flex; flex-direction: column; gap: 2px; }
        .user-info b { color: #333; font-size: 14px; }
        .user-info span { font-size: 12px; color: #777; }
        
        /* Action Area (Right Side) */
        .user-actions { display: flex; align-items: center; gap: 10px; }

        /* Role Dropdown */
        .role-select {
            padding: 6px 10px; border: 1px solid #ddd; border-radius: 4px;
            font-size: 12px; font-weight: bold; color: #555;
            background-color: #f8f9fa; cursor: pointer; width: auto; margin: 0;
        }
        .role-select:focus { border-color: var(--primary-navy); }

        /* Disable/Enable Button */
        .btn-toggle {
            padding: 7px 12px; border: none; border-radius: 4px;
            font-size: 11px; font-weight: bold; color: white;
            cursor: pointer; text-transform: uppercase; transition: 0.2s;
        }
        .btn-disable { background-color: #e74c3c; } /* Red */
        .btn-disable:hover { background-color: #c0392b; }
        
        .btn-enable { background-color: #2ecc71; } /* Green */
        .btn-enable:hover { background-color: #27ae60; }

        #loadingOverlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: white; z-index: 9999; display: flex; justify-content: center; align-items: center; font-size: 24px; color: #333; flex-direction: column; gap: 10px; }

        /* Responsive */
        @media (max-width: 900px) {
            .sidebar { position: absolute; left: -260px; height: 100%; z-index: 200; }
            .sidebar.open { left: 0; }
            .toggle-btn { display: block; margin-right: 15px; cursor: pointer; font-size: 24px; }
        }
        @media (min-width: 901px) { .toggle-btn { display: none; } }
    </style>

    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-auth-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-firestore-compat.js"></script>
</head>
<body>

    <div id="loadingOverlay">
        <div style="font-size: 40px; margin-bottom: 10px;">⚙️</div>
        <div>Loading System Settings...</div>
    </div>

    <nav class="sidebar" id="sidebar">
        <div class="sidebar-header">
            <img src="synod_logo.png" alt="Synod Logo" class="sidebar-logo">
            <div class="sidebar-brand">ADMIN PORTAL</div>
        </div>

        <ul class="nav-menu">
            <li class="nav-item">
                <a href="admin_homepage.html"><span class="nav-icon">🏠</span> Home</a>
            </li>
            <li class="nav-item">
                <a href="admin_dashboard.jsp"><span class="nav-icon">📊</span> Live Dashboard</a>
            </li>
            <li class="nav-item">
                <a href="manage_employees.jsp"><span class="nav-icon">👥</span> Employees</a>
            </li>
            <li class="nav-item">
                <a href="admin_task_monitoring.jsp"><span class="nav-icon">📝</span> Tasks</a>
            </li>
            <li class="nav-item">
                <a href="admin_attendance.jsp"><span class="nav-icon">📅</span> Attendance</a>
            </li>
            <li class="nav-item">
                <a href="admin_expenses.jsp"><span class="nav-icon">💸</span> Expenses</a>
            </li>
             <li class="nav-item">
                <a href="payroll.jsp" class="active"><span class="nav-icon">💰</span> Payroll</a>
            </li>
            <li class="nav-item">
                <a href="admin_settings.jsp" class="active"><span class="nav-icon">⚙️</span> Settings</a>
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
                <div class="page-title">System Configuration</div>
            </div>
            <div class="user-profile">
                <span id="adminEmail">Loading...</span>
                <div class="user-avatar">A</div>
            </div>
        </header>

        <div class="content">

            <div class="card card-shifts">
                <h3>⏰ Employee Shift Manager</h3>
                <p style="color:#666; font-size:13px; margin-bottom:15px;">
                    Select an employee to define their daily start times. Type "OFF" for holidays. 
                    <br>Format: HH:MM (24-hour) e.g., 09:00, 14:30
                </p>
                
                <select id="shiftEmpSelect" onchange="loadShifts()">
                    <option value="">-- Select Employee to Edit Shift --</option>
                </select>

                <div id="shiftInputs" style="display:none; margin-top:20px;">
                    <div style="display:grid; grid-template-columns: repeat(auto-fit, minmax(100px, 1fr)); gap:15px;">
                        <div><label>Mon</label><input type="text" id="shift_Mon" placeholder="09:30"></div>
                        <div><label>Tue</label><input type="text" id="shift_Tue" placeholder="09:30"></div>
                        <div><label>Wed</label><input type="text" id="shift_Wed" placeholder="09:30"></div>
                        <div><label>Thu</label><input type="text" id="shift_Thu" placeholder="09:30"></div>
                        <div><label>Fri</label><input type="text" id="shift_Fri" placeholder="09:30"></div>
                        <div><label>Sat</label><input type="text" id="shift_Sat" placeholder="09:30"></div>
                        <div><label>Sun</label><input type="text" id="shift_Sun" placeholder="OFF"></div>
                    </div>
                    <button class="action-btn btn-blue" onclick="saveShifts()">💾 Save Shift Timings</button>
                </div>
            </div>

            <div class="grid-row">
                
                <div class="card card-system">
                    <h3>⚙️ System Preferences</h3>
                    <label>Company Name</label>
                    <input type="text" id="companyName" value="Synod Bioscience">
                    
                    <button class="action-btn btn-green" onclick="alert('Company Name Updated!')">Update Info</button>

                    <label style="margin-top:25px;">Public Registration</label>
                    <button class="action-btn btn-red" onclick="toggleReg()">🚫 Disable New Signups</button>
                </div>

                <div class="card card-security">
                    <h3>🔐 Admin Security</h3>
                    <label>New Password</label>
                    <input type="password" id="newPass" placeholder="New password">
                    
                    <label>Confirm Password</label>
                    <input type="password" id="confirmPass" placeholder="Confirm password">
                    
                    <button class="action-btn btn-green" onclick="changeAdminPass()">Update Password</button>
                </div>

            </div>

            <div class="card card-users">
                <h3>👥 Active Users & Roles</h3>
                <p style="color:#666; font-size:13px; margin-bottom:15px;">
                    Use the controls below to manage access or disable accounts instantly.
                </p>
                
                <div id="usersList" style="max-height: 400px; overflow-y: auto; border:1px solid #f1f1f1; border-radius:6px;">
                    <div style="text-align:center; padding:20px; color:#999;">Loading users...</div>
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

        // --- 2. AUTH CHECK ---
        auth.onAuthStateChanged(user => {
            if (user) {
                document.getElementById("adminEmail").innerText = user.email;
                loadEmployeeList();
                document.getElementById("loadingOverlay").style.display = "none";
            } else {
                window.location.replace("login.jsp");
            }
        });

        // --- 3. LOAD USERS ---
        function loadEmployeeList() {
            const select = document.getElementById("shiftEmpSelect");
            const listDiv = document.getElementById("usersList");
            
            listDiv.innerHTML = "";
            select.innerHTML = '<option value="">-- Select Employee to Edit Shift --</option>';

            db.collection("users").get().then(snap => {
                snap.forEach(doc => {
                    const data = doc.data();
                    const email = doc.id;
                    const role = data.role || "employee";
                    const status = data.status || "Active"; // Default to Active
                    
                    // 1. Shift Dropdown (Skip admins if desired)
                    if(role !== 'admin') {
                        const opt = document.createElement("option");
                        opt.value = email;
                        opt.innerText = data.fullName + " (" + email + ")";
                        select.appendChild(opt);
                    }

                    // 2. User List Item
                    let isEmp = (role === 'employee') ? 'selected' : '';
                    let isAdmin = (role === 'admin') ? 'selected' : '';

                    // Role Select
                    let roleSelect = "<select onchange=\"updateRole('" + email + "', this.value)\" class='role-select'>";
                    roleSelect += "<option value='employee' " + isEmp + ">Employee</option>";
                    roleSelect += "<option value='admin' " + isAdmin + ">Admin</option>";
                    roleSelect += "</select>";

                    // Disable Button Logic
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
                        "<div class='user-actions'>" + roleSelect + btnHtml + "</div>";
                    
                    listDiv.appendChild(row);
                });
            });
        }

        // --- 4. UPDATE ROLE ---
        function updateRole(email, newRole) {
            if(!confirm("Change " + email + " to " + newRole.toUpperCase() + "?")) {
                loadEmployeeList(); 
                return;
            }

            db.collection("users").doc(email).update({
                role: newRole
            }).then(() => {
                alert("✅ Role Updated!");
            }).catch(e => {
                alert("Error: " + e.message);
                loadEmployeeList();
            });
        }

        // --- 5. TOGGLE STATUS (DISABLE/ENABLE) ---
        function toggleUserStatus(email, newStatus) {
            let action = (newStatus === 'Active') ? "ENABLE" : "DISABLE";
            if(!confirm("Are you sure you want to " + action + " this user account?")) return;

            db.collection("users").doc(email).update({
                status: newStatus
            }).then(() => {
                alert("✅ Account " + (newStatus === 'Active' ? "Enabled" : "Disabled"));
                loadEmployeeList(); // Refresh list to update button color
            }).catch(e => alert("Error: " + e.message));
        }

        // --- 6. SHIFT MGMT ---
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
                alert("✅ Shift Timings Updated for " + email);
            });
        }

        // --- 7. ADMIN SECURITY ---
        function changeAdminPass() {
            const p1 = document.getElementById("newPass").value;
            const p2 = document.getElementById("confirmPass").value;
            
            if(p1.length < 6) { alert("Password too short."); return; }
            if(p1 !== p2) { alert("Passwords do not match."); return; }

            auth.currentUser.updatePassword(p1).then(() => {
                alert("Password Updated! Please login again.");
                logout();
            }).catch(e => alert("Error: " + e.message));
        }

        function toggleReg() {
            alert("This feature requires backend configuration.");
        }

        function logout(){
            auth.signOut().then(() => window.location.href = "index.html");
        }
        
        function toggleSidebar() {
            document.getElementById("sidebar").classList.toggle("open");
        }
    </script>
</body>
</html>