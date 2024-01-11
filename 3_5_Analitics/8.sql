/*
Посчитать среднее время, за которое пользователи проходят урок по следующему алгоритму:

1. для каждого пользователя вычислить время прохождения шага как сумму времени, потраченного на каждую попытку (время попытки - это разница между временем 
отправки задания и временем начала попытки), при этом попытки, которые длились больше 4 часов не учитывать, так как пользователь мог просто оставить задание 
открытым в браузере, а вернуться к нему на следующий день;
2. для каждого студента посчитать общее время, которое он затратил на каждый урок;
3. вычислить среднее время выполнения урока в часах, результат округлить до 2-х знаков после запятой;
4. вывести информацию по возрастанию времени, пронумеровав строки, для каждого урока указать номер модуля и его позицию в нем.
Столбцы результата назвать Номер, Урок, Среднее_время.
*/

WITH
student_lesson_passing_duration(student_id, lesson_id, passing_duration) AS (
    SELECT 
        ss.student_id,
        s.lesson_id,
        SUM((ss.submission_time - ss.attempt_time) / 3600) AS passing_duration
    FROM 
        step AS s
        JOIN step_student AS ss USING(step_id)
    WHERE 
        ss.submission_time - ss.attempt_time <= 4 * 3600
    GROUP BY 
        ss.student_id,
        s.lesson_id
),
lesson_avg_passing_duration(lesson_id, avg_passing_duration) AS (
    SELECT
        lesson_id,
        ROUND(AVG(passing_duration), 2) AS avg_passing_duration
    FROM 
        student_lesson_passing_duration
    GROUP BY
        lesson_id
)        
SELECT
    ROW_NUMBER() OVER (ORDER BY lt.avg_passing_duration) AS Номер,
    CONCAT(m.module_id, '.', l.lesson_position, ' ', l.lesson_name) AS Урок,
    lt.avg_passing_duration AS Среднее_время
FROM 
    lesson_avg_passing_duration AS lt
    JOIN lesson AS l USING(lesson_id)
    JOIN module AS m USING(module_id)
ORDER BY
    lt.avg_passing_duration;
