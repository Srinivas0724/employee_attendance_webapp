<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
  response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
  response.setHeader("Pragma", "no-cache");
  response.setDateHeader("Expires", 0);
%>
<%@ page isELIgnored="true" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Manage Employees - emPower Admin</title>

<style>
/* --- GLOBAL ADMIN STYLES --- */
body { margin:0; font-family:"Segoe UI", sans-serif; background:#f4f6f9; display:flex; height:100vh; color:#333; }

/* SIDEBAR */
.sidebar { width:260px; background:#212529; color:#fff; display:flex; flex-direction:column; }
.sidebar h2 { padding:20px; margin:0; background:#c0392b; text-align:center; font-size: 22px; }
.sidebar a { display:block; padding:15px 20px; color:#adb5bd; text-decoration:none; border-left: 3px solid transparent; }
.sidebar a:hover, .sidebar a.active { background:#343a40; color:#fff; border-left: 3px solid #e74c3c; }

/* MAIN CONTENT */
.main { flex:1; display:flex; flex-direction:column; overflow-y: auto; }
.header { height:60px; background:#fff; display:flex; justify-content:space-between; align-items:center; padding:0 30px; border-bottom: 1px solid #dee2e6; }
.content { padding: 30px; }

/* TABS */
.tab-container { display: flex; gap: 10px; margin-bottom: 20px; border-bottom: 2px solid #ddd; padding-bottom: 10px; }
.tab-btn { padding: 10px 20px; border: none; background: #e9ecef; color: #555; cursor: pointer; border-radius: 5px; font-weight: bold; font-size: 14px; }
.tab-btn.active { background: #3498db; color: white; }
.tab-content { display: none; }
.tab-content.active { display: flex; gap: 30px; flex-wrap: wrap; }

/* CARDS */
.card { background: white; padding: 25px; border-radius: 8px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
.half-width { flex: 1; min-width: 300px; }
.full-width { width: 100%; }

h3 { margin-top: 0; color: #2c3e50; border-bottom: 2px solid #eee; padding-bottom: 10px; }

/* FORM ELEMENTS */
label { font-weight: bold; font-size: 13px; color: #555; display: block; margin-top: 15px; }
input, select, textarea { width: 100%; padding: 10px; margin-top: 5px; border: 1px solid #ced4da; border-radius: 4px; box-sizing: border-box; }
textarea { height: 80px; resize: vertical; }

button { margin-top: 20px; padding: 12px; width: 100%; background: #27ae60; color: white; border: none; border-radius: 4px; font-weight: bold; cursor: pointer; transition: 0.3s; }
button:hover { background: #219150; }
.btn-blue { background: #3498db; }
.btn-blue:hover { background: #2980b9; }
.btn-red { background: #e74c3c; margin-top: 10px; }
.btn-red:hover { background: #c0392b; }
.btn-secondary { background: #95a5a6; margin-top: 10px; }
.btn-secondary:hover { background: #7f8c8d; }

/* TABLE */
table { width: 100%; border-collapse: collapse; margin-top: 15px; }
th { background: #34495e; color: white; padding: 12px; text-align: left; font-size: 14px; }
td { padding: 12px; border-bottom: 1px solid #eee; color: #333; }
tr:hover { background: #f8f9fa; }

/* CHAT STYLES (PROJECT) */
.chat-box { border: 1px solid #ddd; height: 300px; overflow-y: auto; background: #f9f9f9; padding: 15px; border-radius: 4px; margin-top: 10px; display: flex; flex-direction: column; gap: 10px; }
.chat-msg { padding: 8px 12px; border-radius: 15px; max-width: 80%; font-size: 13px; line-height: 1.4; }
.msg-mine { background: #dcf8c6; align-self: flex-end; border-bottom-right-radius: 0; }
.msg-other { background: #e9ecef; align-self: flex-start; border-bottom-left-radius: 0; }

.emp-checkbox-list { max-height: 200px; overflow-y: auto; border: 1px solid #ccc; padding: 10px; margin-top: 5px; background: #fafafa; border-radius: 4px; }
.emp-item { display: flex; align-items: center; gap: 10px; margin-bottom: 5px; padding: 5px; border-bottom: 1px solid #eee; }
.emp-item:last-child { border-bottom: none; }

#loadingOverlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: white; z-index: 9999; display: flex; justify-content: center; align-items: center; font-size: 24px; color: #333; }
</style>

<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-auth-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-firestore-compat.js"></script>
</head>
<body>

<div id="loadingOverlay">⌛ Loading System...</div>

<div id="mainApp" style="display:none; width: 100%; height: 100%;">
    
    <div class="sidebar">
      <h2>ADMIN PORTAL</h2>
      <a href="admin_dashboard.jsp">📊 Dashboard</a>
      <a href="manage_employees.jsp" class="active">👥 Manage Employees</a>
      <a href="admin_task_monitoring.jsp">📝 Task Monitoring</a>
      <a href="reports.jsp">📅 Attendance Reports</a>
      <a href="payroll.jsp">💰 Payroll Management</a>
      <a href="admin_expenses.jsp" class="active">💸 Expense Approvals</a>
      <a href="admin_settings.jsp">⚙️ Settings</a>
      <a href="#" onclick="logout()" style="margin-top:auto; background:#1a1d20;">🚪 Logout</a>
    </div>

    <div class="main">
        <div class="header">
            <h3>Manage Employees & Projects</h3>
            <span id="adminEmail" style="font-weight:bold; color:#555;">Loading...</span>
        </div>

        <div class="content">
            
            <div class="tab-container">
                <button class="tab-btn active" onclick="switchTab('individual')">👤 Individual Assignment</button>
                <button class="tab-btn" onclick="switchTab('project')">🚀 Project Groups</button>
            </div>

            <div id="tab-individual" class="tab-content active">
                <div class="card half-width">
                    <h3>📝 Assign Individual Task</h3>
                    <label>Select Employee</label>
                    <select id="empSelect">
                        <option value="">-- Choose Employee --</option>
                    </select>

                    <label>Task Title</label>
                    <input type="text" id="taskTitle" placeholder="e.g. Complete Site Report">
                    
                    <label>Description</label>
                    <textarea id="taskDesc" placeholder="Enter instructions..."></textarea>

                    <div style="display:flex; gap:10px;">
                        <div style="flex:1"><label>Project</label><input type="text" id="taskProject" placeholder="General"></div>
                        <div style="flex:1">
                            <label>Priority</label>
                            <select id="taskPriority">
                                <option value="LOW">Low</option>
                                <option value="MEDIUM" selected>Medium</option>
                                <option value="HIGH">High</option>
                            </select>
                        </div>
                    </div>
                    
                    <div style="display:flex; gap:10px;">
                        <div style="flex:1"><label>Due Date</label><input type="date" id="taskDate"></div>
                        <div style="flex:1"><label>Ref Image</label><input type="file" id="taskFile" accept="image/*"></div>
                    </div>

                    <button onclick="assignTask()" id="assignBtn">Assign Task</button>
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
                    
                    <div style="background:#f1f8ff; padding:15px; border-radius:5px; border:1px solid #cce5ff; margin-bottom:20px;">
                        <h4 style="margin-top:0;">Select Active Project</h4>
                        <select id="projectSelect" onchange="handleProjectChange()">
                            <option value="">-- CREATE NEW PROJECT --</option>
                        </select>
                    </div>

                    <div id="createMode">
                        <h4 style="margin-bottom:10px; border-top:1px solid #eee; padding-top:15px;">Create New Project Group</h4>
                        <label>New Project Name</label>
                        <input type="text" id="newProjName" placeholder="e.g. Alpha Team">
                        
                        <label>Select Initial Members</label>
                        <div id="createCheckboxes" class="emp-checkbox-list"></div>
                        
                        <button class="btn-blue" onclick="createProject()">Create Project Group</button>
                    </div>

                    <div id="editMode" style="display:none;">
                        <h4 style="margin-bottom:10px; border-top:1px solid #eee; padding-top:15px;">Edit Project: <span id="editProjTitle" style="color:#007bff"></span></h4>
                        
                        <label>Project Name</label>
                        <input type="text" id="editProjName">

                        <label>Manage Members (Check/Uncheck)</label>
                        <div id="editCheckboxes" class="emp-checkbox-list"></div>

                        <button class="btn-blue" onclick="updateProject()">💾 Save Changes</button>
                        <button class="btn-red" onclick="deleteProject()">🗑️ Delete Project</button>
                        <button class="btn-secondary" onclick="resetToCreateMode()">❌ Cancel</button>
                    </div>
                </div>

                <div class="card half-width">
                    <h3>💬 Project Group Chat</h3>
                    <div id="chatContainer" style="display:none;">
                        <div style="font-size:12px; color:#666; margin-bottom:5px;">
                            Broadcasting to: <b id="chatProjName"></b>
                        </div>
                        <div id="projectChatBox" class="chat-box"></div>
                        
                        <div style="display:flex; gap:10px; margin-top:10px;">
                            <input type="text" id="projMsgInput" placeholder="Type a message to the group...">
                            <button style="margin:0; width:auto;" onclick="sendProjectMsg()">Send</button>
                        </div>
                    </div>
                    <div id="noProjectMsg" style="text-align:center; color:#999; margin-top:50px;">
                        Select a project from the left to start chatting.
                    </div>
                </div>

            </div>

        </div>
    </div>
</div>

<script>
const firebaseConfig = { apiKey: "AIzaSyCV5tKJMLOVcXiZUyuJZhLWOOSD96gsmP0", authDomain: "attendencewebapp-4215b.firebaseapp.com", projectId: "attendencewebapp-4215b" };
if (!firebase.apps.length) firebase.initializeApp(firebaseConfig);
const auth = firebase.auth();
const db = firebase.firestore();

let allEmployees = [];
let currentProjectID = null;
let projectChatListener = null;

/* AUTH CHECK */
auth.onAuthStateChanged(user => {
  if (user) {
      document.getElementById("adminEmail").innerText = user.email;
      document.getElementById("loadingOverlay").style.display = "none";
      document.getElementById("mainApp").style.display = "flex";
      loadEmployees();
      loadProjects();
  } else {
      window.location.replace("login.jsp");
  }
});

/* TAB SWITCHING */
function switchTab(tabName) {
    document.querySelectorAll('.tab-content').forEach(el => el.classList.remove('active'));
    document.querySelectorAll('.tab-btn').forEach(el => el.classList.remove('active'));
    
    document.getElementById('tab-' + tabName).classList.add('active');
    const btns = document.querySelectorAll('.tab-btn');
    if(tabName === 'individual') btns[0].classList.add('active');
    else btns[1].classList.add('active');
}

/* LOAD EMPLOYEES */
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
                tbody.innerHTML += "<tr><td>" + data.fullName + "</td><td>" + data.email + "</td><td>" + (data.contact||'-') + "</td></tr>";

                // 3. Create Checkboxes
                createBox.innerHTML += "<div class='emp-item'><input type='checkbox' value='" + data.email + "' class='create-member-check'> <span>" + data.fullName + " (" + data.email + ")</span></div>";
                
                // 4. Edit Checkboxes (Empty initially)
                editBox.innerHTML += "<div class='emp-item'><input type='checkbox' value='" + data.email + "' class='edit-member-check'> <span>" + data.fullName + " (" + data.email + ")</span></div>";
            }
        });
    });
}

/* INDIVIDUAL TASK ASSIGNMENT */
function assignTask() {
    const assignedTo = document.getElementById("empSelect").value;
    const title = document.getElementById("taskTitle").value;
    const desc = document.getElementById("taskDesc").value;
    const project = document.getElementById("taskProject").value;
    const priority = document.getElementById("taskPriority").value;
    const dueDate = document.getElementById("taskDate").value;
    const fileInput = document.getElementById("taskFile");
    const btn = document.getElementById("assignBtn");

    if(!assignedTo || !title || !dueDate) { alert("Please fill all fields."); return; }

    btn.innerText = "Assigning..."; btn.disabled = true;

    const save = (photo) => {
        db.collection("tasks").add({
            assignedTo: assignedTo,
            assignedBy: auth.currentUser.email,
            title: title, description: desc, project: project || "General",
            priority: priority, dueDate: dueDate, status: "PENDING",
            photo: photo, timestamp: firebase.firestore.FieldValue.serverTimestamp()
        }).then(() => {
            alert("✅ Task Assigned!");
            btn.innerText = "Assign Task"; btn.disabled = false;
        });
    };

    if(fileInput.files.length > 0) {
        const reader = new FileReader();
        reader.onload = e => save(e.target.result);
        reader.readAsDataURL(fileInput.files[0]);
    } else { save(null); }
}

/* --- PROJECT MANAGEMENT LOGIC --- */

function loadProjects() {
    db.collection("projects").onSnapshot(snap => {
        const select = document.getElementById("projectSelect");
        // Save current selection to restore after refresh if possible
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
        // Show Create Mode
        resetToCreateMode();
    } else {
        // Show Edit Mode
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
        alert("Enter a Project Name and select at least one member.");
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
    
    // Switch UI to Edit Mode
    document.getElementById("createMode").style.display = "none";
    document.getElementById("editMode").style.display = "block";
    
    // Fetch Project Data
    db.collection("projects").doc(projId).get().then(doc => {
        if(doc.exists) {
            const data = doc.data();
            document.getElementById("editProjName").value = data.name;
            document.getElementById("editProjTitle").innerText = data.name;
            
            // Check the boxes for current members
            const checkboxes = document.querySelectorAll(".edit-member-check");
            checkboxes.forEach(cb => {
                cb.checked = data.members.includes(cb.value);
            });
            
            // Load Chat
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
    if(!confirm("Are you sure you want to delete this project? This cannot be undone.")) return;
    
    db.collection("projects").doc(currentProjectID).delete().then(() => {
        alert("🗑️ Project Deleted.");
        resetToCreateMode();
    });
}

/* --- CHAT LOGIC --- */

function loadProjectChat(projId, projName) {
    const chatContainer = document.getElementById("chatContainer");
    const noProjectMsg = document.getElementById("noProjectMsg");
    const chatBox = document.getElementById("projectChatBox");

    document.getElementById("chatProjName").innerText = projName;
    chatContainer.style.display = "block";
    noProjectMsg.style.display = "none";
    chatBox.innerHTML = "<div style='text-align:center; color:#999'>Loading history...</div>";

    // Listen to Messages
    if(projectChatListener) projectChatListener();
    
    projectChatListener = db.collection("projects").doc(projId).collection("messages")
        .orderBy("timestamp", "asc")
        .onSnapshot(snap => {
            chatBox.innerHTML = "";
            snap.forEach(doc => {
                const m = doc.data();
                const isMine = m.sender === auth.currentUser.email;
                const mineClass = isMine ? "msg-mine" : "msg-other";
                
                // FIXED: Using String Concatenation to avoid JSP Errors
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
  auth.signOut().then(() => {
    window.location.replace("login.jsp");
  });
}
</script>

</body>
</html>