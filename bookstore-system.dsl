workspace {
    model {
        # People/Actors
        # <variable> = person <name> <description> <tag>
        publicUser = person "Public User" "An anonymous user of the bookstore" "User"
        authorizedUser = person "Authorized User" "A registered user of the bookstore, with personal account" "User"
        internalUser = person "Internal User" "A staff working in bookstore, with internal account" "User"


        # Level 1: Software Systems
        # <variable> = softwareSystem <name> <description> <tag>
        bookstoreSystem = softwareSystem "iBookstore System of Chau" "Allows users to view about book, and administrate the book details" "Target System" {
            # Level 2: Containers
            # <variable> = container <name> <description> <technology> <tag>
            frontStoreApp = container "Front-store Application" "Provide all the bookstore functionalities to both public and authorized users" "Javascript & ReactJS"
            backOfficeApp = container "Back-office Application" "Provide all the bookstore administration functionalities to internal users" "JavaScript & ReactJS"
            searchWebApi = container "Search Web API" "Allows only authorized users searching books records via HTTPS API" "Go"
            searchDatabase = container "Search Database" "Stores searchable book information" "ElasticSearch" "Database"
            publicWebApi = container "Public Web API" "Allows public users getting books information" "Go"
            adminWebApi = container "Admin Web API" "Allows only authorized users administering books details via HTTPS API" "Go" {
                # Level 3: Component
                # <variable> = component <name> <description> <technology> <tag>
                bookService = component "Book Service" "Allow administrating book details" "Go"
                authService = component "Authorizer" "Authorize users by using external Authorization System" "Go"
                bookEventPublisher = component "Book Events Publisher" "Publishes books-related events to Events Publisher" "Go"
            }
            bookstoreDatabase = container "Bookstore Database" "Stores book details" "PostgreSQL" "Database"
            bookEventStream = container "Book Event Stream" "Handles book-related domain events" "Apache Kafka 3.0"
            bookSearchEventConsumer = container "Book Search Event Consumer" "Listening to domain events and write publisher to Search Database for updating" "Go"
            publisherRecurrentUpdater = container "Publisher Recurrent Updater" "Listening to external events from Publisher System, and update book information" "Go"
        }

        # External Software Systems
        authSystem = softwareSystem "Authorization System" "The external Identiy Provider Platform" "External System"
        publisherSystem = softwareSystem "Publisher System" "The 3rd party system of publishers that gives details about books published by them" "External System"
        shippingSystem = softwareSystem "Shipping System" "The 3rd party system of delivery that handles delivery process to customers" "External System"

        # Relationship between People and Software Systems
        # <variable> -> <variable> <description> <protocol>
        publicUser -> bookstoreSystem "View book information"
        authorizedUser -> bookstoreSystem "Search book with more details, administrate books and their details"
        internalUser -> bookstoreSystem "Manage books, registered users and others in bookstore"
        bookstoreSystem -> authSystem "Register new user, and authorize user access"
        publisherSystem -> bookstoreSystem "Publish events for new book publication, and book information updates" {
            tags "Async Request"
        }
        bookstoreSystem -> shippingSystem "Create invoice and deliver order to customer"

        # Relationship between Containers
        frontStoreApp -> publicWebApi "View book information" "JSON/HTTPS"
        frontStoreApp -> searchWebApi "Search book with more details" "JSON/HTTPS"
        publicUser -> frontStoreApp "Access and use"
        authorizedUser -> frontStoreApp "Access and use"
        backOfficeApp -> adminWebApi "Administrate books and purchases" "JSON/HTTPS"
        internalUser -> backOfficeApp "Access and use"
        searchWebApi -> searchDatabase "Retrieve book search data" "ODBC"
        bookSearchEventConsumer -> searchDatabase "Handle and write book data search" "ODBC"
        publicWebApi -> bookstoreDatabase "Read/Write book detail data" "ODBC"
        adminWebApi -> bookstoreDatabase "Read/Write book detail data" "ODBC"
        adminWebApi -> bookEventStream "Publish book update events" {
            tags "Async Request"
        }
        bookEventStream -> bookSearchEventConsumer "Handle the book published event and forward to"
        publisherRecurrentUpdater -> adminWebApi "Makes API calls to update data" "JSON/HTTPS"

        # Relationship between Containers and External System
        searchWebApi -> authSystem "Authorize user" "JSON/HTTPS"
        adminWebApi -> authSystem "Authorize internal user" "JSON/HTTPS"
        publisherSystem -> publisherRecurrentUpdater "Consume book publication update events" {
            tags "Async Request"
        }

        # Relationship between Components
        bookService -> authService "Uses"
        bookService -> bookEventPublisher "Uses"

        # Relationship between Components and Other Containers
        bookService -> bookstoreDatabase "Read/Write book detail data" "ODBC"
        backOfficeApp -> bookService "Administrate book details" "JSON/HTTPS"
        authService -> authSystem "Authorize the internal users" "JSON/HTTPS"
        bookEventPublisher -> bookEventStream "Publish book-related events" {
            tags "Async Request"
        }
        publisherRecurrentUpdater -> bookService "Makes API calls to" "JSON/HTTPS"
    }

    views {
        # Level 1
        systemContext bookstoreSystem "SystemContext" {
            include *
            # default: tb,
            # support tb, bt, lr, rl
            autoLayout tb
        }

        # Level 2
        container bookstoreSystem "Containers" {
            include *
            autoLayout
        }

        # Level 3
        component adminWebApi "Components" {
            include *
            autoLayout
        }



        styles {
            element "Software System" {
                background #1168bd
                color #ffffff
            }
            element "User" {
                shape person
                background #08427b
                color #ffffff
            }
            element "External System" {
                background #999999
                color #ffffff
            }
            relationship "Relationship" {
                dashed false
            }
            relationship "Async Request" {
                dashed true
            }
            element "Database" {
                shape Cylinder
                background #33CC99
            }
        }
    }
}