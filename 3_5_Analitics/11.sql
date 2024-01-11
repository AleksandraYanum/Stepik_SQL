/*
Для студента с именем student_59 вывести следующую информацию по всем его попыткам:

1. информация о шаге: номер модуля, символ '.', позиция урока в модуле, символ '.', позиция шага в модуле;
2. порядковый номер попытки для каждого шага - определяется по возрастанию времени отправки попытки;
3. результат попытки;
4. время попытки (преобразованное к формату времени) - определяется как разность между временем отправки попытки и времени ее начала, в случае если попытка 
длилась более 1 часа, то время попытки заменить на среднее время всех попыток пользователя по всем шагам без учета тех, которые длились больше 1 часа;
5. относительное время попытки  - определяется как отношение времени попытки (с учетом замены времени попытки) к суммарному времени всех попыток  шага, 
округленное до двух знаков после запятой  .
Столбцы назвать  Студент,  Шаг, Номер_попытки, Результат, Время_попытки и Относительное_время. Информацию отсортировать сначала по возрастанию id шага, 
 а затем по возрастанию номера попытки (определяется по времени отправки попытки).
*/


WITH
selected_student_course_info(student_id, lesson_id, step_id, step_position, attempt_time, submission_time, result, attempt_duration) AS (
    SELECT 
        ss.student_id, 
        s.lesson_id, 
        ss.step_id, 
        s.step_position,
        ss.attempt_time, 
        ss.submission_time, 
        ss.result,
        (ss.submission_time - ss.attempt_time) AS attempt_duration
    FROM 
        step_student AS ss 
        JOIN step AS s USING(step_id)
    WHERE 
        ss.student_id = (SELECT student_id FROM student WHERE student_name = "student_59")
),

avg_student_attempt_duration(avg_attempt_duration) AS (
    SELECT 
        AVG(attempt_duration)
    FROM 
        selected_student_course_info
    WHERE 
        attempt_duration <= 3600
),

selected_student_course_time_info(student_id, lesson_id, step_id, step_position, rang, result, result_attempt_duration) AS (
    SELECT 
        student_id, 
        lesson_id, 
        step_id, 
        step_position,
        RANK() OVER (PARTITION BY step_id ORDER BY submission_time) AS rang, 
        result,
        CASE
            WHEN attempt_duration > 3600 THEN (SELECT avg_attempt_duration FROM avg_student_attempt_duration)
            ELSE attempt_duration
        END AS result_attempt_duration
    FROM 
        selected_student_course_info
)

SELECT
    st.student_name AS Студент,
    CONCAT(l.module_id, ".", l.lesson_position, ".", i.step_position) AS Шаг,
    i.rang AS Номер_попытки,
    i.result AS Результат,
    SEC_TO_TIME(CEIL(i.result_attempt_duration)) AS Время_попытки,
    ROUND((i.result_attempt_duration / (SUM(i.result_attempt_duration) OVER (PARTITION BY i.step_id)) * 100), 2) AS Относительное_время
 FROM 
     selected_student_course_time_info AS i
     JOIN student AS st USING(student_id)
     JOIN lesson AS l USING(lesson_id)
ORDER BY 
    step_id, 
    Номер_попытки;
