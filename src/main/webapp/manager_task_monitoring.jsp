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
    <title>Task Monitoring - Manager Portal</title>
    
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

        /* --- 4. CONTENT --- */
        .content { padding: 40px; max-width: 1400px; margin: 0 auto; width: 100%; display: flex; flex-direction: column; gap: 30px; }
        
        .card { 
            background: white; 
            padding: 30px; 
            border-radius: 16px; 
            box-shadow: var(--card-shadow); 
            border-top: 4px solid var(--primary-navy); 
        }
        
        h3 { 
            margin-top: 0; 
            color: var(--primary-navy); 
            border-bottom: 1px solid #f1f1f1; 
            padding-bottom: 15px; 
            margin-bottom: 25px; 
            font-size: 18px; 
            font-weight: 700; 
        }

        /* Grid Layout */
        .grid-row { display: grid; grid-template-columns: 1fr 1.5fr; gap: 30px; }

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
        
        /* Table */
        table { width: 100%; border-collapse: separate; border-spacing: 0; }
        th { 
            background: #f8f9fa; color: var(--text-grey); padding: 15px; 
            text-align: left; font-size: 12px; text-transform: uppercase; letter-spacing: 1px;
            border-bottom: 2px solid #eee; font-weight: 700;
        }
        td { 
            padding: 15px; border-bottom: 1px solid #f1f1f1; 
            color: var(--text-dark); font-size: 14px; vertical-align: middle;
        }
        tr:hover td { background: #fcfcfc; }

        /* Badges */
        .badge { padding: 6px 12px; border-radius: 20px; font-size: 11px; font-weight: 700; color: white; display: inline-block; }
        .PENDING { background: #e74c3c; }
        .IN_PROGRESS { background: #f39c12; }
        .DONE { background: #27ae60; }

        /* Chat Button */
        .btn-chat { 
            background: #3498db; color: white; border: none; padding: 8px 16px; 
            border-radius: 6px; cursor: pointer; font-size: 12px; font-weight: 600; 
            transition: all 0.2s;
        }
        .btn-chat:hover { background: #2980b9; transform: translateY(-2px); }

        /* --- MODAL --- */
        .modal { display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; background-color: rgba(0,0,0,0.6); backdrop-filter: blur(5px); align-items: center; justify-content: center; }
        .modal-content { background-color: #fff; width: 600px; max-width: 90%; height: 85vh; border-radius: 16px; display: flex; flex-direction: column; overflow: hidden; box-shadow: 0 20px 50px rgba(0,0,0,0.2); }

        .modal-header { background: var(--primary-navy); color: white; padding: 20px 25px; display: flex; justify-content: space-between; align-items: center; }
        .modal-title { font-size: 18px; font-weight: 700; }
        .close-btn { background: none; border: none; color: white; font-size: 24px; cursor: pointer; opacity: 0.8; }
        .close-btn:hover { opacity: 1; }

        .modal-body { flex: 1; padding: 25px; overflow-y: auto; display: flex; flex-direction: column; gap: 20px; background: #f8f9fa; }

        .task-info-box { background: white; padding: 20px; border-radius: 10px; border: 1px solid #eee; box-shadow: 0 4px 10px rgba(0,0,0,0.02); }
        .task-info-box h3 { border: none; margin: 0 0 5px 0; padding: 0; font-size: 18px; color: var(--primary-navy); }

        /* Chat Area */
        .chat-section { display: flex; flex-direction: column; flex: 1; background: white; border: 1px solid #eee; border-radius: 10px; overflow: hidden; }
        .chat-header { padding: 15px; background: #f9f9f9; font-size: 13px; font-weight: 600; color: var(--text-grey); border-bottom: 1px solid #eee; }
        
        .chat-messages { flex: 1; padding: 20px; overflow-y: auto; display: flex; flex-direction: column; gap: 15px; background: #fff; }

        .msg-bubble { padding: 12px 16px; border-radius: 15px; max-width: 80%; font-size: 14px; line-height: 1.5; position: relative; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
        .msg-mine { background: #dcf8c6; align-self: flex-end; border-bottom-right-radius: 2px; color: var(--text-dark); }
        .msg-other { background: #f1f1f1; align-self: flex-start; border-bottom-left-radius: 2px; color: var(--text-dark); }
        
        .msg-meta { font-size: 11px; color: var(--text-grey); margin-top: 5px; display: block; text-align: right; }

        .chat-input-area { padding: 15px; border-top: 1px solid #eee; display: flex; gap: 10px; background: #fafafa; }
        .chat-input { flex: 1; padding: 12px; border: 1px solid #ddd; border-radius: 25px; outline: none; font-size: 14px; }
        .btn-send { background: var(--primary-navy); color: white; border: none; padding: 0 25px; border-radius: 25px; cursor: pointer; font-weight: 700; font-size: 13px; transition: all 0.2s; }
        .btn-send:hover { background: #132c52; transform: scale(1.05); }

        #loadingOverlay { 
            position: fixed; top: 0; left: 0; width: 100%; height: 100%; 
            background: rgba(255,255,255,0.8); backdrop-filter: blur(5px);
            z-index: 9999; display: flex; justify-content: center; align-items: center; 
            font-size: 24px; color: var(--primary-navy); flex-direction: column; gap: 15px; font-weight: 600;
        }

        @media (max-width: 900px) {
            .sidebar { position: fixed; left: -280px; height: 100%; }
            .sidebar.active { transform: translateX(280px); }
            .content { padding: 20px; }
            .topbar { padding: 0 20px; }
            .toggle-btn { display: block; font-size: 24px; cursor: pointer; margin-right: 15px; }
            .grid-row { grid-template-columns: 1fr; }
        }
        @media (min-width: 901px) { .toggle-btn { display: none; } }
    </style>

    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-auth-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-firestore-compat.js"></script>
</head>
<body>

    <div id="loadingOverlay">
        <div style="font-size: 50px;">📝</div>
        <div>Loading Task Manager...</div>
    </div>

    <nav class="sidebar" id="sidebar">
        <div class="sidebar-header">
            <img src="synod_logo.png" alt="Synod Logo" class="sidebar-logo">
            <div class="sidebar-brand">MANAGER PORTAL</div>
        </div>

        <ul class="nav-menu">
            <li class="nav-item">
                <a href="manager_dashboard.jsp"><span class="nav-icon">📊</span> Overview</a>
            </li>
            <li class="nav-item">
                <a href="manager_mark_attendance.jsp"><span class="nav-icon">📍</span> My Attendance</a>
            </li>
            <li class="nav-item">
                <a href="manager_manage_employees.jsp"><span class="nav-icon">👥</span> Assign Tasks</a>
            </li>
            <li class="nav-item">
                <a href="manager_task_monitoring.jsp" class="active"><span class="nav-icon">📝</span> Task Monitoring</a>
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
            <div style="display:flex; align-items:center;">
                <div class="toggle-btn" onclick="toggleSidebar()">☰</div>
                <div class="page-title">Task Management</div>
            </div>
            <div class="user-profile">
                <span id="mgrEmail" class="user-email">Loading...</span>
                <div class="user-avatar">M</div>
            </div>
        </header>

        <div class="content">
            
            <div class="grid-row">
                <div class="card">
                    <h3>📝 Assign New Task</h3>
                    <label>Select Employee</label>
                    <select id="empSelect">
                        <option value="">-- Choose Employee --</option>
                    </select>

                    <label>Task Title</label>
                    <input type="text" id="taskTitle" placeholder="e.g. Weekly Report">
                    
                    <label>Description</label>
                    <textarea id="taskDesc" placeholder="Enter detailed task instructions..."></textarea>

                    <div style="display:flex; gap:20px;">
                        <div style="flex:1">
                            <label>Project</label>
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
                            <label>Attachment</label>
                            <input type="file" id="taskFile" accept="image/*" style="padding:11px;">
                        </div>
                    </div>

                    <button onclick="assignTask()" id="assignBtn" class="btn-action btn-green">Assign Task</button>
                </div>

                <div class="card">
                    <h3>📋 All Assigned Tasks</h3>
                    <p style="color:var(--text-grey); font-size:13px; margin-top:0;">Monitor progress and chat with team members.</p>
                    
                    <div style="max-height:600px; overflow-y:auto;">
                        <table>
                            <thead>
                                <tr>
                                    <th>Assigned To</th>
                                    <th>Title</th>
                                    <th>Status</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody id="taskTableBody">
                                <tr><td colspan="4" style="text-align:center; padding:20px;">Loading...</td></tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

        </div>
    </div>

    <div id="taskModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <div class="modal-title">Task Discussion</div>
                <button class="close-btn" onclick="closeModal()">×</button>
            </div>
            <div class="modal-body">
                
                <div class="task-info-box">
                    <h3 id="mTitle"></h3>
                    <div style="font-size:13px; color:var(--text-grey); margin-bottom:10px;">
                        Assigned To: <b id="mAssignee" style="color:var(--text-dark);"></b>
                    </div>
                    <p id="mDesc" style="color:var(--text-dark); font-size:14px; line-height:1.6;"></p>
                    <div style="font-size:12px; color:var(--text-grey); margin-top:10px; border-top:1px solid #eee; padding-top:10px;">
                        Project: <span id="mProj" style="font-weight:600; color:var(--primary-navy);"></span>
                    </div>
                </div>

                <div class="chat-section">
                    <div class="chat-header">Conversation History</div>
                    <div id="chatMessages" class="chat-messages"></div>
                    <div class="chat-input-area">
                        <input type="text" id="chatInput" class="chat-input" placeholder="Type a reply...">
                        <button class="btn-send" onclick="sendReply()">Reply</button>
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

        let currentTaskId = null;
        let currentUserEmail = null;
        let currentUserRole = "manager";
        let chatListener = null;

        // --- 2. AUTH CHECK & ROLE MANAGER ---
        auth.onAuthStateChanged(user => {
            if (user) {
                db.collection("users").doc(user.email).get().then(doc => {
                    const role = doc.data().role;
                    if (role !== 'manager' && role !== 'admin') {
                        window.location.href = "login.jsp"; 
                        return;
                    }
                    
                    currentUserEmail = user.email;
                    document.getElementById("mgrEmail").innerText = user.email;
                    
                    loadEmployees(); // Load dropdown
                    loadAllTasks(); // Load table
                    
                    document.getElementById("loadingOverlay").style.display = "none";
                });
            } else {
                window.location.href = "index.html";
            }
        });

        // --- 3. LOAD EMPLOYEES (For Dropdown) ---
        function loadEmployees() {
            const select = document.getElementById("empSelect");
            select.innerHTML = '<option value="">-- Choose Employee --</option>';
            
            db.collection("users").where("role", "==", "employee").get().then(snap => {
                snap.forEach(doc => {
                    const d = doc.data();
                    const opt = document.createElement("option");
                    opt.value = d.email;
                    opt.innerText = d.fullName + " (" + d.email + ")";
                    select.appendChild(opt);
                });
            });
        }

        // --- 4. ASSIGN TASK ---
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
                    assignedBy: currentUserEmail, // Track Manager
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

        // --- 5. LOAD ALL TASKS ---
        function loadAllTasks() {
            db.collection("tasks").orderBy("timestamp", "desc").onSnapshot(snap => {
                const tbody = document.getElementById("taskTableBody");
                if(snap.empty) {
                    tbody.innerHTML = "<tr><td colspan='4' style='text-align:center;'>No tasks assigned.</td></tr>";
                    return;
                }

                let rows = "";
                snap.forEach(doc => {
                    const d = doc.data();
                    const id = doc.id;
                    const safeData = encodeURIComponent(JSON.stringify(d));

                    rows += "<tr>";
                    rows += "<td>" + d.assignedTo + "</td>";
                    rows += "<td><b>" + d.title + "</b></td>";
                    rows += "<td><span class='badge " + d.status + "'>" + d.status + "</span></td>";
                    rows += "<td><button class='btn-chat' onclick='openTask(\"" + id + "\", \"" + safeData + "\")'>Chat</button></td>";
                    rows += "</tr>";
                });
                tbody.innerHTML = rows;
            });
        }

        // --- 6. CHAT LOGIC ---
        function openTask(id, encodedData) {
            currentTaskId = id;
            const d = JSON.parse(decodeURIComponent(encodedData));

            document.getElementById("mTitle").innerText = d.title;
            document.getElementById("mAssignee").innerText = d.assignedTo;
            document.getElementById("mDesc").innerText = d.description;
            document.getElementById("mProj").innerText = d.project;

            document.getElementById("taskModal").style.display = "flex";
            loadChat(id);
        }

        function loadChat(taskId) {
            const chatBox = document.getElementById("chatMessages");
            chatBox.innerHTML = "<div style='text-align:center; color:#999; margin-top:10px;'>Loading...</div>";

            if(chatListener) chatListener();

            chatListener = db.collection("tasks").doc(taskId).collection("replies")
                .orderBy("timestamp", "asc")
                .onSnapshot(snap => {
                    chatBox.innerHTML = "";
                    if(snap.empty) chatBox.innerHTML = "<div style='text-align:center; color:#ccc;'>No messages.</div>";

                    snap.forEach(doc => {
                        const m = doc.data();
                        const isMine = m.email === currentUserEmail; 
                        const bubbleClass = isMine ? "msg-mine" : "msg-other";
                        let senderName = "Employee";
                        
                        if (m.role === 'admin') senderName = "Admin";
                        if (m.role === 'manager') senderName = "Manager";
                        if (isMine) senderName = "Me";

                        let msgHtml = "<div class='msg-bubble " + bubbleClass + "'>";
                        msgHtml += "<div>" + m.message + "</div>";
                        msgHtml += "<span class='msg-meta'>" + senderName + "</span>";
                        msgHtml += "</div>";
                        chatBox.innerHTML += msgHtml;
                    });
                    chatBox.scrollTop = chatBox.scrollHeight;
                });
        }

        function sendReply() {
            const input = document.getElementById("chatInput");
            const msg = input.value.trim();
            if(!msg) return;

            db.collection("tasks").doc(currentTaskId).collection("replies").add({
                message: msg,
                email: currentUserEmail,
                role: 'manager', 
                timestamp: firebase.firestore.FieldValue.serverTimestamp()
            }).then(() => input.value = "").catch(e => alert("Error: " + e.message));
        }

        function closeModal() {
            document.getElementById("taskModal").style.display = "none";
            if(chatListener) chatListener();
        }

        function logout() { auth.signOut().then(() => window.location.href = "index.html"); }
        function toggleSidebar() { document.getElementById("sidebar").classList.toggle("open"); }
    </script>
</body>
</html>