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
    <title>Employee Directory - Synod Bioscience</title>
    
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

        .content { padding: 30px 40px; max-width: 1600px; margin: 0 auto; width: 100%; }

        /* --- 4. TABLE CARD --- */
        .card { background: white; padding: 30px; border-radius: 16px; box-shadow: var(--card-shadow); display: flex; flex-direction: column; border: 1px solid white; }
        .card-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; border-bottom: 1px solid #f0f0f0; padding-bottom: 15px; }
        .card-title { font-size: 18px; font-weight: 700; color: var(--primary-navy); margin: 0; }
        
        /* Table Styles */
        .table-wrap { overflow-x: auto; border-radius: 8px; border: 1px solid #f0f0f0; }
        table { width: 100%; border-collapse: collapse; min-width: 900px; }
        
        th { background: #f8f9fa; text-align: left; padding: 15px; font-size: 12px; color: var(--text-grey); font-weight: 700; text-transform: uppercase; border-bottom: 2px solid #eee; }
        td { padding: 15px; font-size: 14px; border-bottom: 1px solid #f9f9f9; color: var(--text-dark); vertical-align: middle; }
        tr:hover td { background: #fcfcfc; }

        /* Badges */
        .role-badge { padding: 5px 12px; border-radius: 20px; font-size: 11px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; background: #e3f2fd; color: #1a3b6e; display: inline-block; }
        .missing-data { color: #e74c3c; font-style: italic; font-size: 12px; }

        /* Action Button */
        .btn-edit { 
            background: white; border: 1px solid #e0e0e0; color: var(--text-dark); 
            padding: 8px 16px; border-radius: 8px; cursor: pointer; font-size: 12px; 
            font-weight: 600; display: inline-flex; align-items: center; gap: 6px; 
            transition: all 0.2s ease; text-decoration: none;
        }
        .btn-edit:hover { background: var(--primary-navy); color: white; border-color: var(--primary-navy); transform: translateY(-2px); box-shadow: 0 2px 5px rgba(0,0,0,0.1); }

        /* --- 5. EDIT MODAL --- */
        .modal { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.6); backdrop-filter: blur(4px); z-index: 2000; justify-content: center; align-items: center; }
        .modal-content { background: white; padding: 30px; border-radius: 16px; width: 600px; max-width: 95%; box-shadow: 0 20px 50px rgba(0,0,0,0.2); max-height: 90vh; overflow-y: auto; }
        .modal-header { font-size: 18px; font-weight: 700; margin-bottom: 25px; color: var(--primary-navy); border-bottom: 1px solid #f0f0f0; padding-bottom: 15px; display: flex; justify-content: space-between; align-items: center; }
        
        .row { display: flex; gap: 20px; margin-bottom: 20px; }
        .col { flex: 1; }

        label { display: block; font-size: 12px; font-weight: 700; color: var(--text-dark); margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.5px; }
        input, select { width: 100%; padding: 12px 15px; border: 1px solid #e0e0e0; border-radius: 8px; font-size: 14px; background: #f9f9f9; transition: 0.2s; }
        input:focus, select:focus { border-color: var(--primary-navy); background: white; outline: none; box-shadow: 0 0 0 3px rgba(26, 59, 110, 0.1); }
        .readonly-field { background: #eee; cursor: not-allowed; color: #666; font-weight: 600; }

        .modal-actions { margin-top: 30px; display: flex; gap: 15px; }
        .btn-modal { flex: 1; padding: 14px; border: none; border-radius: 8px; font-weight: 700; font-size: 14px; cursor: pointer; color: white; transition: 0.2s; }
        .btn-save { background: var(--primary-navy); box-shadow: 0 4px 10px rgba(26, 59, 110, 0.3); }
        .btn-save:hover { background: #132c52; transform: translateY(-2px); }
        .btn-cancel { background: #95a5a6; }
        .btn-cancel:hover { background: #7f8c8d; }
        .close-btn { background: none; border: none; font-size: 24px; cursor: pointer; color: #999; }

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
        <div style="font-size: 50px;">👥</div>
        <div style="margin-top:15px;">Loading Directory...</div>
    </div>

    <nav class="sidebar" id="sidebar">
        <div class="sidebar-header">
            <img src="synod_logo.png" alt="Logo" class="sidebar-logo">
            <div class="sidebar-brand">ADMIN PORTAL</div>
        </div>

        <ul class="nav-menu">
            <li class="nav-item"><a href="manager_dashboard.jsp"><span class="nav-icon">📊</span> Overview</a></li>
            <li class="nav-item"><a href="manager_mark_attendance.jsp"><span class="nav-icon">📍</span> My Attendance</a></li>
            <li class="nav-item"><a href="manager_manage_employees.jsp"><span class="nav-icon">👥</span> Assign Tasks</a></li>
            <li class="nav-item"><a href="manager_task_monitoring.jsp"><span class="nav-icon">📝</span> Task Monitoring</a></li>
            <li class="nav-item"><a href="manager_report.jsp"><span class="nav-icon">📅</span> View Attendance</a></li>
            <li class="nav-item"><a href="manager_list_of_employees.jsp" class="active"><span class="nav-icon">📋</span> Directory</a></li>
            <li class="nav-item"><a href="manager_settings.jsp"><span class="nav-icon">⚙️</span> My Settings</a></li>
        </ul>

        <div class="sidebar-footer">
            <button onclick="logout()" class="btn-logout">Sign Out</button>
        </div>
    </nav>

    <div class="main-content">
        <header class="topbar">
            <div style="display:flex; align-items:center;">
                <div class="toggle-btn" onclick="toggleSidebar()">☰</div>
                <div class="page-title">Employee Directory</div>
            </div>
            <div class="user-profile">
                <span id="adminEmail">Loading...</span>
                <div class="user-avatar">A</div>
            </div>
        </header>

        <div class="content">
            <div class="card">
                <div class="card-header">
                    <h3 class="card-title">All Employees</h3>
                    <button onclick="loadEmployees()" class="btn-edit" style="background:#f8f9fa;">🔄 Refresh List</button>
                </div>

                <div class="table-wrap">
                    <table>
                        <thead>
                            <tr>
                                <th>Name / Email</th>
                                <th>Position (Access)</th>
                                <th>Job Role</th>
                                <th>Phone</th>
                                <th>Current Project</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody id="empTableBody">
                            <tr><td colspan="6" style="text-align:center; padding:30px; color:#999;">Loading data...</td></tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <div id="editModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <span>Edit User Profile</span>
                <button class="close-btn" onclick="closeModal()">×</button>
            </div>
            
            <div class="row">
                <div class="col">
                    <label>Email ID (Locked)</label>
                    <input type="text" id="editEmail" class="readonly-field" disabled>
                </div>
                <div class="col">
                    <label>Employee ID</label>
                    <input type="text" id="editEmpId" placeholder="e.g. EMP001">
                </div>
            </div>

            <div class="row">
                <div class="col">
                    <label>Full Name</label>
                    <input type="text" id="editName">
                </div>
                <div class="col">
                    <label>Position (Access Level)</label>
                    <select id="editPosition">
                        <option value="intern">Intern</option>
                        <option value="employee">Employee</option>
                        <option value="manager">Manager</option>
                        <option value="admin">Admin</option>
                    </select>
                </div>
            </div>

            <div class="row">
                <div class="col">
                    <label>Job Title / Role</label>
                    <input type="text" id="editRole" placeholder="e.g. Senior Developer">
                </div>
                <div class="col">
                    <label>Phone Number</label>
                    <input type="text" id="editPhone" placeholder="+91...">
                </div>
            </div>

            <div>
                <label>Current Project</label>
                <input type="text" id="editProject" placeholder="e.g. Alpha Project">
            </div>

            <div class="modal-actions">
                <button class="btn-modal btn-cancel" onclick="closeModal()">Cancel</button>
                <button class="btn-modal btn-save" onclick="saveChanges()">💾 Save Changes</button>
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

        // Local Store to hold user objects
        let loadedUsers = {}; 

        // --- 2. AUTH & LOAD ---
        auth.onAuthStateChanged(user => {
            if(user) {
                db.collection("users").doc(user.email).get().then(doc => {
                    const d = doc.data();
                    if(d.role === 'admin' || d.role === 'manager') {
                        document.getElementById("adminEmail").innerText = user.email;
                        if(d.role === 'manager') document.querySelector('.sidebar-brand').innerText = "MANAGER PORTAL";
                        
                        loadEmployees();
                        document.getElementById("loadingOverlay").style.display = "none";
                    } else {
                        window.location.href = "index.html";
                    }
                });
            } else {
                window.location.href = "index.html";
            }
        });

        // --- 3. HELPER: DATA SANITIZER ---
        const checkVal = (val, fallback = "Not Set") => {
            if (!val) return fallback;
            const s = String(val).trim();
            if (s === "" || s.toLowerCase() === "false" || s.toLowerCase() === "undefined" || s.toLowerCase() === "null") return fallback;
            return s;
        };

        // --- 4. LOAD DATA ---
        function loadEmployees() {
            const tbody = document.getElementById("empTableBody");
            
            db.collection("users").get().then(snap => {
                if (snap.empty) {
                    tbody.innerHTML = "<tr><td colspan='6' style='text-align:center; padding:30px; color:#999;'>No employees found.</td></tr>";
                    return;
                }

                let html = "";
                loadedUsers = {}; 

                snap.forEach(doc => {
                    const d = doc.data();
                    // Identify user by Email field (default) or Doc ID if missing
                    const emailKey = d.email || doc.id; 
                    
                    // Store data locally using this key
                    loadedUsers[emailKey] = d;

                    if(d.role !== 'admin') {
                        // Display Logic
                        let fullName = checkVal(d.fullName, "Unknown Name");
                        let position = (d.role || "employee").toUpperCase();
                        let jobRole = checkVal(d.designation, "-");
                        let phone = checkVal(d.contact || d.phone, "-"); // Check both possible phone fields
                        let project = checkVal(d.currentProject, "-");

                        // Add visual cue for missing data
                        const roleStyle = jobRole === "-" ? "class='missing-data'" : "";
                        const projectStyle = project === "-" ? "class='missing-data'" : "";

                        // STRING CONCATENATION (FIXED FOR JSP)
                        html += "<tr>";
                        html += "<td><strong>" + fullName + "</strong><br><span style='font-size:11px; color:#777;'>" + emailKey + "</span></td>";
                        html += "<td><span class='role-badge'>" + position + "</span></td>";
                        html += "<td " + roleStyle + ">" + jobRole + "</td>";
                        html += "<td>" + phone + "</td>";
                        html += "<td " + projectStyle + ">" + project + "</td>";
                        html += "<td><button class='btn-edit' onclick='openEditModal(\"" + emailKey + "\")'>✏️ Edit</button></td>";
                        html += "</tr>";
                    }
                });
                tbody.innerHTML = html;
            });
        }

        // --- 5. MODAL LOGIC ---
        function openEditModal(emailKey) {
            console.log("Opening edit for:", emailKey);
            const d = loadedUsers[emailKey];
            
            if (!d) {
                alert("Error: User data missing locally. Please refresh.");
                return;
            }

            // Populate Fields - Use empty string if missing so input isn't literally "null"
            document.getElementById("editEmail").value = emailKey;
            document.getElementById("editName").value = checkVal(d.fullName, "") === "Not Set" ? "" : d.fullName;
            document.getElementById("editEmpId").value = checkVal(d.empId, "") === "Not Set" ? "" : d.empId;
            document.getElementById("editPosition").value = d.role || "employee";
            document.getElementById("editRole").value = checkVal(d.designation, "") === "Not Set" ? "" : d.designation;
            
            // Check both contact fields
            let ph = d.contact || d.phone;
            document.getElementById("editPhone").value = checkVal(ph, "") === "Not Set" ? "" : ph;
            
            let proj = d.currentProject;
            document.getElementById("editProject").value = checkVal(proj, "") === "Not Set" ? "" : proj;

            document.getElementById("editModal").style.display = "flex";
        }

        function closeModal() {
            document.getElementById("editModal").style.display = "none";
        }

        function saveChanges() {
            const email = document.getElementById("editEmail").value;
            const btn = document.querySelector('.btn-save');
            
            const updates = {
                fullName: document.getElementById("editName").value,
                empId: document.getElementById("editEmpId").value,
                role: document.getElementById("editPosition").value,
                designation: document.getElementById("editRole").value,
                contact: document.getElementById("editPhone").value,
                phone: document.getElementById("editPhone").value, // Save to both fields just in case
                currentProject: document.getElementById("editProject").value
            };

            btn.innerText = "Saving...";
            btn.disabled = true;

            // Update in Firebase using Set with Merge (safer than update if doc doesn't exist)
            db.collection("users").doc(email).set(updates, { merge: true }).then(() => {
                alert("✅ Profile Updated Successfully!");
                closeModal();
                loadEmployees(); 
                btn.innerText = "💾 Save Changes";
                btn.disabled = false;
            }).catch(e => {
                alert("Error: " + e.message);
                btn.innerText = "💾 Save Changes";
                btn.disabled = false;
            });
        }

        function toggleSidebar() { document.getElementById("sidebar").classList.toggle("active"); }
        function logout() { auth.signOut().then(() => window.location.href="index.html"); }
    </script>
</body>
</html>