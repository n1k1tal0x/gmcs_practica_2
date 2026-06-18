### Task 1: Сделал запуск в docker-compose

### Task 2: Вместе с запуском postgres импортирует dump

### Task 3: Добавил запуск metabase в компоуз

### Task 4: Добавил бд из компоуса (адрес - название контейнера)

![Пример удачного подключения](/imgs/{F0CF554F-C178-412D-A0D3-8BBFDF4BB290}.png)
![Пример бд](/imgs/{4418A39E-6F46-4A5D-8B97-E567F6AC0981}.png)

### Task 5: Ознакомлен :) В колледже проходили.

### Task 6: Ознакомился)

### Task 7: Тут пришлось мозги напрягать ;(

#### SubTask 7.1:
Формулировка: `Сумма Trimp участников команды за день по каждому дню в диапазоне дат выбранного марафона`
1) Выбираем марофон (ФИЛЬТР Графика)
```SQL
SELECT "Id", "Name", "StartDate", "EndDate" FROM "Marathons"
```
Id - для дальнейшей фильтрации, Имя - чтобы выбрать имя марафона, StartDate и EndDate для дальнейше логики
Вывод:
| Id  | Name                       | StartDate              | EndDate                |
| --- | -------------------------- | ---------------------- | ---------------------- |
| 1   | Марафон проверки платформы | 2026-03-15 21:00:00+00 | 2026-04-29 21:00:00+00 |

2) Теперь нужно составить Y ось графика (т.е. КОМАНДЫ):
Каждый элемент графика это КОМАНДА из ИГРОКОВ
```SQL
SELECT t."Id", t."Name", ut."MembersId" FROM "Teams" t JOIN "UserTeam" ut ON ut."TeamId" = t."Id" WHERE t "MarathonId" = 1;
```
Фильтруем по выбранному `MarathonId` из первого пункта и получаем таблицу "Команда - Участник"
Вывод:
| Id  | Name      | MembersId |
| --- | --------- | --------- |
| 1   | Команда А | 1         |

Итого: Левая колонка есть - Команда N

3) Теперь получаем данные на основе которых будет строить график:
```SQL
select "UserId", "BanisterTRIMP", "ActivityDate" from "PhysicalActivityEntries" WHERE "IsInvalid" != true ORDER BY "ActivityDate" ASC;
```
Результат:
| UserId | BanisterTRIMP       | ActivityDate                  |
| ------ | ------------------- | ----------------------------- |
| 1      | 21.355840151306662  | -infinity                     |
| 1      | 48.708734464265895  | -infinity                     |
| 1      | 4.799703774608884   | -infinity                     |
| 1      | 0.04989326796794163 | -infinity                     |
| 1      | 0.0                 | -infinity                     |
| 1      | 0.0                 | -infinity                     |
| 1      | 0.0                 | -infinity                     |
| 1      | 0.0                 | -infinity                     |
| 1      | 0.0                 | -infinity                     |
| 1      | 277.22645816744784  | 2025-10-02 17:18:00+00        |
| 1      | 277.22645816744784  | 2025-10-02 20:18:00+00        |
| 1      | 0.0                 | 2026-03-28 17:51:21.329006+00 |
| 1      | 16.910078873731386  | 2026-04-03 07:48:36.484641+00 |
| 1      | 38.401857385290725  | 2026-04-03 16:44:38.79742+00  |
| 1      | 39.642876538360795  | 2026-05-12 21:15:00+00        |
| 1      | 66.19802729537562   | 2026-05-13 19:48:00+00        |
| 1      | 32.036611728795094  | 2026-05-23 14:36:00+00        |
| 1      | 31.26616807999757   | 2026-05-24 21:00:00+00        |
| 1      | 0.0                 | 2026-05-26 07:40:32.47398+00  |
| 1      | 0.0                 | 2026-06-03 11:50:48.553758+00 |
| 1      | 0.0                 | 2026-06-03 12:03:03.799638+00 |

Остаётся:
    - Фильтровать по ActivityDate в рамках выбранного марафона (см. п. 1)
    - В текущем дампе только один пользователь, но нам нужна сумма за день каждого пользователя конкретной команды
    - Ну и самое весёлое это объеденить всё в один запрос

