package com.aka;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.cloud.firestore.Firestore;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.cloud.FirestoreClient;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.Date;

@WebServlet("/task-handler")
public class TaskServlet extends HttpServlet {

    // 🔴 THIS IS THE MISSING PART THAT CAUSED THE ERROR 🔴
    @Override
    public void init() throws ServletException {
        try {
            if (FirebaseApp.getApps().isEmpty()) {
                FileInputStream serviceAccount = 
                    new FileInputStream("C:/tomcat9/firebase-service-account.json");

                FirebaseOptions options = new FirebaseOptions.Builder()
                    .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                    .build();

                FirebaseApp.initializeApp(options);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        
        // Now this will work because we initialized the App above!
        Firestore db = FirestoreClient.getFirestore();

        try {
            if ("create".equals(action)) {
                // --- ADMIN: Create New Task ---
                String title = request.getParameter("title");
                String description = request.getParameter("description");
                String assignTo = request.getParameter("assignTo"); // Email
                String project = request.getParameter("project");
                String priority = request.getParameter("priority");
                String dueDate = request.getParameter("dueDate");

                Map<String, Object> task = new HashMap<>();
                task.put("title", title);
                task.put("description", description);
                task.put("assignedToEmail", assignTo);
                task.put("project", project);
                task.put("priority", priority);
                task.put("dueDate", dueDate);
                task.put("status", "PENDING"); // Default status
                task.put("createdAt", new Date());

                db.collection("tasks").add(task);
                response.sendRedirect("admin_tasks.jsp?msg=Task Created Successfully");

            } else if ("update".equals(action)) {
                // --- EMPLOYEE: Update Status ---
                String taskId = request.getParameter("taskId");
                String newStatus = request.getParameter("status");

                db.collection("tasks").document(taskId).update("status", newStatus);
                response.sendRedirect("employee_tasks.jsp?msg=Status Updated");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Error: " + e.getMessage());
        }
    }
}