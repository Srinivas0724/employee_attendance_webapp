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

        /* TABLE STYLES */
        .card { background:white; padding:20px; border-radius:8px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
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

        /* --- MODAL (TASK DETAIL & CHAT) --- */
        .modal { display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; background-color: rgba(0,0,0,0.6); align-items: center; justify-content: center; }
        .modal-content { background-color: #fff; width: 600px; max-width: 90%; height: 80vh; border-radius: 8px; display: flex; flex-direction: column; overflow: hidden; box-shadow: 0 5px 15px rgba(0,0,0,0.3); }
        
        .modal-header { background: #343a40; color: white; padding: 15px; display: flex; justify-content: space-between; align-items: center; }
        .modal-body { flex: 1; padding: 20px; overflow-y: auto; display: flex; flex-direction: column; gap: 15px; }
        
        .task-info-box { background: #f8f9fa; padding: 15px; border-radius: 5px; border: 1px solid #e9ecef; }
        
        /* CHAT SECTION */
        .chat-container { border: 1px solid #ddd; border-radius: 5px; flex: 1; display: flex; flex-direction: column; background: #fff; }
        .chat-messages { flex: 1; padding: 15px; overflow-y: auto; background: #fdfdfd; display: flex; flex-direction: column; gap: 10px; }
        
        .msg-bubble { padding: 8px 12px; border-radius: 15px; max-width: 80%; font-size: 13px; line-height: 1.4; position: relative; }
        .msg-mine { background: #dcf8c6; align-self: flex-end; border-bottom-right-radius: 0; }
        .msg-other { background: #e9ecef; align-self: flex-start; border-bottom-left-radius: 0; }
        .msg-meta { font-size: 10px; color: #777; margin-top: 4px; display: block; text-align: right; }

        .chat-input-area { padding: 10px; border-top: 1px solid #ddd; display: flex; gap: 10px; background: #eee; }
        .chat-input { flex: 1; padding: 10px; border: 1px solid #ccc; border-radius: 20px; outline: none; }
        .btn-send { background: #28a745; color: white; border: none; padding: 0 20px; border-radius: 20px; cursor: pointer; font-weight: bold; }

        .close-btn { background: none; border: none; color: white; font-size: 20px; cursor: pointer; }
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
            <h3>My Tasks</h3>
            <span id="userEmail">Loading...</span>
        </div>

        <div class="content">
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
                    <div id="chatMessages" class="chat-messages">
                        </div>
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
        let chatListener = null;

        auth.onAuthStateChanged(user => {
            if(user) {
                currentUserEmail = user.email;
                document.getElementById("userEmail").innerText = user.email;
                loadMyTasks(user.email);
            } else {
                window.location.href = "login.jsp";
            }
        });

        function loadMyTasks(email) {
            const tbody = document.getElementById("myTasksTable");

            /* FIX: REMOVED .orderBy() so it works without index! */
            db.collection("tasks")
                .where("assignedTo", "==", email)
                .onSnapshot(snap => {
                    if(snap.empty) {
                        tbody.innerHTML = "<tr><td colspan='5' style='text-align:center; padding:20px;'>No tasks assigned.</td></tr>";
                        return;
                    }

                    let rows = "";
                    snap.forEach(doc => {
                        const d = doc.data();
                        const id = doc.id; 

                        // Clean Data
                        const title = d.title || "Untitled";
                        const project = d.project || "General";
                        const priority = d.priority || "LOW";
                        
                        // Status Logic
                        const sPending = d.status === 'PENDING' ? 'selected' : '';
                        const sProg = d.status === 'IN_PROGRESS' ? 'selected' : '';
                        const sDone = d.status === 'DONE' ? 'selected' : '';

                        // Store full object in a data attribute to pass to modal
                        const safeData = encodeURIComponent(JSON.stringify(d));

                        rows += "<tr>";
                        rows += "<td><div style='font-weight:bold;'>" + title + "</div></td>";
                        rows += "<td>" + project + "</td>";
                        rows += "<td><span class='badge bg-" + priority + "'>" + priority + "</span></td>";
                        
                        // Status Dropdown
                        rows += "<td>";
                        rows += "<select class='status-select " + d.status + "' onchange='updateStatus(\"" + id + "\", this)'>";
                        rows += "<option value='PENDING' " + sPending + ">PENDING</option>";
                        rows += "<option value='IN_PROGRESS' " + sProg + ">IN PROGRESS</option>";
                        rows += "<option value='DONE' " + sDone + ">DONE</option>";
                        rows += "</select>";
                        rows += "</td>";

                        // Open Button
                        rows += "<td>";
                        rows += "<button class='btn-open' onclick='openTask(\"" + id + "\", \"" + safeData + "\")'>Open & Reply</button>";
                        rows += "</td>";
                        rows += "</tr>";
                    });
                    tbody.innerHTML = rows;
                });
        }

        /* --- MODAL LOGIC --- */
        function openTask(id, encodedData) {
            currentTaskId = id;
            const d = JSON.parse(decodeURIComponent(encodedData));

            // Populate Info
            document.getElementById("mTitle").innerText = d.title;
            document.getElementById("mDesc").innerText = d.description || "No description provided.";
            document.getElementById("mDate").innerText = d.dueDate || "-";
            document.getElementById("mProj").innerText = d.project;

            // Handle Photo
            const photoBox = document.getElementById("mPhotoBox");
            if(d.photo) {
                photoBox.style.display = "block";
                document.getElementById("mPhotoLink").href = d.photo; // Base64 link
            } else {
                photoBox.style.display = "none";
            }

            // Show Modal
            document.getElementById("taskModal").style.display = "flex";

            // LOAD CHAT MESSAGES
            loadChat(id);
        }

        function loadChat(taskId) {
            const chatBox = document.getElementById("chatMessages");
            chatBox.innerHTML = "<div style='text-align:center; color:#999; margin-top:10px;'>Loading conversation...</div>";

            // Detach previous listener if exists
            if(chatListener) chatListener();

            // Realtime listener for sub-collection
            chatListener = db.collection("tasks").doc(taskId).collection("replies")
                .orderBy("timestamp", "asc")
                .onSnapshot(snap => {
                    chatBox.innerHTML = ""; // Clear
                    if(snap.empty) {
                        chatBox.innerHTML = "<div style='text-align:center; color:#ccc; margin-top:20px;'>No replies yet. Start the conversation!</div>";
                    }

                    snap.forEach(doc => {
                        const m = doc.data();
                        const isMine = m.email === currentUserEmail;
                        const bubbleClass = isMine ? "msg-mine" : "msg-other";
                        const senderName = isMine ? "Me" : (m.role === 'admin' ? "Admin" : m.email);

                        const time = m.timestamp ? new Date(m.timestamp.seconds * 1000).toLocaleTimeString([], {hour:'2-digit', minute:'2-digit'}) : "";

                        const msgHtml = "<div class='msg-bubble " + bubbleClass + "'>" + 
                                        "<div>" + m.message + "</div>" +
                                        "<span class='msg-meta'>" + senderName + " • " + time + "</span>" +
                                        "</div>";
                        
                        chatBox.innerHTML += msgHtml;
                    });

                    // Scroll to bottom
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
                role: 'employee',
                timestamp: firebase.firestore.FieldValue.serverTimestamp()
            }).then(() => {
                input.value = ""; // Clear input
            }).catch(e => alert("Error sending: " + e.message));
        }

        function closeModal() {
            document.getElementById("taskModal").style.display = "none";
            if(chatListener) chatListener(); // Stop listening
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