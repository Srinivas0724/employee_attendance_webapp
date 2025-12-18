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

@WebServlet("/mark-attendance")
public class MarkAttendanceServlet extends HttpServlet {

    @Override
    public void init() throws ServletException {
        try {
            if (FirebaseApp.getApps().isEmpty()) {
                // VERIFY THIS PATH IS CORRECT ON YOUR PC
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
        String name = request.getParameter("empName");
        String project = request.getParameter("project");
        String type = request.getParameter("type");
        String lat = request.getParameter("latitude");
        String lon = request.getParameter("longitude");
        String photoBase64 = request.getParameter("photo");

        Map<String, Object> data = new HashMap<>();
        data.put("name", name);
        data.put("project", project);
        data.put("type", type);
        data.put("timestamp", new Date());
        data.put("photo", photoBase64);

        Map<String, Double> location = new HashMap<>();
        try {
            if(lat != null && !lat.isEmpty()) {
                location.put("lat", Double.parseDouble(lat));
                location.put("lng", Double.parseDouble(lon));
            } else {
                location.put("lat", 0.0);
                location.put("lng", 0.0);
            }
        } catch (Exception e) {
            location.put("lat", 0.0);
            location.put("lng", 0.0);
        }
        data.put("location", location);

        try {
            Firestore db = FirestoreClient.getFirestore();
            // --- CRITICAL UPDATE: Pointing to NEW collection ---
            db.collection("attendance_2025").add(data);
            
            response.setContentType("text/html");
            response.getWriter().println("<html><body style='text-align:center; padding:50px; font-family:sans-serif;'>");
            response.getWriter().println("<h1 style='color:green;'>✅ Success! Saved to attendance_2025</h1>");
            response.getWriter().println("<br><a href='attendance_history.jsp' style='padding:10px 20px; background:#007bff; color:white; text-decoration:none;'>See History</a>");
            response.getWriter().println("</body></html>");
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Error: " + e.getMessage());
        }
    }
}