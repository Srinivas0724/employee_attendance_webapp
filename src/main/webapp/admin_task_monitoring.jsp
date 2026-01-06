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
    <title>Task Monitoring - Synod Bioscience</title>
    
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

        .card { background: white; padding: 25px; border-radius: 10px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); }
        
        h3 { margin-top: 0; color: var(--primary-navy); border-bottom: 2px solid #f4f6f9; padding-bottom: 12px; margin-bottom: 20px; }

        /* Table */
        table { width: 100%; border-collapse: collapse; margin-top: 15px; }
        th { background: #f8f9fa; color: #666; padding: 12px; text-align: left; font-size: 13px; text-transform: uppercase; border-bottom: 2px solid #eee; }
        td { padding: 12px; border-bottom: 1px solid #f1f1f1; color: #444; font-size: 14px; vertical-align: middle; }
        tr:hover { background: #fafafa; }

        /* Badges */
        .badge { padding: 5px 10px; border-radius: 6px; color: white; font-size: 11px; font-weight: bold; display: inline-block; }
        .PENDING { background: #e74c3c; }
        .IN_PROGRESS { background: #f39c12; }
        .DONE { background: #27ae60; }

        /* Chat Button */
        .btn-chat { background: #3498db; color: white; border: none; padding: 6px 12px; border-radius: 4px; cursor: pointer; font-size: 12px; font-weight: bold; }
        .btn-chat:hover { background: #2980b9; }

        /* --- MODAL --- */
        .modal { display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; background-color: rgba(0,0,0,0.6); align-items: center; justify-content: center; }
        .modal-content { background-color: #fff; width: 600px; max-width: 90%; height: 85vh; border-radius: 10px; display: flex; flex-direction: column; overflow: hidden; box-shadow: 0 10px 25px rgba(0,0,0,0.2); }

        .modal-header { background: var(--primary-navy); color: white; padding: 15px 20px; display: flex; justify-content: space-between; align-items: center; }
        .modal-title { font-size: 16px; font-weight: bold; }
        .close-btn { background: none; border: none; color: white; font-size: 20px; cursor: pointer; opacity: 0.8; }
        .close-btn:hover { opacity: 1; }

        .modal-body { flex: 1; padding: 20px; overflow-y: auto; display: flex; flex-direction: column; gap: 20px; background: #f8f9fa; }

        .task-info-box { background: white; padding: 20px; border-radius: 8px; border: 1px solid #eee; box-shadow: 0 2px 4px rgba(0,0,0,0.02); }
        .task-info-box h3 { border: none; margin-bottom: 5px; padding: 0; font-size: 18px; }

        /* Chat Area */
        .chat-section { display: flex; flex-direction: column; flex: 1; background: white; border: 1px solid #eee; border-radius: 8px; overflow: hidden; }
        .chat-header { padding: 10px 15px; background: #f1f1f1; font-size: 12px; font-weight: bold; color: #666; border-bottom: 1px solid #ddd; }
        
        .chat-messages { flex: 1; padding: 15px; overflow-y: auto; display: flex; flex-direction: column; gap: 10px; background: #fff; }

        .msg-bubble { padding: 10px 14px; border-radius: 12px; max-width: 80%; font-size: 13px; line-height: 1.4; position: relative; }
        .msg-mine { background: #e3f2fd; align-self: flex-end; border-bottom-right-radius: 2px; color: #333; }
        .msg-other { background: #f1f1f1; align-self: flex-start; border-bottom-left-radius: 2px; color: #333; }
        
        .msg-meta { font-size: 10px; color: #888; margin-top: 4px; display: block; text-align: right; }

        .chat-input-area { padding: 10px; border-top: 1px solid #eee; display: flex; gap: 10px; background: #fafafa; }
        .chat-input { flex: 1; padding: 10px; border: 1px solid #ddd; border-radius: 20px; outline: none; font-size: 13px; }
        .btn-send { background: var(--primary-navy); color: white; border: none; padding: 0 20px; border-radius: 20px; cursor: pointer; font-weight: bold; font-size: 13px; }
        .btn-send:hover { background: #132c52; }

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
        <div style="font-size: 40px; margin-bottom: 10px;">📝</div>
        <div>Loading Task Data...</div>
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
                <a href="admin_task_monitoring.jsp" class="active"><span class="nav-icon">📝</span> Tasks</a>
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
                <div class="page-title">Task Management</div>
            </div>
            <div class="user-profile">
                <span id="adminEmail">Loading...</span>
                <div class="user-avatar">A</div>
            </div>
        </header>

        <div class="content">
            <div class="card">
                <h3>All Assigned Tasks</h3>
                <p style="color:#666; font-size:14px; margin-top:0;">
                    Monitor employee progress and communicate updates directly via chat.
                </p>
                
                <table>
                    <thead>
                        <tr>
                            <th>Assigned To</th>
                            <th>Task Title</th>
                            <th>Project</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="taskTableBody">
                        <tr><td colspan="5" style="text-align:center;">Loading tasks...</td></tr>
                    </tbody>
                </table>
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
                    <div style="font-size:13px; color:#555; margin-bottom:10px;">
                        Assigned To: <b id="mAssignee"></b>
                    </div>
                    <p id="mDesc" style="color:#444; font-size:14px; line-height:1.5;"></p>
                    <div style="font-size:12px; color:#888; margin-top:10px; border-top:1px solid #eee; padding-top:10px;">
                        Project: <span id="mProj"></span>
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
        let currentAdminEmail = null;
        let chatListener = null;

        // --- 2. AUTH CHECK ---
        auth.onAuthStateChanged(user => {
            if (user) {
                currentAdminEmail = user.email;
                document.getElementById("adminEmail").innerText = user.email;
                document.getElementById("loadingOverlay").style.display = "none";
                loadAllTasks();
            } else {
                window.location.replace("index.html");
            }
        });

        // --- 3. LOAD TASKS ---
        function loadAllTasks() {
            db.collection("tasks")
                .orderBy("timestamp", "desc")
                .onSnapshot(snap => {
                    const tbody = document.getElementById("taskTableBody");
                    if(snap.empty) {
                        tbody.innerHTML = "<tr><td colspan='5' style='text-align:center;'>No tasks found in system.</td></tr>";
                        return;
                    }

                    let rows = "";
                    snap.forEach(doc => {
                        const d = doc.data();
                        const id = doc.id;

                        // Safe Variables
                        const badgeClass = d.status || "PENDING";
                        const assignedTo = d.assignedTo || "Unknown";
                        const title = d.title || "Untitled Task";
                        const project = d.project || "General";
                        
                        // Encode data safely for function call
                        const safeData = encodeURIComponent(JSON.stringify(d));

                        // Use String Concatenation to avoid JSP errors
                        rows += "<tr>";
                        rows += "<td>" + assignedTo + "</td>";
                        rows += "<td><b>" + title + "</b></td>";
                        rows += "<td>" + project + "</td>";
                        rows += "<td><span class='badge " + badgeClass + "'>" + badgeClass + "</span></td>";
                        rows += "<td><button class='btn-chat' onclick='openTask(\"" + id + "\", \"" + safeData + "\")'>Open Chat</button></td>";
                        rows += "</tr>";
                    });
                    tbody.innerHTML = rows;
                });
        }

        // --- 4. OPEN TASK MODAL ---
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

        // --- 5. CHAT LOGIC ---
        function loadChat(taskId) {
            const chatBox = document.getElementById("chatMessages");
            chatBox.innerHTML = "<div style='text-align:center; color:#999; margin-top:10px;'>Loading conversation...</div>";

            if(chatListener) chatListener();

            chatListener = db.collection("tasks").doc(taskId).collection("replies")
                .orderBy("timestamp", "asc")
                .onSnapshot(snap => {
                    chatBox.innerHTML = "";
                    if(snap.empty) {
                        chatBox.innerHTML = "<div style='text-align:center; color:#ccc; margin-top:20px;'>No conversation yet.</div>";
                    }

                    snap.forEach(doc => {
                        const m = doc.data();
                        
                        // Admin messages are "Mine"
                        const isMine = m.role === 'admin';
                        const bubbleClass = isMine ? "msg-mine" : "msg-other";
                        const senderName = isMine ? "Me" : "Employee";
                        
                        let time = "";
                        if(m.timestamp) {
                            time = new Date(m.timestamp.seconds * 1000).toLocaleTimeString([], {hour:'2-digit', minute:'2-digit'});
                        }

                        // String Concatenation for Chat Bubble
                        let msgHtml = "<div class='msg-bubble " + bubbleClass + "'>";
                        msgHtml += "<div>" + m.message + "</div>";
                        msgHtml += "<span class='msg-meta'>" + senderName + " • " + time + "</span>";
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
                email: currentAdminEmail,
                role: 'admin', // ID as Admin
                timestamp: firebase.firestore.FieldValue.serverTimestamp()
            }).then(() => {
                input.value = "";
            }).catch(e => alert("Error: " + e.message));
        }

        function closeModal() {
            document.getElementById("taskModal").style.display = "none";
            if(chatListener) chatListener();
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