<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
  // Prevent Caching
  response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
  response.setHeader("Pragma", "no-cache");
  response.setDateHeader("Expires", 0);
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Manage Employees - emPower Admin</title>

<style>
/* --- GLOBAL ADMIN STYLES --- */
body { margin:0; font-family:"Segoe UI", sans-serif; background:#f4f6f9; display:flex; height:100vh; color:#333; }

/* ADMIN SIDEBAR (Red/Dark Theme) */
.sidebar { width:260px; background:#212529; color:#fff; display:flex; flex-direction:column; }
.sidebar h2 { padding:20px; margin:0; background:#c0392b; text-align:center; font-size: 22px; }
.sidebar a { display:block; padding:15px 20px; color:#adb5bd; text-decoration:none; border-left: 3px solid transparent; }
.sidebar a:hover, .sidebar a.active { background:#343a40; color:#fff; border-left: 3px solid #e74c3c; }

/* MAIN CONTENT */
.main { flex:1; display:flex; flex-direction:column; overflow-y: auto; }
.header { height:60px; background:#fff; display:flex; justify-content:space-between; align-items:center; padding:0 30px; border-bottom: 1px solid #dee2e6; }

.content { padding: 30px; display: flex; gap: 30px; flex-wrap: wrap; }

/* CARDS */
.card { background: white; padding: 25px; border-radius: 8px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
.full-width { width: 100%; }
.half-width { flex: 1; min-width: 300px; }

h3 { margin-top: 0; color: #2c3e50; border-bottom: 2px solid #eee; padding-bottom: 10px; }

/* FORM ELEMENTS */
label { font-weight: bold; font-size: 13px; color: #555; display: block; margin-top: 15px; }
input, select, textarea { width: 100%; padding: 10px; margin-top: 5px; border: 1px solid #ced4da; border-radius: 4px; box-sizing: border-box; }
textarea { height: 80px; resize: vertical; }

button { margin-top: 20px; padding: 12px; width: 100%; background: #27ae60; color: white; border: none; border-radius: 4px; font-weight: bold; cursor: pointer; transition: 0.3s; }
button:hover { background: #219150; }

/* TABLE STYLES */
table { width: 100%; border-collapse: collapse; margin-top: 15px; }
th { background: #34495e; color: white; padding: 12px; text-align: left; font-size: 14px; }
td { padding: 12px; border-bottom: 1px solid #eee; color: #333; }
tr:hover { background: #f8f9fa; }

/* LOADING OVERLAY */
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
      <a href="reports.jsp">📅 Attendance Reports</a>
      <a href="payroll.jsp">💰 Payroll Management</a>
      <a href="admin_settings.jsp">⚙️ Settings</a>
      <a href="#" onclick="logout()" style="margin-top:auto; background:#1a1d20;">🚪 Logout</a>
    </div>

    <div class="main">
        <div class="header">
            <h3>Manage Employees</h3>
            <span id="adminEmail" style="font-weight:bold; color:#555;">Loading...</span>
        </div>

        <div class="content">
            
            <div class="card half-width">
                <h3>📝 Assign New Task</h3>
                
                <label>Select Employee</label>
                <select id="empSelect">
                    <option value="">-- Choose Employee --</option>
                </select>

                <label>Task Title</label>
                <input type="text" id="taskTitle" placeholder="e.g. Complete Site Report">

                <label>Description</label>
                <textarea id="taskDesc" placeholder="Enter detailed instructions..."></textarea>

                <div style="display:flex; gap:10px;">
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

                <div style="display:flex; gap:10px;">
                    <div style="flex:1">
                        <label>Due Date</label>
                        <input type="date" id="taskDate">
                    </div>
                    <div style="flex:1">
                        <label>Reference Image (Optional)</label>
                        <input type="file" id="taskFile" accept="image/*">
                    </div>
                </div>

                <button onclick="assignTask()" id="assignBtn">Assign Task</button>
            </div>

            <div class="card half-width">
                <h3>👥 Employee Directory</h3>
                <table>
                    <thead>
                        <tr>
                            <th>Name</th>
                            <th>Email</th>
                            <th>Contact</th>
                        </tr>
                    </thead>
                    <tbody id="empTableBody">
                        <tr><td colspan="3">Loading directory...</td></tr>
                    </tbody>
                </table>
            </div>

        </div>
    </div>
</div>

<script>
/* FIREBASE CONFIG */
const firebaseConfig = { apiKey: "AIzaSyCV5tKJMLOVcXiZUyuJZhLWOOSD96gsmP0", authDomain: "attendencewebapp-4215b.firebaseapp.com", projectId: "attendencewebapp-4215b" };
if (!firebase.apps.length) firebase.initializeApp(firebaseConfig);
const auth = firebase.auth();
const db = firebase.firestore();

/* AUTH CHECK */
auth.onAuthStateChanged(user => {
  if (user) {
      document.getElementById("adminEmail").innerText = user.email;
      document.getElementById("loadingOverlay").style.display = "none";
      document.getElementById("mainApp").style.display = "flex";
      loadEmployees();
  } else {
      window.location.replace("login.jsp");
  }
});

/* LOAD EMPLOYEES (Table & Dropdown) */
function loadEmployees() {
    db.collection("users").get().then(snap => {
        const empSelect = document.getElementById("empSelect");
        const tbody = document.getElementById("empTableBody");
        
        empSelect.innerHTML = '<option value="">-- Choose Employee --</option>';
        tbody.innerHTML = "";

        if(snap.empty) {
            tbody.innerHTML = "<tr><td colspan='3'>No employees found.</td></tr>";
            return;
        }

        snap.forEach(doc => {
            const data = doc.data();
            // Don't show admin in the assignment list (optional check)
            if(data.role !== 'admin') {
                // 1. Populate Dropdown
                const option = document.createElement("option");
                option.value = data.email;
                option.innerText = data.fullName + " (" + data.email + ")";
                empSelect.appendChild(option);

                // 2. Populate Table
                const row = `
                    <tr>
                        <td>\${data.fullName || 'N/A'}</td>
                        <td>\${data.email}</td>
                        <td>\${data.contact || '-'}</td>
                    </tr>
                `;
                tbody.innerHTML += row;
            }
        });
    });
}

/* ASSIGN TASK */
function assignTask() {
    const assignedTo = document.getElementById("empSelect").value;
    const title = document.getElementById("taskTitle").value;
    const desc = document.getElementById("taskDesc").value;
    const project = document.getElementById("taskProject").value;
    const priority = document.getElementById("taskPriority").value;
    const dueDate = document.getElementById("taskDate").value;
    const fileInput = document.getElementById("taskFile");
    const btn = document.getElementById("assignBtn");

    if(!assignedTo || !title || !dueDate) {
        alert("Please select an employee, enter a title, and pick a due date.");
        return;
    }

    btn.innerText = "Assigning...";
    btn.disabled = true;

    // Helper function to save to DB
    const saveToDB = (photoBase64) => {
        db.collection("tasks").add({
            assignedTo: assignedTo,
            assignedBy: auth.currentUser.email,
            title: title,
            description: desc,
            project: project || "General",
            priority: priority,
            dueDate: dueDate,
            status: "PENDING",
            photo: photoBase64, // Saves image string or null
            timestamp: firebase.firestore.FieldValue.serverTimestamp()
        }).then(() => {
            alert("✅ Task Assigned Successfully!");
            // Reset Form
            document.getElementById("taskTitle").value = "";
            document.getElementById("taskDesc").value = "";
            document.getElementById("taskFile").value = "";
            btn.innerText = "Assign Task";
            btn.disabled = false;
        }).catch(err => {
            alert("Error: " + err.message);
            btn.innerText = "Assign Task";
            btn.disabled = false;
        });
    };

    // Handle File Upload (If exists)
    if(fileInput.files.length > 0) {
        const file = fileInput.files[0];
        const reader = new FileReader();
        reader.onload = function(e) {
            // Basic compression/resize logic could go here, 
            // but for simple tasks we just use the result.
            saveToDB(e.target.result); 
        };
        reader.readAsDataURL(file);
    } else {
        saveToDB(null); // No photo
    }
}

function logout(){
  auth.signOut().then(() => {
    window.location.replace("login.jsp");
  });
}
</script>

</body>
</html>