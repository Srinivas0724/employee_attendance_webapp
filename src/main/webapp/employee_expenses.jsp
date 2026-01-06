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
<title>My Expenses - emPower</title>

<style>
/* GLOBAL STYLES */
body { margin:0; font-family:"Segoe UI", sans-serif; background:#f4f6f9; display:flex; height:100vh; color:#333; }

/* SIDEBAR */
.sidebar { width:260px; background:#343a40; color:#fff; display:flex; flex-direction:column; }
.sidebar h2 { padding:20px; margin:0; background:#212529; text-align:center; }
.sidebar a { display:block; padding:15px 20px; color:#c2c7d0; text-decoration:none; border-left: 3px solid transparent; }
.sidebar a:hover, .sidebar a.active { background:#495057; color:#fff; border-left: 3px solid #007bff; }
@media (max-width: 768px) { .sidebar { display:none; } }

/* MAIN CONTENT */
.main { flex:1; display:flex; flex-direction:column; overflow: hidden; }
.header { height:60px; background:#fff; display:flex; justify-content:space-between; align-items:center; padding:0 20px; border-bottom: 1px solid #dee2e6; }
.content { padding:30px; overflow-y: auto; }

/* FORM STYLES */
.card { background:#fff; padding:20px; border-radius:8px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); margin-bottom: 20px; }
input, select { width: 100%; padding: 10px; margin: 5px 0 15px 0; border: 1px solid #ced4da; border-radius: 4px; box-sizing: border-box; }
button { padding: 10px 20px; border: none; background: #28a745; color: white; border-radius: 4px; cursor: pointer; width: 100%; font-weight: bold; }
button:hover { background: #218838; }
button:disabled { background: #ccc; cursor: not-allowed; }

/* TABLE STYLES */
table { width: 100%; border-collapse: collapse; margin-top: 15px; }
th, td { text-align: left; padding: 12px; border-bottom: 1px solid #ddd; font-size: 14px; }
th { background-color: #f8f9fa; }

/* BADGES */
.badge { padding: 5px 10px; border-radius: 12px; font-size: 11px; font-weight: bold; color: white; display: inline-block; }
.bg-Pending { background: #f1c40f; color: #333; }
.bg-Approved { background: #3498db; }
.bg-Paid { background: #27ae60; }
.bg-Rejected { background: #e74c3c; }

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
    
    <div class="card" style="max-width: 500px; margin: 0 auto;">
        <h3 style="margin-top:0;">Add New Expense</h3>
        
        <label>Expense Type</label>
        <select id="expType">
            <option>Travel</option>
            <option>Food</option>
            <option>Equipment</option>
            <option>Medical</option>
            <option>Other</option>
        </select>
        
        <label>Amount (₹)</label>
        <input type="number" id="expAmount" placeholder="0.00">
        
        <label>Description</label>
        <input type="text" id="expDesc" placeholder="e.g. Lunch with Client">

        <button onclick="addExpense()" id="submitBtn">Submit Claim</button>
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
// --- ⚠️ PASTE YOUR NEW API KEY HERE ⚠️ ---
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

    const btn = document.getElementById("submitBtn");
    btn.innerText = "Submitting...";
    btn.disabled = true;

    db.collection("expenses").add({
        email: user.email,
        type: type,
        amount: parseFloat(amount),
        description: desc,
        status: "Pending",
        date: firebase.firestore.FieldValue.serverTimestamp()
    }).then(() => {
        alert("✅ Expense submitted successfully!");
        location.reload();
    }).catch(err => {
        alert("Error: " + err.message);
        btn.innerText = "Submit Claim";
        btn.disabled = false;
    });
}

/* LOAD EXPENSES */
function loadExpenses(email){
    const tbody = document.getElementById("tableBody");
    
    db.collection("expenses")
      .where("email", "==", email)
      .orderBy("date", "desc")
      .get()
      .then(snap => {
          tbody.innerHTML = "";
          if(snap.empty){ 
              tbody.innerHTML = "<tr><td colspan='5' style='text-align:center'>No records found</td></tr>"; 
              return; 
          }
          
          snap.forEach(doc => {
              const d = doc.data();
              const date = d.date ? new Date(d.date.seconds*1000).toLocaleDateString() : "-";
              
              let row = "<tr>";
              row += "<td>" + date + "</td>";
              row += "<td>" + d.type + "</td>";
              row += "<td>" + d.description + "</td>";
              row += "<td>₹" + d.amount + "</td>";
              row += "<td><span class='badge bg-" + d.status + "'>" + d.status + "</span></td>";
              row += "</tr>";

              tbody.innerHTML += row;
          });
      })
      .catch(error => {
          // ⚠️ CATCHES MISSING INDEX ERRORS
          console.error("Error loading expenses:", error);
          if(error.message.includes("requires an index")) {
              alert("⚠️ SYSTEM ALERT: A database index is missing.\n\nOpen the Browser Console (F12) and click the link in the error message to create it.");
              tbody.innerHTML = "<tr><td colspan='5' style='color:red'>Database Index Missing (See Console)</td></tr>";
          } else {
              tbody.innerHTML = "<tr><td colspan='5' style='color:red'>Error: " + error.message + "</td></tr>";
          }
      });
}

function logout(){ auth.signOut().then(() => location.href = "index.html"); }
</script>
</body>
</html>