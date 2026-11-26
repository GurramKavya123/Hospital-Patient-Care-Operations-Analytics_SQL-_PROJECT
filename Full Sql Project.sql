-- Data base Creation

CREATE DATABASE hospital_analytics;

-- Using database

USE hospital_analytics;

-- crreating tables and establising relationship between tabelss

-- Creating patients table 

CREATE TABLE patients (
    patient_id VARCHAR(10) PRIMARY KEY,
    patient_name VARCHAR(100),
    age INT,
    gender VARCHAR(10),
    city VARCHAR(50),
    patient_type VARCHAR(20),
    preferred_time_slot VARCHAR(20),
    registration_date DATE
);

-- Creating doctors table

CREATE TABLE doctors (
    doctor_id VARCHAR(10) PRIMARY KEY,
    doctor_name VARCHAR(100),
    specialty VARCHAR(50),
    hire_date DATE,
    rating DECIMAL(3,2),
    employment_type VARCHAR(30),
    is_active VARCHAR(10)
);

-- Creating rooms table

CREATE TABLE rooms (
    room_id VARCHAR(10) PRIMARY KEY,
    room_type VARCHAR(30),
    floor INT,
    equipment_type VARCHAR(50),
    capacity INT,
    last_maintenance_date DATE,
    is_available VARCHAR(10)
);

-- Creating appointments table

CREATE TABLE appointments (
    appointment_id VARCHAR(10) PRIMARY KEY,
    patient_id VARCHAR(10),
    appointment_date DATE,
    doctor_id VARCHAR(10),
    service_type VARCHAR(50),
    priority VARCHAR(20),
    estimated_cost DECIMAL(10,2),
    booking_channel VARCHAR(30),

    FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id),

    FOREIGN KEY (doctor_id)
        REFERENCES doctors(doctor_id)
);

-- creating treaments table

CREATE TABLE treatments (
    treatment_id VARCHAR(10) PRIMARY KEY,
    appointment_id VARCHAR(10),
    doctor_id VARCHAR(10),
    room_id VARCHAR(10),
    actual_treatment_date DATE,
    status VARCHAR(30),
    treatment_attempt INT,
    treatment_duration_min INT,
    waiting_time_min INT,
    treatment_cost DECIMAL(10,2),

    FOREIGN KEY (appointment_id)
        REFERENCES appointments(appointment_id),

    FOREIGN KEY (doctor_id)
        REFERENCES doctors(doctor_id),

    FOREIGN KEY (room_id)
        REFERENCES rooms(room_id)
);

-- show tables

SHOW TABLES;

-- describing about each table

DESCRIBE patients;
DESCRIBE doctors;
DESCRIBE rooms;
DESCRIBE appointments;
DESCRIBE treatments;
USE hospital_analytics;


-- importing dataset
-- DATA VALIDATING
-- viewing data
 
-- patients table
 
  SELECT COUNT(*) FROM patients;
  
  select * from patients;
  
  -- doctors table
  
  SELECT COUNT(*) FROM doctors;
  
  select * from doctors;
  
  -- rooms table
  
  SELECT COUNT(*) FROM rooms;
  
  select * from rooms;
  
  -- appointments tables 
  
  SELECT COUNT(*) FROM appointments;
  
  select * from appointments;
  
  -- treatments table

SELECT COUNT(*) FROM treatments;
  
  select * from treatments;
  
  -- CHECKING DUPLICATES
  
  SELECT patient_id, COUNT(*)
FROM patients
GROUP BY patient_id
HAVING COUNT(*) > 1;

SELECT doctor_id, COUNT(*)
FROM doctors
GROUP BY doctor_id
HAVING COUNT(*) > 1;

SELECT appointment_id, COUNT(*)
FROM appointments
GROUP BY appointment_id
HAVING COUNT(*) > 1;

SELECT treatment_id, COUNT(*)
FROM treatments
GROUP BY treatment_id
HAVING COUNT(*) > 1;

-- NO DUPLICATES
 
 -- CHECKING FOR NULL VALUES
 
 SELECT *
FROM patients
WHERE patient_id IS NULL;

SELECT COUNT(*) AS null_patient_ids
FROM patients
WHERE patient_id IS NULL;

SELECT *
FROM doctors
WHERE doctor_id IS NULL;

SELECT COUNT(*) AS null_doctors_ids
FROM doctors
WHERE doctor_id IS NULL;

SELECT *
FROM rooms
WHERE room_id IS NULL;

SELECT COUNT(*) AS null_rooms_ids
FROM rooms
WHERE room_id IS NULL;

