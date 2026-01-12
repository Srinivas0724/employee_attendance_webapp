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
    <title>Employee Management - Synod Bioscience</title>
    
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

        /* --- 2. SIDEBAR (Standardized) --- */
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

        /* --- 4. TABS & GRID --- */
        .tab-header { display: flex; gap: 15px; margin-bottom: 25px; border-bottom: 1px solid #e0e0e0; padding-bottom: 15px; }
        .tab-btn { 
            padding: 10px 25px; border: 1px solid #e0e0e0; background: white; 
            border-radius: 30px; cursor: pointer; font-weight: 600; color: #7f8c8d; 
            transition: 0.2s; display: flex; align-items: center; gap: 8px;
        }
        .tab-btn.active { background: var(--primary-navy); color: white; border-color: var(--primary-navy); box-shadow: 0 4px 10px rgba(26, 59, 110, 0.2); }
        
        .tab-content { display: none; }
        .tab-content.active { display: flex; gap: 25px; flex-wrap: wrap; }

        /* Two Column Layout */
        .col-left { flex: 1; min-width: 350px; display: flex; flex-direction: column; gap: 25px; }
        .col-right { flex: 1.5; min-width: 450px; display: flex; flex-direction: column; gap: 25px; }

        /* Cards */
        .card { background: white; border-radius: 16px; padding: 30px; box-shadow: var(--card-shadow); display: flex; flex-direction: column; border: 1px solid white; }
        .card-header { font-size: 18px; font-weight: 700; color: var(--primary-navy); margin-bottom: 20px; border-bottom: 1px solid #f0f0f0; padding-bottom: 15px; }

        /* Form Elements */
        .form-group { margin-bottom: 15px; }
        label { display: block; font-size: 12px; font-weight: 700; color: #333; margin-bottom: 6px; text-transform: uppercase; letter-spacing: 0.5px; }
        input, select, textarea { width: 100%; padding: 12px; border: 1px solid #e0e0e0; border-radius: 8px; font-size: 14px; background: #f9f9f9; transition: 0.2s; }
        input:focus, select:focus, textarea:focus { border-color: var(--primary-navy); background: white; outline: none; box-shadow: 0 0 0 3px rgba(26, 59, 110, 0.1); }
        textarea { resize: vertical; height: 100px; }

        .row { display: flex; gap: 15px; }
        .col { flex: 1; }

        /* Buttons */
        .btn-action { width: 100%; padding: 12px; border: none; border-radius: 8px; font-weight: 700; color: white; cursor: pointer; transition: 0.2s; margin-top: 10px; font-size: 14px; }
        .btn-green { background: var(--primary-green); box-shadow: 0 4px 10px rgba(46, 204, 113, 0.3); }
        .btn-green:hover { background: #27ae60; transform: translateY(-2px); }
        .btn-blue { background: var(--primary-navy); box-shadow: 0 4px 10px rgba(26, 59, 110, 0.3); }
        .btn-blue:hover { background: #132c52; transform: translateY(-2px); }
        .btn-red { background: #e74c3c; box-shadow: 0 4px 10px rgba(231, 76, 60, 0.3); }
        .btn-red:hover { background: #c0392b; }
        .btn-gray { background: #95a5a6; color: white; }

        /* Table */
        .table-wrap { overflow-x: auto; border-radius: 8px; border: 1px solid #f0f0f0; }
        table { width: 100%; border-collapse: collapse; min-width: 500px; }
        th { background: #f8f9fa; text-align: left; padding: 15px; font-size: 12px; color: #7f8c8d; font-weight: 700; text-transform: uppercase; border-bottom: 2px solid #eee; }
        td { padding: 15px; font-size: 14px; border-bottom: 1px solid #f9f9f9; color: #333; }
        tr:hover td { background: #fcfcfc; }

        /* Member List Checkboxes */
        .member-list { border: 1px solid #e0e0e0; padding: 12px; max-height: 250px; overflow-y: auto; border-radius: 8px; background: #fcfcfc; }
        .emp-item { display: flex; align-items: center; gap: 10px; padding: 10px; border-bottom: 1px solid #eee; cursor: pointer; transition: 0.2s; }
        .emp-item:hover { background: #f0f2f5; }
        .emp-item input { width: 18px; height: 18px; margin: 0; cursor: pointer; accent-color: var(--primary-navy); }
        .emp-item span { font-size: 14px; font-weight: 500; color: #333; }

        /* Chat Styles */
        .chat-container { border: 1px solid #eee; background: #fdfdfd; border-radius: 12px; height: 450px; display: flex; flex-direction: column; overflow: hidden; }
        .chat-header-bar { padding: 15px; border-bottom: 1px solid #eee; background: #fff; font-weight: 600; color: var(--primary-navy); display: flex; align-items: center; gap: 10px; font-size: 14px; }
        .chat-box { flex: 1; overflow-y: auto; padding: 20px; display: flex; flex-direction: column; gap: 12px; }
        .chat-msg { padding: 12px 16px; border-radius: 12px; max-width: 80%; font-size: 13px; line-height: 1.5; box-shadow: 0 2px 5px rgba(0,0,0,0.03); }
        .msg-mine { background: var(--primary-navy); color: white; align-self: flex-end; border-bottom-right-radius: 2px; }
        .msg-other { background: white; border: 1px solid #eee; align-self: flex-start; border-bottom-left-radius: 2px; color: #333; }
        .chat-input-row { padding: 15px; background: #fff; border-top: 1px solid #eee; display: flex; gap: 10px; }
        .chat-input-row input { margin: 0; border-radius: 30px; padding-left: 20px; }

        /* Project Select Box */
        .project-select-wrapper { background: #e3f2fd; padding: 20px; border-radius: 10px; border: 1px solid #bbdefb; margin-bottom: 20px; }
        .project-select-wrapper h4 { margin: 0 0 10px 0; color: #1565c0; font-size: 13px; font-weight: 700; text-transform: uppercase; }

        /* Loader */
        #loadingOverlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: white; z-index: 9999; display: flex; flex-direction: column; justify-content: center; align-items: center; color: var(--primary-navy); font-weight: 600; }

        @media (max-width: 1024px) {
            .sidebar { position: fixed; left: -280px; height: 100%; }
            .sidebar.active { transform: translateX(280px); }
            .content { padding: 20px; }
            .tab-content.active { flex-direction: column; }
            .toggle-btn { display: block; font-size: 24px; cursor: pointer; margin-right: 15px; }
        }
        @media (min-width: 1025px) { .toggle-btn { display: none; } }
    </style>
</head>
<body>

    <div id="loadingOverlay">
        <div style="font-size: 50px;">👥</div>
        <div style="margin-top:15px;">Loading Data...</div>
    </div>

    <nav class="sidebar" id="sidebar">
        <div class="sidebar-header">
            <img src="synod_logo.png" alt="Logo" class="sidebar-logo">
            <div class="sidebar-brand">ADMIN PORTAL</div>
        </div>
        <ul class="nav-menu">
            <li class="nav-item"><a href="admin_homepage.html"><span class="nav-icon">🏠</span> Home</a></li>
            <li class="nav-item"><a href="admin_dashboard.jsp"><span class="nav-icon">📊</span> Live Dashboard</a></li>
            <li class="nav-item"><a href="manage_employees.jsp" class="active"><span class="nav-icon">👥</span> Employees</a></li>
            <li class="nav-item"><a href="admin_task_monitoring.jsp"><span class="nav-icon">📝</span> Tasks</a></li>
            <li class="nav-item"><a href="reports.jsp"><span class="nav-icon">📅</span> Attendance</a></li>
            <li class="nav-item"><a href="admin_expenses.jsp"><span class="nav-icon">💸</span> Expenses</a></li>
            <li class="nav-item"><a href="payroll.jsp"><span class="nav-icon">💰</span> Payroll</a></li>
            <li class="nav-item"><a href="admin_settings.jsp"><span class="nav-icon">⚙️</span> Settings</a></li>
        </ul>
        <div class="sidebar-footer">
            <button onclick="logout()" class="btn-logout">Sign Out</button>
        </div>
    </nav>

    <div class="main-content">
        <header class="topbar">
            <div style="display:flex; align-items:center;">
                <div class="toggle-btn" onclick="toggleSidebar()">☰</div>
                <div class="page-title">Employee Management</div>
            </div>
            <div class="user-profile">
                <span id="adminEmail">Loading...</span>
                <div class="user-avatar">A</div>
            </div>
        </header>

        <div class="content">
            
            <div class="tab-header">
                <button class="tab-btn active" onclick="switchTab('individual')">👤 Assign Tasks</button>
                <button class="tab-btn" onclick="switchTab('project')">🚀 Project Groups</button>
            </div>

            <div id="tab-individual" class="tab-content active">
                
                <div class="col-left">
                    <div class="card">
                        <div class="card-header">📝 Assign New Task</div>
                        
                        <div class="form-group">
                            <label>Select Employee</label>
                            <select id="empSelect"><option value="">-- Choose Employee --</option></select>
                        </div>

                        <div class="form-group">
                            <label>Task Title</label>
                            <input type="text" id="taskTitle" placeholder="e.g. Weekly Site Inspection">
                        </div>

                        <div class="form-group">
                            <label>Description</label>
                            <textarea id="taskDesc" placeholder="Enter detailed instructions..."></textarea>
                        </div>

                        <div class="row">
                            <div class="col">
                                <label>Project Name</label>
                                <input type="text" id="taskProject" placeholder="General">
                            </div>
                            <div class="col">
                                <label>Priority</label>
                                <select id="taskPriority">
                                    <option value="LOW">Low</option>
                                    <option value="MEDIUM" selected>Medium</option>
                                    <option value="HIGH">High</option>
                                </select>
                            </div>
                        </div>

                        <div class="row" style="margin-top:10px;">
                            <div class="col">
                                <label>Due Date</label>
                                <input type="date" id="taskDate">
                            </div>
                            <div class="col">
                                <label>Image (Optional)</label>
                                <input type="file" id="taskFile" accept="image/*" style="background:white; padding:9px;">
                            </div>
                        </div>

                        <button onclick="assignTask()" id="assignBtn" class="btn-action btn-green">Assign Task</button>
                    </div>
                </div>

                <div class="col-right">
                    <div class="card" style="height:100%;">
                        <div class="card-header">👥 Employee Directory</div>
                        <div class="table-wrap">
                            <table>
                                <thead><tr><th>Name</th><th>Email</th><th>Contact</th></tr></thead>
                                <tbody id="empTableBody"><tr><td colspan="3" style="text-align:center;">Loading...</td></tr></tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>

            <div id="tab-project" class="tab-content">
                
                <div class="col-left">
                    <div class="card">
                        <div class="card-header">📂 Project Settings</div>
                        
                        <div class="project-select-wrapper">
                            <h4>Select Active Project</h4>
                            <select id="projectSelect" onchange="handleProjectChange()" style="background:white; margin:0;">
                                <option value="">-- CREATE NEW PROJECT --</option>
                            </select>
                        </div>

                        <div id="createMode">
                            <div class="form-group">
                                <label>New Project Name</label>
                                <input type="text" id="newProjName" placeholder="e.g. Alpha Team">
                            </div>
                            <div class="form-group">
                                <label>Select Members</label>
                                <div id="createCheckboxes" class="member-list"></div>
                            </div>
                            <button onclick="createProject()" class="btn-action btn-blue">Create Group</button>
                        </div>

                        <div id="editMode" style="display:none;">
                            <div class="form-group">
                                <label>Project Name</label>
                                <input type="text" id="editProjName">
                            </div>
                            <div class="form-group">
                                <label>Manage Members</label>
                                <div id="editCheckboxes" class="member-list"></div>
                            </div>
                            <div class="row">
                                <div class="col"><button onclick="updateProject()" class="btn-action btn-blue">Save Changes</button></div>
                                <div class="col"><button onclick="deleteProject()" class="btn-action btn-red">Delete</button></div>
                            </div>
                            <button onclick="resetToCreateMode()" class="btn-action btn-gray">Cancel Edit</button>
                        </div>
                    </div>
                </div>

                <div class="col-right">
                    <div class="card" style="height:100%;">
                        <div class="card-header">💬 Group Chat</div>
                        <div id="chatContainer" class="chat-container" style="display:none;">
                            <div class="chat-header-bar">
                                <span style="font-size:18px;">📢</span> 
                                Broadcasting to: <strong id="chatProjName" style="margin-left:5px;"></strong>
                            </div>
                            <div id="projectChatBox" class="chat-box"></div>
                            <div class="chat-input-row">
                                <input type="text" id="projMsgInput" placeholder="Type a message..." style="flex:1;">
                                <button onclick="sendProjectMsg()" class="btn-action btn-green" style="width:auto; margin:0; padding:0 25px; border-radius:30px;">➤</button>
                            </div>
                        </div>
                        <div id="noProjectMsg" style="text-align:center; color:#999; margin-top:80px;">
                            <div style="font-size:40px; margin-bottom:15px; opacity:0.3;">👈</div>
                            <p>Select a project from the left panel to open the group chat.</p>
                        </div>
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

        let allEmployees = [];
        let currentProjectID = null;
        let projectChatListener = null;
        let currentUserRole = "admin"; // Default

        // --- 2. AUTH CHECK & ROLE MANAGER ---
        auth.onAuthStateChanged(user => {
            if (user) {
                db.collection("users").doc(user.email).get().then(doc => {
                    if (doc.exists) {
                        const data = doc.data();
                        const role = data.role;
                        
                        // 1. ACCESS CHECK: Allow Admin OR Manager
                        if (role !== 'admin' && role !== 'manager') {
                            window.location.href = "index.html"; 
                            return;
                        }

                        // 2. STORE ROLE
                        currentUserRole = role;

                        // 3. LOAD USER INFO
                        if(document.getElementById("adminEmail")) {
                             document.getElementById("adminEmail").innerText = user.email;
                        }
                        
                        // 4. MANAGER SPECIFIC UI
                        if (role === 'manager') {
                            // Update Brand
                            const brand = document.querySelector('.sidebar-brand');
                            if(brand) brand.innerText = "MANAGER PORTAL";

                            // Hide Restricted Links (Expenses & Payroll)
                            const expLink = document.querySelector('a[href="admin_expenses.jsp"]');
                            if(expLink && expLink.parentElement) expLink.parentElement.style.display = 'none';

                            const payLink = document.querySelector('a[href="payroll.jsp"]');
                            if(payLink && payLink.parentElement) payLink.parentElement.style.display = 'none';
                        }

                        // 5. LOAD PAGE DATA
                        loadEmployees();
                        loadProjects();
                        
                        // Hide Loader
                        document.getElementById("loadingOverlay").style.display = "none";
                    }
                });
            } else {
                window.location.replace("index.html");
            }
        });

        // --- 3. TABS ---
        function switchTab(tabName) {
            document.querySelectorAll('.tab-content').forEach(el => el.classList.remove('active'));
            document.querySelectorAll('.tab-btn').forEach(el => el.classList.remove('active'));
            
            document.getElementById('tab-' + tabName).classList.add('active');
            const btns = document.querySelectorAll('.tab-btn');
            if(tabName === 'individual') btns[0].classList.add('active');
            else btns[1].classList.add('active');
        }

        // --- 4. LOAD EMPLOYEES ---
        function loadEmployees() {
            db.collection("users").get().then(snap => {
                const empSelect = document.getElementById("empSelect");
                const tbody = document.getElementById("empTableBody");
                const createBox = document.getElementById("createCheckboxes");
                const editBox = document.getElementById("editCheckboxes");
                
                empSelect.innerHTML = '<option value="">-- Choose Employee --</option>';
                tbody.innerHTML = "";
                createBox.innerHTML = "";
                editBox.innerHTML = "";
                allEmployees = [];

                snap.forEach(doc => {
                    const data = doc.data();
                    // Load everyone except Admin (Managers can see other Managers and Employees)
                    if(data.role !== 'admin') {
                        allEmployees.push(data);
                        
                        // 1. Dropdown
                        const opt = document.createElement("option");
                        opt.value = data.email;
                        opt.innerText = data.fullName + " (" + data.email + ")";
                        empSelect.appendChild(opt);

                        // 2. Table
                        let row = "<tr>";
                        row += "<td>" + data.fullName + "</td>";
                        row += "<td>" + data.email + "</td>";
                        row += "<td>" + (data.contact || '-') + "</td>";
                        row += "</tr>";
                        tbody.innerHTML += row;

                        // 3. Checkboxes (Create)
                        let cbCreate = "<div class='emp-item'>";
                        cbCreate += "<input type='checkbox' value='" + data.email + "' class='create-member-check'>";
                        cbCreate += "<span> " + data.fullName + "</span>";
                        cbCreate += "</div>";
                        createBox.innerHTML += cbCreate;
                        
                        // 4. Checkboxes (Edit)
                        let cbEdit = "<div class='emp-item'>";
                        cbEdit += "<input type='checkbox' value='" + data.email + "' class='edit-member-check'>";
                        cbEdit += "<span> " + data.fullName + "</span>";
                        cbEdit += "</div>";
                        editBox.innerHTML += cbEdit;
                    }
                });
            });
        }

        // --- 5. ASSIGN TASK ---
        function assignTask() {
            const assignedTo = document.getElementById("empSelect").value;
            const title = document.getElementById("taskTitle").value;
            const desc = document.getElementById("taskDesc").value;
            const project = document.getElementById("taskProject").value;
            const priority = document.getElementById("taskPriority").value;
            const dueDate = document.getElementById("taskDate").value;
            const fileInput = document.getElementById("taskFile");
            const btn = document.getElementById("assignBtn");

            if(!assignedTo || !title || !dueDate) { alert("Please fill all required fields."); return; }

            btn.innerText = "Assigning..."; 
            btn.disabled = true;

            const saveTaskToDB = function(photoUrl) {
                db.collection("tasks").add({
                    assignedTo: assignedTo,
                    assignedBy: auth.currentUser.email,
                    title: title, 
                    description: desc, 
                    project: project || "General",
                    priority: priority, 
                    dueDate: dueDate, 
                    status: "PENDING",
                    photo: photoUrl, 
                    timestamp: firebase.firestore.FieldValue.serverTimestamp()
                }).then(() => {
                    alert("✅ Task Assigned Successfully!");
                    btn.innerText = "Assign Task"; 
                    btn.disabled = false;
                    document.getElementById("taskTitle").value = "";
                    document.getElementById("taskDesc").value = "";
                }).catch(err => {
                    alert("Error: " + err.message);
                    btn.disabled = false;
                });
            };

            if(fileInput.files.length > 0) {
                const reader = new FileReader();
                reader.onload = function(e) {
                    saveTaskToDB(e.target.result);
                };
                reader.readAsDataURL(fileInput.files[0]);
            } else { 
                saveTaskToDB(null); 
            }
        }

        // --- 6. PROJECTS ---
        function loadProjects() {
            db.collection("projects").onSnapshot(snap => {
                const select = document.getElementById("projectSelect");
                const currentVal = select.value;
                
                select.innerHTML = '<option value="">-- CREATE NEW PROJECT --</option>';
                snap.forEach(doc => {
                    const p = doc.data();
                    const opt = document.createElement("option");
                    opt.value = doc.id;
                    opt.innerText = p.name;
                    select.appendChild(opt);
                });
                
                if(currentVal) select.value = currentVal;
            });
        }

        function handleProjectChange() {
            const projId = document.getElementById("projectSelect").value;
            if(!projId) {
                resetToCreateMode();
            } else {
                loadProjectForEdit(projId);
            }
        }

        function resetToCreateMode() {
            document.getElementById("projectSelect").value = "";
            document.getElementById("createMode").style.display = "block";
            document.getElementById("editMode").style.display = "none";
            document.getElementById("chatContainer").style.display = "none";
            document.getElementById("noProjectMsg").style.display = "block";
            currentProjectID = null;
            if(projectChatListener) projectChatListener();
        }

        function createProject() {
            const name = document.getElementById("newProjName").value;
            const checks = document.querySelectorAll(".create-member-check:checked");
            let members = [];
            checks.forEach(c => members.push(c.value));

            if(!name || members.length === 0) {
                alert("Please enter a Project Name and select at least one member.");
                return;
            }

            db.collection("projects").add({
                name: name,
                members: members,
                createdBy: auth.currentUser.email,
                timestamp: firebase.firestore.FieldValue.serverTimestamp()
            }).then(() => {
                alert("✅ Project Group Created!");
                document.getElementById("newProjName").value = "";
                checks.forEach(c => c.checked = false);
            });
        }

        function loadProjectForEdit(projId) {
            currentProjectID = projId;
            document.getElementById("createMode").style.display = "none";
            document.getElementById("editMode").style.display = "block";
            
            db.collection("projects").doc(projId).get().then(doc => {
                if(doc.exists) {
                    const data = doc.data();
                    document.getElementById("editProjName").value = data.name;
                    document.getElementById("editProjTitle").innerText = data.name;
                    
                    const checkboxes = document.querySelectorAll(".edit-member-check");
                    checkboxes.forEach(cb => {
                        cb.checked = data.members.includes(cb.value);
                    });
                    
                    loadProjectChat(projId, data.name);
                }
            });
        }

        function updateProject() {
            if(!currentProjectID) return;
            const name = document.getElementById("editProjName").value;
            const checks = document.querySelectorAll(".edit-member-check:checked");
            let members = [];
            checks.forEach(c => members.push(c.value));
            
            if(!name || members.length === 0) {
                alert("Project must have a name and at least one member.");
                return;
            }
            
            db.collection("projects").doc(currentProjectID).update({
                name: name,
                members: members
            }).then(() => {
                alert("✅ Project Updated Successfully!");
            });
        }

        function deleteProject() {
            if(!currentProjectID) return;
            if(!confirm("Are you sure you want to delete this project? Chat history will be lost.")) return;
            
            db.collection("projects").doc(currentProjectID).delete().then(() => {
                alert("🗑️ Project Deleted.");
                resetToCreateMode();
            });
        }

        // --- 7. CHAT ---
        function loadProjectChat(projId, projName) {
            const chatContainer = document.getElementById("chatContainer");
            const noProjectMsg = document.getElementById("noProjectMsg");
            const chatBox = document.getElementById("projectChatBox");

            document.getElementById("chatProjName").innerText = projName;
            chatContainer.style.display = "block";
            noProjectMsg.style.display = "none";
            chatBox.innerHTML = "<div style='text-align:center; color:#999'>Loading history...</div>";

            if(projectChatListener) projectChatListener();
            
            projectChatListener = db.collection("projects").doc(projId).collection("messages")
                .orderBy("timestamp", "asc")
                .onSnapshot(snap => {
                    chatBox.innerHTML = "";
                    snap.forEach(doc => {
                        const m = doc.data();
                        const isMine = m.sender === auth.currentUser.email;
                        const mineClass = isMine ? "msg-mine" : "msg-other";
                        
                        let bubble = "<div class='chat-msg " + mineClass + "'>";
                        bubble += "<b>" + m.senderName + ":</b> " + m.text;
                        bubble += "</div>";
                        
                        chatBox.innerHTML += bubble;
                    });
                    chatBox.scrollTop = chatBox.scrollHeight;
                });
        }

        function sendProjectMsg() {
            const input = document.getElementById("projMsgInput");
            const txt = input.value.trim();
            if(!txt || !currentProjectID) return;

            // Determine Sender Name: Admin or Manager?
            let senderTitle = (currentUserRole === 'admin') ? "Admin" : "Manager";

            db.collection("projects").doc(currentProjectID).collection("messages").add({
                text: txt,
                sender: auth.currentUser.email,
                senderName: senderTitle,
                timestamp: firebase.firestore.FieldValue.serverTimestamp()
            }).then(() => { input.value = ""; });
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