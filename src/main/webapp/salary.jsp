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
<title>My Salary - emPower</title>

<style>
/* GLOBAL STYLES */
body { margin:0; font-family:"Segoe UI", sans-serif; background:#f4f6f9; display:flex; height:100vh; }

/* SIDEBAR */
.sidebar { width:260px; background:#343a40; color:#fff; display:flex; flex-direction:column; }
.sidebar h2 { padding:20px; margin:0; background:#212529; text-align:center; }
.sidebar a { display:block; padding:15px 20px; color:#c2c7d0; text-decoration:none; border-left: 3px solid transparent; }
.sidebar a:hover, .sidebar a.active { background:#495057; color:#fff; border-left: 3px solid #007bff; }

/* MAIN CONTENT */
.main { flex:1; display:flex; flex-direction:column; }
.header { height:60px; background:#fff; display:flex; justify-content:space-between; align-items:center; padding:0 20px; border-bottom: 1px solid #dee2e6; }
.content { padding:30px; display:flex; justify-content:center; align-items: flex-start; }

.salary-slip {
    background: white;
    width: 600px;
    padding: 40px;
    box-shadow: 0 4px 10px rgba(0,0,0,0.1);
    border-radius: 8px;
}
.slip-header { text-align: center; border-bottom: 2px solid #333; padding-bottom: 20px; margin-bottom: 20px; }
.row { display: flex; justify-content: space-between; padding: 10px 0; border-bottom: 1px solid #eee; }
.total { font-weight: bold; font-size: 1.2em; border-top: 2px solid #333; margin-top: 20px; padding-top: 10px; }

.btn-print { background: #007bff; color: white; border: none; padding: 10px 20px; margin-top: 20px; cursor: pointer; border-radius: 4px; }
.btn-back { background: #6c757d; color: white; text-decoration: none; padding: 10px 20px; border-radius: 4px; margin-right: 10px; display: inline-block; }
</style>

<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-auth-compat.js"></script>
</head>

<body>

<div class="sidebar">
  <h2>emPower</h2>
  <a href="mark_attendance.jsp">📍 Mark Attendance</a>
  <a href="employee_tasks.jsp">📝 Assigned Tasks</a>
  <a href="attendance_history.jsp">🕒 Attendance History</a>
  <a href="employee_expenses.jsp">💸 My Expenses</a>
  <a href="salary.jsp" class="active">💰 My Salary</a>
  <a href="settings.jsp">⚙️ Settings</a>
  <a href="#" onclick="logout()">🚪 Logout</a>
</div>

<div class="main">
  <div class="header">
    <b>Salary Slip</b>
    <span id="userEmail">Loading...</span>
  </div>

  <div class="content">
    <div class="salary-slip">
        <div class="slip-header">
            <h2>PAYSLIP</h2>
            <p>For Month: <b>December 2025</b></p>
        </div>

        <div class="row"><span>Basic Salary</span> <span>₹ 25,000</span></div>
        <div class="row"><span>HRA</span> <span>₹ 10,000</span></div>
        <div class="row"><span>Special Allowance</span> <span>₹ 5,000</span></div>
        <div class="row" style="color:red"><span>Tax Deductions</span> <span>- ₹ 2,000</span></div>
        
        <div class="row total">
            <span>NET PAYABLE</span>
            <span style="color:green">₹ 38,000</span>
        </div>

        <br>
        <a href="mark_attendance.jsp" class="btn-back">Back to Dashboard</a>
        <button class="btn-print" onclick="window.print()">Print Slip</button>
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

/* AUTH CHECK */
auth.onAuthStateChanged(user => {
  if(!user) { location.href="login.jsp"; return; }
  document.getElementById("userEmail").innerText = user.email;
});

/* LOGOUT */
function logout(){
    auth.signOut().then(() => {
        window.location.href = "login.jsp";
    });
}
</script>

</body>
</html>