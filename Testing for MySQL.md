## Варіант 18

## Узагальнення

SQL Injection уразливості виникають, коли вхідні дані використовуються при побудові SQL-запиту без належного обмеження або перевірки на безпеку. Використання динамічного SQL (побудова SQL-запитів шляхом конкатенації рядків) відкриває шлях до цих уразливостей. SQL-ін'єкція дозволяє зловмиснику отримати доступ до SQL-серверів. Вона дозволяє виконувати SQL-код під привілеями користувача, що використовується для підключення до бази даних.

Сервер MySQL має декілька особливостей, тому деякі експлойти повинні бути спеціально налаштовані для цієї програми. Це і є темою цього розділу.
## Цілі тестування

Коли в додатку, що використовує базу даних MySQL, знаходять уразливість до SQL-ін'єкцій, існує ряд атак, які можуть бути виконані в залежності від версії MySQL та привілеїв користувача до СУБД.

MySQL має щонайменше чотири версії, які використовуються у всьому світі: **3.23.x, 4.0.x, 4.1.x** та **5.0.x.** Кожна версія має набір функцій, пропорційний номеру версії.

Починаючи з версії 4.0: UNION
Починаючи з версії 4.1: Підзапити
Починаючи з версії 5.0: Збережені процедури, Збережені функції та подання з назвою **INFORMATION_SCHEMA**.
Починаючи з версії 5.0.2: Тригери
Слід зазначити, що для версій MySQL до 4.0.x можна було використовувати лише логічні атаки або атаки типу "сліпа ін'єкція" на основі часу, оскільки функціонал підзапитів або оператори **UNION** не були реалізовані.

Надалі будемо вважати, що існує класична SQL ін'єкція, яка може бути викликана запитом, подібним до того, що описаний в розділі Тестування на SQL ін'єкцію.

**http://www.example.com/page.php?id=2**
### Проблема одинарних лапок
Перш ніж скористатися можливостями MySQL, слід врахувати, як рядки можуть бути представлені в операторі, оскільки часто веб-додатки екранують одинарні лапки.

В MySQL лапки екрануються наступним чином:

**'Рядок з лапками\''**.

Тобто MySQL інтерпретує приховані апострофи **\'** як символи, а не як метасимволи.

Тому, якщо для коректної роботи додатку потрібно використовувати константні рядки, слід розрізняти два випадки:

Веб-додаток використовує одинарні лапки **'** => **\'**
Веб-додаток не використовує одинарні лапки **'** => **'**
В MySQL існує стандартний спосіб обійти необхідність використання одинарних лапок - створити константний рядок, який буде оголошено без необхідності використання одинарних лапок.

Припустимо, ми хочемо дізнатися значення поля з ім'ям **password** у записі, з умовою на кшталт наступної:

пароль має вигляд **'A%'**.
ASCII-значення у вигляді конкатенованого шістнадцяткового числа: password LIKE **0x4125**
Функція char(): **пароль LIKE CHAR(65,37)**
### Багаторазові змішані запити
Коннектори бібліотеки MySQL не підтримують декілька запитів, розділених символами **;**, тому неможливо виконати декілька неоднорідних SQL-команд в одну уразливість, як в Microsoft SQL Server.

Наприклад, наступна ін'єкція призведе до помилки:

_**1 ; update tablename set code='javascript code' where 1 --**_

## Збір інформації
### Зняття відбитків MySQL
Звичайно, перше, що потрібно знати, це чи є СУБД MySQL в якості внутрішньої бази даних. Сервер MySQL має функцію, яка дозволяє іншим СУБД ігнорувати речення на діалекті MySQL. Коли блок коментарів __**'/* */'**_ містить знак оклику **'/*! sql here*/'**, він інтерпретується MySQL, а іншими СУБД розглядається як звичайний блок коментарів, як пояснюється в посібнику з MySQL.

Приклад:

1 **/*! і 1=0 */**

Якщо MySQL присутня, буде інтерпретовано речення всередині блоку коментарів.

#### Версія
Отримати цю інформацію можна трьома способами:

- За допомогою глобальної змінної **@@version**.
- За допомогою функції VERSION()
- За допомогою використання відбитків коментарів з номером версії **/*!40110 і 1=0*/**
що означає

   _**f(version >= 4.1.10)
   add 'and 1=0' to the query.**_.


Вони еквівалентні, оскільки результат буде однаковим.

У режимі введення діапазону:

**1 AND 1=0 UNION SELECT @@version /***

Інференційна ін'єкція:

**1 AND @@version like '4.0%'**.

Відповідь буде містити щось на кшталт

**5.0.22-log**.

### Користувач для входу
Існує два типи користувачів, на яких працює MySQL Server.

- USER(): користувач, підключений до сервера MySQL.
- CURRENT_USER(): внутрішній користувач, який виконує запит.
Між 1 і 2 є деякі відмінності. Основна полягає в тому, що анонімний користувач може підключатися (якщо це дозволено) з будь-яким ім'ям, а внутрішній користувач MySQL - це порожнє ім'я (''). Інша відмінність полягає в тому, що збережена процедура або збережена функція виконуються від імені користувача-творця, якщо він не оголошений деінде. Це можна дізнатися за допомогою **CURRENT_USER.**.

В ін'єкції діапазону

**1 І 1=0 UNION SELECT USER()**

Інференційна ін'єкція:

**1 AND USER() like 'root%'**.

Відповідь буде містити щось на кшталт

**user@hostname**

### Ім'я бази даних, що використовується
Існує нативна функція **DATABASE()**

В ін'єкції діапазону:

**1 ТА 1=0 UNION SELECT DATABASE()**

Інференційна ін'єкція:

**1 AND DATABASE() like 'db%'** Очікуваний результат, рядок на кшталт 'db%'.

Очікуваний результат, Рядок на зразок цього:

_**dbname**_

### INFORMATION_SCHEMA
У MySQL 5.0 було створено подання INFORMATION_SCHEMA. Воно дозволяє нам отримати всю інформацію про бази даних, таблиці та стовпці, а також процедури та функції.

| Tables_in_INFORMATION_SCHEMA | DESCRIPTION                               |
|------------------------------|-------------------------------------------|
| SCHEMATA                     | Усі бази даних, на які користувач має (принаймні) SELECT_priv |
| SCHEMA_PRIVILEGES            | Привілеї, які користувач має для кожної БД |
| TABLES                       | Усі таблиці, на які користувач має (принаймні) SELECT_priv |
| TABLE_PRIVILEGES             | Привілеї, які користувач має для кожної таблиці |
| COLUMNS                      | Усі стовпці, на які користувач має (принаймні) SELECT_priv |
| COLUMN_PRIVILEGES            | Привілеї, які користувач має для кожного стовпця |
| VIEWS                        | Усі відображення, на які користувач має (принаймні) SELECT_priv |
| ROUTINES                     | Процедури та функції (потрібний EXECUTE_priv) |
| TRIGGERS                     | Тригери (потрібний INSERT_priv) |
| USER_PRIVILEGES              | Привілегії, що має підключений користувач |

## Вектори атаки
### Запис у файл
Якщо підключений користувач має привілеї **FILE** і одинарні лапки не екрануються, то речення **into outfile** можна використовувати для експорту результатів запиту у файл.

**Select * from table into outfile '/tmp/file'**

Зауважте: не існує способу обійти одинарні лапки, що оточують ім'я файлу. Тому, якщо є певна перевірка одинарних лапок, наприклад, escape **\'**, то не буде можливості використати речення **into outfile**.

Цей тип атаки може бути використаний як позасмугова техніка для отримання інформації про результати запиту або для запису файлу, який може бути виконаний всередині каталогу веб-сервера.

Приклад:

**1 limit 1 into outfile '/var/www/root/test.jsp' FIELDS ENCLOSED BY '//'  LINES TERMINATED BY '\n<%jsp code here%>';**
Результати зберігаються у файлі з привілеями **rw-rw-rw**, що належать користувачу та групі MySQL.

Де **/var/www/root/test.jsp** буде містити:

**//field values// <%jsp code here%>**

### Читання з файлу
**load_file** є власною функцією, яка може читати файл, якщо це дозволено правами файлової системи. Якщо підключений користувач має привілеї **FILE**, вона може бути використана для отримання вмісту файлів. Захист від витікання одинарних лапок можна обійти за допомогою раніше описаних методів.

**load_file('filename')**

- Весь файл буде доступним для експорту стандартними методами.

### Стандартна атака через SQL ін'єкцію
При стандартній SQL-ін'єкції результати можуть відображатися безпосередньо на сторінці як звичайний вивід або як помилка MySQL. Використовуючи вже згадані атаки SQL Injection і вже описані можливості MySQL, пряме введення SQL можна легко виконати на рівні глибини, що залежить, в першу чергу, від версії MySQL, з якою працює пентестер.

Хороша атака полягає в тому, щоб дізнатися результати, змусивши функцію/процедуру або сам сервер згенерувати помилку. Список помилок, які видає MySQL і, зокрема, вбудовані функції, можна знайти в MySQL Manual.

### Позамережеве введення SQL-коду
Позамежову ін'єкцію можна виконати, використовуючи речення **into outfile**.

**load_file('filename')**

### Сліпа ін'єкція SQL
Для сліпої SQL-ін'єкції існує набір корисних функцій, що надаються сервером MySQL.

Довжина рядка:
**LENGTH(str)**
Витягнути підрядок із заданого рядка:
**SUBSTRING(string, offset, #chars_returned)**
Сліпа ін'єкція на основі часу:
**BENCHMARK(#ofcycles,action_to_be_performed)** Функція бенчмарку може бути використана для виконання атак за часом, коли сліпе введення булевих значень не дає жодних результатів. Див. **SLEEP()** (MySQL > 5.0.x) для альтернативи бенчмарку.
Повний список можна знайти в посібнику з MySQL

## Як тестувати