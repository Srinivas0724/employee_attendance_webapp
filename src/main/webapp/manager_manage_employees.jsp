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
    <title>Team Management - Manager Portal</title>
    
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
        .content { padding: 40px; max-width: 1400px; margin: 0 auto; width: 100%; display: flex; flex-direction: column; gap: 30px; }

        /* Tabs */
        .tab-container { 
            display: flex; gap: 15px; border-bottom: 2px solid #e9ecef; padding-bottom: 15px; 
        }
        
        .tab-btn { 
            padding: 12px 30px; 
            border: none; 
            background: transparent; 
            color: var(--text-grey); 
            cursor: pointer; 
            border-radius: 30px; 
            font-weight: 600; 
            font-size: 14px; 
            transition: all 0.3s ease;
        }
        
        .tab-btn:hover { background: #e9ecef; color: var(--primary-navy); }
        
        .tab-btn.active { 
            background: var(--primary-navy); 
            color: white; 
            box-shadow: 0 4px 10px rgba(26, 59, 110, 0.2); 
        }
        
        .tab-content { display: none; width: 100%; }
        .tab-content.active { display: flex; gap: 30px; flex-wrap: wrap; animation: fadeIn 0.3s ease-in-out; }

        @keyframes fadeIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }

        /* Cards */
        .card { 
            background: white; 
            padding: 30px; 
            border-radius: 16px; 
            box-shadow: var(--card-shadow); 
            flex: 1; 
            min-width: 350px;
        }
        
        .half-width { flex: 1; }
        
        h3 { 
            margin-top: 0; 
            color: var(--primary-navy); 
            border-bottom: 1px solid #f1f1f1; 
            padding-bottom: 15px; 
            margin-bottom: 25px; 
            font-size: 18px; 
            font-weight: 700; 
        }

        /* Forms */
        label { 
            font-weight: 600; font-size: 13px; color: var(--text-dark); 
            display: block; margin-top: 20px; text-transform: uppercase; letter-spacing: 0.5px;
        }
        
        input, select, textarea { 
            width: 100%; padding: 14px; margin-top: 8px; 
            border: 1px solid #e0e0e0; border-radius: 8px; box-sizing: border-box; 
            font-size: 14px; transition: all 0.3s; background: #fdfdfd;
        }
        
        input:focus, select:focus, textarea:focus { 
            border-color: var(--primary-navy); outline: none; background: white; 
            box-shadow: 0 0 0 3px rgba(26, 59, 110, 0.1);
        }
        
        textarea { height: 120px; resize: vertical; }

        /* Action Buttons */
        .btn-action { 
            margin-top: 25px; padding: 14px; width: 100%; color: white; border: none; 
            border-radius: 8px; font-weight: 700; cursor: pointer; transition: all 0.2s; 
            font-size: 14px;
        }
        
        .btn-green { background: var(--primary-green); box-shadow: 0 4px 10px rgba(46, 204, 113, 0.3); }
        .btn-green:hover { background: #27ae60; transform: translateY(-2px); }
        
        .btn-blue { background: #3498db; box-shadow: 0 4px 10px rgba(52, 152, 219, 0.3); }
        .btn-blue:hover { background: #2980b9; transform: translateY(-2px); }
        
        .btn-red { background: #e74c3c; margin-top: 15px; }
        .btn-red:hover { background: #c0392b; }
        
        .btn-secondary { background: #95a5a6; margin-top: 15px; color: white; }
        .btn-secondary:hover { background: #7f8c8d; }

        /* Directory Table */
        table { width: 100%; border-collapse: separate; border-spacing: 0; }
        th { 
            background: #f8f9fa; color: var(--text-grey); padding: 15px; 
            text-align: left; font-size: 12px; text-transform: uppercase; letter-spacing: 1px;
            border-bottom: 2px solid #eee; font-weight: 700;
        }
        td { 
            padding: 15px; border-bottom: 1px solid #f1f1f1; 
            color: var(--text-dark); font-size: 14px; 
        }
        tr:hover td { background: #fcfcfc; }

        /* Checkbox List */
        .emp-checkbox-list { 
            max-height: 250px; overflow-y: auto; 
            border: 1px solid #eee; padding: 15px; margin-top: 10px; 
            background: #fafafa; border-radius: 8px; 
        }
        .emp-item { 
            display: flex; align-items: center; gap: 12px; padding: 10px; 
            border-bottom: 1px solid #f0f0f0; transition: background 0.2s;
            cursor: pointer;
        }
        .emp-item:hover { background: white; }
        .emp-item:last-child { border-bottom: none; }

        /* Chat Styles */
        .chat-box { 
            border: 1px solid #eee; height: 400px; overflow-y: auto; 
            background: #f9f9f9; padding: 20px; border-radius: 10px; 
            display: flex; flex-direction: column; gap: 15px; 
        }
        
        .chat-msg { 
            padding: 12px 18px; border-radius: 15px; max-width: 80%; 
            font-size: 14px; line-height: 1.5; box-shadow: 0 2px 5px rgba(0,0,0,0.05); 
        }
        
        .msg-mine { 
            background: #dcf8c6; align-self: flex-end; 
            border-bottom-right-radius: 2px; color: var(--text-dark);
        }
        
        .msg-other { 
            background: white; align-self: flex-start; 
            border-bottom-left-radius: 2px; color: var(--text-dark);
        }

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
            .tab-content.active { flex-direction: column; }
            .toggle-btn { display: block; font-size: 24px; cursor: pointer; margin-right: 15px; }
        }
        @media (min-width: 901px) { .toggle-btn { display: none; } }
    </style>

    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-auth-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-firestore-compat.js"></script>
</head>
<body>

    <div id="loadingOverlay">
        <div style="font-size: 50px;">👥</div>
        <div>Loading Team Data...</div>
    </div>

    <nav class="sidebar" id="sidebar">
        <div class="sidebar-header">
            <img src="synod_logo.png" alt="Synod Logo" class="sidebar-logo">
            <div class="sidebar-brand">MANAGER PORTAL</div>
        </div>

        <ul class="nav-menu">
            <li class="nav-item"><a href="manager_dashboard.jsp"><span class="nav-icon">📊</span> Overview</a></li>
            <li class="nav-item"><a href="manager_mark_attendance.jsp"><span class="nav-icon">📍</span> My Attendance</a></li>
            <li class="nav-item"><a href="manager_manage_employees.jsp" class="active"><span class="nav-icon">👥</span> Assign Tasks</a></li>
            <li class="nav-item"><a href="manager_task_monitoring.jsp"><span class="nav-icon">📝</span> Task Monitoring</a></li>
            <li class="nav-item"><a href="manager_report.jsp"><span class="nav-icon">📅</span> View Attendance</a></li>
            <li class="nav-item"><a href="manager_list_of_employees.jsp"><span class="nav-icon">📋</span> Directory</a></li>
            <li class="nav-item"><a href="manager_settings.jsp"><span class="nav-icon">⚙️</span> My Settings</a></li>
        </ul>
        
        <div class="sidebar-footer">
            <button onclick="logout()" class="btn-logout"><span>🚪</span> Sign Out</button>
        </div>
    </nav>

    <div class="main-content">
        <header class="topbar">
            <div style="display:flex; align-items:center;">
                <div class="toggle-btn" onclick="toggleSidebar()">☰</div>
                <div class="page-title">Team Management</div>
            </div>
            <div class="user-profile">
                <span id="mgrEmail" class="user-email">Loading...</span>
                <div class="user-avatar">M</div>
            </div>
        </header>

        <div class="content">
            
            <div class="tab-container">
                <button class="tab-btn active" onclick="switchTab('individual')">👤 Individual Tasks</button>
                <button class="tab-btn" onclick="switchTab('project')">🚀 Project Groups</button>
            </div>

            <div id="tab-individual" class="tab-content active">
                
                <div class="card half-width">
                    <h3>📝 Assign New Task</h3>
                    <label>Select Employee</label>
                    <select id="empSelect">
                        <option value="">-- Choose Employee --</option>
                    </select>

                    <label>Task Title</label>
                    <input type="text" id="taskTitle" placeholder="e.g. Site Inspection">
                    
                    <label>Description</label>
                    <textarea id="taskDesc" placeholder="Enter detailed instructions..."></textarea>

                    <div style="display:flex; gap:20px;">
                        <div style="flex:1">
                            <label>Project Name</label>
                            <input type="text" id="taskProject" placeholder="General">
                        </div>
                        <div style="flex:1">
                            <label>Priority</label>
                            <select id="taskPriority">
                                <option value="LOW">Low</option>
                                <option value="MEDIUM" selected>Medium</option>
                                <option value="HIGH">High</option>
                            </select>
                        </div>
                    </div>
                    
                    <div style="display:flex; gap:20px;">
                        <div style="flex:1">
                            <label>Due Date</label>
                            <input type="date" id="taskDate">
                        </div>
                        <div style="flex:1">
                            <label>Reference Image (Optional)</label>
                            <input type="file" id="taskFile" accept="image/*" style="padding:11px;">
                        </div>
                    </div>

                    <button onclick="assignTask()" id="assignBtn" class="btn-action btn-green">Assign Task</button>
                </div>

                <div class="card half-width">
                    <h3>👥 Team Directory</h3>
                    <table>
                        <thead><tr><th>Name</th><th>Email</th><th>Contact</th></tr></thead>
                        <tbody id="empTableBody"><tr><td colspan="3" style="text-align:center; padding:20px;">Loading...</td></tr></tbody>
                    </table>
                </div>
            </div>

            <div id="tab-project" class="tab-content">
                
                <div class="card half-width" style="flex: 0.8;">
                    <h3>📂 Project Management</h3>
                    
                    <div style="background:#f0f7ff; padding:20px; border-radius:10px; border:1px solid #d0e1f5; margin-bottom:25px;">
                        <h4 style="margin:0 0 10px 0; color:#1a3b6e; font-size:14px; font-weight:700;">Select Active Project</h4>
                        <select id="projectSelect" onchange="handleProjectChange()" style="margin:0; background:white;">
                            <option value="">-- CREATE NEW PROJECT --</option>
                        </select>
                    </div>

                    <div id="createMode">
                        <h4 style="margin-bottom:20px; color:var(--text-dark);">Create New Group</h4>
                        <label>New Project Name</label>
                        <input type="text" id="newProjName" placeholder="e.g. Alpha Team">
                        
                        <label>Select Members</label>
                        <div id="createCheckboxes" class="emp-checkbox-list"></div>
                        
                        <button class="btn-action btn-blue" onclick="createProject()">Create Project Group</button>
                    </div>

                    <div id="editMode" style="display:none;">
                        <h4 style="margin-bottom:20px; color:var(--text-dark);">
                            Edit Project: <span id="editProjTitle" style="color:var(--primary-navy)"></span>
                        </h4>
                        
                        <label>Project Name</label>
                        <input type="text" id="editProjName">

                        <label>Manage Members</label>
                        <div id="editCheckboxes" class="emp-checkbox-list"></div>

                        <button class="btn-action btn-blue" onclick="updateProject()">💾 Save Changes</button>
                        <button class="btn-action btn-red" onclick="deleteProject()">🗑️ Delete Project</button>
                        <button class="btn-action btn-secondary" onclick="resetToCreateMode()">❌ Cancel</button>
                    </div>
                </div>

                <div class="card half-width">
                    <h3>💬 Group Broadcast</h3>
                    <div id="chatContainer" style="display:none;">
                        <div style="font-size:13px; color:#7f8c8d; margin-bottom:10px; font-weight:500;">
                            Broadcasting to: <b id="chatProjName" style="color:var(--primary-navy);"></b>
                        </div>
                        <div id="projectChatBox" class="chat-box"></div>
                        
                        <div style="display:flex; gap:15px; margin-top:20px;">
                            <input type="text" id="projMsgInput" placeholder="Type a message to the group..." style="margin:0;">
                            <button style="margin:0; width:auto; padding:0 30px;" class="btn-action btn-green" onclick="sendProjectMsg()">Send</button>
                        </div>
                    </div>
                    <div id="noProjectMsg" style="text-align:center; color:#bdc3c7; margin-top:100px;">
                        <div style="font-size:50px; margin-bottom:15px;">👈</div>
                        Select a project from the left panel to open the chat.
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
        let currentUserRole = "manager"; 

        // --- 2. AUTH CHECK ---
        auth.onAuthStateChanged(user => {
            if (user) {
                db.collection("users").doc(user.email).get().then(doc => {
                    const role = doc.data().role;
                    if (role !== 'manager' && role !== 'admin') {
                        window.location.href = "login.jsp"; 
                        return;
                    }
                    
                    currentUserRole = role;
                    document.getElementById("mgrEmail").innerText = user.email;
                    
                    loadEmployees();
                    loadProjects();
                    
                    document.getElementById("loadingOverlay").style.display = "none";
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

        // --- 4. LOAD EMPLOYEES (Hide Admins) ---
        function loadEmployees() {
            const empSelect = document.getElementById("empSelect");
            const tbody = document.getElementById("empTableBody");
            const createBox = document.getElementById("createCheckboxes");
            const editBox = document.getElementById("editCheckboxes");
            
            empSelect.innerHTML = '<option value="">-- Choose Employee --</option>';
            tbody.innerHTML = "";
            createBox.innerHTML = "";
            editBox.innerHTML = "";
            allEmployees = [];

            db.collection("users").get().then(snap => {
                snap.forEach(doc => {
                    const data = doc.data();
                    if(data.role !== 'admin') {
                        allEmployees.push(data);
                        
                        const opt = document.createElement("option");
                        opt.value = data.email;
                        opt.innerText = data.fullName + " (" + data.email + ")";
                        empSelect.appendChild(opt);

                        let row = "<tr>";
                        row += "<td>" + data.fullName + "</td>";
                        row += "<td>" + data.email + "</td>";
                        row += "<td>" + (data.contact || '-') + "</td>";
                        row += "</tr>";
                        tbody.innerHTML += row;

                        let cbCreate = "<div class='emp-item'>";
                        cbCreate += "<input type='checkbox' value='" + data.email + "' class='create-member-check'>";
                        cbCreate += "<span> " + data.fullName + "</span>";
                        cbCreate += "</div>";
                        createBox.innerHTML += cbCreate;
                        
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
                    assignedRole: 'manager', 
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
                reader.onload = function(e) { saveTaskToDB(e.target.result); };
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
            if(!projId) resetToCreateMode();
            else loadProjectForEdit(projId);
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
                role: 'manager',
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
            
            db.collection("projects").doc(currentProjectID).update({
                name: name,
                members: members
            }).then(() => alert("✅ Project Updated!"));
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

            db.collection("projects").doc(currentProjectID).collection("messages").add({
                text: txt,
                sender: auth.currentUser.email,
                senderName: "Manager",
                timestamp: firebase.firestore.FieldValue.serverTimestamp()
            }).then(() => { input.value = ""; });
        }

        function logout(){ auth.signOut().then(() => window.location.href = "index.html"); }
        function toggleSidebar() { document.getElementById("sidebar").classList.toggle("open"); }
    </script>
</body>
</html>