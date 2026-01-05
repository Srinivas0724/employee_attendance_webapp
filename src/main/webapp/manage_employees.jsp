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
    <title>Manage Employees - Synod Bioscience</title>
    
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

        /* --- 4. PAGE SPECIFIC STYLES --- */
        .content { padding: 30px; max-width: 1400px; margin: 0 auto; width: 100%; }

        /* Tabs */
        .tab-container { display: flex; gap: 10px; margin-bottom: 25px; border-bottom: 2px solid #e0e0e0; padding-bottom: 15px; }
        .tab-btn { 
            padding: 12px 25px; border: none; background: #fff; color: #555; 
            cursor: pointer; border-radius: 6px; font-weight: bold; font-size: 14px; 
            box-shadow: 0 2px 4px rgba(0,0,0,0.05); transition: 0.3s;
        }
        .tab-btn.active { background: var(--primary-navy); color: white; transform: translateY(-2px); }
        .tab-content { display: none; }
        .tab-content.active { display: flex; gap: 30px; flex-wrap: wrap; }

        /* Cards */
        .card { background: white; padding: 25px; border-radius: 10px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); }
        .half-width { flex: 1; min-width: 320px; }
        
        h3 { margin-top: 0; color: var(--primary-navy); border-bottom: 2px solid #f4f6f9; padding-bottom: 12px; margin-bottom: 20px; }

        /* Forms */
        label { font-weight: 600; font-size: 13px; color: #555; display: block; margin-top: 15px; text-transform: uppercase; }
        input, select, textarea { 
            width: 100%; padding: 12px; margin-top: 8px; 
            border: 1px solid #ddd; border-radius: 6px; box-sizing: border-box; font-size: 14px;
        }
        input:focus, select:focus, textarea:focus { border-color: var(--primary-navy); outline: none; }
        textarea { height: 100px; resize: vertical; }

        /* Action Buttons */
        .btn-action { margin-top: 20px; padding: 14px; width: 100%; color: white; border: none; border-radius: 6px; font-weight: bold; cursor: pointer; transition: 0.3s; }
        .btn-green { background: var(--primary-green); }
        .btn-green:hover { background: #27ae60; }
        .btn-blue { background: #3498db; }
        .btn-blue:hover { background: #2980b9; }
        .btn-red { background: #e74c3c; margin-top: 10px; }
        .btn-secondary { background: #95a5a6; margin-top: 10px; }

        /* Directory Table */
        table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        th { background: #f8f9fa; color: #666; padding: 12px; text-align: left; font-size: 13px; text-transform: uppercase; border-bottom: 2px solid #eee; }
        td { padding: 12px; border-bottom: 1px solid #f1f1f1; color: #444; font-size: 14px; }
        tr:hover { background: #fafafa; }

        /* Employee Checkbox List */
        .emp-checkbox-list { max-height: 250px; overflow-y: auto; border: 1px solid #eee; padding: 10px; margin-top: 8px; background: #fff; border-radius: 6px; }
        .emp-item { display: flex; align-items: center; gap: 10px; padding: 8px; border-bottom: 1px solid #f9f9f9; }
        .emp-item:hover { background: #f4f6f9; }

        /* Chat Styles */
        .chat-box { border: 1px solid #eee; height: 350px; overflow-y: auto; background: #fdfdfd; padding: 15px; border-radius: 6px; margin-top: 15px; display: flex; flex-direction: column; gap: 12px; }
        .chat-msg { padding: 10px 14px; border-radius: 12px; max-width: 80%; font-size: 13px; line-height: 1.5; }
        .msg-mine { background: #e3f2fd; align-self: flex-end; border-bottom-right-radius: 2px; }
        .msg-other { background: #f1f1f1; align-self: flex-start; border-bottom-left-radius: 2px; }

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
        <div style="font-size: 40px; margin-bottom: 10px;">👥</div>
        <div>Loading Employee Data...</div>
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
                <a href="manage_employees.jsp" class="active"><span class="nav-icon">👥</span> Employees</a>
            </li>
            <li class="nav-item">
                <a href="admin_task_monitoring.jsp"><span class="nav-icon">📝</span> Tasks</a>
            </li>
            <li class="nav-item">
                <a href="reports.jsp"><span class="nav-icon">📅</span> Attendance</a>
            </li>
            <li class="nav-item">
                <a href="admin_expenses.jsp"><span class="nav-icon">💸</span> Expenses</a>
            </li>
             <li class="nav-item">
                <a href="payroll.jsp" class="active"><span class="nav-icon">💰</span> Payroll</a>
            </li>
            <li class="nav-item">
                <a href="admin_settings.jsp"><span class="nav-icon">⚙️</span> Settings</a>
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
                <div class="page-title">Employee Management</div>
            </div>
            <div class="user-profile">
                <span id="adminEmail">Loading...</span>
                <div class="user-avatar">A</div>
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

                    <div style="display:flex; gap:15px;">
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
                    
                    <div style="display:flex; gap:15px;">
                        <div style="flex:1">
                            <label>Due Date</label>
                            <input type="date" id="taskDate">
                        </div>
                        <div style="flex:1">
                            <label>Reference Image (Optional)</label>
                            <input type="file" id="taskFile" accept="image/*" style="padding:9px;">
                        </div>
                    </div>

                    <button onclick="assignTask()" id="assignBtn" class="btn-action btn-green">Assign Task</button>
                </div>

                <div class="card half-width">
                    <h3>👥 Employee Directory</h3>
                    <table>
                        <thead><tr><th>Name</th><th>Email</th><th>Contact</th></tr></thead>
                        <tbody id="empTableBody"><tr><td colspan="3">Loading...</td></tr></tbody>
                    </table>
                </div>
            </div>

            <div id="tab-project" class="tab-content">
                
                <div class="card half-width" style="flex: 0.8;">
                    <h3>📂 Project Management</h3>
                    
                    <div style="background:#e3f2fd; padding:15px; border-radius:6px; border:1px solid #bbdefb; margin-bottom:20px;">
                        <h4 style="margin:0 0 10px 0; color:#1565c0;">Select Active Project</h4>
                        <select id="projectSelect" onchange="handleProjectChange()" style="margin:0;">
                            <option value="">-- CREATE NEW PROJECT --</option>
                        </select>
                    </div>

                    <div id="createMode">
                        <h4 style="margin-bottom:15px; padding-top:10px; border-top:1px solid #eee;">Create New Group</h4>
                        <label>New Project Name</label>
                        <input type="text" id="newProjName" placeholder="e.g. Alpha Team">
                        
                        <label>Select Members</label>
                        <div id="createCheckboxes" class="emp-checkbox-list"></div>
                        
                        <button class="btn-action btn-blue" onclick="createProject()">Create Project Group</button>
                    </div>

                    <div id="editMode" style="display:none;">
                        <h4 style="margin-bottom:15px; padding-top:10px; border-top:1px solid #eee;">
                            Edit Project: <span id="editProjTitle" style="color:#2980b9"></span>
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
                        <div style="font-size:12px; color:#666; margin-bottom:5px;">
                            Broadcasting to: <b id="chatProjName"></b>
                        </div>
                        <div id="projectChatBox" class="chat-box"></div>
                        
                        <div style="display:flex; gap:10px; margin-top:15px;">
                            <input type="text" id="projMsgInput" placeholder="Type a message to the group..." style="margin:0;">
                            <button style="margin:0; width:auto; padding:0 25px;" class="btn-action btn-green" onclick="sendProjectMsg()">Send</button>
                        </div>
                    </div>
                    <div id="noProjectMsg" style="text-align:center; color:#999; margin-top:80px;">
                        <div style="font-size:40px; margin-bottom:10px;">👈</div>
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

        // --- 2. AUTH CHECK ---
        auth.onAuthStateChanged(user => {
            if (user) {
                document.getElementById("adminEmail").innerText = user.email;
                document.getElementById("loadingOverlay").style.display = "none";
                loadEmployees();
                loadProjects();
            } else {
                window.location.replace("login.jsp");
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
                    if(data.role !== 'admin') {
                        allEmployees.push(data);
                        
                        // 1. Dropdown
                        const opt = document.createElement("option");
                        opt.value = data.email;
                        opt.innerText = data.fullName + " (" + data.email + ")";
                        empSelect.appendChild(opt);

                        // 2. Table
                        // Note: Using string concatenation to prevent JSP errors
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
                    // Reset form optional
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

            db.collection("projects").doc(currentProjectID).collection("messages").add({
                text: txt,
                sender: auth.currentUser.email,
                senderName: "Admin",
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