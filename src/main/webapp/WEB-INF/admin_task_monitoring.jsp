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
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
    <title>Task Monitoring - Synod Bioscience</title>
    
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

        .content { padding: 30px 40px; max-width: 1400px; margin: 0 auto; width: 100%; }

        /* --- 4. TASK TABLE CARD --- */
        .card { background: white; padding: 30px; border-radius: 16px; box-shadow: var(--card-shadow); border: 1px solid white; display: flex; flex-direction: column; }
        .card h3 { margin: 0 0 10px 0; font-size: 18px; font-weight: 700; color: var(--primary-navy); }
        
        /* Table Styles */
        .table-wrap { overflow-x: auto; border-radius: 8px; border: 1px solid #f0f0f0; margin-top: 20px; }
        table { width: 100%; border-collapse: collapse; min-width: 600px; }
        th { background: #f8f9fa; padding: 15px; text-align: left; font-size: 12px; color: var(--text-grey); font-weight: 700; text-transform: uppercase; border-bottom: 2px solid #eee; }
        td { padding: 15px; border-bottom: 1px solid #f9f9f9; font-size: 14px; color: var(--text-dark); vertical-align: middle; }
        tr:hover td { background: #fcfcfc; }

        /* Status Badges */
        .badge { padding: 6px 12px; border-radius: 20px; font-size: 11px; font-weight: 700; display: inline-block; text-transform: uppercase; letter-spacing: 0.5px; }
        .PENDING { background: #ffebee; color: #c0392b; }
        .IN_PROGRESS { background: #fff3cd; color: #f39c12; }
        .COMPLETED { background: #e8f5e9; color: #27ae60; }

        /* Action Button */
        .btn-chat { background: var(--primary-navy); color: white; border: none; padding: 8px 16px; border-radius: 6px; cursor: pointer; font-size: 12px; font-weight: 600; transition: 0.2s; display: inline-flex; align-items: center; gap: 5px; }
        .btn-chat:hover { background: #132c52; transform: translateY(-1px); }

        /* --- 5. MODAL (Standardized) --- */
        .modal { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.6); backdrop-filter: blur(4px); z-index: 2000; justify-content: center; align-items: center; }
        .modal-content { background: white; width: 700px; max-width: 95%; height: 85vh; border-radius: 16px; display: flex; flex-direction: column; overflow: hidden; box-shadow: 0 20px 50px rgba(0,0,0,0.2); }

        .modal-header { background: white; padding: 20px 25px; border-bottom: 1px solid #f0f0f0; display: flex; justify-content: space-between; align-items: center; }
        .modal-title { font-size: 18px; font-weight: 700; color: var(--primary-navy); }
        .close-btn { background: #f8f9fa; border: none; color: #666; width: 32px; height: 32px; border-radius: 50%; font-size: 20px; cursor: pointer; display: flex; align-items: center; justify-content: center; transition: 0.2s; }
        .close-btn:hover { background: #e74c3c; color: white; }

        .modal-body { flex: 1; padding: 25px; overflow-y: auto; background: #f9f9f9; display: flex; flex-direction: column; gap: 20px; }

        /* Task Details Box */
        .task-box { background: white; padding: 20px; border-radius: 12px; border: 1px solid #eee; box-shadow: 0 2px 8px rgba(0,0,0,0.03); }
        .task-box h3 { margin: 0 0 5px 0; color: var(--text-dark); font-size: 16px; }
        .task-meta { font-size: 13px; color: var(--text-grey); margin-bottom: 15px; display: flex; gap: 15px; }
        .task-desc { color: #555; font-size: 14px; line-height: 1.6; }

        /* Chat Section */
        .chat-section { flex: 1; background: white; border-radius: 12px; border: 1px solid #eee; display: flex; flex-direction: column; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.03); }
        .chat-title { padding: 15px; background: #fdfdfd; font-size: 13px; font-weight: 600; color: var(--primary-navy); border-bottom: 1px solid #f0f0f0; }
        
        .chat-list { flex: 1; padding: 20px; overflow-y: auto; display: flex; flex-direction: column; gap: 12px; }
        .msg-bubble { padding: 12px 16px; border-radius: 12px; max-width: 80%; font-size: 13px; line-height: 1.5; box-shadow: 0 2px 5px rgba(0,0,0,0.02); }
        .msg-mine { background: var(--primary-navy); color: white; align-self: flex-end; border-bottom-right-radius: 2px; }
        .msg-other { background: #f0f2f5; color: var(--text-dark); align-self: flex-start; border-bottom-left-radius: 2px; }
        .msg-info { font-size: 10px; opacity: 0.7; margin-top: 4px; display: block; text-align: right; }

        .chat-input-area { padding: 15px; background: white; border-top: 1px solid #f0f0f0; display: flex; gap: 10px; }
        .chat-input { flex: 1; padding: 12px 20px; border: 1px solid #eee; border-radius: 30px; outline: none; background: #f9f9f9; }
        .btn-send { background: var(--primary-green); color: white; border: none; padding: 0 25px; border-radius: 30px; cursor: pointer; font-weight: 700; font-size: 14px; transition: 0.2s; }
        .btn-send:hover { background: #27ae60; transform: translateY(-1px); }

        /* Loader */
        #loadingOverlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: white; z-index: 9999; display: flex; flex-direction: column; justify-content: center; align-items: center; color: var(--primary-navy); font-weight: 600; }

        @media (max-width: 1024px) {
            .sidebar { position: fixed; left: -280px; height: 100%; }
            .sidebar.active { transform: translateX(280px); }
            .toggle-btn { display: block; font-size: 24px; cursor: pointer; margin-right: 15px; }
            .content { padding: 20px; }
        }
        @media (min-width: 1025px) { .toggle-btn { display: none; } }

        /* Mobile Optimizations */

@media (max-width: 768px) {

    /* Hide Sidebar by default on mobile */

    .sidebar {

        display: none; 

        position: fixed;

        z-index: 1000;

        width: 250px;

        height: 100%;

    }



    /* Make Content use full width */

    .main-content {

        margin-left: 0 !important;

        width: 100%;

    }



    /* Show a Hamburger Menu Button (You need to add this button to your HTML) */

    .mobile-menu-btn {

        display: block !important; /* Visible only on mobile */

        font-size: 24px;

        background: none;

        border: none;

        color: white; /* or dark color depending on your header */

        cursor: pointer;

    }

    

    /* Adjust Grid/Cards for Mobile */

    .card-container, .stats-row {

        flex-direction: column; /* Stack items vertically */

    }

}

.table-responsive, .attendance-grid-container {

    display: block;

    width: 100%;

    overflow-x: auto; /* Allows horizontal scrolling */

    -webkit-overflow-scrolling: touch; /* Smooth scroll on iPhones */

}
    </style>
</head>
<body>

    <div id="loadingOverlay">
        <div style="font-size: 50px;">📝</div>
        <div style="margin-top:15px;">Loading Tasks...</div>
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
            <li class="nav-item"><a href="list_of_employees.jsp"><span class="nav-icon">📋</span> Directory</a></li>
            <li class="nav-item"><a href="admin_task_monitoring.jsp" class="active"><span class="nav-icon">📝</span> Tasks</a></li>
            <li class="nav-item"><a href="reports.jsp"><span class="nav-icon">📅</span> Attendance</a></li>
            <li class="nav-item"><a href="admin_expenses.jsp"><span class="nav-icon">💸</span> Expenses</a></li>
            <li class="nav-item"><a href="payroll.jsp"><span class="nav-icon">💰</span> Payroll</a></li>
            <li class="nav-item"><a href="admin_settings.jsp"><span class="nav-icon">⚙️</span> Settings</a></li>
        </ul>

        <div class="sidebar-footer">
            <button onclick="logout()" class="btn-logout"><span>🚪</span> Sign Out</button>
        </div>
    </nav>

    <div class="main-content">
        <header class="topbar">
            <div style="display:flex; align-items:center;">
                <div class="toggle-btn" onclick="toggleSidebar()">☰</div>
                <div class="page-title">Task Monitoring</div>
            </div>
            <div class="user-profile">
                <span id="adminEmail">Loading...</span>
                <div class="user-avatar">A</div>
            </div>
        </header>

        <div class="content">
            <div class="card">
                <div style="display:flex; justify-content:space-between; align-items:center;">
                    <div>
                        <h3>All Assigned Tasks</h3>
                        <p style="color:#7f8c8d; font-size:14px; margin:0;">Track progress and communicate with assignees.</p>
                    </div>
                </div>
                
                <div class="table-wrap">
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
                            <tr><td colspan="5" style="text-align:center; padding:30px; color:#999;">Loading tasks...</td></tr>
                        </tbody>
                    </table>
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
                
                <div class="task-box">
                    <h3 id="mTitle">Task Title</h3>
                    <div class="task-meta">
                        <span>👤 <b id="mAssignee">User</b></span>
                        <span>📂 <b id="mProj">Project</b></span>
                    </div>
                    <div id="mDesc" class="task-desc">Task description goes here...</div>
                </div>

                <div class="chat-section">
                    <div class="chat-title">💬 Discussion History</div>
                    <div id="chatMessages" class="chat-list">
                        </div>
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
        let currentUserRole = "admin"; // Default
        let chatListener = null;

        // --- 2. AUTH CHECK & ROLE MANAGER ---
        auth.onAuthStateChanged(user => {
            if (user) {
                db.collection("users").doc(user.email).get().then(doc => {
                    if (doc.exists) {
                        const data = doc.data();
                        const role = data.role;
                        
                        // 1. ACCESS CHECK
                        if (role !== 'admin' && role !== 'manager') {
                            window.location.href = "index.html"; 
                            return;
                        }

                        // 2. STORE ROLE & EMAIL
                        currentUserRole = role;
                        currentUserEmail = user.email;

                        // 3. LOAD USER INFO
                        if(document.getElementById("adminEmail")) {
                             document.getElementById("adminEmail").innerText = user.email;
                        }
                        
                        // 4. MANAGER SPECIFIC UI
                        if (role === 'manager') {
                            // Update Brand
                            const brand = document.querySelector('.sidebar-brand');
                            if(brand) brand.innerText = "MANAGER PORTAL";

                            // Hide Restricted Links
                            const expLink = document.querySelector('a[href="admin_expenses.jsp"]');
                            if(expLink && expLink.parentElement) expLink.parentElement.style.display = 'none';

                            const payLink = document.querySelector('a[href="payroll.jsp"]');
                            if(payLink && payLink.parentElement) payLink.parentElement.style.display = 'none';
                        }

                        // 5. LOAD PAGE DATA
                        loadAllTasks();
                        
                        // Hide Loader
                        document.getElementById("loadingOverlay").style.display = "none";
                    }
                });
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
                        
                        // Encode data safely
                        const safeData = encodeURIComponent(JSON.stringify(d));

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
                        
                        // Check if message is mine (Current Admin/Manager)
                        const isMine = m.email === currentUserEmail; 
                        const bubbleClass = isMine ? "msg-mine" : "msg-other";
                        
                        // Sender Name Logic
                        let senderName = "Employee";
                        if (m.role === 'admin') senderName = "Admin";
                        if (m.role === 'manager') senderName = "Manager";
                        if (isMine) senderName = "Me";
                        
                        let time = "";
                        if(m.timestamp) {
                            time = new Date(m.timestamp.seconds * 1000).toLocaleTimeString([], {hour:'2-digit', minute:'2-digit'});
                        }

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
                email: currentUserEmail,
                role: currentUserRole, // Sends as 'admin' or 'manager'
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