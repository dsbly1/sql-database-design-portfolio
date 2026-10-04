/* =============================================================================
   PLS School Database - 04: reporting queries
   Author : Damon Bly
   Business questions a school administrator would ask, answered in T-SQL.
   Queries 1-3 come from the original case study; 4-12 extend it.
   ============================================================================= */

USE PLS;
GO

-- 1. Who is enrolled in Chinese Classic Music 1?                  (Case study Q4)
SELECT StudentId, StudentName, CourseName, Grade
FROM Academics.vw_ClassRoster
WHERE CourseName = N'Chinese Classic Music 1'
ORDER BY StudentName;

-- 2. How many students are registered for Chinese Classic Music 1? (Case study Q6)
SELECT COUNT(*) AS StudentsInChineseClassicMusic
FROM Academics.Enrollments AS e
JOIN Academics.Classes       AS cl ON e.ClassId  = cl.ClassId
JOIN Academics.CourseCatalog AS cc ON cl.CourseId = cc.CourseId
WHERE cc.CourseName = N'Chinese Classic Music 1';

-- 3. Students in each Kung Fu class with their instructor.        (Case study Q3/Q4)
SELECT ClassId, Term, InstructorName, StudentName
FROM Academics.vw_ClassRoster
WHERE CourseName LIKE N'Kung Fu%'
ORDER BY ClassId, StudentName;

-- 4. Seats used vs. capacity for every class, fullest first.
SELECT ClassId, CourseName, Term, Enrolled, MaxCapacity, SeatsLeft, FillPercent
FROM Academics.vw_ClassEnrollmentSummary
ORDER BY FillPercent DESC;

-- 5. Classes at 75% capacity or more (candidates for a second section).
SELECT ClassId, CourseName, Term, Enrolled, MaxCapacity, FillPercent
FROM Academics.vw_ClassEnrollmentSummary
WHERE FillPercent >= 75
ORDER BY FillPercent DESC;

-- 6. Instructor workload: classes taught, students taught, tuition generated.
--    Tuition counts only enrolled seats, so an empty class adds $0.
SELECT CONCAT(p.FirstName, N' ', p.LastName) AS Instructor,
       i.Specialization,
       COUNT(DISTINCT cl.ClassId)             AS ClassesTaught,
       COUNT(e.EnrollmentId)                  AS StudentSeats,
       COALESCE(SUM(CASE WHEN e.EnrollmentId IS NOT NULL
                         THEN cl.TuitionFee END), 0) AS TuitionRevenue
FROM People.Instructors    AS i
JOIN People.Persons        AS p  ON i.PersonId  = p.PersonId
LEFT JOIN Academics.Classes     AS cl ON i.InstructorId = cl.InstructorId
LEFT JOIN Academics.Enrollments AS e  ON cl.ClassId = e.ClassId
GROUP BY p.FirstName, p.LastName, i.Specialization
ORDER BY TuitionRevenue DESC;

-- 7. Students who have not joined any club (outreach list for club leaders).
SELECT s.StudentId, CONCAT(p.FirstName, N' ', p.LastName) AS StudentName
FROM People.Students AS s
JOIN People.Persons  AS p ON s.PersonId = p.PersonId
LEFT JOIN Activities.ClubMemberships AS m ON s.StudentId = m.StudentId
WHERE m.StudentId IS NULL;

-- 8. Members per club, including clubs with no members yet.
--    CASE (not COALESCE) is needed because CONCAT turns NULLs into empty text.
SELECT c.ClubName,
       CASE WHEN ap.PersonId IS NULL THEN N'(no advisor)'
            ELSE CONCAT(ap.FirstName, N' ', ap.LastName) END AS Advisor,
       COUNT(m.StudentId) AS Members
