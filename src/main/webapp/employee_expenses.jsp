<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<title>Employee Expenses</title>

<style>
body { margin:0; font-family:Arial; background:#f4f6f9; display:flex; }
.sidebar { width:220px; background:#212529; color:#fff; padding:20px; }
.sidebar a { color:#cfd4da; display:block; padding:10px 0; text-decoration:none; }
.sidebar a.active, .sidebar a:hover { color:#fff; }

.main { flex:1; padding:30px; }
.card { background:#fff; padding:20px; border-radius:6px; margin-bottom:25px; }

table { width:100%; border-collapse:collapse; }
th { background:#0d6efd; color:#fff; padding:10px; }
td { padding:10px; border-bottom:1px solid #ddd; }

.badge { padding:4px 10px; border-radius:4px; color:#fff; font-size:12px; }
.badge-SUBMITTED { background:#6c757d; }
.badge-APPROVED { background:#17a2b8; }
.badge-REJECTED { background:#dc3545; }
.badge-PAID { background:#28a745; }

input { width:100%; padding:6px; }
button { padding:8px 14px; cursor:pointer; }
.total { text-align:right; font-weight:bold; }
</style>

<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-auth-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-firestore-compat.js"></script>
</head>

<body>

<div class="sidebar">
  <h3>emPower</h3>
  <a href="#">Attendance</a>
  <a href="#">Tasks</a>
  <a class="active" href="#">Expenses</a>
  <a href="#">Salary</a>
</div>

<div class="main">

<!-- SUBMIT -->
<div class="card">
<h3>Submit Expense</h3>

<table>
<thead>
<tr>
  <th>Sl.No</th>
  <th>Product Name</th>
  <th>Quantity</th>
  <th>Cost (₹)</th>
</tr>
</thead>
<tbody id="itemBody"></tbody>
</table>

<button onclick="addRow()">+ Add Item</button>
<div class="total">Total: ₹<span id="totalAmt">0</span></div>
<br>
<button onclick="submitExpense()">Submit</button>
</div>

<!-- HISTORY -->
<div class="card">
<h3>My Expense History</h3>

<table>
<thead>
<tr>
  <th>Date</th>
  <th>Amount</th>
  <th>Status</th>
</tr>
</thead>
<tbody id="historyBody">
<tr><td colspan="3">Loading...</td></tr>
</tbody>
</table>
</div>

</div>

<script>
firebase.initializeApp({
  apiKey: "AIzaSyCV5tKJMLOVcXiZUyuJZhLWOOSD96gsmP0",
  authDomain: "attendencewebapp-4215b.firebaseapp.com",
  projectId: "attendencewebapp-4215b"
});

const auth = firebase.auth();
const db = firebase.firestore();

/* AUTH */
auth.onAuthStateChanged(user => {
  if (!user) return alert("Login required");
  addRow();
  loadHistory(user.email);
});

/* ADD ROW */
function addRow() {
  const body = document.getElementById("itemBody");
  const n = body.rows.length + 1;

  body.insertAdjacentHTML("beforeend",
    "<tr>" +
      "<td>" + n + "</td>" +
      "<td><input class='name'></td>" +
      "<td><input type='number' class='qty' value='1' oninput='calc()'></td>" +
      "<td><input type='number' class='cost' oninput='calc()'></td>" +
    "</tr>"
  );
}

/* TOTAL */
function calc() {
  let total = 0;
  document.querySelectorAll("#itemBody tr").forEach(r => {
    total += (+r.querySelector(".qty").value || 0) *
             (+r.querySelector(".cost").value || 0);
  });
  document.getElementById("totalAmt").innerText = total;
  return total;
}

/* SUBMIT */
function submitExpense() {
  const user = auth.currentUser;
  const amount = calc();
  if (amount <= 0) return alert("Invalid amount");

  db.collection("expenses").add({
    email: user.email,
    amount: amount,
    status: "SUBMITTED",
    timestamp: firebase.firestore.FieldValue.serverTimestamp()
  }).then(() => {
    alert("Submitted");
    document.getElementById("itemBody").innerHTML = "";
    document.getElementById("totalAmt").innerText = "0";
    addRow();
  });
}

/* LOAD HISTORY (JSP SAFE) */
function loadHistory(email) {
  const body = document.getElementById("historyBody");

  db.collection("expenses")
    .where("email","==",email)
    .onSnapshot(snap => {

      body.innerHTML = "";

      if (snap.empty) {
        body.innerHTML = "<tr><td colspan='3'>No records</td></tr>";
        return;
      }

      snap.forEach(doc => {
        const x = doc.data();
        const dt = x.timestamp
          ? new Date(x.timestamp.seconds * 1000).toLocaleDateString()
          : "-";

        body.innerHTML +=
          "<tr>" +
            "<td>" + dt + "</td>" +
            "<td>₹" + x.amount + "</td>" +
            "<td><span class='badge badge-" + x.status + "'>" + x.status + "</span></td>" +
          "</tr>";
      });
    });
}
</script>

</body>
</html>



