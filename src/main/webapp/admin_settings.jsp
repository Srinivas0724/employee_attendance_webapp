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
<title>Admin Settings - emPower</title>

<style>
/* GLOBAL STYLES */
body { margin:0; font-family:"Segoe UI", sans-serif; background:#f4f6f9; display:flex; height:100vh; color:#333; }

/* SIDEBAR */
.sidebar { width:260px; background:#212529; color:#fff; display:flex; flex-direction:column; }
.sidebar h2 { padding:20px; margin:0; background:#c0392b; text-align:center; font-size: 22px; }
.sidebar a { display:block; padding:15px 20px; color:#adb5bd; text-decoration:none; border-left: 3px solid transparent; }
.sidebar a:hover, .sidebar a.active { background:#343a40; color:#fff; border-left: 3px solid #e74c3c; }

/* MAIN CONTENT */
.main { flex:1; display:flex; flex-direction:column; overflow-y: auto; }
.header { height:60px; background:#fff; display:flex; justify-content:space-between; align-items:center; padding:0 30px; border-bottom: 1px solid #dee2e6; }
.content { padding: 30px; display:flex; flex-direction:column; gap:30px; }

/* CARDS */
.card { background: white; padding: 25px; border-radius: 8px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); width: 100%; box-sizing: border-box; }
.card h3 { margin-top: 0; color: #2c3e50; border-bottom: 2px solid #eee; padding-bottom: 10px; margin-bottom: 20px; }

/* ROW LAYOUT */
.row { display: flex; gap: 20px; flex-wrap: wrap; }
.col { flex: 1; min-width: 300px; }

/* INPUTS */
label { font-weight: bold; font-size: 13px; color: #555; display: block; margin-top: 15px; }
input, select { width: 100%; padding: 10px; margin-top: 5px; border: 1px solid #ced4da; border-radius: 4px; box-sizing: border-box; }

/* SHIFT GRID */
.shift-grid { display: grid; grid-template-columns: repeat(7, 1fr); gap: 10px; margin-top: 15px; }
.day-box { background: #f8f9fa; padding: 10px; border-radius: 5px; border: 1px solid #eee; text-align: center; }
.day-box label { margin-top: 0; margin-bottom: 5px; color: #2980b9; }
.day-box input { padding: 5px; text-align: center; }

/* TABLE */
table { width: 100%; border-collapse: collapse; margin-top: 15px; }
th { background: #34495e; color: white; padding: 12px; text-align: left; font-size: 14px; }
td { padding: 12px; border-bottom: 1px solid #eee; color: #333; vertical-align: middle; }

/* BUTTONS */
button { margin-top: 0; padding: 8px 12px; border: none; border-radius: 4px; font-weight: bold; cursor: pointer; transition: 0.3s; font-size:12px; }
.btn-green { background: #27ae60; color:white; }
.btn-blue { background: #3498db; color:white; }
.btn-disable { background: #e74c3c; color:white; }
.btn-disable:hover { background: #c0392b; }
.btn-enable { background: #3498db; color:white; }
.btn-save { background: #34495e; color:white; }
.btn-toggle { background: #34495e; color: white; width: auto; padding: 8px 15px; margin-top: 5px; }
.btn-toggle.active { background: #27ae60; }
.btn-toggle.inactive { background: #e74c3c; }

/* BADGES */
.badge { padding: 5px 10px; border-radius: 12px; font-size: 11px; font-weight: bold; color: white; display: inline-block; }
.bg-Pending { background: #f1c40f; color: #333; }
.bg-Approved { background: #27ae60; }
.bg-Disabled { background: #e74c3c; }

/* LOADING */
#loadingOverlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: white; z-index: 9999; display: flex; justify-content: center; align-items: center; font-size: 24px; color: #333; }
</style>

<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-auth-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-firestore-compat.js"></script>
</head>
<body>

<div id="loadingOverlay">⌛ Loading Settings...</div>

<div class="sidebar">
  <h2>ADMIN PORTAL</h2>
  <a href="admin_dashboard.jsp">📊 Dashboard</a>
  <a href="manage_employees.jsp">👥 Manage Employees</a>
  <a href="admin_task_monitoring.jsp">📝 Task Monitoring</a>
  <a href="reports.jsp">📅 Attendance Reports</a>
  <a href="payroll.jsp">💰 Payroll Management</a>
  <a href="admin_expenses.jsp">💸 Expense Approvals</a>
  <a href="admin_settings.jsp" class="active">⚙️ Settings</a>
  <a href="#" onclick="logout()" style="margin-top:auto; background:#1a1d20;">🚪 Logout</a>
</div>

<div class="main">
    <div class="header">
        <h3>User Management & Settings</h3>
        <span id="adminEmail" style="font-weight:bold; color:#555;">Loading...</span>
    </div>

    <div class="content">
        
        <div class="card" id="pendingSection" style="display:none; border-left: 5px solid #f1c40f;">
            <h3 style="color:#f39c12;">⏳ Pending Registrations</h3>
            <p style="margin-top:0; font-size:14px; color:#666;">These users have signed up but cannot login until you approve them.</p>
            <table>
                <thead>
                    <tr><th>Name</th><th>Email</th><th>Contact</th><th>Action</th></tr>
                </thead>
                <tbody id="pendingTable"></tbody>
            </table>
        </div>

        <div class="card">
            <h3>⏰ Employee Shift Manager</h3>
            <p style="font-size:14px; color:#666; margin-top:0;">
                Select an employee to define their daily start times. Type <b>"OFF"</b> for holidays.
                <br><i>Format: HH:MM (24-hour) e.g., 09:00, 14:30</i>
            </p>

            <select id="shiftUserSelect" onchange="loadUserShift()">
                <option value="">-- Select Employee to Edit Shift --</option>
            </select>

            <div id="shiftEditor" style="display:none;">
                <div class="shift-grid">
                    <div class="day-box"><label>Mon</label><input type="text" id="t_Mon" placeholder="09:30"></div>
                    <div class="day-box"><label>Tue</label><input type="text" id="t_Tue" placeholder="09:30"></div>
                    <div class="day-box"><label>Wed</label><input type="text" id="t_Wed" placeholder="09:30"></div>
                    <div class="day-box"><label>Thu</label><input type="text" id="t_Thu" placeholder="09:30"></div>
                    <div class="day-box"><label>Fri</label><input type="text" id="t_Fri" placeholder="09:30"></div>
                    <div class="day-box"><label>Sat</label><input type="text" id="t_Sat" placeholder="09:30"></div>
                    <div class="day-box"><label>Sun</label><input type="text" id="t_Sun" placeholder="OFF"></div>
                </div>
                <button class="btn-blue" onclick="saveShift()" style="margin-top:15px;">💾 Save Weekly Schedule</button>
            </div>
        </div>

        <div class="row">
            <div class="card col">
                <h3>⚙️ System Preferences</h3>
                <label>Company Name</label>
                <input type="text" id="companyName" placeholder="e.g. emPower Tech">
                <button class="btn-green" onclick="saveCompanyInfo()" style="margin-top:10px; width:auto;">Update</button>
                <hr style="margin:20px 0; border:0; border-top:1px solid #eee;">
                <label>Public Registration</label>
                <button id="signupToggleBtn" class="btn-toggle inactive" onclick="toggleSignups()">🚫 Disabled</button>
            </div>

            <div class="card col">
                <h3>🔐 Security</h3>
                <label>New Password</label>
                <input type="password" id="newPass" placeholder="New password">
                <label>Confirm Password</label>
                <input type="password" id="confirmPass" placeholder="Confirm password">
                <button class="btn-green" onclick="updatePassword()">Update Password</button>
            </div>
        </div>

        <div class="card">
            <h3>👥 All Users (Roles & Access)</h3>
            <table>
                <thead>
                    <tr>
                        <th>Name</th>
                        <th>Email</th>
                        <th>Role</th>
                        <th>Status</th>
                        <th>Role Action</th>
                        <th>Account Action</th>
                    </tr>
                </thead>
                <tbody id="userTable">
                    <tr><td colspan="6">Loading...</td></tr>
                </tbody>
            </table>
        </div>

    </div>
</div>

<script>
const firebaseConfig = { apiKey: "AIzaSyCV5tKJMLOVcXiZUyuJZhLWOOSD96gsmP0", authDomain: "attendencewebapp-4215b.firebaseapp.com", projectId: "attendencewebapp-4215b" };
if (!firebase.apps.length) firebase.initializeApp(firebaseConfig);
const auth = firebase.auth();
const db = firebase.firestore();

let currentUserEmail = "";
let signupEnabled = false;

auth.onAuthStateChanged(user => {
  if (user) {
      currentUserEmail = user.email;
      document.getElementById("adminEmail").innerText = user.email;
      loadSystemSettings();
      loadUsers();
  } else {
      window.location.replace("login.jsp");
  }
});

/* --- USER & SHIFT MANAGEMENT --- */
function loadUsers() {
    db.collection("users").get().then(snap => {
        const pendingTb = document.getElementById("pendingTable");
        const userTb = document.getElementById("userTable");
        const shiftSelect = document.getElementById("shiftUserSelect");
        const pendingSec = document.getElementById("pendingSection");
        
        pendingTb.innerHTML = "";
        userTb.innerHTML = "";
        shiftSelect.innerHTML = '<option value="">-- Select Employee to Edit Shift --</option>';
        
        let pendingCount = 0;

        snap.forEach(doc => {
            const u = doc.data();
            // Default status 'Approved' for legacy users so they don't get locked out
            const status = u.status || "Approved"; 
            const isMe = u.email === currentUserEmail;

            // 1. FILL SHIFT DROPDOWN (Employees Only)
            if(u.role !== 'admin') {
                let opt = document.createElement("option");
                opt.value = u.email;
                opt.text = (u.fullName || "User") + " (" + u.email + ")";
                shiftSelect.appendChild(opt);
            }

            // 2. PENDING REQUESTS TABLE
            if (status === 'Pending') {
                pendingCount++;
                pendingTb.innerHTML += `
                    <tr>
                        <td>\${u.fullName}</td>
                        <td>\${u.email}</td>
                        <td>\${u.contact || '-'}</td>
                        <td>
                            <button class="btn-green" onclick="updateStatus('\${doc.id}', 'Approved')">✅ Approve</button>
                            <button class="btn-disable" onclick="updateStatus('\${doc.id}', 'Disabled')">🚫 Reject</button>
                        </td>
                    </tr>`;
            }

            // 3. MAIN USER TABLE
            // Role Logic
            let roleHtml = isMe ? "<b>ADMIN</b>" : `
                <select id="role_\${doc.id}" style="padding:5px;">
                    <option value="employee" \${u.role==='employee'?'selected':''}>Employee</option>
                    <option value="admin" \${u.role==='admin'?'selected':''}>Admin</option>
                </select>
            `;
            let roleBtn = isMe ? "-" : `<button class="btn-save" onclick="updateRole('\${doc.id}')">Save Role</button>`;

            // Status Logic (Disable/Enable)
            let actionBtn = "";
            if(isMe) {
                actionBtn = "-";
            } else if (status === 'Disabled') {
                actionBtn = `<button class="btn-enable" onclick="updateStatus('\${doc.id}', 'Approved')">🔄 Re-Enable</button>`;
            } else {
                actionBtn = `<button class="btn-disable" onclick="updateStatus('\${doc.id}', 'Disabled')">🚫 Disable</button>`;
            }

            userTb.innerHTML += `
                <tr>
                    <td>\${u.fullName}</td>
                    <td>\${u.email}</td>
                    <td>\${roleHtml}</td>
                    <td><span class="badge bg-\${status}">\${status}</span></td>
                    <td>\${roleBtn}</td>
                    <td>\${actionBtn}</td>
                </tr>`;
        });

        // Toggle Pending Section
        if(pendingCount > 0) pendingSec.style.display = "block";
        else pendingSec.style.display = "none";
        
        document.getElementById("loadingOverlay").style.display = "none";
    });
}

function updateStatus(email, newStatus) {
    if(newStatus === 'Disabled' && !confirm("Block this user from logging in?")) return;
    db.collection("users").doc(email).update({ status: newStatus }).then(() => {
        alert("User updated to: " + newStatus);
        loadUsers();
    });
}

function updateRole(email) {
    const newRole = document.getElementById("role_" + email).value;
    db.collection("users").doc(email).update({ role: newRole }).then(() => {
        alert("Role Updated!");
        loadUsers();
    });
}

/* --- SHIFT LOGIC (KEPT FROM YOUR CODE) --- */
function loadUserShift() {
    const email = document.getElementById("shiftUserSelect").value;
    const editor = document.getElementById("shiftEditor");
    if(!email) { editor.style.display = "none"; return; }
    editor.style.display = "block";
    db.collection("users").doc(email).get().then(doc => {
        const data = doc.data();
        const s = data.shiftTimings || {};
        document.getElementById("t_Mon").value = s.Mon || "09:30";
        document.getElementById("t_Tue").value = s.Tue || "09:30";
        document.getElementById("t_Wed").value = s.Wed || "09:30";
        document.getElementById("t_Thu").value = s.Thu || "09:30";
        document.getElementById("t_Fri").value = s.Fri || "09:30";
        document.getElementById("t_Sat").value = s.Sat || "09:30";
        document.getElementById("t_Sun").value = s.Sun || "OFF";
    });
}

function saveShift() {
    const email = document.getElementById("shiftUserSelect").value;
    if(!email) return;
    const timings = {
        Mon: document.getElementById("t_Mon").value,
        Tue: document.getElementById("t_Tue").value,
        Wed: document.getElementById("t_Wed").value,
        Thu: document.getElementById("t_Thu").value,
        Fri: document.getElementById("t_Fri").value,
        Sat: document.getElementById("t_Sat").value,
        Sun: document.getElementById("t_Sun").value
    };
    db.collection("users").doc(email).update({ shiftTimings: timings })
      .then(() => alert("✅ Weekly Schedule Updated for " + email))
      .catch(e => alert("Error: " + e.message));
}

/* --- SYSTEM SETTINGS --- */
function loadSystemSettings() {
    db.collection("settings").doc("system").onSnapshot(doc => {
        if(doc.exists) {
            const data = doc.data();
            if(data.companyName) document.getElementById("companyName").value = data.companyName;
            signupEnabled = data.allowSignups || false;
            updateToggleUI();
        }
    });
}
function saveCompanyInfo() {
    const name = document.getElementById("companyName").value;
    db.collection("settings").doc("system").set({ companyName: name }, { merge: true }).then(() => alert("✅ Saved!"));
}
function toggleSignups() {
    signupEnabled = !signupEnabled;
    db.collection("settings").doc("system").set({ allowSignups: signupEnabled }, { merge: true }).then(() => updateToggleUI());
}
function updateToggleUI() {
    const btn = document.getElementById("signupToggleBtn");
    if(signupEnabled) { btn.innerText = "✅ Signups Enabled"; btn.className = "btn-toggle active"; }
    else { btn.innerText = "🚫 Disabled"; btn.className = "btn-toggle inactive"; }
}

/* --- SECURITY --- */
function updatePassword() {
    const p1 = document.getElementById("newPass").value;
    const p2 = document.getElementById("confirmPass").value;
    if(p1.length < 6 || p1 !== p2) { alert("Invalid password."); return; }
    auth.currentUser.updatePassword(p1).then(() => { alert("Updated! Login again."); logout(); })
    .catch(e => { if(e.code==='auth/requires-recent-login'){ alert("Session old. Logging out."); logout(); } else alert(e.message); });
}

function logout(){ auth.signOut().then(() => location.href = "login.jsp"); }
</script>
</body>
</html>