-- Additional seed data for the restored database.
-- This file is executed after 01-restore.sh by the Postgres init process.

INSERT INTO public."Users" (
    "Id", "Email", "PasswordHash", "FirstName", "LastName", "Gender",
    "WeightKg", "HeightCm", "CreatedOn", "RestingHeartRate", "Role",
    "OrganizationId", "MustChangePassword", "Comment", "DateOfBirth"
) VALUES
    (5, 'ekaterina.smolina@test.com', '$2a$11$k3mQnB3i5Xw3nP4dQ0wE5uQ5Y5mV6nR7sT8uV9wX0yZ1aB2cD3eF4G', 'Екатерина', 'Смолина', 1, 60, 168, TIMESTAMPTZ '2026-06-10 10:00:00+00', 58, 0, 1, FALSE, NULL, DATE '1994-02-14'),
    (6, 'roman.lebedev@test.com', '$2a$11$k3mQnB3i5Xw3nP4dQ0wE5uQ5Y5mV6nR7sT8uV9wX0yZ1aB2cD3eF4G', 'Роман', 'Лебедев', 0, 78, 180, TIMESTAMPTZ '2026-06-10 10:05:00+00', 54, 0, 1, FALSE, NULL, DATE '1990-11-03'),
    (7, 'irina.morozova@test.com', '$2a$11$k3mQnB3i5Xw3nP4dQ0wE5uQ5Y5mV6nR7sT8uV9wX0yZ1aB2cD3eF4G', 'Ирина', 'Морозова', 1, 62, 170, TIMESTAMPTZ '2026-06-10 10:10:00+00', 57, 0, 1, FALSE, NULL, DATE '1996-08-21'),
    (8, 'kirill.novikov@test.com', '$2a$11$k3mQnB3i5Xw3nP4dQ0wE5uQ5Y5mV6nR7sT8uV9wX0yZ1aB2cD3eF4G', 'Кирилл', 'Новиков', 0, 82, 184, TIMESTAMPTZ '2026-06-10 10:15:00+00', 56, 0, 1, FALSE, NULL, DATE '1989-04-09'),
    (9, 'natalia.volkova@test.com', '$2a$11$k3mQnB3i5Xw3nP4dQ0wE5uQ5Y5mV6nR7sT8uV9wX0yZ1aB2cD3eF4G', 'Наталья', 'Волкова', 1, 59, 166, TIMESTAMPTZ '2026-06-10 10:20:00+00', 55, 0, 1, FALSE, NULL, DATE '1993-01-17'),
    (10, 'dmitry.egorov@test.com', '$2a$11$k3mQnB3i5Xw3nP4dQ0wE5uQ5Y5mV6nR7sT8uV9wX0yZ1aB2cD3eF4G', 'Дмитрий', 'Егоров', 0, 86, 182, TIMESTAMPTZ '2026-06-10 10:25:00+00', 60, 0, 1, FALSE, NULL, DATE '1987-12-02'),
    (11, 'sofia.pavlova@test.com', '$2a$11$k3mQnB3i5Xw3nP4dQ0wE5uQ5Y5mV6nR7sT8uV9wX0yZ1aB2cD3eF4G', 'София', 'Павлова', 1, 57, 165, TIMESTAMPTZ '2026-06-10 10:30:00+00', 59, 0, 1, FALSE, NULL, DATE '1997-06-30'),
    (12, 'andrey.sidorov@test.com', '$2a$11$k3mQnB3i5Xw3nP4dQ0wE5uQ5Y5mV6nR7sT8uV9wX0yZ1aB2cD3eF4G', 'Андрей', 'Сидоров', 0, 74, 178, TIMESTAMPTZ '2026-06-10 10:35:00+00', 53, 0, 1, FALSE, NULL, DATE '1992-09-11');

INSERT INTO public."Marathons" (
    "Id", "Name", "Description", "StartDate", "EndDate", "OwnerId", "OrganizationId"
) VALUES
    (2, 'Марафон летний темп', 'Летний марафон для проверки нескольких команд', TIMESTAMPTZ '2026-06-01 00:00:00+00', TIMESTAMPTZ '2026-07-15 23:59:59+00', 5, 1),
    (3, 'Марафон осенний финиш', 'Осенний марафон с отдельным набором команд', TIMESTAMPTZ '2026-09-01 00:00:00+00', TIMESTAMPTZ '2026-10-20 23:59:59+00', 6, 1);

INSERT INTO public."Teams" (
    "Id", "Name", "MarathonId"
) VALUES
    (2, 'Команда Сириус', 2),
    (3, 'Команда Вектор', 2),
    (4, 'Команда Пульс', 3),
    (5, 'Команда Шторм', 3);

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
    (1, 4),
    (2, 5);

INSERT INTO public."MarathonPhysicalActivityType" ("MarathonsId", "PhysicalActivityTypesId") VALUES
    (2, 1),
    (2, 2),
    (3, 1),
    (3, 2),
    (3, 3);

