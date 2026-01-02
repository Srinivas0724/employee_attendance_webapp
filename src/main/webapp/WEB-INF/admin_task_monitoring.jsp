<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
  response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
  response.setHeader("Pragma", "no-cache");
  response.setDateHeader("Expires", 0);
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Task Monitoring - Admin</title>

<style>
/* ADMIN GLOBAL STYLES */
body { margin:0; font-family:"Segoe UI", sans-serif; background:#f4f6f9; display:flex; height:100vh; color:#333; }

/* ADMIN SIDEBAR (Red/Dark Theme) */
.sidebar { width:260px; background:#212529; color:#fff; display:flex; flex-direction:column; }
.sidebar h2 { padding:20px; margin:0; background:#c0392b; text-align:center; font-size: 22px; }
.sidebar a { display:block; padding:15px 20px; color:#adb5bd; text-decoration:none; border-left: 3px solid transparent; }
.sidebar a:hover, .sidebar a.active { background:#343a40; color:#fff; border-left: 3px solid #e74c3c; }

/* MAIN CONTENT */
.main { flex:1; display:flex; flex-direction:column; overflow-y: auto; }
.header { height:60px; background:#fff; display:flex; justify-content:space-between; align-items:center; padding:0 30px; border-bottom: 1px solid #dee2e6; }
.content { padding: 30px; }

/* TABLE */
.card { background: white; padding: 25px; border-radius: 8px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
table { width: 100%; border-collapse: collapse; margin-top: 15px; }
th { background: #34495e; color: white; padding: 12px; text-align: left; font-size: 14px; }
td { padding: 12px; border-bottom: 1px solid #eee; color: #333; vertical-align: middle; }
tr:hover { background: #f8f9fa; }

/* STATUS BADGES */
.badge { padding: 4px 8px; border-radius: 4px; color: white; font-size: 11px; font-weight: bold; }
.PENDING { background: #c0392b; }
.IN_PROGRESS { background: #f39c12; }
.DONE { background: #27ae60; }

.btn-chat { background: #3498db; color: white; border: none; padding: 6px 12px; border-radius: 4px; cursor: pointer; font-size: 12px; }
.btn-chat:hover { background: #2980b9; }

/* --- MODAL (Copied Logic) --- */
.modal { display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; background-color: rgba(0,0,0,0.6); align-items: center; justify-content: center; }
.modal-content { background-color: #fff; width: 600px; max-width: 90%; height: 80vh; border-radius: 8px; display: flex; flex-direction: column; overflow: hidden; box-shadow: 0 5px 15px rgba(0,0,0,0.3); }

.modal-header { background: #c0392b; color: white; padding: 15px; display: flex; justify-content: space-between; align-items: center; } /* Red Header for Admin */
.modal-body { flex: 1; padding: 20px; overflow-y: auto; display: flex; flex-direction: column; gap: 15px; }

.task-info-box { background: #f8f9fa; padding: 15px; border-radius: 5px; border: 1px solid #e9ecef; }

/* CHAT AREA */
.chat-container { border: 1px solid #ddd; border-radius: 5px; flex: 1; display: flex; flex-direction: column; background: #fff; }
.chat-messages { flex: 1; padding: 15px; overflow-y: auto; background: #fdfdfd; display: flex; flex-direction: column; gap: 10px; }

.msg-bubble { padding: 8px 12px; border-radius: 15px; max-width: 80%; font-size: 13px; line-height: 1.4; position: relative; }
.msg-mine { background: #fadbd8; align-self: flex-end; border-bottom-right-radius: 0; } /* Red tint for Admin */
.msg-other { background: #e9ecef; align-self: flex-start; border-bottom-left-radius: 0; }
.msg-meta { font-size: 10px; color: #777; margin-top: 4px; display: block; text-align: right; }

.chat-input-area { padding: 10px; border-top: 1px solid #ddd; display: flex; gap: 10px; background: #eee; }
.chat-input { flex: 1; padding: 10px; border: 1px solid #ccc; border-radius: 20px; outline: none; }
.btn-send { background: #c0392b; color: white; border: none; padding: 0 20px; border-radius: 20px; cursor: pointer; font-weight: bold; }

.close-btn { background: none; border: none; color: white; font-size: 20px; cursor: pointer; }

#loadingOverlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: white; z-index: 9999; display: flex; justify-content: center; align-items: center; font-size: 24px; color: #333; }
</style>

<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-auth-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-firestore-compat.js"></script>
</head>
<body>

<div id="loadingOverlay">⌛ Loading...</div>

<div id="mainApp" style="display:none; width: 100%; height: 100%;">
    
    <div class="sidebar">
      <h2>ADMIN PORTAL</h2>
      <a href="admin_dashboard.jsp">📊 Dashboard</a>
      <a href="manage_employees.jsp">👥 Manage Employees</a>
      <a href="admin_task_monitoring.jsp" class="active">📝 Task Monitoring</a> <a href="reports.jsp">📅 Attendance Reports</a>
      <a href="payroll.jsp">💰 Payroll Management</a>
      <a href="admin_expenses.jsp" class="active">💸 Expense Approvals</a>
      <a href="admin_settings.jsp">⚙️ Settings</a>
      <a href="#" onclick="logout()" style="margin-top:auto; background:#1a1d20;">🚪 Logout</a>
    </div>

    <div class="main">
        <div class="header">
            <h3>Task Monitoring</h3>
            <span style="font-weight:bold; color:#555;">Admin View</span>
        </div>

        <div class="content">
            <div class="card">
                <h3>All Assigned Tasks</h3>
                <p style="color:#666; font-size:14px; margin-top:0;">Monitor progress and reply to employee updates.</p>
                
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
                        <tr><td colspan="5">Loading...</td></tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<div id="taskModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <span style="font-size:18px; font-weight:bold;">Task Discussion (Admin Mode)</span>
            <button class="close-btn" onclick="closeModal()">×</button>
        </div>
        <div class="modal-body">
            <div class="task-info-box">
                <h3 id="mTitle" style="margin:0 0 5px 0; color:#333;"></h3>
                <div style="font-size:13px; color:#555;">Assigned To: <b id="mAssignee"></b></div>
                <p id="mDesc" style="margin:10px 0; color:#666; font-size:14px;"></p>
                <div style="font-size:12px; color:#888;">Project: <span id="mProj"></span></div>
            </div>

            <div style="font-weight:bold; font-size:14px; margin-top:5px;">Conversation:</div>
            <div class="chat-container">
                <div id="chatMessages" class="chat-messages"></div>
                <div class="chat-input-area">
                    <input type="text" id="chatInput" class="chat-input" placeholder="Reply to employee...">
                    <button class="btn-send" onclick="sendReply()">Reply</button>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
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

auth.onAuthStateChanged(user => {
  if (user) {
      currentAdminEmail = user.email;
      document.getElementById("loadingOverlay").style.display = "none";
      document.getElementById("mainApp").style.display = "flex";
      loadAllTasks();
  } else {
      window.location.replace("login.jsp");
  }
});

function loadAllTasks() {
    db.collection("tasks")
        .orderBy("timestamp", "desc")
        .onSnapshot(snap => {
            const tbody = document.getElementById("taskTableBody");
            if(snap.empty) {
                tbody.innerHTML = "<tr><td colspan='5'>No tasks found in system.</td></tr>";
                return;
            }

            let rows = "";
            snap.forEach(doc => {
                const d = doc.data();
                const id = doc.id;

                // Status Badge Color
                const badgeClass = d.status || "PENDING";
                
                // Safe Data for Modal
                const safeData = encodeURIComponent(JSON.stringify(d));

                rows += "<tr>";
                rows += "<td>" + d.assignedTo + "</td>";
                rows += "<td><b>" + d.title + "</b></td>";
                rows += "<td>" + (d.project || "General") + "</td>";
                rows += "<td><span class='badge " + badgeClass + "'>" + badgeClass + "</span></td>";
                rows += "<td><button class='btn-chat' onclick='openTask(\"" + id + "\", \"" + safeData + "\")'>Open Chat</button></td>";
                rows += "</tr>";
            });
            tbody.innerHTML = rows;
        });
}

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
            if(snap.empty) {
                chatBox.innerHTML = "<div style='text-align:center; color:#ccc; margin-top:20px;'>No conversation yet.</div>";
            }

            snap.forEach(doc => {
                const m = doc.data();
                // Admin messages are "Mine" in this view
                const isMine = m.role === 'admin';
                const bubbleClass = isMine ? "msg-mine" : "msg-other";
                const senderName = isMine ? "Admin (Me)" : "Employee";
                
                const time = m.timestamp ? new Date(m.timestamp.seconds * 1000).toLocaleTimeString([], {hour:'2-digit', minute:'2-digit'}) : "";

                const msgHtml = "<div class='msg-bubble " + bubbleClass + "'>" + 
                                "<div>" + m.message + "</div>" +
                                "<span class='msg-meta'>" + senderName + " • " + time + "</span>" +
                                "</div>";
                
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
        role: 'admin', // IMPORTANT: Identifies this as Admin reply
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
  auth.signOut().then(() => {
    window.location.replace("login.jsp");
  });
}
</script>

</body>
</html>