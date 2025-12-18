<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>My Salary</title>
    <style>
        body { font-family: 'Segoe UI', sans-serif; background: #f4f6f9; display: flex; height: 100vh; margin: 0; }
        .sidebar { width: 260px; background: #343a40; color: white; padding-top:20px; }
        .sidebar a { display: block; padding: 15px 20px; color: #ccc; text-decoration: none; }
        .main { flex: 1; padding: 40px; display: flex; justify-content: center; align-items: center; }
        .salary-card { background: linear-gradient(135deg, #007bff, #0056b3); color: white; padding: 40px; border-radius: 15px; width: 300px; text-align: center; box-shadow: 0 10px 20px rgba(0,123,255,0.3); }
        h1 { font-size: 40px; margin: 10px 0; }
    </style>
    <script src="https://www.gstatic.com/firebasejs/9.0.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.0.0/firebase-auth-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.0.0/firebase-firestore-compat.js"></script>
</head>
<body>
    <div class="sidebar">
        <h3 style="text-align:center; color:white;">emPower</h3>
        <a href="mark_attendance.jsp">&larr; Back to Dashboard</a>
    </div>
    <div class="main">
        <div class="salary-card">
            <h3>💰 Current Salary</h3>
            <h1 id="salaryAmt">Loading...</h1>
            <p>Monthly Credited</p>
        </div>
    </div>
    <script>
           const firebaseConfig = {
  apiKey: "AIzaSyCV5tKJMLOVcXiZUyuJZhLWOOSD96gsmP0",
  authDomain: "attendencewebapp-4215b.firebaseapp.com",
  projectId: "attendencewebapp-4215b",
        };
        if (!firebase.apps.length) firebase.initializeApp(firebaseConfig);
        const auth = firebase.auth();
        const db = firebase.firestore();

        auth.onAuthStateChanged(user => {
            if(user) {
                db.collection("users").doc(user.uid).get().then(doc => {
                    if(doc.exists) document.getElementById("salaryAmt").innerText = "₹" + doc.data().salary;
                });
            }
        });
    </script>
</body>
</html>