FROM Activities.Clubs AS c
LEFT JOIN People.Instructors         AS a  ON c.AdvisorId = a.InstructorId
LEFT JOIN People.Persons             AS ap ON a.PersonId  = ap.PersonId
LEFT JOIN Activities.ClubMemberships AS m  ON c.ClubId    = m.ClubId
GROUP BY c.ClubName, ap.PersonId, ap.FirstName, ap.LastName
ORDER BY Members DESC;

-- 9. Business rule check: what share of students are in the 5-15 core age group?
--    Age is computed exactly (DATEDIFF alone counts year boundaries, not birthdays).
WITH StudentAges AS
(
    SELECT StudentId,
           DATEDIFF(YEAR, BirthDate, GETDATE())
             - CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, BirthDate, GETDATE()), BirthDate) > GETDATE()
                    THEN 1 ELSE 0 END AS Age
    FROM People.Students
)
SELECT CASE WHEN Age BETWEEN 5 AND 15 THEN N'Ages 5-15 (core)'
            WHEN Age < 5              THEN N'Under 5'
            ELSE                           N'16 and over' END AS AgeGroup,
       COUNT(*) AS Students,
       CAST(100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS DECIMAL(5, 1)) AS PercentOfStudents
FROM StudentAges
GROUP BY CASE WHEN Age BETWEEN 5 AND 15 THEN N'Ages 5-15 (core)'
              WHEN Age < 5              THEN N'Under 5'
              ELSE                           N'16 and over' END;

-- 10. Donations by donor type: count, total, and average gift.
SELECT d.DonorType,
       COUNT(*)         AS Gifts,
       SUM(dn.Amount)   AS TotalGiven,
       AVG(dn.Amount)   AS AverageGift
FROM Fundraising.Donors    AS d
JOIN Fundraising.Donations AS dn ON d.DonorId = dn.DonorId
GROUP BY d.DonorType
ORDER BY TotalGiven DESC;

-- 11. Funding mix: tuition vs. donations, with each source's share.
WITH Funding AS
(
    SELECT N'Tuition' AS Source, SUM(TuitionRevenue) AS Amount
    FROM Academics.vw_ClassEnrollmentSummary
    UNION ALL
    SELECT N'Donations', SUM(Amount)
    FROM Fundraising.Donations
)
SELECT Source,
       Amount,
       CAST(100.0 * Amount / SUM(Amount) OVER () AS DECIMAL(5, 1)) AS PercentOfFunding
FROM Funding;

-- 12. Donor leaderboard: lifetime giving with rank.
SELECT RANK() OVER (ORDER BY SUM(dn.Amount) DESC) AS DonorRank,
       d.DonorName,
       d.DonorType,
       COUNT(*)          AS Gifts,
       SUM(dn.Amount)    AS LifetimeGiving,
       MAX(dn.DonationDate) AS MostRecentGift
FROM Fundraising.Donors    AS d
JOIN Fundraising.Donations AS dn ON d.DonorId = dn.DonorId
GROUP BY d.DonorName, d.DonorType;

-- 13. Family contact sheet: each student with guardian and family contact info.
--     Persons is joined twice under different aliases: once for the student,
--     once for the guardian.
SELECT CONCAT(sp.FirstName, N' ', sp.LastName) AS Student,
       f.FamilyName,
       CASE WHEN g.GuardianId IS NULL THEN N'(adult student, no guardian)'
            ELSE CONCAT(gp.FirstName, N' ', gp.LastName, N' (', g.Relationship, N')')
       END                                     AS Guardian,
       COALESCE(gp.Phone, f.HomePhone)         AS ContactPhone,
       f.Email                                 AS FamilyEmail
FROM People.Students  AS s
JOIN People.Persons   AS sp ON s.PersonId = sp.PersonId
JOIN People.Families  AS f  ON s.FamilyId = f.FamilyId
LEFT JOIN People.Guardians AS g  ON f.FamilyId = g.FamilyId
LEFT JOIN People.Persons   AS gp ON g.PersonId = gp.PersonId
ORDER BY f.FamilyName, Student;