SELECT *
FROM appointments
WHERE appointment_id IS NULL;

SELECT COUNT(*) AS null_appointments_ids
FROM appointments
WHERE appointment_id IS NULL;

SELECT *
FROM treatments
WHERE treatment_id IS NULL;

SELECT COUNT(*) AS null_treatments_ids
FROM treatments
WHERE treatment_id IS NULL;

-- no null values

-- checking relationships

SELECT *
FROM appointments a
LEFT JOIN patients p
ON a.patient_id = p.patient_id
WHERE p.patient_id IS NULL;

SELECT *
FROM treatments t
LEFT JOIN appointments a
ON t.appointment_id = a.appointment_id
WHERE a.appointment_id IS NULL;

SELECT
    p.patient_name,
    a.appointment_id,
    d.doctor_name,
    t.status,
    r.room_type
FROM patients p
INNER JOIN appointments a
ON p.patient_id = a.patient_id

INNER JOIN doctors d
ON a.doctor_id = d.doctor_id

INNER JOIN treatments t
ON a.appointment_id = t.appointment_id

INNER JOIN rooms r
ON t.room_id = r.room_id;

-- Sprint 3: Basic Analysis / Data Exploration

-- 1. What is the total number of patients?

SELECT COUNT(*) AS total_patients
FROM patients;

-- 2. What is the total number of appointments?

SELECT COUNT(*) AS total_appointments
FROM appointments;

-- 3. What is the total number of treatment records?

SELECT COUNT(*) AS total_treatments
FROM treatments;

-- 4. What are the different medical service types?

SELECT DISTINCT service_type
FROM appointments;

-- 5. How many doctors are currently active?

SELECT COUNT(*) AS active_doctors
FROM doctors
WHERE is_active = 'Yes';

-- 6. What are the different room types?

SELECT DISTINCT room_type
FROM rooms;

-- 7. What is the total estimated appointment value?

SELECT SUM(estimated_cost) AS total_value
FROM appointments;

-- 8. What is the average treatment duration?

SELECT AVG(treatment_duration_min) AS avg_duration
FROM treatments;

-- Sprint 4: Objective-Based Analysis

--  4.1 Understand Patient and Appointment Demand
-- Compare appointment volume across cities.

SELECT
    p.city,
    COUNT(a.appointment_id) AS total_appointments
FROM patients p
JOIN appointments a
ON p.patient_id = a.patient_id
GROUP BY p.city
ORDER BY total_appointments DESC;

-- Compare appointments across service types and priorities.
-- Analytical Question: How are appointments distributed across different service types and priorities?

SELECT
    service_type,
    priority,
    COUNT(*) AS total_appointments
FROM appointments
GROUP BY service_type, priority
ORDER BY total_appointments DESC;

-- Examine appointment volume over time.
-- Analytical Question: How does appointment volume change month by month?
SELECT
    DATE_FORMAT(appointment_date, '%Y-%m') AS appointment_month,
    COUNT(*) AS total_appointments
FROM appointments
GROUP BY appointment_month
ORDER BY appointment_month;


-- Compare estimated appointment value across patient types.
-- Analytical Question: Which patient type contributes the highest estimated appointment value?

SELECT
    p.patient_type,
    COUNT(a.appointment_id) AS total_appointments,
    SUM(a.estimated_cost) AS total_estimated_value
FROM patients p
JOIN appointments a
    ON p.patient_id = a.patient_id
GROUP BY p.patient_type
ORDER BY total_estimated_value DESC;

-- Examine booking channels and their contribution to demand.
-- Analytical Question: Which booking channel contributes the highest number of appointments?
SELECT
    booking_channel,
    COUNT(*) AS total_appointments,
    SUM(estimated_cost) AS total_estimated_value
FROM appointments
GROUP BY booking_channel
ORDER BY total_appointments DESC;

-- 4.2 Understand Patient Appointment Behaviour
-- Compare patients by number of appointments.
-- Analytical Question: Which patients have booked the highest number of appointments?
SELECT
    p.patient_id,
    p.patient_name,
    COUNT(a.appointment_id) AS total_appointments
FROM patients p
JOIN appointments a
    ON p.patient_id = a.patient_id
GROUP BY p.patient_id, p.patient_name
ORDER BY total_appointments DESC;

-- Identify patients with higher cumulative estimated appointment value.

-- Analytical Question: Which patients have the highest cumulative estimated appointment value?
SELECT
    p.patient_id,
    p.patient_name,
    SUM(a.estimated_cost) AS cumulative_estimated_value
