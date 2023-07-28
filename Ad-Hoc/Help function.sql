
--- Teradata Date Functions

SELECT CURRENT_DATE;        -- Output: 2018-06-07                           -- Возвращает текущую системную дату 
SELECT CURRENT_TIME;        -- Output: 23:48:59+00:00                       -- Возвращает текущее системное время с часовым поясом
SELECT CURRENT_TIMESTAMP;   -- Output: 2018-06-07 23:49:56.690000+00:00     -- Возвращает текущую системную дату и системное время с часовым поясом

SELECT NEXT_DAY (DATE '2018-06-09', 'MONSDAY');     -- Output: 2018-06-11   -- Возвращает следующую дату, которая эквивалентна указанному дню недели
SELECT NEXT_DAY (DATE '2018-06-12', 'TUESDAY');     -- Output: 2018-06-19
SELECT NEXT_DAY (DATE '2018-06-13', 'WEDNESDAY');   -- Output: 2018-06-20   -- ('MONSDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRISDAY', 'SATURDAY', 'SANDAY')

SELECT LAST_DAY (DATE '2018-06-07');    -- Output: 2018-06-30       -- Возвращает последний день месяца по указанной дате

SELECT ROUND (DATE '2018-05-16','RM');  -- Output: 2018-06-01       -- Возвращает округленную дату, поскольку дата была больше 15, дата округляется до следующего месяца 
SELECT ROUND (DATE '2018-05-15','RM');  -- Output: 2018-05-01

SELECT TRUNC (DATE '2016-11-18','RM');  -- Output: 2016-11-01       -- Возвращает усеченную дату до начала месяца

SELECT EXTRACT ( YEAR FROM TIMESTAMP '2018-06-01 12:15:19');        -- Output: 2018      -- Извлекает год, месяц, день, часы, минуты, секунды из указанной даты/времени
SELECT EXTRACT ( MONTH FROM TIMESTAMP '2018-06-01 12:15:19');       -- Output: 06
SELECT EXTRACT ( DAY FROM TIMESTAMP '2018-06-01 12:15:19');         -- Output: 09
SELECT EXTRACT ( DAY FROM DATE '96-11-09');                         -- Output: Error     -- Date not in Ansi format
SELECT EXTRACT ( DAY FROM DATE '2018-02-29');                       -- Output: Error     -- Invalid date/недопустимая дата
SELECT EXTRACT ( HOUR FROM TIMESTAMP '2018-06-09 12:15:19');        -- Output: 12
SELECT EXTRACT ( MINUTE FROM TIMESTAMP '2018-06-09 12:15:19');      -- Output: 15
SELECT EXTRACT ( SECOND FROM TIMESTAMP '2018-06-09 12:15:19');      -- Output: 19

SELECT TIMESTAMP'2016-11-09 12:15:19' + INTERVAL '1' SECOND;                    -- Output: 2016-11-09 12:15:20       -- adding 1 second -- Можно использовать для добавления/вычитания интервалов
SELECT TIMESTAMP'2016-11-09 12:15:19' - INTERVAL '1' MINUTE;                    -- Output: 2016-11-09 12:14:19       -- subracting 1 minute
SELECT TIMESTAMP'2016-11-09 12:15:19' + INTERVAL '2' HOUR;                      -- Output: 2016-11-09 14:15:19       -- adding 2 HOUR
SELECT TIMESTAMP'2016-11-09 12:15:19' - INTERVAL '1' DAY;                       -- Output: 2016-11-08 12:15:19       -- subracting 1 Day
SELECT TIMESTAMP'2016-11-09 12:15:19' + INTERVAL '3' MONTH;                     -- Output: 2017-02-09 12:15:19       -- adding 3 Month
SELECT TIMESTAMP'2016-11-09 12:15:19' + INTERVAL '2' YEAR;                      -- Output: 2018-11-09 12:15:19       -- adding 2 Years
SELECT TIMESTAMP'2016-11-09 12:15:19' + INTERVAL '12:30:15' HOUR TO SECOND;     -- Output: 2016-11-10 00:45:34       -- adding 12:30:15 to the timestamp
SELECT 10000* Interval '1' SECOND;                                              -- Output: *** Failure 7453 Interval field overflow   -- Interval fields can hold upto 4 digits only
SELECT CAST ((9999* Interval '1' SECOND) AS INTERVAL HOUR TO MINUTE);           -- Output: 2:46                      -- Conveting number to time interval
SELECT CAST ((36600* Interval '00:00:01' HOUR TO SECOND) AS INTERVAL HOUR TO MINUTE);               -- Output: 10:10
SELECT (CURRENT_TIMESTAMP(0) - CAST('2016-11-06 12:15:19' AS TIMESTAMP(0))) hour(4) to second(4);   -- Output: 18:02:17.0000 --Subtracting 2 timestamps

