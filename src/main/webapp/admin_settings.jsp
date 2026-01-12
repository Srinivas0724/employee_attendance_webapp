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

        .content { padding: 30px 40px; max-width: 1600px; margin: 0 auto; width: 100%; display: flex; flex-direction: column; gap: 30px; }

        /* --- 4. LAYOUT GRID --- */
        .grid-row { display: grid; grid-template-columns: repeat(auto-fit, minmax(400px, 1fr)); gap: 30px; }

        /* --- 5. CARDS --- */
        .card { background: white; padding: 30px; border-radius: 16px; box-shadow: var(--card-shadow); border: 1px solid white; display: flex; flex-direction: column; }
        .card h3 { margin: 0 0 15px 0; font-size: 18px; font-weight: 700; color: var(--primary-navy); border-bottom: 1px solid #f0f0f0; padding-bottom: 15px; }
        .card-desc { font-size: 13px; color: var(--text-grey); margin-bottom: 20px; line-height: 1.5; }

        /* Forms */
        label { display: block; font-size: 12px; font-weight: 700; color: var(--text-dark); margin-bottom: 6px; text-transform: uppercase; letter-spacing: 0.5px; }
        input, select { width: 100%; padding: 12px; border: 1px solid #e0e0e0; border-radius: 8px; font-size: 14px; background: #f9f9f9; transition: 0.2s; margin-bottom: 15px; }
        input:focus, select:focus { border-color: var(--primary-navy); background: white; outline: none; box-shadow: 0 0 0 3px rgba(26, 59, 110, 0.1); }

        /* Shift Grid */
        .shift-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(80px, 1fr)); gap: 15px; margin-top: 15px; }
        .shift-grid div label { font-size: 11px; margin-bottom: 4px; color: var(--text-grey); }
        .shift-grid input { text-align: center; font-weight: 600; padding: 10px; margin-bottom: 0; }

        /* Buttons */
        .btn-action { width: 100%; padding: 12px; border: none; border-radius: 8px; cursor: pointer; font-size: 14px; font-weight: 700; transition: 0.2s; color: white; margin-top: 10px; }
        .btn-blue { background: var(--primary-navy); box-shadow: 0 4px 10px rgba(26, 59, 110, 0.3); }
        .btn-blue:hover { background: #132c52; transform: translateY(-2px); }
        .btn-green { background: var(--primary-green); box-shadow: 0 4px 10px rgba(46, 204, 113, 0.3); }
        .btn-green:hover { background: #27ae60; transform: translateY(-2px); }
        .btn-red { background: #e74c3c; box-shadow: 0 4px 10px rgba(231, 76, 60, 0.3); }
        .btn-red:hover { background: #c0392b; transform: translateY(-2px); }

        /* User List */
        .user-list-container { max-height: 400px; overflow-y: auto; border: 1px solid #f0f0f0; border-radius: 12px; }
        .user-list-item { display: flex; justify-content: space-between; align-items: center; padding: 15px; border-bottom: 1px solid #f0f0f0; transition: 0.2s; }
        .user-list-item:last-child { border-bottom: none; }
        .user-list-item:hover { background: #f9f9f9; }
        
        .user-info b { font-size: 14px; color: var(--text-dark); display: block; }
        .user-info span { font-size: 12px; color: var(--text-grey); }
        
        .user-actions { display: flex; gap: 10px; align-items: center; }
        .role-select { padding: 6px 12px; margin: 0; font-size: 12px; width: auto; font-weight: 600; }
        
        .btn-toggle { padding: 6px 12px; border-radius: 6px; border: none; font-size: 11px; font-weight: 700; text-transform: uppercase; cursor: pointer; color: white; }
        .btn-enable { background: var(--primary-green); }
        .btn-disable { background: #e74c3c; }

        #loadingOverlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: white; z-index: 9999; display: flex; flex-direction: column; justify-content: center; align-items: center; color: var(--primary-navy); font-weight: 600; }

        @media (max-width: 1024px) {
            .sidebar { position: fixed; left: -280px; height: 100%; }
            .sidebar.active { transform: translateX(280px); }
            .toggle-btn { display: block; font-size: 24px; cursor: pointer; margin-right: 15px; }
            .content { padding: 20px; }
        }
        @media (min-width: 1025px) { .toggle-btn { display: none; } }
    </style>
</head>
<body>

    <div id="loadingOverlay">
        <div style="font-size: 50px;">⚙️</div>
        <div style="margin-top:15px;">Loading Configuration...</div>
    </div>

    <nav class="sidebar" id="sidebar">
        <div class="sidebar-header">
            <img src="synod_logo.png" alt="Logo" class="sidebar-logo">
            <div class="sidebar-brand">ADMIN PORTAL</div>
        </div>
        <ul class="nav-menu">
            <li class="nav-item"><a href="admin_homepage.html"><span class="nav-icon">🏠</span> Home</a></li>
            <li class="nav-item"><a href="admin_dashboard.jsp"><span class="nav-icon">📊</span> Live Dashboard</a></li>
            <li class="nav-item"><a href="manage_employees.jsp"><span class="nav-icon">👥</span> Employees</a></li>
            <li class="nav-item"><a href="admin_task_monitoring.jsp"><span class="nav-icon">📝</span> Tasks</a></li>
            <li class="nav-item"><a href="reports.jsp"><span class="nav-icon">📅</span> Attendance</a></li>
            <li class="nav-item"><a href="admin_expenses.jsp"><span class="nav-icon">💸</span> Expenses</a></li>
            <li class="nav-item"><a href="payroll.jsp"><span class="nav-icon">💰</span> Payroll</a></li>
            <li class="nav-item"><a href="admin_settings.jsp" class="active"><span class="nav-icon">⚙️</span> Settings</a></li>
        </ul>
        <div class="sidebar-footer">
            <button onclick="logout()" class="btn-logout"><span>🚪</span> Sign Out</button>
        </div>
    </nav>

    <div class="main-content">
        <header class="topbar">
            <div style="display:flex; align-items:center;">
                <div class="toggle-btn" onclick="toggleSidebar()">☰</div>
                <div class="page-title">System Settings</div>
            </div>
            <div class="user-profile">
                <span id="adminEmail">Loading...</span>
                <div class="user-avatar">A</div>
            </div>
        </header>

        <div class="content">

            <div class="card">
                <h3>⏰ Employee Shift Manager</h3>
                <p class="card-desc">Select an employee to define their daily start times. Type <strong>"OFF"</strong> for weekends/holidays.</p>
                
                <select id="shiftEmpSelect" onchange="loadShifts()">
                    <option value="">-- Select Employee --</option>
                </select>

                <div id="shiftInputs" style="display:none;">
                    <div class="shift-grid">
                        <div><label>Mon</label><input type="text" id="shift_Mon" placeholder="09:30"></div>
                        <div><label>Tue</label><input type="text" id="shift_Tue" placeholder="09:30"></div>
                        <div><label>Wed</label><input type="text" id="shift_Wed" placeholder="09:30"></div>
                        <div><label>Thu</label><input type="text" id="shift_Thu" placeholder="09:30"></div>
                        <div><label>Fri</label><input type="text" id="shift_Fri" placeholder="09:30"></div>
                        <div><label>Sat</label><input type="text" id="shift_Sat" placeholder="OFF"></div>
                        <div><label>Sun</label><input type="text" id="shift_Sun" placeholder="OFF"></div>
                    </div>
                    <button class="btn-action btn-blue" onclick="saveShifts()">💾 Save Shift Timings</button>
                </div>
            </div>

            <div class="grid-row">
                <div class="card">
                    <h3>⚙️ System Preferences</h3>
                    <label>Company Name</label>
                    <input type="text" id="companyName" value="Synod Bioscience">
                    <button class="btn-action btn-green" onclick="alert('Company Name Updated!')">Update Info</button>
                    
                    <label style="margin-top:20px;">Registration Access</label>
                    <button class="btn-action btn-red" onclick="alert('This requires backend configuration.')">🚫 Disable New Signups</button>
                </div>

                <div class="card">
                    <h3>🔐 Admin Security</h3>
                    <label>New Password</label>
                    <input type="password" id="newPass" placeholder="New password">
                    
                    <label>Confirm Password</label>
                    <input type="password" id="confirmPass" placeholder="Confirm password">
                    
                    <button class="btn-action btn-blue" onclick="changeAdminPass()">Update Password</button>
                </div>
            </div>

            <div class="card">
                <h3>👥 Active Users & Roles</h3>
                <p class="card-desc">Manage system access, update roles, or disable employee accounts.</p>
                <div id="usersList" class="user-list-container">
                    <div style="text-align:center; padding:30px; color:#999;">Loading users...</div>
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
        db.collection("users").doc(user.email).get().then(doc => {
            if (doc.exists) {
                const role = doc.data().role;
                
                // 1. CHECK ACCESS: Allow Admin OR Manager
                if (role !== 'admin' && role !== 'manager') {
                    window.location.href = "index.html"; // Kick out employees
                    return;
                }

                // 2. LOAD USER INFO
                if(document.getElementById("adminEmail")) {
                     document.getElementById("adminEmail").innerText = user.email;
                }
                
                // 3. IF MANAGER -> HIDE RESTRICTED SIDEBAR LINKS
                if (role === 'manager') {
                    // Change Brand Name
                    const brand = document.querySelector('.sidebar-brand');
                    if(brand) brand.innerText = "MANAGER PORTAL";

                    // Hide Expenses Link (Find by href)
                    const expLink = document.querySelector('a[href="admin_expenses.jsp"]');
                    if(expLink && expLink.parentElement) expLink.parentElement.style.display = 'none';

                    // Hide Payroll Link
                    const payLink = document.querySelector('a[href="payroll.jsp"]');
                    if(payLink && payLink.parentElement) payLink.parentElement.style.display = 'none';
                }

                // 4. LOAD PAGE DATA (Call your page's load function)
                // Note: Ensure the specific page's load function exists (e.g., loadEmployees(), loadTasks())
                // You might need to check which page you are on, or just let the existing code run below this block.
                if(typeof loadEmployeeList === "function") loadEmployeeList();
                if(typeof loadTasks === "function") loadTasks();
                if(typeof loadAttendance === "function") loadAttendance();
                
                // Hide Loader
                const loader = document.getElementById("loadingOverlay");
                if(loader) loader.style.display = "none";
            }
        });
    } else {
        window.location.replace("index.html");
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
                    roleSelect += "<option value='manager' " + (role === 'manager' ? 'selected' : '') + ">Manager</option>"; 
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