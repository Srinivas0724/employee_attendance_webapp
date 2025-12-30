<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
  // 1. PASTE THE CACHE CODE HERE (Lines 2-6)
  response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
  response.setHeader("Pragma", "no-cache");
  response.setDateHeader("Expires", 0);
%>
<%@ page isELIgnored="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Admin - Task Manager</title>
    <style>
        /* --- GLOBAL LAYOUT (Consistent with other pages) --- */
        body { display: flex; height: 100vh; margin: 0; font-family: 'Segoe UI', sans-serif; background: #f4f6f9; overflow: hidden; }
        .sidebar { width: 260px; background: #343a40; color: white; display: flex; flex-direction: column; }
        .brand { padding: 20px; font-size: 22px; font-weight: bold; background: #212529; text-align: center; }
        .nav-links { list-style: none; padding: 0; margin: 0; }
        .nav-links li a { display: block; padding: 15px 20px; color: #c2c7d0; text-decoration: none; border-left: 4px solid transparent; }
        .nav-links li a:hover, .nav-links li a.active { background: #495057; color: white; border-left-color: #007bff; }
        .main { flex: 1; display: flex; flex-direction: column; }
        .header { background: white; padding: 10px 30px; display: flex; justify-content: flex-end; align-items: center; height: 60px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
        .content { padding: 30px; overflow-y: auto; }
        
        /* --- CARDS & FORMS --- */
        .card { background: white; padding: 25px; border-radius: 8px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); margin-bottom: 25px; }
        h3 { margin-top: 0; color: #333; border-bottom: 2px solid #007bff; padding-bottom: 10px; display: inline-block;}

        .form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-top: 15px; }
        .form-group { margin-bottom: 5px; }
        label { display: block; margin-bottom: 5px; font-weight: bold; color: #555; font-size: 13px; }
        input, select, textarea { width: 100%; padding: 10px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box; font-size: 14px; }
        textarea { resize: vertical; }

        button.btn-primary { background: #007bff; color: white; border: none; padding: 12px 25px; border-radius: 4px; cursor: pointer; font-size: 15px; font-weight: bold; margin-top: 20px; }
        button.btn-primary:hover { background: #0056b3; }

        /* --- TABLE STYLES --- */
        table { width: 100%; border-collapse: collapse; margin-top: 10px; font-size: 14px; }
        th { background: #343a40; color: white; padding: 12px; text-align: left; }
        td { padding: 12px; border-bottom: 1px solid #ddd; color: #333; vertical-align: middle; }
        tr:hover { background-color: #f1f1f1; }
        
        /* Badges */
        .badge { padding: 4px 8px; border-radius: 4px; font-size: 11px; font-weight: bold; color: white; }
        .bg-HIGH { background-color: #dc3545; }
        .bg-MEDIUM { background-color: #ffc107; color: #333; }
        .bg-LOW { background-color: #28a745; }

        /* Status Dropdown (Mini) */
        .status-mini { padding: 4px; font-size: 12px; border-radius: 4px; border: 1px solid #ccc; }
    </style>

    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-auth-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-firestore-compat.js"></script>
</head>
<body>

    <div class="sidebar">
        <div class="brand">emPower Admin</div>
        <ul class="nav-links">
            <li><a href="#" class="active">📝 Task Manager</a></li>
            <li><a href="#" onclick="logout()">🚪 Logout</a></li>
        </ul>
    </div>

    <div class="main">
        <div class="header">
            <strong>Admin Console</strong>
        </div>

        <div class="content">
            
            <div class="card">
                <h3>Assign New Task</h3>
                <div class="form-grid">
                    <div class="form-group">
                        <label>Task Title</label>
                        <input type="text" id="t_title" placeholder="e.g. Fix Login Page Bug">
                    </div>
                    <div class="form-group">
                        <label>Project Name</label>
                        <input type="text" id="t_project" placeholder="e.g. Website Redesign">
                    </div>
                    <div class="form-group">
                        <label>Assign To (Employee)</label>
                        <select id="t_assignee">
                            <option value="">Loading employees...</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Priority</label>
                        <select id="t_priority">
                            <option value="LOW">Low</option>
                            <option value="MEDIUM">Medium</option>
                            <option value="HIGH">High</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Due Date</label>
                        <input type="date" id="t_date">
                    </div>
                    <div class="form-group">
                        <label>Description</label>
                        <textarea id="t_desc" rows="1" placeholder="Task details..."></textarea>
                    </div>
                </div>
                <button class="btn-primary" onclick="createTask()">+ Assign Task</button>
            </div>

            <div class="card">
                <h3>All Company Tasks</h3>
                <table>
                    <thead>
                        <tr>
                            <th>Title</th>
                            <th>Assigned To</th>
                            <th>Project</th>
                            <th>Priority</th>
                            <th>Due Date</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody id="allTasksTable">
                        <tr><td colspan="6">Loading tasks...</td></tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <script>
        /* --- FIREBASE CONFIG --- */
        const firebaseConfig = {
            apiKey: "AIzaSyCV5tKJMLOVcXiZUyuJZhLWOOSD96gsmP0",
            authDomain: "attendencewebapp-4215b.firebaseapp.com",
            projectId: "attendencewebapp-4215b",
            storageBucket: "attendencewebapp-4215b.firebasestorage.app",
            messagingSenderId: "97124588288",
            appId: "1:97124588288:web:08507eaacdc6155ad1b1e5"
        };
        if (!firebase.apps.length) firebase.initializeApp(firebaseConfig);
        const db = firebase.firestore();
        const auth = firebase.auth();

        /* --- INIT --- */
        auth.onAuthStateChanged(user => {
            if(user) {
                // In a real app, you should check if this user is actually an Admin here
                loadUsersForDropdown();
                loadAllTasks(); 
            } else {
                window.location.href = "login.jsp";
            }
        });

        /* --- 1. POPULATE 'ASSIGN TO' DROPDOWN --- */
        function loadUsersForDropdown() {
            const select = document.getElementById("t_assignee");
            db.collection("users").get().then(snap => {
                let options = '<option value="">Select Employee...</option>';
                snap.forEach(doc => {
                    const data = doc.data();
                    // Fallback if fullName doesn't exist
                    const name = data.fullName || "User";
                    const email = data.email || doc.id;
                    options += `<option value="${email}">${name} (${email})</option>`;
                });
                select.innerHTML = options;
            });
        }

        /* --- 2. CREATE TASK --- */
        function createTask() {
            // Get values
            const title = document.getElementById("t_title").value;
            const project = document.getElementById("t_project").value;
            const assignee = document.getElementById("t_assignee").value;
            const priority = document.getElementById("t_priority").value;
            const dueDate = document.getElementById("t_date").value;
            const desc = document.getElementById("t_desc").value;

            // Validation
            if(!title || !assignee || !dueDate) {
                alert("Please fill in Title, Assignee, and Due Date.");
                return;
            }

            // Save to Firestore
            db.collection("tasks").add({
                title: title,
                project: project || "General",
                assignedTo: assignee, // We store the email to link it
                priority: priority,
                dueDate: dueDate,
                description: desc,
                status: "PENDING", // Default status
                timestamp: firebase.firestore.FieldValue.serverTimestamp()
            }).then(() => {
                alert("Task Assigned Successfully!");
                loadAllTasks(); // Refresh table immediately
                // Reset Form
                document.getElementById("t_title").value = "";
                document.getElementById("t_desc").value = "";
            }).catch(err => {
                alert("Error saving task: " + err.message);
            });
        }

        /* --- 3. LOAD ALL TASKS (MASTER VIEW) --- */
        function loadAllTasks() {
            const tbody = document.getElementById("allTasksTable");
            
            db.collection("tasks")
                .orderBy("timestamp", "desc") // Show newest tasks first
                .get()
                .then(snap => {
                    if(snap.empty) {
                        tbody.innerHTML = "<tr><td colspan='6'>No tasks found.</td></tr>";
                        return;
                    }
                    
                    let rows = "";
                    snap.forEach(doc => {
                        const d = doc.data();
                        const id = doc.id;

                        // Admin Status Override Logic
                        const sPending = d.status === 'PENDING' ? 'selected' : '';
                        const sProg = d.status === 'IN_PROGRESS' ? 'selected' : '';
                        const sDone = d.status === 'DONE' ? 'selected' : '';

                        rows += `
                            <tr>
                                <td><b>${d.title}</b></td>
                                <td>${d.assignedTo}</td>
                                <td>${d.project || "-"}</td>
                                <td><span class="badge bg-${d.priority}">${d.priority}</span></td>
                                <td>${d.dueDate}</td>
                                <td>
                                    <select class="status-mini" onchange="updateStatus('${id}', this)">
                                        <option value="PENDING" ${sPending}>PENDING</option>
                                        <option value="IN_PROGRESS" ${sProg}>IN_PROGRESS</option>
                                        <option value="DONE" ${sDone}>DONE</option>
                                    </select>
                                </td>
                            </tr>
                        `;
                    });
                    tbody.innerHTML = rows;
                })
                .catch(err => {
                    console.error(err);
                    tbody.innerHTML = "<tr><td colspan='6' style='color:red'>Error loading tasks.</td></tr>";
                });
        }

        /* --- 4. UPDATE STATUS (ADMIN OVERRIDE) --- */
        window.updateStatus = function(docId, selectElement) {
            db.collection("tasks").doc(docId).update({
                status: selectElement.value
            }).then(() => {
                console.log("Admin updated status.");
            });
        };

        function logout() {
            auth.signOut().then(() => window.location.href = "login.jsp");
        }
    </script>
</body>
</html>