SELECT CAST(TIMESTAMP'2016-11-12 14:32:45' AS FORMAT 'yyyy-mm-ddbhh:mi:ssBt');  -- Output: 2016-11-12 02:32:45 PM   -- Displaying AM/PM using 'T' -- 'B' is used for space.
SELECT '2016-11-12 14:32:45' (format 'E4,BDDB M4,YYYYBHH:MI:SSBT');             -- Output: *** Failure 3527 Format string 'E3,BDDBM3,YYYYBHH:MI:SS' has combination of  numeric, character  and GRAPHIC values -- Need to cast timestamp explicitly if string 
SELECT TIMESTAMP'2016-11-12 14:32:45' (format 'E4,BDDB M4,YYYYBHH:MI:SSBT');    -- Output: Saturday, 12 November,2016 02:32:45 PM -- E4 used to show full day name -- M4 used to show full month name
SELECT TIMESTAMP'2016-11-12 14:32:45' (format 'E3,BDDB M3,YYYYBHH:MI:SS');      -- Output: Sat, 12 Nov,2016 14:32:45  -- E3 used to show short day name -- M3 used to show short month name 
SELECT CAST('2016-11-12' AS DATE) (format 'dd/mm/yyyy');                        -- Output: 12/11/2016 --Default format is YYYY-MM-DD

sel current_date - date'2010-03-08' month;
sel months_between (date '2010-03-01',trunc (current_date,'mm')); 

--- Teradata String Functions

SELECT LOWER ('TERAData');               -- Output: teradata            -- Изменяет строку на нижний регистр
SELECT UPPER ('TERAData');               -- Output: TERADATA            -- Изменяет строку на верхний регистр
SELECT INITCAP ('tERAData learning');    -- Output: Teradata Learning   -- Изменяет каждый начальный символ на верхний регистр
SELECT LENGTH ('TERAData');              -- Output: 8                   -- Возвращает кол-во символов в строке
SELECT POSITION ('D' IN 'TERADATA');     -- Output: 5                   -- Возвращает позицию символа в строке
SELECT INDEX ('TERADATA','D');           -- Output: 5                   -- Возвращает позицию символа в строке
SELECT INSTR ('TERADATA','A',1,2);       -- Output: 6                   -- Возвращает позицию символа, в зависимости от места входа
SELECT INSTR ('TERADATA','A');           -- Output: 4
SELECT SUBSTR ('TERADATA',3,4);          -- Output: RADA                -- Извлекает указанные символы из строки

SELECT (COALESCE(2,1)) * 5;         -- 1 значение что меняем если null, 2 значение на что меняем
SELECT (COALESCE(null,1)) * 5;      -- если число (даже 0) то не меняется, если NULL то меняется на второе значение

SELECT SUBSTRING ('TERADATA' from 5 for 4);  -- Output: DATA            -- Извлекает указанные символы из строки
SELECT TRIM ('    TERADATA    ');            -- Output: TERADATA        -- Обрезает пробелы или конкретные символы от начала или конца строки
SELECT TRIM (TRAILING FROM '  TERADATA   '); -- Output: '  TERADATA'    -- Trims from right sides
SELECT TRIM (LEADING FROM '  TERADATA   ');  -- Output: 'TERADATA   '   -- Trims from left sides
SELECT TRIM (LEADING '0' FROM '00033');      -- Output: '33'            -- Trims starting '0' from string

