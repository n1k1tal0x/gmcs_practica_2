-- Additional seed data for the restored database.
-- This file is executed after 01-restore.sh by the Postgres init process.

INSERT INTO public."Users" (
    "Id", "Email", "PasswordHash", "FirstName", "LastName", "Gender",
    "WeightKg", "HeightCm", "CreatedOn", "RestingHeartRate", "Role",
    "OrganizationId", "MustChangePassword", "Comment", "DateOfBirth"
) VALUES
    (5, 'ekaterina.smolina@test.com', '$2a$11$k3mQnB3i5Xw3nP4dQ0wE5uQ5Y5mV6nR7sT8uV9wX0yZ1aB2cD3eF4G', 'Ekaterina', 'Smolina', 1, 60, 168, TIMESTAMPTZ '2026-06-10 10:00:00+00', 58, 0, 1, FALSE, NULL, DATE '1994-02-14'),
    (6, 'roman.lebedev@test.com', '$2a$11$k3mQnB3i5Xw3nP4dQ0wE5uQ5Y5mV6nR7sT8uV9wX0yZ1aB2cD3eF4G', 'Roman', 'Lebedev', 0, 78, 180, TIMESTAMPTZ '2026-06-10 10:05:00+00', 54, 0, 1, FALSE, NULL, DATE '1990-11-03'),
    (7, 'irina.morozova@test.com', '$2a$11$k3mQnB3i5Xw3nP4dQ0wE5uQ5Y5mV6nR7sT8uV9wX0yZ1aB2cD3eF4G', 'Irina', 'Morozova', 1, 62, 170, TIMESTAMPTZ '2026-06-10 10:10:00+00', 57, 0, 1, FALSE, NULL, DATE '1996-08-21'),
    (8, 'kirill.novikov@test.com', '$2a$11$k3mQnB3i5Xw3nP4dQ0wE5uQ5Y5mV6nR7sT8uV9wX0yZ1aB2cD3eF4G', 'Kirill', 'Novikov', 0, 82, 184, TIMESTAMPTZ '2026-06-10 10:15:00+00', 56, 0, 1, FALSE, NULL, DATE '1989-04-09'),
    (9, 'natalia.volkova@test.com', '$2a$11$k3mQnB3i5Xw3nP4dQ0wE5uQ5Y5mV6nR7sT8uV9wX0yZ1aB2cD3eF4G', 'Natalia', 'Volkova', 1, 59, 166, TIMESTAMPTZ '2026-06-10 10:20:00+00', 55, 0, 1, FALSE, NULL, DATE '1993-01-17'),
    (10, 'dmitry.egorov@test.com', '$2a$11$k3mQnB3i5Xw3nP4dQ0wE5uQ5Y5mV6nR7sT8uV9wX0yZ1aB2cD3eF4G', 'Dmitry', 'Egorov', 0, 86, 182, TIMESTAMPTZ '2026-06-10 10:25:00+00', 60, 0, 1, FALSE, NULL, DATE '1987-12-02'),
    (11, 'sofia.pavlova@test.com', '$2a$11$k3mQnB3i5Xw3nP4dQ0wE5uQ5Y5mV6nR7sT8uV9wX0yZ1aB2cD3eF4G', 'Sofia', 'Pavlova', 1, 57, 165, TIMESTAMPTZ '2026-06-10 10:30:00+00', 59, 0, 1, FALSE, NULL, DATE '1997-06-30'),
    (12, 'andrey.sidorov@test.com', '$2a$11$k3mQnB3i5Xw3nP4dQ0wE5uQ5Y5mV6nR7sT8uV9wX0yZ1aB2cD3eF4G', 'Andrey', 'Sidorov', 0, 74, 178, TIMESTAMPTZ '2026-06-10 10:35:00+00', 53, 0, 1, FALSE, NULL, DATE '1992-09-11');

INSERT INTO public."Marathons" (
    "Id", "Name", "Description", "StartDate", "EndDate", "OwnerId", "OrganizationId"
) VALUES
    (2, 'Summer Pace Marathon', 'Summer marathon with two competing teams', TIMESTAMPTZ '2026-06-01 00:00:00+00', TIMESTAMPTZ '2026-07-15 23:59:59+00', 5, 1),
    (3, 'Autumn Finish Marathon', 'Autumn marathon with a separate team set', TIMESTAMPTZ '2026-09-01 00:00:00+00', TIMESTAMPTZ '2026-10-20 23:59:59+00', 6, 1);

INSERT INTO public."Teams" (
    "Id", "Name", "MarathonId"
) VALUES
    (2, 'Team Sirius', 2),
    (3, 'Team Vector', 2),
    (4, 'Team Pulse', 3),
    (5, 'Team Storm', 3),
    (6, 'Team North', 1),
    (7, 'Team Tempo', 1);

INSERT INTO public."UserTeam" ("MembersId", "TeamId") VALUES
    (2, 1),
    (5, 2),
    (6, 2),
    (7, 3),
    (8, 3),
    (9, 4),
    (10, 4),
    (11, 5),
    (12, 5),
    (5, 6),
    (6, 6),
    (7, 7),
    (8, 7);

INSERT INTO public."MarathonPhysicalActivityType" ("MarathonsId", "PhysicalActivityTypesId") VALUES
    (1, 1),
    (1, 2),
    (1, 3),
    (2, 1),
    (2, 2),
    (3, 1),
    (3, 2),
    (3, 3)
ON CONFLICT ("MarathonsId", "PhysicalActivityTypesId") DO NOTHING;

