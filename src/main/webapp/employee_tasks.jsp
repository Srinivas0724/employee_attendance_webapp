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
    <title>My Tasks - Synod Bioscience</title>
    
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
            --border-color: #e0e0e0;
        }

        body { display: flex; height: 100vh; background-color: var(--bg-light); overflow: hidden; }

        /* --- 2. SIDEBAR --- */
        .sidebar {
            width: var(--sidebar-width);
            background-color: var(--primary-navy);
            color: white;
            display: flex;
            flex-direction: column;
            transition: transform 0.3s ease-in-out;
            flex-shrink: 0;
            z-index: 1000;
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
            position: relative;
        }

        /* Top Bar */
        .topbar {
            background: white;
            height: 60px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 0 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
            position: sticky; top: 0; z-index: 100;
        }

        .toggle-btn { display: none; font-size: 24px; cursor: pointer; color: var(--primary-navy); margin-right: 15px; }
        .page-title { font-size: 18px; font-weight: bold; color: var(--primary-navy); }
        .user-profile { font-size: 14px; color: var(--text-grey); display: flex; align-items: center; gap: 10px; }
        .user-avatar { width: 35px; height: 35px; background: #e0e0e0; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: bold; color: var(--primary-navy); }

        /* --- 4. TABS & LAYOUT --- */
        .content { padding: 20px; max-width: 1200px; margin: 0 auto; width: 100%; }

        .tab-nav { display: flex; gap: 15px; margin-bottom: 20px; border-bottom: 2px solid #eee; padding-bottom: 10px; }
        .tab-btn {
            background: transparent; border: none; padding: 10px 20px;
            font-size: 15px; font-weight: 600; color: #777;
            cursor: pointer; border-radius: 20px; transition: 0.3s;
        }
        .tab-btn.active { background: var(--primary-navy); color: white; box-shadow: 0 4px 6px rgba(26, 59, 110, 0.2); }
        .tab-btn:hover:not(.active) { background: #e9ecef; }

        .tab-pane { display: none; animation: fadeIn 0.3s; }
        .tab-pane.active { display: block; }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(5px); } to { opacity: 1; transform: translateY(0); } }

        /* Cards */
        .card { background: white; padding: 25px; border-radius: 10px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); border: 1px solid #f1f1f1; }
        
        /* Table */
        .table-responsive { overflow-x: auto; }
        table { width: 100%; border-collapse: collapse; min-width: 600px; }
        th { text-align: left; padding: 15px; background: #f8f9fa; color: #555; font-size: 13px; text-transform: uppercase; font-weight: 700; border-bottom: 2px solid #eee; }
        td { padding: 15px; border-bottom: 1px solid #f1f1f1; font-size: 14px; color: #333; vertical-align: middle; }
        tr:hover { background-color: #fafafa; }

        /* Badges */
        .badge { padding: 5px 12px; border-radius: 12px; font-size: 11px; font-weight: bold; color: white; display: inline-block; }
        .bg-HIGH { background-color: #e74c3c; }
        .bg-MEDIUM { background-color: #f39c12; }
        .bg-LOW { background-color: #2ecc71; }

        /* Status Select */
        .status-select { padding: 6px 10px; border-radius: 6px; font-size: 12px; font-weight: bold; border: 1px solid transparent; cursor: pointer; outline: none; }
        .status-select.PENDING { background: #fff0f0; color: #c0392b; border-color: #ffcccc; }
        .status-select.IN_PROGRESS { background: #fff8e1; color: #d35400; border-color: #ffe0b2; }
        .status-select.DONE { background: #e8f5e9; color: #27ae60; border-color: #c8e6c9; }

        .btn-action { background: var(--primary-navy); color: white; border: none; padding: 6px 15px; border-radius: 4px; font-size: 12px; cursor: pointer; font-weight: 600; }
        .btn-action:hover { background: #132c52; }

        /* --- 5. PROJECT CHAT LAYOUT --- */
        .chat-layout { display: flex; gap: 20px; height: 500px; }
        .chat-sidebar { width: 250px; border-right: 1px solid #eee; display: flex; flex-direction: column; gap: 10px; padding-right: 20px; }
        .chat-main { flex: 1; display: flex; flex-direction: column; background: #f9f9f9; border-radius: 8px; border: 1px solid #eee; overflow: hidden; }
        
        .chat-header { padding: 15px; background: white; border-bottom: 1px solid #eee; font-weight: bold; color: var(--primary-navy); }
        .chat-messages { flex: 1; overflow-y: auto; padding: 20px; display: flex; flex-direction: column; gap: 15px; }
        
        /* Chat Bubbles */
        .msg-bubble { max-width: 75%; padding: 10px 15px; border-radius: 15px; font-size: 13px; line-height: 1.4; position: relative; box-shadow: 0 1px 2px rgba(0,0,0,0.05); }
        .msg-mine { align-self: flex-end; background: #dcf8c6; color: #333; border-bottom-right-radius: 2px; }
        .msg-other { align-self: flex-start; background: white; color: #333; border-bottom-left-radius: 2px; }
        .msg-info { font-size: 10px; color: #777; margin-top: 4px; display: block; text-align: right; }
        .msg-sender { font-size: 11px; font-weight: bold; color: var(--primary-navy); display: block; margin-bottom: 2px; }

        .chat-input-area { padding: 15px; background: white; border-top: 1px solid #eee; display: flex; gap: 10px; }
        .chat-input { flex: 1; padding: 12px; border: 1px solid #ddd; border-radius: 25px; outline: none; transition: 0.3s; }
        .chat-input:focus { border-color: var(--primary-navy); }
        .btn-send { background: var(--primary-green); color: white; border: none; width: 45px; height: 45px; border-radius: 50%; cursor: pointer; display: flex; align-items: center; justify-content: center; font-size: 18px; }
        .btn-send:hover { background: #27ae60; }

        /* --- 6. MODAL --- */
        .modal { display: none; position: fixed; z-index: 2000; left: 0; top: 0; width: 100%; height: 100%; background-color: rgba(0,0,0,0.5); align-items: center; justify-content: center; backdrop-filter: blur(2px); }
        .modal-content { background-color: white; width: 600px; max-width: 90%; height: 80vh; border-radius: 12px; display: flex; flex-direction: column; overflow: hidden; box-shadow: 0 20px 50px rgba(0,0,0,0.2); }
        .modal-header { padding: 15px 20px; background: var(--primary-navy); color: white; display: flex; justify-content: space-between; align-items: center; }
        .modal-title { font-size: 16px; font-weight: bold; }
        .close-btn { background: none; border: none; color: white; font-size: 24px; cursor: pointer; }
        
        .task-details { padding: 20px; background: #f8f9fa; border-bottom: 1px solid #eee; }
        .task-details h3 { margin: 0 0 5px 0; color: #333; font-size: 18px; }
        .task-meta { font-size: 13px; color: #666; display: flex; gap: 15px; margin-top: 5px; }

        /* Loader */
        #loadingOverlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: white; z-index: 9999; display: flex; justify-content: center; align-items: center; font-size: 24px; color: #333; flex-direction: column; gap: 10px; }

        /* Mobile Responsive */
        @media (max-width: 900px) {
            .sidebar { position: fixed; left: -260px; height: 100%; width: 260px; }
            .sidebar.active { transform: translateX(260px); }
            .toggle-btn { display: block; }
            
            .chat-layout { flex-direction: column; height: auto; }
            .chat-sidebar { width: 100%; border-right: none; border-bottom: 1px solid #eee; padding-bottom: 15px; padding-right: 0; }
            .chat-main { height: 400px; }
        }
    </style>

    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-auth-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-firestore-compat.js"></script>
</head>
<body>

    <div id="loadingOverlay">
        <div style="font-size: 40px; margin-bottom: 10px;">📝</div>
        <div>Loading Tasks...</div>
    </div>

    <nav class="sidebar" id="sidebar">
        <div class="sidebar-header">
            <img src="synod_logo.png" alt="Synod Logo" class="sidebar-logo">
            <div class="sidebar-brand">EMPLOYEE PORTAL</div>
        </div>

        <ul class="nav-menu">
            <li class="nav-item">
                <a href="mark_attendance.jsp"><span class="nav-icon">📍</span> Mark Attendance</a>
            </li>
            <li class="nav-item">
                <a href="employee_tasks.jsp" class="active"><span class="nav-icon">📝</span> Assigned Tasks</a>
            </li>
            <li class="nav-item">
                <a href="attendance_history.jsp"><span class="nav-icon">🕒</span> History</a>
            </li>
            <li class="nav-item">
                <a href="employee_expenses.jsp"><span class="nav-icon">💸</span> My Expenses</a>
            </li>
            <li class="nav-item">
                <a href="salary.jsp"><span class="nav-icon">💰</span> My Salary</a>
            </li>
            <li class="nav-item">
                <a href="settings.jsp"><span class="nav-icon">⚙️</span> Settings</a>
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
                <div class="page-title">Work & Projects</div>
            </div>
            <div class="user-profile">
                <span id="userEmail">Loading...</span>
                <div class="user-avatar">E</div>
            </div>
        </header>

        <div class="content">
            
            <div class="tab-nav">
                <button class="tab-btn active" onclick="switchTab('tasks')">📋 My Tasks</button>
                <button class="tab-btn" onclick="switchTab('projects')">🚀 Project Groups</button>
            </div>

            <div id="tab-tasks" class="tab-pane active">
                <div class="card">
                    <p style="color:#666; margin-top:0; font-size:14px; margin-bottom:20px;">
                        Update statuses or click <b>"View & Reply"</b> to discuss tasks with admins.
                    </p>
                    
                    <div class="table-responsive">
                        <table>
                            <thead>
                                <tr>
                                    <th>Task Title</th>
                                    <th>Project</th>
                                    <th>Priority</th>
                                    <th>Status</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody id="myTasksTable">
                                <tr><td colspan="5" style="text-align:center; padding:20px;">Loading tasks...</td></tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <div id="tab-projects" class="tab-pane">
                <div class="card">
                    <div class="chat-layout">
                        <div class="chat-sidebar">
                            <h4 style="margin:0 0 10px 0; color:var(--primary-navy);">📂 Select Project</h4>
                            <select id="empProjectSelect" onchange="loadProjectChat()" style="width:100%; padding:10px; border-radius:6px; border:1px solid #ddd;">
                                <option value="">-- Choose a Project --</option>
                            </select>
                            <p style="font-size:13px; color:#777; line-height:1.4;">
                                Select a project to join the group discussion. Only projects you are assigned to will appear here.
                            </p>
                        </div>

                        <div class="chat-main">
                            <div class="chat-header">
                                <span id="chatProjName">Select a project...</span>
                            </div>
                            
                            <div id="projectChatBox" class="chat-messages">
                                <div style="text-align:center; color:#ccc; margin-top:50px;">👈 Select a project to start chatting</div>
                            </div>
                            
                            <div id="projInputArea" class="chat-input-area" style="display:none;">
                                <input type="text" id="projMsgInput" class="chat-input" placeholder="Type a message to the team...">
                                <button class="btn-send" onclick="sendProjectMsg()">➤</button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

        </div>
    </div>

    <div id="taskModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <span class="modal-title">Task Details</span>
                <button class="close-btn" onclick="closeModal()">×</button>
            </div>
            
            <div class="task-details">
                <h3 id="mTitle">Task Title</h3>
                <p id="mDesc" style="color:#555; font-size:14px; margin:5px 0;">Description...</p>
                <div class="task-meta">
                    <span id="mProj">Project: -</span>
                    <span id="mDate">Due: -</span>
                </div>
                <div id="mPhotoBox" style="margin-top:10px; display:none;">
                    <a id="mPhotoLink" href="#" target="_blank" style="color:var(--primary-navy); font-weight:bold; font-size:13px; text-decoration:none;">📎 View Attached Reference</a>
                </div>
            </div>

            <div class="chat-messages" id="chatMessages" style="background:#fff;">
                </div>

            <div class="chat-input-area">
                <input type="text" id="chatInput" class="chat-input" placeholder="Type a reply or update...">
                <button class="btn-send" onclick="sendReply()">➤</button>
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
        let chatListener = null; 
        let projChatListener = null; 
        let currentProjectID = null;

        // --- 2. AUTH & LOAD ---
        auth.onAuthStateChanged(user => {
            if(user) {
                currentUserEmail = user.email;
                document.getElementById("userEmail").innerText = user.email;
                document.getElementById("loadingOverlay").style.display = "none";
                loadMyTasks(user.email);
                loadEmployeeProjects(user.email);
            } else {
                window.location.href = "index.html";
            }
        });

        function toggleSidebar() {
            document.getElementById("sidebar").classList.toggle("active");
        }

        function switchTab(tabName) {
            document.querySelectorAll('.tab-pane').forEach(el => el.classList.remove('active'));
            document.querySelectorAll('.tab-btn').forEach(el => el.classList.remove('active'));
            
            document.getElementById('tab-' + tabName).classList.add('active');
            // Find specific button (hardcoded index for simplicity)
            const btns = document.querySelectorAll('.tab-btn');
            if(tabName === 'tasks') btns[0].classList.add('active');
            else btns[1].classList.add('active');
        }

        // --- 3. TASKS LOGIC ---
        function loadMyTasks(email) {
            const tbody = document.getElementById("myTasksTable");
            
            db.collection("tasks").where("assignedTo", "==", email).onSnapshot(snap => {
                if(snap.empty) {
                    tbody.innerHTML = "<tr><td colspan='5' style='text-align:center; padding:30px; color:#777;'>🎉 No active tasks assigned to you.</td></tr>";
                    return;
                }
                
                let rows = "";
                snap.forEach(doc => {
                    const d = doc.data();
                    const id = doc.id; 
                    const safeData = encodeURIComponent(JSON.stringify(d));

                    // Status Logic
                    const sP = d.status === 'PENDING' ? 'selected' : '';
                    const sI = d.status === 'IN_PROGRESS' ? 'selected' : '';
                    const sD = d.status === 'DONE' ? 'selected' : '';

                    rows += "<tr>";
                    rows += "<td><b>" + (d.title || "Untitled") + "</b></td>";
                    rows += "<td>" + (d.project || "General") + "</td>";
                    rows += "<td><span class='badge bg-" + (d.priority || "LOW") + "'>" + (d.priority || "LOW") + "</span></td>";
                    rows += "<td>";
                    rows += "<select class='status-select " + d.status + "' onchange='updateStatus(\"" + id + "\", this)'>";
                    rows += "<option value='PENDING' " + sP + ">PENDING</option>";
                    rows += "<option value='IN_PROGRESS' " + sI + ">IN PROGRESS</option>";
                    rows += "<option value='DONE' " + sD + ">DONE</option>";
                    rows += "</select>";
                    rows += "</td>";
                    rows += "<td><button class='btn-action' onclick='openTask(\"" + id + "\", \"" + safeData + "\")'>View & Reply</button></td>";
                    rows += "</tr>";
                });
                tbody.innerHTML = rows;
            });
        }

        window.updateStatus = function(docId, selectElement) {
            const newStatus = selectElement.value;
            selectElement.className = "status-select " + newStatus;
            db.collection("tasks").doc(docId).update({ status: newStatus });
        };

        // --- 4. PROJECT CHAT LOGIC ---
        function loadEmployeeProjects(email) {
            db.collection("projects").where("members", "array-contains", email).onSnapshot(snap => {
                const select = document.getElementById("empProjectSelect");
                select.innerHTML = '<option value="">-- Choose a Project --</option>';
                
                if(snap.empty) {
                    const opt = document.createElement("option");
                    opt.text = "No projects found";
                    select.appendChild(opt);
                    select.disabled = true;
                    return;
                }

                snap.forEach(doc => {
                    const p = doc.data();
                    const opt = document.createElement("option");
                    opt.value = doc.id;
                    opt.innerText = p.name;
                    select.appendChild(opt);
                });
            });
        }

        function loadProjectChat() {
            const projId = document.getElementById("empProjectSelect").value;
            const chatBox = document.getElementById("projectChatBox");
            const inputArea = document.getElementById("projInputArea");
            
            if(!projId) {
                inputArea.style.display = "none";
                chatBox.innerHTML = "<div style='text-align:center; color:#ccc; margin-top:50px;'>👈 Select a project to start chatting</div>";
                document.getElementById("chatProjName").innerText = "Select a project...";
                if(projChatListener) projChatListener();
                return;
            }

            currentProjectID = projId;
            const projName = document.getElementById("empProjectSelect").options[document.getElementById("empProjectSelect").selectedIndex].text;
            document.getElementById("chatProjName").innerText = "💬 " + projName;
            inputArea.style.display = "flex";

            if(projChatListener) projChatListener();
            
            projChatListener = db.collection("projects").doc(projId).collection("messages")
                .orderBy("timestamp", "asc")
                .onSnapshot(snap => {
                    chatBox.innerHTML = "";
                    if(snap.empty) {
                        chatBox.innerHTML = "<div style='text-align:center; color:#ccc; margin-top:20px;'>No messages yet. Say hello! 👋</div>";
                    }
                    
                    snap.forEach(doc => {
                        const m = doc.data();
                        const isMine = m.sender === currentUserEmail;
                        const bubbleClass = isMine ? "msg-mine" : "msg-other";
                        
                        let html = "<div class='msg-bubble " + bubbleClass + "'>";
                        if(!isMine) html += "<span class='msg-sender'>" + (m.senderName || "User") + "</span>";
                        html += m.text;
                        html += "</div>";
                        
                        chatBox.innerHTML += html;
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
                sender: currentUserEmail,
                senderName: "Employee",
                timestamp: firebase.firestore.FieldValue.serverTimestamp()
            }).then(() => { input.value = ""; });
        }

        // --- 5. MODAL LOGIC ---
        function openTask(id, encodedData) {
            currentTaskId = id;
            const d = JSON.parse(decodeURIComponent(encodedData));
            
            document.getElementById("mTitle").innerText = d.title;
            document.getElementById("mDesc").innerText = d.description || "No description provided.";
            document.getElementById("mDate").innerText = "Due: " + (d.dueDate || "-");
            document.getElementById("mProj").innerText = "Project: " + (d.project || "General");
            
            const photoBox = document.getElementById("mPhotoBox");
            if(d.photo) {
                photoBox.style.display = "block";
                document.getElementById("mPhotoLink").href = d.photo; 
            } else { photoBox.style.display = "none"; }
            
            document.getElementById("taskModal").style.display = "flex";
            loadTaskChat(id);
        }

        function loadTaskChat(taskId) {
            const chatBox = document.getElementById("chatMessages");
            chatBox.innerHTML = "<div style='text-align:center; padding:20px; color:#999'>Loading updates...</div>";
            
            if(chatListener) chatListener();
            
            chatListener = db.collection("tasks").doc(taskId).collection("replies").orderBy("timestamp", "asc").onSnapshot(snap => {
                chatBox.innerHTML = "";
                if(snap.empty) {
                    chatBox.innerHTML = "<div style='text-align:center; padding:20px; color:#ccc'>No discussions yet.</div>";
                    return;
                }
                
                snap.forEach(doc => {
                    const m = doc.data();
                    const isMine = m.email === currentUserEmail;
                    const bubbleClass = isMine ? "msg-mine" : "msg-other";
                    const sender = isMine ? "Me" : (m.role === 'admin' ? "Admin" : "User");
                    const time = m.timestamp ? new Date(m.timestamp.seconds * 1000).toLocaleTimeString([], {hour:'2-digit', minute:'2-digit'}) : "";

                    let html = "<div class='msg-bubble " + bubbleClass + "'>";
                    if(!isMine) html += "<span class='msg-sender'>" + sender + "</span>";
                    html += m.message;
                    html += "<span class='msg-info'>" + time + "</span>";
                    html += "</div>";
                    
                    chatBox.innerHTML += html;
                });
                chatBox.scrollTop = chatBox.scrollHeight;
            });
        }

        function sendReply() {
            const input = document.getElementById("chatInput");
            const msg = input.value.trim();
            if(!msg) return;
            
            db.collection("tasks").doc(currentTaskId).collection("replies").add({
                message: msg, email: currentUserEmail, role: 'employee',
                timestamp: firebase.firestore.FieldValue.serverTimestamp()
            }).then(() => { input.value = ""; }).catch(e => alert("Error: " + e.message));
        }

        function closeModal() {
            document.getElementById("taskModal").style.display = "none";
            if(chatListener) chatListener();
        }

        function logout() { auth.signOut().then(() => window.location.href = "index.html"); }
    </script>
</body>
</html>