SELECT LTRIM ('  TERADATA   ');              -- Output: 'TERADATA   '   -- Обрезает пробелы или конкретные символы с левой стороны
SELECT LTRIM ('00033','0');                  -- Output: '33'
SELECT RTRIM ('  TERADATA   ');              -- Output: '  TERADATA'    -- Обрезает пробелы или конкретные символы с правой стороны
SELECT RTRIM ('00033','3');                  -- Output: '000'

SELECT OREPLACE ('Teradata support high volume of data','data','byte'); -- Output: Terabyte support high volume of byte     -- Производит замену каждого вхождения в строке
SELECT OTRANSLATE ('Speak Less','pka','lpe');                           -- Output: Sleep Less                               -- Characters 'p' & 'k' are replaced with 'l' and 'p' respectively
SELECT OTRANSLATE ('Slice','Sl','D');                                   -- Output: Dice                                     -- Characters 'S' is replaced with 'D', аnd extra character 'l' in from_string is removed from source string

SELECT LPAD ('Teradata',10);            -- Output: '  Teradata'     -- Возвращает строку влево, что бы она имела заданную длину
SELECT LPAD ('Teradata',11,'I<3');      -- Output: 'I<3Teradata'
SELECT LPAD ('Teradata',5,'I<3');       -- Output: 'Terad'

SELECT RPAD ('Teradata',10);            -- Output: 'Teradata  ' -- Возвращает строку вправо, что бы она имела заданную длину
SELECT RPAD ('Teradata',11,'<3u');      -- Output: 'Teradata<3u'
SELECT RPAD ('Teradata',5,'<3u');       -- Output: 'Terad'

--- Teradata Numeric Functions

SELECT ZEROIFNULL (NULL);   -- Output: 0        -- Возвращает 0, если аргумент равен NULL
SELECT NULLIFZERO (0);      -- Output: NULL     -- Возвращает NULL, если аргумент равен 0


SELECT SQRT (81);           -- Output: 9        -- Возвращает квадратный корень из заданного числа

SELECT ABS (500);           -- Output: 500      -- Возвращает абсолютное значение числа
SELECT ABS (-500);          -- Output: 500
SELECT ABS (+500);          -- Output: 500

SELECT LOG (100);           -- Output: 2.00000000000000E 000    -- Возвращает логарифм заданного числа
 
SELECT ROUND (35.222,1);    -- Output: 35.200   -- Возвращает округленное значение числа до заданного значения
SELECT ROUND (10.23,0);     -- Output: 10.00
SELECT ROUND (10.63,0);     -- Output: 11.00
SELECT ROUND (65.63,-2);    -- Output: 100.00
SELECT ROUND (65.63,-3);    -- Output: 0.00

SELECT FLOOR (55.63);       -- Output: 55.00    -- Возвращает наибольшое целое число
SELECT FLOOR (-55.63);      -- Output: -56.00

SELECT CEILING (55.63);     -- Output: 56.00    -- возвращает наименьшее целое число
SELECT CEILING (-55.63);    -- Output: -55.00

SELECT LEAST (2,12,434,21,543,243,111) smaller_num;         -- Output: 2        -- Возвращает наименьшее число
SELECT GREATEST (2,12,434,21,543,243,111) smaller_num;      -- Output: 543      -- Возвращает наибольшее число

SELECT LEAST (cast(timestamp'2019-01-01 00:00:05' as timestamp), cast(timestamp'2019-01-01 00:00:00' as timestamp));
SELECT GREATEST (timestamp'2019-01-01 00:00:05', timestamp'2019-01-01 00:00:00');

select cast(timestamp'2019-01-01 00:00:05' as decimal(19,0));
select cast(date '2019-01-01' as int);


select timestamp'2019-01-01 00:00:05' - timestamp'2019-01-01 00:00:05' second

SELECT LEAST(CAST('2019-01-01 00:00:05' AS TIMESTAMP WITH TIME ZONE), CAST('2019-01-01 00:00:00' AS TIMESTAMP WITH TIME ZONE));