4) Через нейронку у меня получился такой запрос:
```sql
WITH marathon AS (
    SELECT
        m."Id",
        m."Name",
        m."StartDate"::date AS start_date,
        m."EndDate"::date AS end_date
    FROM "Marathons" m
    WHERE m."Id" = 1
),
days AS (
    SELECT generate_series(
        (SELECT start_date FROM marathon),
        (SELECT end_date FROM marathon),
        interval '1 day'
    )::date AS day
),
teams AS (
    SELECT
        t."Id" AS team_id,
        t."Name" AS team_name
    FROM "Teams" t
    JOIN marathon m ON t."MarathonId" = m."Id"
),
team_members AS (
    SELECT
        t.team_id,
        t.team_name,
        ut."MembersId" AS user_id
    FROM teams t
    JOIN "UserTeam" ut ON ut."TeamId" = t.team_id
),
activity_by_team_day AS (
    SELECT
        tm.team_id,
        tm.team_name,
        pae."ActivityDate"::date AS day,
        SUM(pae."BanisterTRIMP") AS trimp_sum
    FROM team_members tm
    JOIN "PhysicalActivityEntries" pae
        ON pae."UserId" = tm.user_id
    JOIN marathon m
        ON pae."ActivityDate"::date BETWEEN m.start_date AND m.end_date
    WHERE pae."IsInvalid" IS DISTINCT FROM TRUE
      -- Metabase Field Filter: PhysicalActivityEntries -> ActivityDate
      [[AND {{activity_date}}]]
    GROUP BY tm.team_id, tm.team_name, pae."ActivityDate"::date
)
SELECT
    t.team_id,
    t.team_name,
    d.day,
    COALESCE(a.trimp_sum, 0) AS trimp_sum
FROM teams t
CROSS JOIN days d
LEFT JOIN activity_by_team_day a
    ON a.team_id = t.team_id
   AND a.day = d.day
ORDER BY t.team_name, d.day;
```

Вот итоговая формула, изменил фильтр по имени, т.к. не разобрался как выбирать имя, а подставлялся чтобы Id:
```
WITH marathon AS (
    SELECT
        m."Id",
        m."Name",
        m."StartDate"::date AS start_date,
        m."EndDate"::date AS end_date
    FROM "Marathons" m
    WHERE m."Name" = {{maraphon_name}}
),
days AS (
    SELECT generate_series(
        (SELECT start_date FROM marathon),
        (SELECT end_date FROM marathon),
        interval '1 day'
    )::date AS day
),
teams AS (
    SELECT
        t."Id" AS team_id,
        t."Name" AS team_name
    FROM "Teams" t
    JOIN marathon m ON t."MarathonId" = m."Id"
),
team_members AS (
    SELECT
        t.team_id,
        t.team_name,
        ut."MembersId" AS user_id
    FROM teams t
    JOIN "UserTeam" ut ON ut."TeamId" = t.team_id
),
activity_by_team_day AS (
    SELECT
        tm.team_id,
        tm.team_name,
        pae."ActivityDate"::date AS day,
        SUM(pae."BanisterTRIMP") AS trimp_sum
    FROM team_members tm
    JOIN "PhysicalActivityEntries" pae
        ON pae."UserId" = tm.user_id
    JOIN marathon m
        ON pae."ActivityDate"::date BETWEEN m.start_date AND m.end_date
    WHERE pae."IsInvalid" IS DISTINCT FROM TRUE
      -- Metabase Field Filter: PhysicalActivityEntries -> ActivityDate
      [[AND {{activity_date}}]]
    GROUP BY tm.team_id, tm.team_name, pae."ActivityDate"::date
)
SELECT
    t.team_id,
    t.team_name,
    d.day,
    COALESCE(a.trimp_sum, 0) AS trimp_sum
FROM teams t
CROSS JOIN days d
LEFT JOIN activity_by_team_day a
    ON a.team_id = t.team_id
   AND a.day = d.day
ORDER BY t.team_name, d.day;
```

#### SubTask 7.2:

Всё тоже самое, что и в 7.1, только не `BanisterTRIMP`, а `EstimatedPaeeKcal`

