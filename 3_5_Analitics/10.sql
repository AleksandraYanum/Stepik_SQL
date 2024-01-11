/*
Проанализировать, в каком порядке и с каким интервалом пользователь отправлял последнее верно выполненное задание каждого урока. В базе занесены попытки студентов  для трех уроков курса, поэтому анализ проводить только для этих уроков.

Для студентов прошедших как минимум по одному шагу в каждом уроке, найти последний пройденный шаг каждого урока - крайний шаг, и указать:

имя студента;
номер урока, состоящий из номера модуля и через точку позиции каждого урока в модуле;
время отправки  - время подачи решения на проверку;
разницу во времени отправки между текущим и предыдущим крайним шагом в днях, при этом для первого шага поставить прочерк ("-"), а количество дней округлить до целого в большую сторону.
Столбцы назвать  Студент, Урок,  Макс_время_отправки и Интервал  соответственно. Отсортировать результаты по имени студента в алфавитном порядке, а потом по возрастанию времени отправки.
*/

WITH

student_lesson_submission_time(student_id, lesson_id, lesson_submission_time) AS (
    SELECT 
        ss.student_id,  
        s.lesson_id, 
        MAX(ss.submission_time) AS lesson_submission_time
    FROM 
        step_student AS ss
        JOIN step AS s USING(step_id)
    WHERE  
        ss.result = 'correct'  
    GROUP BY 
        ss.student_id,
        s.lesson_id
),

selected_student(student_id) AS (
    SELECT
        student_id
    FROM
        student_lesson_submission_time
    GROUP BY
        student_id
    HAVING
        COUNT(lesson_id) = 3
),

selected_student_lesson_submission_time(student_id, lesson_id, lesson_submission_time) AS (
    SELECT 
        student_id,  
        lesson_id, 
        lesson_submission_time
    FROM 
        student_lesson_submission_time
    WHERE 
        student_id IN (SELECT student_id FROM selected_student)
)

SELECT 
    st.student_name AS Студент,  
    CONCAT(l.module_id, '.', l.lesson_position) AS Урок, 
    FROM_UNIXTIME(sslt.lesson_submission_time) AS Макс_время_отправки, 
    IFNULL(
        CEIL(
                (
                    sslt.lesson_submission_time - LAG(sslt.lesson_submission_time) OVER (
                          PARTITION BY 
                              sslt.student_id 
                          ORDER BY 
                              sslt.lesson_submission_time
                          )
                 ) / 86400
             ), 
       '-'
    ) AS Интервал
FROM 
    selected_student_lesson_submission_time AS sslt
    JOIN lesson AS l USING(lesson_id)
    JOIN student AS st USING(student_id)  
ORDER BY
    Студент,
    Макс_время_отправки;