WITH marathons AS (
    SELECT
        m."Id" AS marathon_id,
        m."StartDate"::date AS start_date,
        m."EndDate"::date AS end_date
    FROM public."Marathons" m
    WHERE m."Id" IN (1, 2, 3)
),
days AS (
    SELECT
        md.marathon_id,
        gs::date AS day,
        ROW_NUMBER() OVER (PARTITION BY md.marathon_id ORDER BY gs)::int - 1 AS day_idx
    FROM marathons md
    CROSS JOIN generate_series(md.start_date, md.end_date, interval '1 day') AS gs
),
team_members AS (
    SELECT
        t."MarathonId" AS marathon_id,
        t."Id" AS team_id,
        ut."MembersId" AS user_id
    FROM public."Teams" t
    JOIN public."UserTeam" ut ON ut."TeamId" = t."Id"
    WHERE t."MarathonId" IN (1, 2, 3)
),
templates AS (
    SELECT *
    FROM (VALUES
        (1, 6200, 124.0, 42.0, 410.0, 3.40, 0.62, 24.8, 0.61, 1, FALSE, 6, 35.2),
        (2, 7350, 128.0, 48.0, 455.0, 3.60, 0.63, 26.0, 0.64, 2, TRUE, 7, 40.5),
        (5, 6800, 131.0, 45.0, 470.0, 3.70, 0.65, 27.5, 0.67, 1, FALSE, 6, 38.8),
        (6, 8100, 137.0, 53.0, 540.0, 4.10, 0.69, 30.2, 0.73, 2, FALSE, 7, 44.6),
        (7, 5900, 118.0, 39.0, 360.0, 2.90, 0.57, 21.0, 0.54, 1, TRUE, 5, 29.7),
        (8, 9000, 145.0, 60.0, 620.0, 4.90, 0.74, 34.5, 0.81, 3, FALSE, 8, 55.9),
        (9, 6500, 126.0, 44.0, 430.0, 3.45, 0.61, 25.8, 0.60, 1, FALSE, 6, 34.2),
        (10, 8800, 139.0, 57.0, 585.0, 4.35, 0.70, 31.9, 0.76, 2, TRUE, 7, 46.1),
        (11, 6000, 119.0, 40.0, 365.0, 3.05, 0.58, 21.7, 0.55, 3, FALSE, 5, 30.6),
        (12, 8450, 142.0, 54.0, 565.0, 4.20, 0.72, 33.1, 0.79, 2, TRUE, 8, 50.4)
    ) AS t(
        user_id,
        iterations_base,
        avg_hr,
        duration_base,
        kcal_base,
        kcal_per_kg,
        percent_hrr,
        effort_base,
        combined_base,
        activity_type_id,
        filled_by_ocr,
        rpe,
        trimp_base
    )
)
INSERT INTO public."PhysicalActivityEntries" (
    "Id",
    "UserId",
    "Iterations",
    "AvgHeartRate",
    "DurationMinutes",
    "CreatedOn",
    "EstimatedPaeeKcal",
    "EstimatedPaeePerKg",
    "PercentHrr",
    "EffortScore",
    "CombinedScore",
    "PhysicalActivityTypeId",
    "FilledByOcr",
    "RPEvalue",
    "BanisterTRIMP",
    "IsPublished",
    "ActivityDate",
    "IsInvalid"
)
SELECT
    38 + ROW_NUMBER() OVER (ORDER BY d.marathon_id, d.day, tm.team_id, tm.user_id) - 1 AS "Id",
    tm.user_id,
    t.iterations_base + (d.day_idx * 18) + (tm.team_id * 5) AS "Iterations",
    t.avg_hr
        + ((d.day_idx + tm.team_id) % 5)
        - 2 AS "AvgHeartRate",
    t.duration_base
        + (((d.day_idx + tm.team_id) % 4) - 1) * 1.5 AS "DurationMinutes",
    (d.day::timestamp + make_interval(hours => (tm.user_id % 6) * 2 + 6))::timestamptz AS "CreatedOn",
    t.kcal_base
        + (d.day_idx * 6)
        + (tm.team_id * 3) AS "EstimatedPaeeKcal",
    t.kcal_per_kg
        + ((d.day_idx % 7) * 0.02)
        - 0.04 AS "EstimatedPaeePerKg",
    t.percent_hrr
        + sin((d.day_idx + tm.team_id) / 3.0) * 0.08 AS "PercentHrr",
    t.effort_base
        + cos((d.day_idx + tm.marathon_id) / 4.0) * 2.5 AS "EffortScore",
    t.combined_base
        + sin((d.day_idx + tm.user_id) / 5.0) * 1.5 AS "CombinedScore",
    t.activity_type_id AS "PhysicalActivityTypeId",
    t.filled_by_ocr AS "FilledByOcr",
    t.rpe + ((d.day_idx + tm.team_id) % 2) AS "RPEvalue",
    round((
        t.trimp_base
        + sin((d.day_idx + tm.marathon_id) / 2.2) * 8
        + cos((d.day_idx + tm.team_id) / 3.5) * 4
        + (((d.day_idx + tm.user_id) % 6) - 2.5) * 1.4
    )::numeric, 1) AS "BanisterTRIMP",
    TRUE AS "IsPublished",
    (d.day::timestamp + make_interval(hours => (tm.user_id % 6) * 2 + 6))::timestamptz AS "ActivityDate",
    FALSE AS "IsInvalid"
FROM days d
CROSS JOIN team_members tm
JOIN templates t ON t.user_id = tm.user_id
ORDER BY d.marathon_id, d.day, tm.team_id, tm.user_id;

SELECT pg_catalog.setval('public."Users_Id_seq"', 12, true);
SELECT pg_catalog.setval('public."Marathons_Id_seq"', 3, true);
SELECT pg_catalog.setval('public."Teams_Id_seq"', 7, true);
SELECT pg_catalog.setval('public."PhysicalActivityEntries_Id_seq"', 1000, true);
