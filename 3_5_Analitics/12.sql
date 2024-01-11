/*
Online курс обучающиеся могут проходить по различным траекториям, проследить за которыми можно по способу решения ими заданий шагов курса. Большинство обучающихся за несколько попыток  получают правильный ответ 
и переходят к следующему шагу. Но есть такие, что остаются на шаге, выполняя несколько верных попыток, или переходят к следующему, оставив нерешенные шаги.

Выделив эти "необычные" действия обучающихся, можно проследить их траекторию работы с курсом и проанализировать задания, для которых эти действия выполнялись, а затем их как-то изменить. 

Для этой цели необходимо выделить группы обучающихся по способу прохождения шагов:

I группа - это те пользователи, которые после верной попытки решения шага делают неверную (скорее всего для того, чтобы поэкспериментировать или проверить, как работают примеры);
II группа - это те пользователи, которые делают больше одной верной попытки для одного шага (возможно, улучшают свое решение или пробуют другой вариант);
III группа - это те пользователи, которые не смогли решить задание какого-то шага (у них все попытки по этому шагу - неверные).
Вывести группу (I, II, III), имя пользователя, количество шагов, которые пользователь выполнил по соответствующему способу. Столбцы назвать Группа, Студент, Количество_шагов. Отсортировать информацию по возрастанию номеров групп, потом по убыванию количества шагов и, наконец, по имени студента в алфавитном порядке.
*/

WITH
multiple_correct_attempt_student(student_id, step_id) AS (  
    SELECT 
        student_id, 
        step_id
    FROM 
        step_student
    WHERE 
        result = "correct"
    GROUP BY 
        student_id,
        step_id
    HAVING COUNT(result) > 1
),

student_group_2(group_name, student_id, step_amount) AS (
    SELECT
        'II' AS group_name,
        student_id,
        COUNT(step_id) AS step_amount
    FROM
        multiple_correct_attempt_student
    GROUP BY
        student_id   
),

student_step_int_result(student_id, step_id, int_result) AS (
    SELECT 
        student_id, 
        step_id,
        CASE 
            WHEN result = "wrong" THEN 0 ELSE 1 
        END AS new_result
    FROM 
        step_student
),

student_step_sum_result(student_id, step_id, sum_result) AS (
    SELECT
        student_id, 
        step_id, 
        SUM(int_result) OVER (PARTITION BY student_id, step_id) AS sum_result
    FROM 
        student_step_int_result
),

student_group_3(group_name, student_id, step_amount) AS (
    SELECT
        'III' AS group_name,
        student_id,
        COUNT(DISTINCT step_id) AS step_amount
    FROM
        student_step_sum_result
    WHERE
        sum_result = 0
    GROUP BY
        student_id
        
),

wrong_after_correct_result_info(student_id, step_id, is_wrong_after_correct_result) AS (
    SELECT 
        student_id, 
        step_id, 
        IF(
            result = "correct" 
            AND submission_time < MAX(submission_time) OVER (
                PARTITION BY 
                    student_id, 
                    step_id
                ), 
                IF(
                    LEAD(result) OVER (
                        PARTITION BY 
                            student_id, 
                            step_id 
                        ORDER BY 
                            submission_time
                      ) = "wrong", 
                      1, 
                      0
                ), 
            0
          ) AS is_wrong_after_correct_result
    FROM
        step_student
),

student_group_1(group_name, student_id, step_amount) AS (
    SELECT
        'I' AS group_name,
        student_id,
       COUNT(step_id) AS step_amount
    FROM 
        wrong_after_correct_result_info
    WHERE 
        is_wrong_after_correct_result = 1
    GROUP BY
        student_id
), 

all_group_info(group_name, student_id, step_amount) AS (
    SELECT
        group_name, 
        student_id,
        step_amount
    FROM 
        student_group_1 
    
    UNION ALL
    
    SELECT
        group_name, 
        student_id,
        step_amount
    FROM 
        student_group_2
    
    UNION ALL

    SELECT
        group_name, 
        student_id,
        step_amount
    FROM 
        student_group_3 
)

SELECT 
    g.group_name AS Группа, 
    st.student_name AS Студент, 
    g.step_amount AS Количество_шагов
FROM
    all_group_info AS g
    JOIN student AS st USING(student_id)
ORDER BY 
    Группа, 
    Количество_шагов DESC, 
    Студент;


/*
SELECT 
    student_id,
    step_id
FROM 
    step_student 
GROUP BY 
    student_id, step_id
HAVING SUM(IF(result = 'wrong', 0, 1)) = 0 
*/
