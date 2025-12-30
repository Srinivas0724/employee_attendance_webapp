<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
  response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
  response.setHeader("Pragma", "no-cache");
  response.setDateHeader("Expires", 0);
%>
<%@ page isELIgnored="true" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>My Tasks - emPower</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <style>
        /* --- GLOBAL STYLES --- */
        body { margin:0; font-family:"Segoe UI", sans-serif; background:#f4f6f9; display:flex; height:100vh; color: #333; }
        
        /* SIDEBAR */
        .sidebar { width:260px; background:#343a40; color:#fff; display:flex; flex-direction:column; }
        .sidebar h2 { padding:20px; margin:0; background:#212529; text-align:center; }
        .sidebar a { display:block; padding:15px 20px; color:#c2c7d0; text-decoration:none; }
        .sidebar a:hover, .sidebar a.active { background:#495057; color:#fff; border-left: 3px solid #007bff; }
        @media (max-width: 768px) { .sidebar { display:none; } }

        /* MAIN CONTENT */
        .main { flex:1; display:flex; flex-direction:column; overflow: hidden; }
        .header { height:60px; background:#fff; display:flex; align-items:center; padding:0 20px; border-bottom: 1px solid #dee2e6; justify-content: space-between; }
        .content { flex:1; padding:20px; overflow-y:auto; }

        /* TABS */
        .tab-container { display: flex; gap: 10px; margin-bottom: 20px; border-bottom: 2px solid #ddd; padding-bottom: 10px; }
        .tab-btn { padding: 10px 20px; border: none; background: #e9ecef; color: #555; cursor: pointer; border-radius: 5px; font-weight: bold; font-size: 14px; }
        .tab-btn.active { background: #007bff; color: white; }
        .tab-content { display: none; }
        .tab-content.active { display: block; }

        /* CARDS & LAYOUT */
        .card { background:white; padding:20px; border-radius:8px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); margin-bottom: 20px;}
        .flex-row { display: flex; gap: 20px; flex-wrap: wrap; }
        .half-width { flex: 1; min-width: 300px; }

        /* TABLE STYLES */
        table { width:100%; border-collapse:collapse; background:#fff; margin-top: 15px; }
        th, td { padding:15px; text-align:left; border-bottom:1px solid #dee2e6; vertical-align: middle; }
        th { background:#343a40; color:#fff; font-weight:600; }
        tr:hover { background-color: #f8f9fa; }

        /* BADGES */
        .badge { padding: 5px 10px; border-radius: 12px; font-size: 11px; font-weight: bold; color: white; display: inline-block; }
        .bg-HIGH { background-color: #dc3545; }
        .bg-MEDIUM { background-color: #ffc107; color: #333; }
        .bg-LOW { background-color: #28a745; }

        /* STATUS SELECT */
        .status-select { padding: 8px; border-radius: 4px; border: 1px solid #ccc; font-weight: bold; cursor: pointer; }
        .PENDING { color: #dc3545; border-color: #dc3545; }
        .IN_PROGRESS { color: #e0a800; border-color: #e0a800; }
        .DONE { color: #28a745; border-color: #28a745; }

        /* BUTTONS */
        .btn-open { background:#007bff; color:white; border:none; padding:8px 15px; border-radius:4px; cursor:pointer; font-size:13px; font-weight:bold; }
        .btn-open:hover { background:#0056b3; }

        /* --- PROJECT CHAT STYLES --- */
        .chat-box { border: 1px solid #ddd; height: 350px; overflow-y: auto; background: #f9f9f9; padding: 15px; border-radius: 4px; margin-top: 10px; display: flex; flex-direction: column; gap: 10px; }
        .chat-msg { padding: 8px 12px; border-radius: 15px; max-width: 80%; font-size: 13px; line-height: 1.4; }
        .msg-mine { background: #dcf8c6; align-self: flex-end; border-bottom-right-radius: 0; }
        .msg-other { background: #e9ecef; align-self: flex-start; border-bottom-left-radius: 0; }
        
        .chat-input-row { display:flex; gap:10px; margin-top:10px; }
        .proj-input { flex:1; padding:10px; border:1px solid #ccc; border-radius:4px; }
        .btn-send-proj { background:#007bff; color:white; border:none; padding:0 20px; border-radius:4px; cursor:pointer; }

        /* --- MODAL (TASK DETAIL) --- */
        .modal { display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; background-color: rgba(0,0,0,0.6); align-items: center; justify-content: center; }
        .modal-content { background-color: #fff; width: 600px; max-width: 90%; height: 80vh; border-radius: 8px; display: flex; flex-direction: column; overflow: hidden; box-shadow: 0 5px 15px rgba(0,0,0,0.3); }
        .modal-header { background: #343a40; color: white; padding: 15px; display: flex; justify-content: space-between; align-items: center; }
        .modal-body { flex: 1; padding: 20px; overflow-y: auto; display: flex; flex-direction: column; gap: 15px; }
        .task-info-box { background: #f8f9fa; padding: 15px; border-radius: 5px; border: 1px solid #e9ecef; }
        
        /* Modal Chat */
        .chat-container { border: 1px solid #ddd; border-radius: 5px; flex: 1; display: flex; flex-direction: column; background: #fff; }
        .chat-messages { flex: 1; padding: 15px; overflow-y: auto; background: #fdfdfd; display: flex; flex-direction: column; gap: 10px; }
        .msg-bubble { padding: 8px 12px; border-radius: 15px; max-width: 80%; font-size: 13px; line-height: 1.4; position: relative; }
        .msg-meta { font-size: 10px; color: #777; margin-top: 4px; display: block; text-align: right; }
        .chat-input-area { padding: 10px; border-top: 1px solid #ddd; display: flex; gap: 10px; background: #eee; }
        .chat-input { flex: 1; padding: 10px; border: 1px solid #ccc; border-radius: 20px; outline: none; }
        .btn-send { background: #28a745; color: white; border: none; padding: 0 20px; border-radius: 20px; cursor: pointer; font-weight: bold; }
        .close-btn { background: none; border: none; color: white; font-size: 20px; cursor: pointer; }
        
        /* Select Dropdown styling for projects */
        select { width: 100%; padding: 10px; margin-bottom: 15px; border: 1px solid #ccc; border-radius: 4px; }
    </style>

    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-auth-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-firestore-compat.js"></script>
</head>

<body>

    <div class="sidebar">
      <h2>emPower</h2>
      <a href="mark_attendance.jsp">📍 Mark Attendance</a>
      <a href="employee_tasks.jsp" class="active">📝 Assigned Tasks</a>
      <a href="attendance_history.jsp">🕒 Attendance History</a>
      <a href="employee_expenses.jsp">💸 My Expenses</a>
      <a href="salary.jsp">💰 My Salary</a>
      <a href="settings.jsp">⚙️ Settings</a>
      <a href="#" onclick="logout()">🚪 Logout</a>
    </div>

    <div class="main">
        <div class="header">
            <h3>My Workspace</h3>
            <span id="userEmail">Loading...</span>
        </div>

        <div class="content">
            
            <div class="tab-container">
                <button class="tab-btn active" onclick="switchTab('tasks')">📋 My Tasks</button>
                <button class="tab-btn" onclick="switchTab('projects')">🚀 Project Groups</button>
            </div>

            <div id="tab-tasks" class="tab-content active">
                <div class="card">
                    <p style="color:#666; margin-top:0;">
                        Click <b>"Open & Reply"</b> to view full details and update the admin.
                    </p>
                    
                    <table>
                        <thead>
                            <tr>
                                <th style="width: 35%;">Task</th>
                                <th style="width: 15%;">Project</th>
                                <th style="width: 10%;">Priority</th>
                                <th style="width: 20%;">Status</th>
                                <th style="width: 20%;">Action</th>
                            </tr>
                        </thead>
                        <tbody id="myTasksTable">
                            <tr><td colspan="5" style="text-align:center; padding:20px;">⌛ Loading...</td></tr>
                        </tbody>
                    </table>
                </div>
            </div>

            <div id="tab-projects" class="tab-content">
                <div class="flex-row">
                    
                    <div class="card half-width" style="flex: 0.4;">
                        <h3>📂 Select Project</h3>
                        <p style="color:#666; font-size:14px;">Select a project group you are a member of to start chatting.</p>
                        
                        <label><b>My Projects:</b></label>
                        <select id="empProjectSelect" onchange="loadProjectChat()">
                            <option value="">-- Choose a Project --</option>
                        </select>
                        
                        <div id="projInfo" style="margin-top:20px; font-size:13px; color:#555; display:none;">
                            ✅ You are a member of this project group.
                        </div>
                    </div>

                    <div class="card half-width">
                        <h3>💬 Project Group Chat</h3>
                        
                        <div id="projChatContainer" style="display:none;">
                            <div style="font-size:12px; color:#666; margin-bottom:5px;">
                                Connected to: <b id="chatProjName"></b>
                            </div>
                            
                            <div id="projectChatBox" class="chat-box"></div>
                            
                            <div class="chat-input-row">
                                <input type="text" id="projMsgInput" class="proj-input" placeholder="Type a message to the group...">
                                <button class="btn-send-proj" onclick="sendProjectMsg()">Send</button>
                            </div>
                        </div>

                        <div id="noProjectMsg" style="text-align:center; color:#999; margin-top:80px;">
                            👈 Select a project from the left menu.
                        </div>
                    </div>

                </div>
            </div>

        </div>
    </div>

    <div id="taskModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <span style="font-size:18px; font-weight:bold;">Task Discussion</span>
                <button class="close-btn" onclick="closeModal()">×</button>
            </div>
            <div class="modal-body">
                <div class="task-info-box">
                    <h3 id="mTitle" style="margin:0 0 5px 0; color:#333;"></h3>
                    <p id="mDesc" style="margin:0; color:#666; font-size:14px;"></p>
                    <div style="margin-top:10px; font-size:12px; color:#888;">
                        Due: <span id="mDate"></span> | Project: <span id="mProj"></span>
                    </div>
                    <div id="mPhotoBox" style="margin-top:10px; display:none;">
                        <a id="mPhotoLink" href="#" target="_blank" style="color:#007bff; text-decoration:none;">📷 View Attached Reference Image</a>
                    </div>
                </div>

                <div style="font-weight:bold; font-size:14px; margin-top:5px;">Replies & Updates:</div>
                <div class="chat-container">
                    <div id="chatMessages" class="chat-messages"></div>
                    <div class="chat-input-area">
                        <input type="text" id="chatInput" class="chat-input" placeholder="Type your update here...">
                        <button class="btn-send" onclick="sendReply()">Send</button>
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

        let currentTaskId = null;
        let currentUserEmail = null;
        let chatListener = null; // For Task Modal
        let projChatListener = null; // For Project Tab
        let currentProjectID = null;

        auth.onAuthStateChanged(user => {
            if(user) {
                currentUserEmail = user.email;
                document.getElementById("userEmail").innerText = user.email;
                loadMyTasks(user.email);
                loadEmployeeProjects(user.email); // [NEW] Load Projects
            } else {
                window.location.href = "login.jsp";
            }
        });

        /* --- TABS LOGIC --- */
        function switchTab(tabName) {
            document.querySelectorAll('.tab-content').forEach(el => el.classList.remove('active'));
            document.querySelectorAll('.tab-btn').forEach(el => el.classList.remove('active'));
            
            document.getElementById('tab-' + tabName).classList.add('active');
            // Find button and active it
            const btns = document.querySelectorAll('.tab-btn');
            if(tabName === 'tasks') btns[0].classList.add('active');
            else btns[1].classList.add('active');
        }

        /* --- TAB 1: TASKS LOGIC --- */
        function loadMyTasks(email) {
            const tbody = document.getElementById("myTasksTable");
            // REMOVED .orderBy() to avoid index error
            db.collection("tasks").where("assignedTo", "==", email).onSnapshot(snap => {
                if(snap.empty) {
                    tbody.innerHTML = "<tr><td colspan='5' style='text-align:center; padding:20px;'>No tasks assigned.</td></tr>";
                    return;
                }
                let rows = "";
                snap.forEach(doc => {
                    const d = doc.data();
                    const id = doc.id; 
                    const title = d.title || "Untitled";
                    const project = d.project || "General";
                    const priority = d.priority || "LOW";
                    const sPending = d.status === 'PENDING' ? 'selected' : '';
                    const sProg = d.status === 'IN_PROGRESS' ? 'selected' : '';
                    const sDone = d.status === 'DONE' ? 'selected' : '';
                    const safeData = encodeURIComponent(JSON.stringify(d));

                    // Use string concatenation for row building
                    rows += "<tr>";
                    rows += "<td><div style='font-weight:bold;'>" + title + "</div></td>";
                    rows += "<td>" + project + "</td>";
                    rows += "<td><span class='badge bg-" + priority + "'>" + priority + "</span></td>";
                    rows += "<td><select class='status-select " + d.status + "' onchange='updateStatus(\"" + id + "\", this)'><option value='PENDING' " + sPending + ">PENDING</option><option value='IN_PROGRESS' " + sProg + ">IN PROGRESS</option><option value='DONE' " + sDone + ">DONE</option></select></td>";
                    rows += "<td><button class='btn-open' onclick='openTask(\"" + id + "\", \"" + safeData + "\")'>Open & Reply</button></td>";
                    rows += "</tr>";
                });
                tbody.innerHTML = rows;
            });
        }

        /* --- TAB 2: PROJECTS LOGIC --- */
        function loadEmployeeProjects(email) {
            // Find projects where this employee is a member
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
            const chatContainer = document.getElementById("projChatContainer");
            const noProjectMsg = document.getElementById("noProjectMsg");
            const chatBox = document.getElementById("projectChatBox");
            const infoBox = document.getElementById("projInfo");

            if(!projId) {
                chatContainer.style.display = "none";
                noProjectMsg.style.display = "block";
                infoBox.style.display = "none";
                if(projChatListener) projChatListener();
                return;
            }

            // Setup UI
            currentProjectID = projId;
            const projName = document.getElementById("empProjectSelect").options[document.getElementById("empProjectSelect").selectedIndex].text;
            document.getElementById("chatProjName").innerText = projName;
            
            chatContainer.style.display = "block";
            noProjectMsg.style.display = "none";
            infoBox.style.display = "block";
            chatBox.innerHTML = "<div style='text-align:center; color:#999'>Loading history...</div>";

            // Listen to Messages
            if(projChatListener) projChatListener();
            
            projChatListener = db.collection("projects").doc(projId).collection("messages")
                .orderBy("timestamp", "asc")
                .onSnapshot(snap => {
                    chatBox.innerHTML = "";
                    snap.forEach(doc => {
                        const m = doc.data();
                        const isMine = m.sender === auth.currentUser.email;
                        const mineClass = isMine ? "msg-mine" : "msg-other";
                        
                        // FIXED: String Concatenation to avoid JSP display error
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
                senderName: "Employee", // Can fetch real name if needed, but keeping simple
                timestamp: firebase.firestore.FieldValue.serverTimestamp()
            }).then(() => { input.value = ""; });
        }

        /* --- MODAL LOGIC (Existing) --- */
        function openTask(id, encodedData) {
            currentTaskId = id;
            const d = JSON.parse(decodeURIComponent(encodedData));
            document.getElementById("mTitle").innerText = d.title;
            document.getElementById("mDesc").innerText = d.description || "No description provided.";
            document.getElementById("mDate").innerText = d.dueDate || "-";
            document.getElementById("mProj").innerText = d.project;
            const photoBox = document.getElementById("mPhotoBox");
            if(d.photo) {
                photoBox.style.display = "block";
                document.getElementById("mPhotoLink").href = d.photo; 
            } else { photoBox.style.display = "none"; }
            document.getElementById("taskModal").style.display = "flex";
            loadChat(id);
        }

        function loadChat(taskId) {
            const chatBox = document.getElementById("chatMessages");
            chatBox.innerHTML = "<div style='text-align:center; color:#999; margin-top:10px;'>Loading conversation...</div>";
            if(chatListener) chatListener();
            chatListener = db.collection("tasks").doc(taskId).collection("replies").orderBy("timestamp", "asc").onSnapshot(snap => {
                chatBox.innerHTML = "";
                if(snap.empty) chatBox.innerHTML = "<div style='text-align:center; color:#ccc; margin-top:20px;'>No replies yet.</div>";
                snap.forEach(doc => {
                    const m = doc.data();
                    const isMine = m.email === currentUserEmail;
                    const bubbleClass = isMine ? "msg-mine" : "msg-other";
                    const senderName = isMine ? "Me" : (m.role === 'admin' ? "Admin" : m.email);
                    const time = m.timestamp ? new Date(m.timestamp.seconds * 1000).toLocaleTimeString([], {hour:'2-digit', minute:'2-digit'}) : "";
                    
                    // FIXED: String Concatenation here too
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
                message: msg, email: currentUserEmail, role: 'employee',
                timestamp: firebase.firestore.FieldValue.serverTimestamp()
            }).then(() => { input.value = ""; }).catch(e => alert("Error: " + e.message));
        }

        function closeModal() {
            document.getElementById("taskModal").style.display = "none";
            if(chatListener) chatListener();
        }

        window.updateStatus = function(docId, selectElement) {
            const newStatus = selectElement.value;
            selectElement.className = "status-select " + newStatus;
            db.collection("tasks").doc(docId).update({ status: newStatus });
        };

        function logout() {
            auth.signOut().then(() => window.location.href = "login.jsp");
        }
    </script>
</body>
</html>