FROM patients p
JOIN appointments a
    ON p.patient_id = a.patient_id
GROUP BY p.patient_id, p.patient_name
ORDER BY cumulative_estimated_value DESC;

-- Compare patient activity across cities.
-- Analytical Question: Which cities have the highest number of active patients?

SELECT
    city,
    COUNT(DISTINCT patient_id) AS total_active_patients
FROM patients
GROUP BY city
ORDER BY total_active_patients DESC;

-- Compare General, Corporate, and Insurance patients.
-- Analytical Question: How do General, Corporate, and Insurance patients differ in appointment volume and estimated value?

SELECT
    p.patient_type,
    COUNT(a.appointment_id) AS total_appointments,
    SUM(a.estimated_cost) AS total_estimated_value,
    AVG(a.estimated_cost) AS average_estimated_value
FROM patients p
JOIN appointments a
    ON p.patient_id = a.patient_id
GROUP BY p.patient_type
ORDER BY total_appointments DESC;

-- Examine patient booking patterns over time.
-- Analytical Question: How does patient appointment booking activity change month by month?

SELECT
    DATE_FORMAT(appointment_date, '%Y-%m') AS booking_month,
    COUNT(*) AS total_appointments,
    COUNT(DISTINCT patient_id) AS unique_patients
FROM appointments
GROUP BY booking_month
ORDER BY booking_month;


-- 4.3 Evaluate Treatment Performance
-- Compare treatment outcomes across cities.
-- Analytical Question: How do treatment outcomes differ across cities?
 
 SELECT
    p.city,
    COUNT(t.treatment_id) AS total_treatments,
    SUM(CASE WHEN t.status = 'Completed' THEN 1 ELSE 0 END) AS completed,
    SUM(CASE WHEN t.status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled,
    SUM(CASE WHEN t.status = 'No-Show' THEN 1 ELSE 0 END) AS no_show
FROM patients p
JOIN appointments a
    ON p.patient_id = a.patient_id
JOIN treatments t
    ON a.appointment_id = t.appointment_id
GROUP BY p.city
ORDER BY total_treatments DESC;

-- Examine treatment duration and waiting time.
-- Analytical Question: What are the average treatment duration and waiting time for each service type?

SELECT
    a.service_type,
    ROUND(AVG(t.treatment_duration_min), 2) AS avg_treatment_duration,
    ROUND(AVG(t.waiting_time_min), 2) AS avg_waiting_time
FROM appointments a
JOIN treatments t
    ON a.appointment_id = t.appointment_id
GROUP BY a.service_type
ORDER BY avg_waiting_time DESC;

-- Compare Completed, Cancelled, No-Show, Rescheduled, and In Progress outcomes.
-- Analytical Question: How are treatments distributed across different treatment statuses?

SELECT
    status,
    COUNT(*) AS total_treatments,
    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM treatments), 2
    ) AS percentage
FROM treatments
GROUP BY status
ORDER BY total_treatments DESC;

-- Identify areas with higher treatment activity or poorer outcomes.
-- Analytical Question: Which cities have higher treatment activity and more unsuccessful treatment outcomes?

SELECT
    p.city,
    COUNT(t.treatment_id) AS total_treatments,
    SUM(
        CASE
            WHEN t.status IN ('Cancelled', 'No-Show')
            THEN 1 ELSE 0
        END
    ) AS unsuccessful_treatments
FROM patients p
JOIN appointments a
    ON p.patient_id = a.patient_id
JOIN treatments t
    ON a.appointment_id = t.appointment_id
GROUP BY p.city
ORDER BY unsuccessful_treatments DESC;

-- Compare treatment performance over time.
-- Analytical Question: How do treatment outcomes change month by month?

SELECT
    DATE_FORMAT(actual_treatment_date, '%Y-%m') AS treatment_month,
    status,
    COUNT(*) AS total_treatments
FROM treatments
GROUP BY treatment_month, status
ORDER BY treatment_month, total_treatments DESC;

-- 4.4 Understand Doctor and Room Performance
-- Compare the number of treatments handled by doctors.
-- Analytical Question: Which doctors handle the highest number of treatments?
 
 SELECT
    d.doctor_id,
    d.doctor_name,
    d.specialty,
    COUNT(t.treatment_id) AS total_treatments
FROM doctors d
JOIN treatments t
    ON d.doctor_id = t.doctor_id
GROUP BY d.doctor_id, d.doctor_name, d.specialty
ORDER BY total_treatments DESC; 

