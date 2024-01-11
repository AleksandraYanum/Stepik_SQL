/*
Вычислить рейтинг каждого студента относительно студента, прошедшего наибольшее количество шагов в модуле (вычисляется как отношение количества пройденных 
студентом шагов к максимальному количеству пройденных шагов, умноженное на 100). Вывести номер модуля, имя студента, количество пройденных им шагов и относительный 
рейтинг. Относительный рейтинг округлить до одного знака после запятой. Столбцы назвать Модуль, Студент, Пройдено_шагов и Относительный_рейтинг  соответственно. 
Информацию отсортировать сначала по возрастанию номера модуля, потом по убыванию относительного рейтинга и, наконец, по имени студента в алфавитном порядке.
*/

WITH
student_step_amount_passed(student_id, module_id, step_amount) AS (
    SELECT
        ss.student_id,
        l.module_id,
        COUNT(DISTINCT ss.step_id) AS step_amount
    FROM 
        step_student AS ss
        JOIN step AS s USING(step_id)
        JOIN lesson AS l USING(lesson_id)
    WHERE 
        ss.result = 'correct'
    GROUP BY
        ss.student_id,
        l.module_id
)

SELECT  
    sta.module_id AS Модуль, 
    s.student_name AS Студент, 
    sta.step_amount AS Пройдено_шагов,
 	ROUND(sta.step_amount / MAX(sta.step_amount) OVER(PARTITION BY sta.module_id) * 100, 1) AS Относительный_рейтинг
FROM 
    student_step_amount_passed AS sta 
	JOIN student AS s USING(student_id)

ORDER BY 
    Модуль, 
    Относительный_рейтинг DESC, 
    Студент
