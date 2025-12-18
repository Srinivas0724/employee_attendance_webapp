<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page isELIgnored="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>My Assigned Tasks</title>
    <style>
        /* --- GLOBAL STYLES (Same as Attendance) --- */
        body { display: flex; height: 100vh; margin: 0; font-family: 'Segoe UI', sans-serif; background: #f4f6f9; overflow: hidden; }
        .sidebar { width: 260px; background: #343a40; color: white; display: flex; flex-direction: column; }
        .brand { padding: 20px; font-size: 22px; font-weight: bold; background: #212529; text-align: center; }
        .nav-links { list-style: none; padding: 0; margin: 0; }
        .nav-links li a { display: block; padding: 15px 20px; color: #c2c7d0; text-decoration: none; border-left: 4px solid transparent; }
        .nav-links li a:hover, .nav-links li a.active { background: #495057; color: white; border-left-color: #007bff; }
        .main { flex: 1; display: flex; flex-direction: column; }
        .header { background: white; padding: 10px 30px; display: flex; justify-content: flex-end; align-items: center; height: 60px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
        .content { padding: 30px; overflow-y: auto; }
        .card { background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
        
        /* --- TABLE STYLES --- */
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th { background: #007bff; color: white; padding: 12px; text-align: left; }
        td { padding: 12px; border-bottom: 1px solid #ddd; color: #555; vertical-align: top;}
        tr:hover { background-color: #f1f1f1; }

        /* --- BADGES & STATUS --- */
        .badge { padding: 4px 8px; border-radius: 4px; font-size: 11px; font-weight: bold; color: white; }
        .bg-HIGH { background-color: #dc3545; }
        .bg-MEDIUM { background-color: #ffc107; color: #333; }
        .bg-LOW { background-color: #28a745; }

        /* Dropdown: The ONLY editable field */
        .status-select { 
            padding: 6px; 
            border-radius: 4px; 
            border: 1px solid #ccc; 
            font-weight: bold; 
            cursor: pointer;
            width: 100%;
        }
        .status-select.PENDING { color: #dc3545; border-color: #dc3545; }
        .status-select.IN_PROGRESS { color: #e0a800; border-color: #e0a800; }
        .status-select.DONE { color: #28a745; border-color: #28a745; }
    </style>

    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-auth-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-firestore-compat.js"></script>
</head>

<body>

    <div class="sidebar">
        <div class="brand">emPower</div>
        <ul class="nav-links">
            <li><a href="mark_attendance.jsp">📍 Mark Attendance</a></li>
            <li><a href="#" class="active">📝 Assigned Tasks</a></li>
            <li><a href="attendance_history.jsp">🕒 Attendance History</a></li>
            <li><a href="employee_expenses.jsp">💸 My Expenses</a></li>
            <li><a href="salary.jsp">💰 My Salary</a></li>
            <li><a href="settings.jsp">⚙️ Settings</a></li>
            <li><a href="#" onclick="logout()">🚪 Logout</a></li>
        </ul>
    </div>

    <div class="main">
        <div class="header">
            <div style="font-weight:bold;">Employee Portal</div>
        </div>

        <div class="content">
            <div class="card">
                <h2>My Tasks</h2>
                <p style="color:#666; font-size: 14px;">You can update the status of your tasks. Task details are read-only.</p>
                
                <table>
                    <thead>
                        <tr>
                            <th style="width: 40%;">Task Details</th>
                            <th>Project</th>
                            <th>Priority</th>
                            <th>Due Date</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody id="myTasksTable">
                        <tr><td colspan="5">Loading your tasks...</td></tr>
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
        const auth = firebase.auth();
        const db = firebase.firestore();

        /* --- AUTH CHECK --- */
        auth.onAuthStateChanged(user => {
            if(user) {
                loadMyTasks(user.email);
            } else {
                window.location.href = "login.jsp";
            }
        });

        /* --- LOAD TASKS --- */
        function loadMyTasks(email) {
            const tbody = document.getElementById("myTasksTable");
            
            // FILTER: Only show tasks assigned to this user
            db.collection("tasks")
                .where("assignedTo", "==", email)
                .get()
                .then(snap => {
                    if(snap.empty) {
                        tbody.innerHTML = "<tr><td colspan='5'>No tasks assigned to you.</td></tr>";
                        return;
                    }

                    let rows = "";
                    snap.forEach(doc => {
                        const d = doc.data();
                        const id = doc.id; 

                        // Pre-select the dropdown option based on database value
                        const sPending = d.status === 'PENDING' ? 'selected' : '';
                        const sProg = d.status === 'IN_PROGRESS' ? 'selected' : '';
                        const sDone = d.status === 'DONE' ? 'selected' : '';

                        rows += `
                            <tr>
                                <td>
                                    <div style="font-weight:bold; font-size:16px;">${d.title}</div>
                                    <div style="font-size:13px; color:#555; margin-top:4px;">${d.description || "No description"}</div>
                                </td>
                                
                                <td>${d.project || "General"}</td>
                                <td><span class="badge bg-${d.priority}">${d.priority}</span></td>
                                <td>${d.dueDate}</td>
                                
                                <td>
                                    <select class="status-select ${d.status}" onchange="updateStatus('${id}', this)">
                                        <option value="PENDING" ${sPending}>PENDING</option>
                                        <option value="IN_PROGRESS" ${sProg}>IN PROGRESS</option>
                                        <option value="DONE" ${sDone}>DONE</option>
                                    </select>
                                </td>
                            </tr>
                        `;
                    });
                    tbody.innerHTML = rows;
                })
                .catch(err => {
                    console.error("Error", err);
                    tbody.innerHTML = "<tr><td colspan='5' style='color:red'>Error loading tasks. " + err.message + "</td></tr>";
                });
        }

        /* --- UPDATE STATUS ONLY --- */
        window.updateStatus = function(docId, selectElement) {
            const newStatus = selectElement.value;
            
            // Visual feedback: change color immediately
            selectElement.className = "status-select " + newStatus;

            // Update Firebase
            db.collection("tasks").doc(docId).update({
                status: newStatus
            }).then(() => {
                console.log("Status updated successfully");
            }).catch(err => {
                alert("Error updating status: " + err.message);
                // Revert dropdown if failed (optional, but good UX)
            });
        };

        function logout() {
            auth.signOut().then(() => window.location.href = "login.jsp");
        }
    </script>
</body>
</html>