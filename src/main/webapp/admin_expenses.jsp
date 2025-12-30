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
<title>Expense Approvals - Admin</title>

<style>
/* GLOBAL STYLES */
body { margin:0; font-family:"Segoe UI", sans-serif; background:#f4f6f9; display:flex; height:100vh; color:#333; }

/* SIDEBAR */
.sidebar { width:260px; background:#212529; color:#fff; display:flex; flex-direction:column; }
.sidebar h2 { padding:20px; margin:0; background:#c0392b; text-align:center; font-size: 22px; }
.sidebar a { display:block; padding:15px 20px; color:#adb5bd; text-decoration:none; border-left: 3px solid transparent; }
.sidebar a:hover, .sidebar a.active { background:#343a40; color:#fff; border-left: 3px solid #e74c3c; }

/* MAIN CONTENT */
.main { flex:1; display:flex; flex-direction:column; overflow: hidden; }
.header { height:60px; background:#fff; display:flex; justify-content:space-between; align-items:center; padding:0 30px; border-bottom: 1px solid #dee2e6; }
.content { padding: 30px; flex:1; overflow-y:auto; }

/* CARD & TABLE */
.card { background: white; padding: 25px; border-radius: 8px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
table { width: 100%; border-collapse: collapse; margin-top: 15px; }
th { background: #34495e; color: white; padding: 12px; text-align: left; font-size: 13px; }
td { padding: 12px; border-bottom: 1px solid #eee; font-size: 13px; vertical-align: middle; }
tr:hover { background: #f8f9fa; }

/* STATUS BADGES */
.badge { padding: 5px 10px; border-radius: 12px; font-size: 11px; font-weight: bold; color: white; display: inline-block; }
.bg-Pending { background: #f1c40f; color: #333; }
.bg-Approved { background: #3498db; }
.bg-Paid { background: #27ae60; }
.bg-Rejected { background: #e74c3c; }

/* BUTTONS */
.btn-action { border: none; padding: 6px 12px; border-radius: 4px; cursor: pointer; font-size: 12px; color: white; margin-right: 5px; }
.btn-approve { background: #3498db; }
.btn-pay { background: #27ae60; }
.btn-reject { background: #e74c3c; }
.btn-view { background: #6c757d; text-decoration: none; padding: 6px 12px; border-radius: 4px; color: white; font-size: 12px; }

#loadingOverlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: white; z-index: 9999; display: flex; justify-content: center; align-items: center; font-size: 24px; color: #333; }
</style>

<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-auth-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-firestore-compat.js"></script>
</head>
<body>

<div id="loadingOverlay">⌛ Loading Claims...</div>

<div class="sidebar">
  <h2>ADMIN PORTAL</h2>
  <a href="admin_dashboard.jsp">📊 Dashboard</a>
  <a href="manage_employees.jsp">👥 Manage Employees</a>
  <a href="admin_task_monitoring.jsp">📝 Task Monitoring</a>
  <a href="reports.jsp">📅 Attendance Reports</a>
  <a href="payroll.jsp">💰 Payroll Management</a>
  <a href="admin_expenses.jsp" class="active">💸 Expense Approvals</a>
  <a href="admin_settings.jsp">⚙️ Settings</a>
  <a href="#" onclick="logout()" style="margin-top:auto; background:#1a1d20;">🚪 Logout</a>
</div>

<div class="main">
    <div class="header">
        <h3>Expense Claims Management</h3>
        <span id="adminEmail">Loading...</span>
    </div>

    <div class="content">
        <div class="card">
            <div style="display:flex; justify-content:space-between; align-items:center;">
                <h3>Pending & Recent Claims</h3>
                <button onclick="loadExpenses()" style="padding:8px; background:#34495e; color:white; border:none; border-radius:4px; cursor:pointer;">🔄 Refresh</button>
            </div>

            <table id="claimsTable">
                <thead>
                    <tr>
                        <th>Date</th>
                        <th>Employee</th>
                        <th>Type</th>
                        <th>Details</th>
                        <th>Amount</th>
                        <th>Receipt</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody id="tableBody">
                    <tr><td colspan="8" style="text-align:center;">Loading records...</td></tr>
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

auth.onAuthStateChanged(user => {
    if(user) {
        document.getElementById("adminEmail").innerText = user.email;
        loadExpenses();
    } else {
        window.location.replace("login.jsp");
    }
});

function loadExpenses() {
    const tbody = document.getElementById("tableBody");
    tbody.innerHTML = "";

    db.collection("expenses")
      .orderBy("date", "desc")
      .get()
      .then(snap => {
          document.getElementById("loadingOverlay").style.display = "none";
          
          if(snap.empty) {
              tbody.innerHTML = "<tr><td colspan='8' style='text-align:center;'>No claims found.</td></tr>";
              return;
          }

          snap.forEach(doc => {
              const d = doc.data();
              const id = doc.id;
              const date = d.date ? new Date(d.date.seconds * 1000).toLocaleDateString() : "-";
              
              // Receipt Link Logic
              let receiptHtml = "<span style='color:#ccc'>No File</span>";
              if(d.receiptUrl) {
                  receiptHtml = "<a href='" + d.receiptUrl + "' target='_blank' class='btn-view'>📎 View</a>";
              }

              // Action Buttons Logic
              let actionsHtml = "";
              if(d.status === 'Pending') {
                  actionsHtml += "<button class='btn-action btn-approve' onclick='updateStatus(\"" + id + "\", \"Approved\")'>Approve</button>";
                  actionsHtml += "<button class='btn-action btn-reject' onclick='updateStatus(\"" + id + "\", \"Rejected\")'>Reject</button>";
              } else if (d.status === 'Approved') {
                  actionsHtml += "<button class='btn-action btn-pay' onclick='updateStatus(\"" + id + "\", \"Paid\")'>Mark Paid</button>";
              } else {
                  actionsHtml = "<span style='color:#777'>Completed</span>";
              }

              let row = "<tr>";
              row += "<td>" + date + "</td>";
              row += "<td>" + d.email + "</td>";
              row += "<td>" + d.type + "</td>";
              row += "<td>" + d.description + "</td>";
              row += "<td><b>₹" + d.amount + "</b></td>";
              row += "<td>" + receiptHtml + "</td>";
              row += "<td><span class='badge bg-" + d.status + "'>" + d.status + "</span></td>";
              row += "<td>" + actionsHtml + "</td>";
              row += "</tr>";

              tbody.innerHTML += row;
          });
      });
}

function updateStatus(docId, status) {
    if(!confirm("Mark this claim as " + status + "?")) return;
    
    db.collection("expenses").doc(docId).update({
        status: status
    }).then(() => {
        alert("✅ Status Updated!");
        loadExpenses();
    });
}

function logout(){ auth.signOut().then(() => location.href = "login.jsp"); }
</script>

</body>
</html>