-- Compare doctor performance across treatment outcomes.
-- Analytical Question: How do treatment outcomes vary across doctors?
 
 SELECT
    d.doctor_name,
    t.status,
    COUNT(t.treatment_id) AS total_treatments
FROM doctors d
JOIN treatments t
    ON d.doctor_id = t.doctor_id
GROUP BY d.doctor_name, t.status
ORDER BY d.doctor_name, total_treatments DESC;

-- Examine treatment duration across doctors.
-- Analytical Question: Which doctors have the highest average treatment duration?

SELECT
    d.doctor_name,
    ROUND(AVG(t.treatment_duration_min), 2) AS avg_duration,
    COUNT(t.treatment_id) AS total_treatments
FROM doctors d
JOIN treatments t
    ON d.doctor_id = t.doctor_id
GROUP BY d.doctor_id, d.doctor_name
ORDER BY avg_duration DESC;

-- Compare room usage across room types and equipment types.
-- Analytical Question: Which room types and equipment types are used for the highest number of treatments?

SELECT
    r.room_type,
    r.equipment_type,
    COUNT(t.treatment_id) AS total_treatments
FROM rooms r
JOIN treatments t
    ON r.room_id = t.room_id
GROUP BY r.room_type, r.equipment_type
ORDER BY total_treatments DESC;

-- Evaluate treatment performance across rooms.-
-- Analytical Question: How does treatment performance vary across different rooms?

SELECT
    r.room_id,
    r.room_type,
    COUNT(t.treatment_id) AS total_treatments,
    SUM(CASE WHEN t.status = 'Completed' THEN 1 ELSE 0 END) AS completed,
    ROUND(AVG(t.waiting_time_min), 2) AS avg_waiting_time,
    ROUND(AVG(t.treatment_duration_min), 2) AS avg_duration
FROM rooms r
JOIN treatments t
    ON r.room_id = t.room_id
GROUP BY r.room_id, r.room_type
ORDER BY total_treatments DESC;

-- 4.5 Identify Treatment and Appointment Problems
-- Identify appointments requiring multiple treatment attempts.
-- Analytical Question: Which appointments required more than one treatment attempt?

SELECT
    appointment_id,
    MAX(treatment_attempt) AS total_attempts,
    COUNT(treatment_id) AS treatment_records
FROM treatments
GROUP BY appointment_id
HAVING MAX(treatment_attempt) > 1
ORDER BY total_attempts DESC;
-- Find common problem statuses and patterns.
-- Analytical Question: Which treatment problem statuses occur most frequently?

SELECT
    status,
    COUNT(*) AS total_records
FROM treatments
WHERE status IN ('Cancelled', 'No-Show', 'Rescheduled')
GROUP BY status
ORDER BY total_records DESC;

-- Compare waiting time for appointments with multiple attempts.
-- Analytical Question: Do appointments with multiple treatment attempts have higher average waiting times?

SELECT
    CASE
        WHEN MAX_ATTEMPT > 1 THEN 'Multiple Attempts'
        ELSE 'Single Attempt'
    END AS attempt_category,
    ROUND(AVG(t.waiting_time_min), 2) AS avg_waiting_time
FROM treatments t
JOIN (
    SELECT
        appointment_id,
        MAX(treatment_attempt) AS MAX_ATTEMPT
    FROM treatments
    GROUP BY appointment_id
) x
ON t.appointment_id = x.appointment_id
GROUP BY attempt_category;

-- Identify cities or service types with more cancellations, no-shows, or rescheduling.
-- Analytical Question: Which cities and service types have the highest number of cancelled, no-show, and rescheduled treatments?

SELECT
    p.city,
    a.service_type,
    t.status,
    COUNT(*) AS total_records
FROM patients p
JOIN appointments a
    ON p.patient_id = a.patient_id
JOIN treatments t
    ON a.appointment_id = t.appointment_id
WHERE t.status IN ('Cancelled', 'No-Show', 'Rescheduled')
GROUP BY p.city, a.service_type, t.status
ORDER BY total_records DESC;

-- Investigate whether priority level is associated with waiting time or treatment outcomes.
-- Analytical Question: How does appointment priority relate to average waiting time and treatment outcomes?
SELECT
    a.priority,
    t.status,
    COUNT(t.treatment_id) AS total_treatments,
    ROUND(AVG(t.waiting_time_min), 2) AS avg_waiting_time
FROM appointments a
JOIN treatments t
    ON a.appointment_id = t.appointment_id
GROUP BY a.priority, t.status
ORDER BY a.priority, total_treatments DESC;