#### SubTask 7.3:

Вот запрос:
```SQL
WITH marathon AS (
    SELECT
        m."Id",
        m."StartDate"::date AS start_date,
        m."EndDate"::date AS end_date
    FROM "Marathons" m
    WHERE m."Id" = 1
),
team_members AS (
    SELECT
        t."Id" AS team_id,
        t."Name" AS team_name,
        ut."MembersId" AS user_id
    FROM "Teams" t
    JOIN marathon m ON t."MarathonId" = m."Id"
    JOIN "UserTeam" ut ON ut."TeamId" = t."Id"
),
team_trimp AS (
    SELECT
        tm.team_id,
        tm.team_name,
        SUM(pae."BanisterTRIMP") AS trimp_sum
    FROM team_members tm
    JOIN "PhysicalActivityEntries" pae
        ON pae."UserId" = tm.user_id
    JOIN marathon m
        ON pae."ActivityDate"::date BETWEEN m.start_date AND m.end_date
    WHERE pae."IsInvalid" IS DISTINCT FROM TRUE
      -- Metabase Field Filter: PhysicalActivityEntries -> ActivityDate
      [[AND {{activity_date}}]]
    GROUP BY tm.team_id, tm.team_name
)
SELECT
    team_id,
    team_name,
    trimp_sum
FROM team_trimp
ORDER BY trimp_sum DESC, team_name
LIMIT 10;
```

Я не использовал тот же график, что и на скриншоте к заданию, а использовал обычную гистограмму т.к. не понятно какие ещё данные брать для линий графиков

#### SubTask 7.4:

Всё тоже самое, что и в 7.3, только не `BanisterTRIMP`, а `EstimatedPaeeKcal`

#### SubTask 7.5:

Запрос:
```SQL
WITH marathon AS (
    SELECT
        m."Id",
        m."StartDate"::date AS start_date,
        m."EndDate"::date AS end_date
    FROM "Marathons" m
    WHERE m."Name" = 'Summer Pace Marathon'
),
participant_members AS (
    SELECT DISTINCT
        ut."MembersId" AS user_id
    FROM "Teams" t
    JOIN "UserTeam" ut ON ut."TeamId" = t."Id"
    JOIN marathon m ON m."Id" = t."MarathonId"
),
participant_trimp AS (
    SELECT
        pm.user_id,
        SUM(pae."BanisterTRIMP") AS trimp_sum
    FROM participant_members pm
    JOIN "PhysicalActivityEntries" pae
        ON pae."UserId" = pm.user_id
    JOIN marathon m
        ON pae."ActivityDate"::date BETWEEN m.start_date AND m.end_date
    WHERE pae."IsInvalid" IS DISTINCT FROM TRUE
      -- Metabase Field Filter: PhysicalActivityEntries -> ActivityDate
      [[AND {{activity_date}}]]
    GROUP BY pm.user_id
)
SELECT
    u."Id" AS user_id,
    u."FirstName",
    u."LastName",
    u."Email",
    COALESCE(pt.trimp_sum, 0) AS trimp_sum
FROM participant_members pm
JOIN "Users" u ON u."Id" = pm.user_id
LEFT JOIN participant_trimp pt ON pt.user_id = pm.user_id
ORDER BY trimp_sum DESC, u."LastName", u."FirstName"
LIMIT 100;
```

#### SubTask 7.6:

Всё тоже самое, что и в 7.3, только не `BanisterTRIMP`, а `EstimatedPaeeKcal`

#### SubTask 7.7:

