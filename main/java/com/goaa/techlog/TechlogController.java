package com.goaa.techlog;

import entity.TechlogEntity;
import jakarta.persistence.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Time;

@WebServlet(name = "TechlogController", urlPatterns = {"/", "/editTechlog", "/submitTechlog", "/updateTechlog", "/deleteTechlog"})
public class TechlogController extends HttpServlet {

    private EntityManagerFactory entityManagerFactory;

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
            int id = Integer.parseInt(request.getParameter("id"));

            EntityManager entityManager = entityManagerFactory.createEntityManager();
            EntityTransaction transaction = entityManager.getTransaction();
            TechlogEntity techLog = entityManager.find(TechlogEntity.class, id);

            if (techLog != null) {
                techLog.setTechNum(Integer.parseInt(request.getParameter("techNum")));
                techLog.setLane(request.getParameter("lane"));
                techLog.setReportTime(Time.valueOf(request.getParameter("reportTime") + ":00"));
                techLog.setStartTime(Time.valueOf(request.getParameter("startTime") + ":00"));
                techLog.setStopTime(Time.valueOf(request.getParameter("stopTime") + ":00"));
                techLog.setReportedProb(request.getParameter("reportedProb"));
                techLog.setActualProb(request.getParameter("actualProb"));
                techLog.setActionTaken(request.getParameter("actionTaken"));
                techLog.setSkidata("1".equals(request.getParameter("skidata")));

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
            int id = Integer.parseInt(request.getParameter("id"));

            EntityManager entityManager = entityManagerFactory.createEntityManager();
            EntityTransaction transaction = entityManager.getTransaction();

            try {
                transaction.begin();

                TechlogEntity techLog = entityManager.find(TechlogEntity.class, id);
                if (techLog != null) {
                    entityManager.remove(techLog);
                }

                transaction.commit();
                response.sendRedirect("index.jsp");

            } catch (Exception e) {
                transaction.rollback();
                e.printStackTrace();
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            } finally {
                entityManager.close();
            }
            return;
        }

        int techNum = Integer.parseInt(request.getParameter("techNum"));
        String lane = request.getParameter("lane");
        Time reportTime = Time.valueOf(request.getParameter("reportTime") + ":00");
        Time startTime = Time.valueOf(request.getParameter("startTime") + ":00");
        Time stopTime = Time.valueOf(request.getParameter("stopTime") + ":00");
        String reportedProb = request.getParameter("reportedProb");
        String actualProb = request.getParameter("actualProb");
        String actionTaken = request.getParameter("actionTaken");
        boolean skidata = "1".equals(request.getParameter("skidata"));
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

        response.sendRedirect("index.jsp");
    }

    @Override
    public void destroy() {
        entityManagerFactory.close();
    }
}