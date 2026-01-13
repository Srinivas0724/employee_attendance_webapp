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
    <title>My Tasks - Employee Portal</title>
    
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
        .tab-container { display: flex; gap: 15px; border-bottom: 2px solid #e9ecef; padding-bottom: 15px; }
        
        .tab-btn { 
            padding: 12px 30px; border: none; background: transparent; 
            color: var(--text-grey); cursor: pointer; border-radius: 30px; 
            font-weight: 600; font-size: 14px; transition: all 0.3s ease;
        }
        .tab-btn:hover { background: #e9ecef; color: var(--primary-navy); }
        .tab-btn.active { background: var(--primary-navy); color: white; box-shadow: 0 4px 10px rgba(26, 59, 110, 0.2); }
        
        .tab-pane { display: none; width: 100%; }
        .tab-pane.active { display: block; animation: fadeIn 0.3s ease-in-out; }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }

        /* Cards */
        .card { 
            background: white; padding: 30px; border-radius: 16px; 
            box-shadow: var(--card-shadow); border-top: 4px solid var(--primary-navy);
        }

        /* Table */
        .table-responsive { overflow-x: auto; }
        table { width: 100%; border-collapse: separate; border-spacing: 0; min-width: 600px; }
        
        th { 
            background: #f8f9fa; color: var(--text-grey); padding: 15px; 
            text-align: left; font-size: 12px; text-transform: uppercase; 
            border-bottom: 2px solid #eee; font-weight: 700; letter-spacing: 0.5px;
        }
        
        td { 
            padding: 15px; border-bottom: 1px solid #f1f1f1; 
            color: var(--text-dark); font-size: 14px; vertical-align: middle; 
        }
        tr:hover td { background: #fcfcfc; }

        /* Badges */
        .badge { padding: 6px 12px; border-radius: 20px; font-size: 11px; font-weight: 700; color: white; display: inline-block; }
        .bg-HIGH { background-color: #e74c3c; }
        .bg-MEDIUM { background-color: #f39c12; }
        .bg-LOW { background-color: #2ecc71; }

        /* Status Select */
        .status-select { 
            padding: 8px 12px; border-radius: 6px; font-size: 12px; font-weight: 700; 
            border: 1px solid transparent; cursor: pointer; outline: none; transition: 0.2s;
        }
        .status-select.PENDING { background: #fff0f0; color: #c0392b; border-color: #ffcccc; }
        .status-select.IN_PROGRESS { background: #fff8e1; color: #d35400; border-color: #ffe0b2; }
        .status-select.DONE { background: #e8f5e9; color: #27ae60; border-color: #c8e6c9; }

        .btn-action { 
            background: var(--primary-navy); color: white; border: none; 
            padding: 8px 16px; border-radius: 6px; font-size: 12px; 
            cursor: pointer; font-weight: 600; transition: all 0.2s;
        }
        .btn-action:hover { background: #132c52; transform: translateY(-2px); }

        /* --- CHAT LAYOUT --- */
        .chat-layout { display: flex; gap: 20px; height: 500px; }
        .chat-sidebar { width: 280px; border-right: 1px solid #eee; display: flex; flex-direction: column; gap: 15px; padding-right: 20px; }
        .chat-main { flex: 1; display: flex; flex-direction: column; background: #fcfcfc; border-radius: 12px; border: 1px solid #e0e0e0; overflow: hidden; }
        
        .chat-header { padding: 15px 20px; background: white; border-bottom: 1px solid #eee; font-weight: 700; color: var(--primary-navy); font-size: 15px; }
        .chat-messages { flex: 1; overflow-y: auto; padding: 20px; display: flex; flex-direction: column; gap: 12px; }
        
        .msg-bubble { max-width: 75%; padding: 12px 16px; border-radius: 16px; font-size: 14px; line-height: 1.5; position: relative; box-shadow: 0 1px 2px rgba(0,0,0,0.05); }
        .msg-mine { align-self: flex-end; background: #dcf8c6; color: var(--text-dark); border-bottom-right-radius: 2px; }
        .msg-other { align-self: flex-start; background: white; color: var(--text-dark); border-bottom-left-radius: 2px; }
        .msg-sender { font-size: 11px; font-weight: 700; color: var(--primary-navy); display: block; margin-bottom: 4px; }

        .chat-input-area { padding: 15px; background: white; border-top: 1px solid #eee; display: flex; gap: 12px; }
        .chat-input { flex: 1; padding: 12px 15px; border: 1px solid #ddd; border-radius: 25px; outline: none; transition: 0.3s; font-size: 14px; }
        .chat-input:focus { border-color: var(--primary-navy); }
        .btn-send { background: var(--primary-green); color: white; border: none; width: 42px; height: 42px; border-radius: 50%; cursor: pointer; display: flex; align-items: center; justify-content: center; font-size: 18px; transition: 0.2s; }
        .btn-send:hover { transform: scale(1.1); }

        /* --- MODAL --- */
        .modal { display: none; position: fixed; z-index: 2000; left: 0; top: 0; width: 100%; height: 100%; background-color: rgba(0,0,0,0.6); align-items: center; justify-content: center; backdrop-filter: blur(4px); }
        .modal-content { background-color: white; width: 600px; max-width: 90%; height: 85vh; border-radius: 16px; display: flex; flex-direction: column; overflow: hidden; box-shadow: 0 20px 50px rgba(0,0,0,0.2); }
        .modal-header { padding: 20px 25px; background: var(--primary-navy); color: white; display: flex; justify-content: space-between; align-items: center; }
        .modal-title { font-size: 18px; font-weight: 700; }
        .close-btn { background: none; border: none; color: white; font-size: 24px; cursor: pointer; opacity: 0.8; }
        .close-btn:hover { opacity: 1; }

        .task-details { padding: 20px 25px; background: #f8f9fa; border-bottom: 1px solid #eee; }
        .task-details h3 { margin: 0 0 8px 0; color: var(--primary-navy); font-size: 18px; font-weight: 700; }
        .task-meta { font-size: 13px; color: var(--text-grey); display: flex; gap: 20px; font-weight: 500; }
        
        #loadingOverlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(255,255,255,0.9); backdrop-filter: blur(5px); z-index: 9999; display: flex; justify-content: center; align-items: center; font-size: 24px; color: var(--primary-navy); flex-direction: column; gap: 15px; font-weight: 600; }

        @media (max-width: 900px) {
            .sidebar { position: fixed; left: -280px; height: 100%; }
            .sidebar.active { transform: translateX(280px); }
            .toggle-btn { display: block; font-size: 24px; cursor: pointer; margin-right: 15px; }
            .content { padding: 20px; }
            .topbar { padding: 0 20px; }
            .chat-layout { flex-direction: column; height: auto; }
            .chat-sidebar { width: 100%; border-right: none; border-bottom: 1px solid #eee; padding-bottom: 15px; }
            .chat-main { height: 400px; }
        }
    </style>

    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-auth-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-firestore-compat.js"></script>
</head>
<body>

    <div id="loadingOverlay">
        <div style="font-size: 50px;">📝</div>
        <div>Loading Tasks...</div>
    </div>

    <nav class="sidebar" id="sidebar">
        <div class="sidebar-header">
            <img src="synod_logo.png" alt="Synod Logo" class="sidebar-logo">
            <div class="sidebar-brand">EMPLOYEE PORTAL</div>
        </div>

        <ul class="nav-menu">
            <li class="nav-item">
                <a href="employee_dashboard.jsp"><span class="nav-icon">📊</span> Dashboard</a>
            </li>
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
                <span id="userEmail" class="user-email">Loading...</span>
                <div class="user-avatar">E</div>
            </div>
        </header>

        <div class="content">
            
            <div class="tab-container">
                <button class="tab-btn active" onclick="switchTab('tasks')">📋 My Tasks</button>
                <button class="tab-btn" onclick="switchTab('projects')">🚀 Project Groups</button>
            </div>

            <div id="tab-tasks" class="tab-pane active">
                <div class="card">
                    <p style="color:var(--text-grey); margin-top:0; font-size:14px; margin-bottom:25px;">
                        Update task status or click <b>"View & Reply"</b> to discuss details with your manager.
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
                                <tr><td colspan="5" style="text-align:center; padding:30px; color:#999;">Loading tasks...</td></tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <div id="tab-projects" class="tab-pane">
                <div class="card">
                    <div class="chat-layout">
                        <div class="chat-sidebar">
                            <h4 style="margin:0 0 10px 0; color:var(--primary-navy); font-size:15px;">📂 Select Project</h4>
                            <select id="empProjectSelect" onchange="loadProjectChat()" style="width:100%; padding:12px; border-radius:8px; border:1px solid #e0e0e0; outline:none; font-size:14px;">
                                <option value="">-- Choose a Project --</option>
                            </select>
                            <p style="font-size:13px; color:var(--text-grey); line-height:1.5;">
                                Join the group discussion for projects you are assigned to.
                            </p>
                        </div>

                        <div class="chat-main">
                            <div class="chat-header">
                                <span id="chatProjName">Select a project...</span>
                            </div>
                            
                            <div id="projectChatBox" class="chat-messages">
                                <div style="text-align:center; color:#ccc; margin-top:80px;">👈 Select a project to start chatting</div>
                            </div>
                            
                            <div id="projInputArea" class="chat-input-area" style="display:none;">
                                <input type="text" id="projMsgInput" class="chat-input" placeholder="Type a message...">
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
                <p id="mDesc" style="color:var(--text-dark); font-size:14px; margin:8px 0; line-height:1.6;">Description...</p>
                <div class="task-meta">
                    <span id="mProj">Project: -</span>
                    <span id="mDate">Due: -</span>
                </div>
                <div id="mPhotoBox" style="margin-top:12px; display:none;">
                    <a id="mPhotoLink" href="#" target="_blank" style="color:var(--primary-navy); font-weight:600; font-size:13px; text-decoration:none; display:flex; align-items:center; gap:5px;">
                        📎 View Attached Reference
                    </a>
                </div>
            </div>

            <div class="chat-messages" id="chatMessages" style="background:#fff;">
                <div style="text-align:center; padding:30px; color:#999;">Loading conversation...</div>
            </div>

            <div class="chat-input-area">
                <input type="text" id="chatInput" class="chat-input" placeholder="Type a reply...">
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
            const btns = document.querySelectorAll('.tab-btn');
            if(tabName === 'tasks') btns[0].classList.add('active');
            else btns[1].classList.add('active');
        }

        // --- 3. TASKS LOGIC ---
        function loadMyTasks(email) {
            const tbody = document.getElementById("myTasksTable");
            
            db.collection("tasks").where("assignedTo", "==", email).onSnapshot(snap => {
                if(snap.empty) {
                    tbody.innerHTML = "<tr><td colspan='5' style='text-align:center; padding:40px; color:#999;'>🎉 No active tasks assigned to you.</td></tr>";
                    return;
                }
                
                let rows = "";
                snap.forEach(doc => {
                    const d = doc.data();
                    const id = doc.id; 
                    const safeData = encodeURIComponent(JSON.stringify(d));

                    const sP = d.status === 'PENDING' ? 'selected' : '';
                    const sI = d.status === 'IN_PROGRESS' ? 'selected' : '';
                    const sD = d.status === 'DONE' ? 'selected' : '';

                    rows += "<tr>";
                    rows += "<td><b style='color:var(--primary-navy);'>" + (d.title || "Untitled") + "</b></td>";
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
                        chatBox.innerHTML = "<div style='text-align:center; color:#ccc; margin-top:40px;'>No messages yet. Say hello! 👋</div>";
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
            chatBox.innerHTML = "<div style='text-align:center; padding:30px; color:#999'>Loading updates...</div>";
            
            if(chatListener) chatListener();
            
            chatListener = db.collection("tasks").doc(taskId).collection("replies").orderBy("timestamp", "asc").onSnapshot(snap => {
                chatBox.innerHTML = "";
                if(snap.empty) {
                    chatBox.innerHTML = "<div style='text-align:center; padding:30px; color:#ccc'>No discussions yet.</div>";
                    return;
                }
                
                snap.forEach(doc => {
                    const m = doc.data();
                    const isMine = m.email === currentUserEmail;
                    const bubbleClass = isMine ? "msg-mine" : "msg-other";
                    const sender = isMine ? "Me" : (m.role === 'admin' ? "Admin" : "Manager");

                    let html = "<div class='msg-bubble " + bubbleClass + "'>";
                    if(!isMine) html += "<span class='msg-sender'>" + sender + "</span>";
                    html += m.message;
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
        function toggleSidebar() { document.getElementById("sidebar").classList.toggle("open"); }
    </script>
</body>
</html>