INSERT INTO public."PhysicalActivityEntries" (
    "Id", "UserId", "Iterations", "AvgHeartRate", "DurationMinutes", "CreatedOn",
    "EstimatedPaeeKcal", "EstimatedPaeePerKg", "PercentHrr", "EffortScore",
    "CombinedScore", "PhysicalActivityTypeId", "FilledByOcr", "S3FileId", "RPEvalue",
    "BanisterTRIMP", "IsPublished", "OcrProcessingError", "ActivityDate", "IsInvalid",
    "PerceptualHash"
) VALUES
    (26, 1, 6200, 124, 42.5, TIMESTAMPTZ '2026-03-20 08:10:00+00', 410, 3.40, 0.62, 24.8, 0.61, 1, FALSE, NULL, 6, 35.2, TRUE, NULL, TIMESTAMPTZ '2026-03-20 08:10:00+00', FALSE, NULL),
    (27, 2, 8400, 132, 55.0, TIMESTAMPTZ '2026-04-10 18:40:00+00', 560, 4.20, 0.68, 31.5, 0.74, 2, TRUE, NULL, 7, 48.9, TRUE, NULL, TIMESTAMPTZ '2026-04-10 18:40:00+00', FALSE, NULL),
    (28, 5, 7100, 128, 47.0, TIMESTAMPTZ '2026-06-05 06:30:00+00', 480, 3.95, 0.66, 27.1, 0.67, 1, FALSE, NULL, 6, 39.4, TRUE, NULL, TIMESTAMPTZ '2026-06-05 06:30:00+00', FALSE, NULL),
    (29, 6, 9200, 141, 63.0, TIMESTAMPTZ '2026-06-18 19:05:00+00', 710, 4.82, 0.74, 36.9, 0.81, 2, FALSE, NULL, 8, 58.7, TRUE, NULL, TIMESTAMPTZ '2026-06-18 19:05:00+00', FALSE, NULL),
    (30, 7, 5300, 118, 38.0, TIMESTAMPTZ '2026-07-01 07:20:00+00', 360, 2.90, 0.58, 20.4, 0.52, 1, TRUE, NULL, 5, 29.8, TRUE, NULL, TIMESTAMPTZ '2026-07-01 07:20:00+00', FALSE, NULL),
    (31, 8, 7600, 136, 50.0, TIMESTAMPTZ '2026-07-10 20:15:00+00', 590, 4.05, 0.70, 29.8, 0.73, 3, FALSE, NULL, 7, 44.1, TRUE, NULL, TIMESTAMPTZ '2026-07-10 20:15:00+00', FALSE, NULL),
    (32, 9, 6400, 121, 41.0, TIMESTAMPTZ '2026-09-07 06:50:00+00', 430, 3.55, 0.61, 23.7, 0.60, 1, FALSE, NULL, 6, 33.5, TRUE, NULL, TIMESTAMPTZ '2026-09-07 06:50:00+00', FALSE, NULL),
    (33, 10, 8900, 144, 58.0, TIMESTAMPTZ '2026-09-14 19:00:00+00', 680, 4.60, 0.76, 35.4, 0.79, 2, TRUE, NULL, 8, 54.6, TRUE, NULL, TIMESTAMPTZ '2026-09-14 19:00:00+00', FALSE, NULL),
    (34, 11, 5700, 117, 36.0, TIMESTAMPTZ '2026-10-01 07:05:00+00', 340, 2.95, 0.57, 19.5, 0.50, 1, FALSE, NULL, 5, 27.2, TRUE, NULL, TIMESTAMPTZ '2026-10-01 07:05:00+00', FALSE, NULL),
    (35, 12, 8100, 138, 52.0, TIMESTAMPTZ '2026-10-10 18:35:00+00', 610, 4.12, 0.71, 30.7, 0.75, 2, TRUE, NULL, 7, 47.5, TRUE, NULL, TIMESTAMPTZ '2026-10-10 18:35:00+00', FALSE, NULL),
    (36, 5, 9400, 147, 66.0, TIMESTAMPTZ '2026-10-15 19:10:00+00', 740, 4.95, 0.78, 38.6, 0.84, 3, FALSE, NULL, 8, 61.3, TRUE, NULL, TIMESTAMPTZ '2026-10-15 19:10:00+00', FALSE, NULL),
    (37, 6, 6000, 123, 40.0, TIMESTAMPTZ '2026-04-20 08:25:00+00', 390, 3.20, 0.60, 22.4, 0.58, 1, FALSE, NULL, 6, 31.7, TRUE, NULL, TIMESTAMPTZ '2026-04-20 08:25:00+00', FALSE, NULL);

SELECT pg_catalog.setval('public."Users_Id_seq"', 12, true);
SELECT pg_catalog.setval('public."Marathons_Id_seq"', 3, true);
SELECT pg_catalog.setval('public."Teams_Id_seq"', 5, true);
SELECT pg_catalog.setval('public."PhysicalActivityEntries_Id_seq"', 37, true);
