package com.goaa.techlog;

import entity.TechlogEntity;
import jakarta.persistence.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import org.apache.commons.io.IOUtils;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.sql.Time;
import jakarta.servlet.annotation.MultipartConfig;

@MultipartConfig
@WebServlet(name = "TechlogController", urlPatterns = {"/", "/editTechlog", "/submitTechlog", "/updateTechlog", "/deleteTechlog"})
public class TechlogController extends HttpServlet {

    private EntityManagerFactory entityManagerFactory;
    private String getStringFromPart(Part part) throws IOException {
        if (part == null) {
            return null;
        }
        return IOUtils.toString(part.getInputStream(), StandardCharsets.UTF_8);
    }

    @Override
    public void init() throws ServletException {
        entityManagerFactory = Persistence.createEntityManagerFactory("default");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String path = request.getServletPath();

        if ("/editTechlog".equals(path)) {
            int id = Integer.parseInt(request.getParameter("id"));

            EntityManager entityManager = entityManagerFactory.createEntityManager();
            TechlogEntity techLog = entityManager.find(TechlogEntity.class, id);
            entityManager.close();

            request.setAttribute("techLog", techLog);
            request.getRequestDispatcher("editTechlog.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String path = request.getServletPath();
        if ("/updateTechlog".equals(path)) {
            Part idPart = request.getPart("id");
            String idString = IOUtils.toString(idPart.getInputStream(), StandardCharsets.UTF_8);
            int id = Integer.parseInt(idString);

            EntityManager entityManager = entityManagerFactory.createEntityManager();
            EntityTransaction transaction = entityManager.getTransaction();
            TechlogEntity techLog = entityManager.find(TechlogEntity.class, id);

            if (techLog != null) {
                techLog.setTechNum(Integer.parseInt(getStringFromPart(request.getPart("techNum"))));
                techLog.setLane(getStringFromPart(request.getPart("lane")));
                techLog.setReportTime(Time.valueOf(getStringFromPart(request.getPart("reportTime")) + ":00"));
                techLog.setStartTime(Time.valueOf(getStringFromPart(request.getPart("startTime")) + ":00"));
                techLog.setStopTime(Time.valueOf(getStringFromPart(request.getPart("stopTime")) + ":00"));
                techLog.setReportedProb(getStringFromPart(request.getPart("reportedProb")));
                techLog.setActualProb(getStringFromPart(request.getPart("actualProb")));
                techLog.setActionTaken(getStringFromPart(request.getPart("actionTaken")));
                techLog.setSkidata("1".equals(getStringFromPart(request.getPart("skidata"))));


                try {
                    transaction.begin();
                    entityManager.merge(techLog);
                    transaction.commit();
                    response.setStatus(HttpServletResponse.SC_OK);
                } catch (Exception e) {
                    transaction.rollback();
                    e.printStackTrace();
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                } finally {
                    entityManager.close();
                }
            } else {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            }
            return;
        }

        if ("/deleteTechlog".equals(path)) {
            //int id = Integer.parseInt(request.getParameter("id"));
            String idStr = request.getParameter("id");
            int id = 0;
            try {
                id = Integer.parseInt(idStr);
            } catch (NumberFormatException e) {
                // Handle the case when the input string is empty or not a valid integer
                // For example, you can log an error message or set a default value for the id
                System.err.println("Invalid or empty 'id' parameter: " + idStr);
            }

            EntityManager entityManager = entityManagerFactory.createEntityManager();
            EntityTransaction transaction = entityManager.getTransaction();
            try {
                transaction.begin();

                TechlogEntity techLog = entityManager.find(TechlogEntity.class, id);
                if (techLog != null) {
                    entityManager.remove(techLog);
                }
                transaction.commit();
                response.setStatus(HttpServletResponse.SC_OK);
            } catch (Exception e) {
                transaction.rollback();
                e.printStackTrace();
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            } finally {
                entityManager.close();
            }
            return;
        }

        int techNum = Integer.parseInt(getStringFromPart(request.getPart("techNum")));
        String lane = getStringFromPart(request.getPart("lane"));
        Time reportTime = Time.valueOf(getStringFromPart(request.getPart("reportTime")) + ":00");
        Time startTime = Time.valueOf(getStringFromPart(request.getPart("startTime")) + ":00");
        Time stopTime = Time.valueOf(getStringFromPart(request.getPart("stopTime")) + ":00");
        String reportedProb = getStringFromPart(request.getPart("reportedProb"));
        String actualProb = getStringFromPart(request.getPart("actualProb"));
        String actionTaken = getStringFromPart(request.getPart("actionTaken"));
        boolean skidata = "1".equals(getStringFromPart(request.getPart("skidata")));

        EntityManager entityManager = entityManagerFactory.createEntityManager();
        EntityTransaction transaction = entityManager.getTransaction();

        try {
            transaction.begin();

            TechlogEntity techLog = null;
            if ("/submitTechlog".equals(path)) {
                techLog = new TechlogEntity();
            } else if ("/editTechlog".equals(path)) {
                int id = Integer.parseInt(request.getParameter("id"));
                techLog = entityManager.find(TechlogEntity.class, id);
            }

            if (techLog != null) {
                techLog.setTechNum(techNum);
                techLog.setLane(lane);
                techLog.setReportTime(reportTime);
                techLog.setStartTime(startTime);
                techLog.setStopTime(stopTime);
                techLog.setReportedProb(reportedProb);
                techLog.setActualProb(actualProb);
                techLog.setActionTaken(actionTaken);
                techLog.setSkidata(skidata);

                if ("/submitTechlog".equals(path)) {
                    entityManager.persist(techLog);
                }
            }

            transaction.commit();
        } catch (Exception e) {
            transaction.rollback();
            e.printStackTrace();
        } finally {
            entityManager.close();
        }

        response.sendRedirect("/");
    }

    @Override
    public void destroy() {
        entityManagerFactory.close();
    }
}