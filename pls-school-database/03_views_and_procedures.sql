/* =============================================================================
   PLS School Database - 03: views and stored procedure
   Author : Damon Bly
   Views hide multi-table joins behind simple names for day-to-day reporting.
   The stored procedure enforces enrollment rules that a CHECK constraint
   cannot (class capacity depends on other rows).
   ============================================================================= */

USE PLS;
GO

/* ---------- View: class roster ----------
   One row per student per class, with course, term, instructor, and grade. */
CREATE OR ALTER VIEW Academics.vw_ClassRoster
AS
SELECT  cl.ClassId,
        cc.CourseName,
        cl.Term,
        cl.MeetDay,
        CONCAT(ip.FirstName, N' ', ip.LastName) AS InstructorName,
        s.StudentId,
        CONCAT(sp.FirstName, N' ', sp.LastName) AS StudentName,
        e.EnrollDate,
        e.Grade
FROM Academics.Enrollments   AS e
JOIN Academics.Classes       AS cl ON e.ClassId      = cl.ClassId
JOIN Academics.CourseCatalog AS cc ON cl.CourseId    = cc.CourseId
JOIN People.Students         AS s  ON e.StudentId    = s.StudentId
JOIN People.Persons          AS sp ON s.PersonId     = sp.PersonId
LEFT JOIN People.Instructors AS i  ON cl.InstructorId = i.InstructorId
LEFT JOIN People.Persons     AS ip ON i.PersonId     = ip.PersonId;
GO

/* ---------- View: enrollment summary ----------
   Seats used vs. capacity for every class, including classes with no
   enrollments yet (LEFT JOIN + COUNT of a column, not COUNT(*)). */
CREATE OR ALTER VIEW Academics.vw_ClassEnrollmentSummary
AS
SELECT  cl.ClassId,
        cc.CourseName,
        cc.CourseType,
        cl.Term,
        cl.MaxCapacity,
        COUNT(e.EnrollmentId)                         AS Enrolled,
        cl.MaxCapacity - COUNT(e.EnrollmentId)        AS SeatsLeft,
        CAST(100.0 * COUNT(e.EnrollmentId) / cl.MaxCapacity AS DECIMAL(5, 1)) AS FillPercent,
        cl.TuitionFee,
        cl.TuitionFee * COUNT(e.EnrollmentId)         AS TuitionRevenue
FROM Academics.Classes        AS cl
JOIN Academics.CourseCatalog  AS cc ON cl.CourseId = cc.CourseId
LEFT JOIN Academics.Enrollments AS e ON cl.ClassId = e.ClassId
GROUP BY cl.ClassId, cc.CourseName, cc.CourseType, cl.Term, cl.MaxCapacity, cl.TuitionFee;
GO

/* ---------- Stored procedure: enroll a student ----------
   Checks that the student and class exist, that the student is not already
   enrolled, and that the class has a seat left, then inserts the enrollment.
   UPDLOCK + HOLDLOCK on the class row stops two simultaneous enrollments from
   both taking the last seat. */
CREATE OR ALTER PROCEDURE Academics.usp_EnrollStudent
    @StudentId INT,
    @ClassId   INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @Capacity INT, @Enrolled INT;

        SELECT @Capacity = MaxCapacity
        FROM Academics.Classes WITH (UPDLOCK, HOLDLOCK)
        WHERE ClassId = @ClassId;

        IF @Capacity IS NULL
            THROW 50001, 'Class not found.', 1;

        IF NOT EXISTS (SELECT 1 FROM People.Students WHERE StudentId = @StudentId)
            THROW 50002, 'Student not found.', 1;

        IF EXISTS (SELECT 1 FROM Academics.Enrollments
                   WHERE StudentId = @StudentId AND ClassId = @ClassId)
            THROW 50003, 'Student is already enrolled in this class.', 1;

        SELECT @Enrolled = COUNT(*)
        FROM Academics.Enrollments
        WHERE ClassId = @ClassId;

        IF @Enrolled >= @Capacity
            THROW 50004, 'Class is full.', 1;

        INSERT INTO Academics.Enrollments (StudentId, ClassId)
        VALUES (@StudentId, @ClassId);

        DECLARE @NewEnrollmentId INT = SCOPE_IDENTITY();

        COMMIT TRANSACTION;

        SELECT @NewEnrollmentId AS NewEnrollmentId;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;   -- undo anything partly done
        THROW;                      -- pass the original error to the caller
    END CATCH;
END;
GO

/* ---------- Try it ----------
   The first test is wrapped in a transaction that is rolled back; the second
   is rejected by the procedure. Neither changes the sample data. */
BEGIN TRANSACTION;

    -- Succeeds: Mateo (student 4) joins Mandarin Level 2 (class 4).
    EXEC Academics.usp_EnrollStudent @StudentId = 4, @ClassId = 4;

ROLLBACK TRANSACTION;

BEGIN TRY
    -- Fails: Calligraphy (class 5) is already at 4 of 4 seats.
    EXEC Academics.usp_EnrollStudent @StudentId = 2, @ClassId = 5;
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER()  AS ErrorNumber,    -- 50004
           ERROR_MESSAGE() AS ErrorMessage;  -- Class is full.
END CATCH;
GO