Запрос:
```SQL
WITH marathon AS (
    SELECT
        m."Id",
        m."StartDate"::date AS start_date,
        m."EndDate"::date AS end_date
    FROM "Marathons" m
    WHERE m."Name" = {{maraphon_name}}
),
activity_types AS (
    SELECT
        pat."Id" AS type_id,
        pat."Name" AS type_name
    FROM "PhysicalActivityTypes" pat
    JOIN "MarathonPhysicalActivityType" mpat
        ON mpat."PhysicalActivityTypesId" = pat."Id"
    JOIN marathon m
        ON mpat."MarathonsId" = m."Id"
),
type_trimp AS (
    SELECT
        at.type_id,
        at.type_name,
        SUM(pae."BanisterTRIMP") AS trimp_sum
    FROM activity_types at
    JOIN "PhysicalActivityEntries" pae
        ON pae."PhysicalActivityTypeId" = at.type_id
    JOIN marathon m
        ON pae."ActivityDate"::date BETWEEN m.start_date AND m.end_date
    WHERE pae."IsInvalid" IS DISTINCT FROM TRUE
      -- Metabase Field Filter: PhysicalActivityEntries -> ActivityDate
      [[AND {{activity_date}}]]
    GROUP BY at.type_id, at.type_name
),
ranked AS (
    SELECT
        ROW_NUMBER() OVER (
            ORDER BY COALESCE(tt.trimp_sum, 0) DESC, tt.type_name
        ) AS place,
        tt.type_name,
        COALESCE(tt.trimp_sum, 0) AS trimp_sum
    FROM type_trimp tt
)
SELECT
    place,
    type_name,
    trimp_sum
FROM ranked
ORDER BY place
LIMIT 10;
```

#### SubTask 7.8:

Всё тоже самое, что и в 7.7, только не `BanisterTRIMP`, а `EstimatedPaeeKcal`

#### SubTask 7.9:

Занейронил данные, в дампе их нема

Запрос:
```SQL
WITH activity_posts AS (
    SELECT
        pae."Id" AS activity_id,
        pae."ActivityDate",
        pae."EstimatedPaeeKcal",
        pae."BanisterTRIMP",
        p."Id" AS post_id,
        p."Title",
        p."Description"
    FROM "PhysicalActivityEntries" pae
    JOIN "Posts" p
        ON p."PhysicalActivityEntryId" = pae."Id"
    WHERE pae."IsInvalid" IS DISTINCT FROM TRUE
      -- Metabase Field Filter: PhysicalActivityEntries -> ActivityDate
      [[AND {{activity_date}}]]
),
post_likes AS (
    SELECT
        ap.activity_id,
        ap."ActivityDate",
        ap."EstimatedPaeeKcal",
        ap."BanisterTRIMP",
        ap.post_id,
        ap."Title",
        ap."Description",
        COUNT(pl."UserId") AS likes_count
    FROM activity_posts ap
    LEFT JOIN "PostLikes" pl
        ON pl."PostId" = ap.post_id
    GROUP BY
        ap.activity_id,
        ap."ActivityDate",
        ap."EstimatedPaeeKcal",
        ap."BanisterTRIMP",
        ap.post_id,
        ap."Title",
        ap."Description"
)
SELECT
    activity_id,
    post_id,
    'http://sitename/posts/' || post_id AS post_url,
    "Title",
    "ActivityDate",
    "EstimatedPaeeKcal",
    "BanisterTRIMP",
    likes_count
FROM post_likes
ORDER BY likes_count DESC, "ActivityDate" DESC
LIMIT 100;
```

#### SubTask 7.10:

Запрос:
```SQL
WITH marathon AS (
    SELECT
        m."Id",
        m."StartDate"::date AS start_date,
        m."EndDate"::date AS end_date
    FROM "Marathons" m
    WHERE m."Name" = {{marathon_name}}
)
SELECT
    pae."Id" AS activity_id,
    pae."ActivityDate",
    pae."UserId",
    u."FirstName",
    u."LastName",
    pae."PhysicalActivityTypeId",
    pat."Name" AS activity_type_name,
    pae."EstimatedPaeeKcal",
    pae."BanisterTRIMP"
FROM "PhysicalActivityEntries" pae
JOIN marathon m
    ON pae."ActivityDate"::date BETWEEN m.start_date AND m.end_date
JOIN "Users" u
    ON u."Id" = pae."UserId"
LEFT JOIN "PhysicalActivityTypes" pat
    ON pat."Id" = pae."PhysicalActivityTypeId"
WHERE pae."IsInvalid" IS DISTINCT FROM TRUE
  -- Metabase Field Filter: PhysicalActivityEntries -> ActivityDate
  [[AND {{activity_date}}]]
ORDER BY pae."ActivityDate" DESC, pae."Id" DESC;
```
