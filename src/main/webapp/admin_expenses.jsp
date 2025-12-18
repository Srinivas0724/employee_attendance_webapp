<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page isELIgnored="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Admin - Expense Management</title>

<style>
body {
    display: flex;
    height: 100vh;
    margin: 0;
    font-family: 'Segoe UI', sans-serif;
    background: #f4f6f9;
}
.sidebar {
    width: 260px;
    background: #343a40;
    color: white;
}
.brand {
    padding: 20px;
    font-size: 22px;
    font-weight: bold;
    background: #212529;
    text-align: center;
}
.nav-links { list-style: none; padding: 0; margin: 0; }
.nav-links li a {
    display: block;
    padding: 15px 20px;
    color: #c2c7d0;
    text-decoration: none;
}
.nav-links li a:hover,
.nav-links li a.active {
    background: #495057;
    color: white;
    border-left: 4px solid #007bff;
}

.main { flex: 1; display: flex; flex-direction: column; }
.header {
    background: white;
    padding: 15px 30px;
    border-bottom: 1px solid #ddd;
}
.content { padding: 30px; overflow-y: auto; }
.card {
    background: white;
    padding: 25px;
    border-radius: 8px;
}

table {
    width: 100%;
    border-collapse: collapse;
    margin-top: 15px;
}
th {
    background: #343a40;
    color: white;
    padding: 12px;
}
td {
    padding: 12px;
    border-bottom: 1px solid #ddd;
}

select {
    padding: 6px;
    font-weight: bold;
    width: 100%;
}
</style>

<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-auth-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-firestore-compat.js"></script>
</head>

<body>

<!-- ===== SIDEBAR ===== -->
<div class="sidebar">
    <div class="brand">emPower Admin</div>
    <ul class="nav-links">
        <li><a href="admin_panel.jsp">📊 Attendance</a></li>
        <li><a class="active">💸 Expenses</a></li>
        <li><a href="#" onclick="logout()">🚪 Logout</a></li>
    </ul>
</div>

<!-- ===== MAIN ===== -->
<div class="main">
    <div class="header">
        <b>Admin Console</b>
    </div>

    <div class="content">
        <div class="card">
            <h2>All Employee Expenses</h2>

            <table>
                <thead>
                    <tr>
                        <th>Date</th>
                        <th>Employee</th>
                        <th>Category</th>
                        <th>Amount</th>
                        <th>Description</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody id="expenseTable">
                    <tr><td colspan="6">Loading...</td></tr>
                </tbody>
            </table>
        </div>
    </div>
</div>

<script>
/* ===== FIREBASE CONFIG ===== */
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

/* ===== AUTH CHECK ===== */
auth.onAuthStateChanged(user => {
    if (!user) {
        window.location.href = "login.jsp";
    } else {
        loadExpenses();
    }
});

/* ===== LOAD EXPENSES (REALTIME) ===== */
function loadExpenses() {
    const tbody = document.getElementById("expenseTable");

    db.collection("expenses").onSnapshot(snapshot => {
        if (snapshot.empty) {
            tbody.innerHTML =
              "<tr><td colspan='6'>No expense records found</td></tr>";
            return;
        }

        let rows = [];

        snapshot.forEach(doc => {
            const d = doc.data();

            // Handle Date / Timestamp safely
            let dateStr = "N/A";
            if (d.timestamp) {
                if (d.timestamp.seconds) {
                    dateStr = new Date(d.timestamp.seconds * 1000).toLocaleDateString();
                } else {
                    dateStr = new Date(d.timestamp).toLocaleDateString();
                }
            }

            // PRE-COMPUTE STATUS FLAGS (JSP SAFE)
            const s1 = d.status === "SUBMITTED" ? "selected" : "";
            const s2 = d.status === "APPROVED" ? "selected" : "";
            const s3 = d.status === "REJECTED" ? "selected" : "";
            const s4 = d.status === "PAID" ? "selected" : "";

            rows.push(
              "<tr>" +
                "<td>" + dateStr + "</td>" +
                "<td>" + (d.userId || d.email) + "</td>" +
                "<td>" + d.category + "</td>" +
                "<td>₹" + d.amount + "</td>" +
                "<td>" + (d.description || "-") + "</td>" +
                "<td>" +
                  "<select onchange=\"updateStatus('" + doc.id + "', this.value)\">" +
                    "<option value='SUBMITTED' " + s1 + ">SUBMITTED</option>" +
                    "<option value='APPROVED' " + s2 + ">APPROVED</option>" +
                    "<option value='REJECTED' " + s3 + ">REJECTED</option>" +
                    "<option value='PAID' " + s4 + ">PAID</option>" +
                  "</select>" +
                "</td>" +
              "</tr>"
            );
        });

        tbody.innerHTML = rows.join("");
    });
}

/* ===== UPDATE STATUS ===== */
function updateStatus(id, status) {
    db.collection("expenses").doc(id).update({
        status: status,
        updatedAt: new Date(),
        approvedBy: auth.currentUser.email
    }).then(() => {
        console.log("Status updated");
    }).catch(err => {
        alert("Update failed: " + err.message);
    });
}

/* ===== LOGOUT ===== */
function logout() {
    auth.signOut().then(() => window.location.href = "login.jsp");
}
</script>

</body>
</html>

