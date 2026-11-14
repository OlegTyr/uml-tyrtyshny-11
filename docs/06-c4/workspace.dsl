workspace "Система автоматического тестирования" "Учебная модель" {

    model {
        dev = person "Разработчик" "Запускает тесты, смотрит отчёты"
        admin = person "Администратор" "Настраивает расписание, размечает флаки"

        ci = softwareSystem "CI-система" "Триггерит прогоны" "External"
        notify = softwareSystem "Система уведомлений" "Slack / почта" "External"

        testing = softwareSystem "Система автоматического тестирования" {
            web = container "Веб-интерфейс" "Запуск тестов, отчёты" "React"
            api = container "Backend API" "Бизнес-логика, REST" "Kotlin, Spring Boot" {
                runCtrl = component "RunController" "REST-эндпоинты прогонов" "Spring MVC"
                runSvc = component "RunService" "Управление прогонами" "Kotlin"
                flakyPolicy = component "FlakyPolicy" "Определение флаки" "Kotlin"
                repo = component "JPA Repositories" "Доступ к данным" "Spring Data"
            }
            scheduler = container "Планировщик" "Запуск по расписанию" "Kotlin"
            agent = container "Runner-агент" "Выполняет тесты" "Go"
            db = container "Основная БД" "Прогоны, результаты" "PostgreSQL" "Database"
            bus = container "Очередь событий" "События прогонов" "RabbitMQ" "Queue"
        }

        dev -> web "Пользуется" "HTTPS"
        admin -> web "Пользуется" "HTTPS"
        ci -> api "Запускает прогоны" "REST/HTTPS"
        web -> api "Вызывает" "JSON/HTTPS"
        api -> db "Читает и пишет" "JDBC"
        api -> bus "Публикует события" "AMQP"
        bus -> agent "Доставляет задания" "AMQP"
        agent -> api "Передаёт результаты" "JSON/HTTPS"
        bus -> scheduler "Доставляет события" "AMQP"
        scheduler -> api "Триггерит прогоны" "JSON/HTTPS"
        api -> notify "Отправляет уведомления" "HTTPS"

        web -> runCtrl "POST /runs" "JSON/HTTPS"
        runCtrl -> runSvc "вызывает"
        runSvc -> flakyPolicy "использует"
        runSvc -> repo "использует" "JDBC"
    }

    views {
        systemContext testing "Context" {
            include *
            autolayout lr
        }

        container testing "Containers" {
            include *
            autolayout lr
        }

        component api "Components" {
            include *
            autolayout lr
        }

        //theme default
    }
}