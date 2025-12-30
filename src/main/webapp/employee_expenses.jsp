<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
  // 1. PASTE THE CACHE CODE HERE (Lines 2-6)
  response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
  response.setHeader("Pragma", "no-cache");
  response.setDateHeader("Expires", 0);
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>My Expenses - emPower</title>

<style>
/* GLOBAL STYLES */
body { margin:0; font-family:"Segoe UI", sans-serif; background:#f4f6f9; display:flex; height:100vh; }

/* SIDEBAR (Standardized) */
.sidebar { width:260px; background:#343a40; color:#fff; display:flex; flex-direction:column; }
.sidebar h2 { padding:20px; margin:0; background:#212529; text-align:center; }
.sidebar a { display:block; padding:15px 20px; color:#c2c7d0; text-decoration:none; border-left: 3px solid transparent; }
.sidebar a:hover, .sidebar a.active { background:#495057; color:#fff; border-left: 3px solid #007bff; }

/* MAIN CONTENT */
.main { flex:1; display:flex; flex-direction:column; }
.header { height:60px; background:#fff; display:flex; justify-content:space-between; align-items:center; padding:0 20px; border-bottom: 1px solid #dee2e6; }
.content { padding:30px; overflow-y: auto; }

/* FORM STYLES */
.card { background:#fff; padding:20px; border-radius:8px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); margin-bottom: 20px; }
input, select { width: 100%; padding: 10px; margin: 5px 0 15px 0; border: 1px solid #ced4da; border-radius: 4px; box-sizing: border-box; }
button { padding: 10px 20px; border: none; background: #28a745; color: white; border-radius: 4px; cursor: pointer; }
button:hover { background: #218838; }

/* TABLE STYLES */
table { width: 100%; border-collapse: collapse; margin-top: 15px; }
th, td { text-align: left; padding: 12px; border-bottom: 1px solid #ddd; }
th { background-color: #f8f9fa; }
</style>

<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-auth-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-firestore-compat.js"></script>
</head>

<body>

<div class="sidebar">
  <h2>emPower</h2>
  <a href="mark_attendance.jsp">📍 Mark Attendance</a>
  <a href="employee_tasks.jsp">📝 Assigned Tasks</a>
  <a href="attendance_history.jsp">🕒 Attendance History</a>
  <a href="employee_expenses.jsp" class="active">💸 My Expenses</a>
  <a href="salary.jsp">💰 My Salary</a>
  <a href="settings.jsp">⚙️ Settings</a>
  <a href="#" onclick="logout()">🚪 Logout</a>
</div>

<div class="main">
  <div class="header">
    <b>My Expenses</b>
    <span id="userEmail">Loading...</span>
  </div>

  <div class="content">
    
    <div class="card">
        <h3>Add New Expense</h3>
        <label>Expense Type</label>
        <select id="expType">
            <option>Travel</option>
            <option>Food</option>
            <option>Equipment</option>
            <option>Other</option>
        </select>
        
        <label>Amount (₹)</label>
        <input type="number" id="expAmount" placeholder="0.00">
        
        <label>Description</label>
        <input type="text" id="expDesc" placeholder="Details...">
        
        <button onclick="addExpense()">Submit Claim</button>
    </div>

    <div class="card">
        <h3>My Recent Claims</h3>
        <table id="expTable">
            <thead>
                <tr>
                    <th>Date</th>
                    <th>Type</th>
                    <th>Description</th>
                    <th>Amount</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody id="tableBody">
                <tr><td colspan="5">Loading...</td></tr>
            </tbody>
        </table>
    </div>
  </div>
</div>

<script>
/* CONFIG */
const firebaseConfig = {
  apiKey: "AIzaSyCV5tKJMLOVcXiZUyuJZhLWOOSD96gsmP0",
  authDomain: "attendencewebapp-4215b.firebaseapp.com",
  projectId: "attendencewebapp-4215b"
};
if (!firebase.apps.length) firebase.initializeApp(firebaseConfig);
const auth = firebase.auth();
const db = firebase.firestore();

/* AUTH CHECK */
auth.onAuthStateChanged(user => {
  if(!user) { location.href="login.jsp"; return; }
  document.getElementById("userEmail").innerText = user.email;
  loadExpenses(user.email);
});

/* ADD EXPENSE */
function addExpense(){
    const user = auth.currentUser;
    const type = document.getElementById("expType").value;
    const amount = document.getElementById("expAmount").value;
    const desc = document.getElementById("expDesc").value;

    if(!amount){ alert("Enter amount"); return; }

    db.collection("expenses").add({
        email: user.email,
        type: type,
        amount: parseFloat(amount),
        description: desc,
        status: "Pending",
        date: firebase.firestore.FieldValue.serverTimestamp()
    }).then(()=>{
        alert("Expense submitted!");
        location.reload();
    });
}

/* LOAD EXPENSES */
function loadExpenses(email){
    db.collection("expenses")
      .where("email", "==", email)
      .orderBy("date", "desc")
      .get()
      .then(snap => {
          const tbody = document.getElementById("tableBody");
          tbody.innerHTML = "";
          if(snap.empty){ tbody.innerHTML = "<tr><td colspan='5'>No records found</td></tr>"; return; }
          
          snap.forEach(doc => {
              const d = doc.data();
              const date = d.date ? new Date(d.date.seconds*1000).toLocaleDateString() : "-";
              
              let statusColor = "orange";
              if(d.status === "Approved") statusColor = "green";
              if(d.status === "Rejected") statusColor = "red";

              tbody.innerHTML += `
                <tr>
                    <td>\${date}</td>
                    <td>\${d.type}</td>
                    <td>\${d.description}</td>
                    <td>₹\${d.amount}</td>
                    <td style="color:\${statusColor}; font-weight:bold">\${d.status}</td>
                </tr>
              `;
          });
      });
}

/* LOGOUT (Fixes redirection) */
function logout(){
    auth.signOut().then(() => {
        window.location.href = "login.jsp";
    });
}
</script>
</body>
</html>



