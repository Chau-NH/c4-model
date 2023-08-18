workspace extends ../bookstore-system.dsl {
    model {
        # Deployment
        prodEnvironment = deploymentEnvironment "Production" {
            deploymentNode "AWS" {
                tags "Amazon Web Services - Cloud"

                route53 = infrastructureNode "Route 53" {
                    tags "Amazon Web Services - Route 53"
                }

                deploymentNode "ap-southeast-1" {
                    tags "Amazon Web Services - Region"

                    deploymentNode "VPC" {
                        tags "Amazon Web Services - VPC"
                        appLoadBalancer = infrastructureNode "Application Load Balancer" {
                            tags "Amazon Web Services - Elastic Load Balancing ELB Application load balancer"
                        }

                        deploymentNode "EKS" {
                            tags "Amazon Web Services - Elastic Kubernetes Service"

                            deploymentNode "private-subnet-a" {
                                tags "Amazon Web Services - VPC subnet private"
                                deploymentNode "ec2-a" {
                                    tags "Amazon Web Services - EC2 Instance"

                                    backOfficeAppInstance = containerInstance backOfficeApp
                                    searchWebApiInstance = containerInstance searchWebApi
                                    adminWebApiInstance = containerInstance adminWebApi
                                    publicWebApiInstance = containerInstance publicWebApi
                                    publisherRecurrentUpdateInstance = containerInstance publisherRecurrentUpdater
                                }
                            }

                            deploymentNode "private-subnet-b" {
                                tags "Amazon Web Services - VPC subnet private"

                                deploymentNode "PostgreSQL RDS" {
                                    tags "Amazon Web Services - RDS"
                                    containerInstance bookstoreDatabase
                                }
                                deploymentNode "AWS OpenSearch" {
                                    tags "Amazon Web Services - Elasticsearch Service"
                                    containerInstance searchDatabase
                                }
                                deploymentNode "ec2-b" {
                                    tags "Amazon Web Services - EC2 Instance"

                                    containerInstance bookSearchEventConsumer
                                    containerInstance bookEventStream
                                }
                            }
                            
                        }
                    }
                    cloudFront = infrastructureNode "CloudFront" {
                        tags "Amazon Web Services - CloudFront"
                    }
                    deploymentNode "S3" {
                        tags "Amazon Web Services - Simple Storage Service S3 Bucket"
                        frontStoreAppInstance = containerInstance frontStoreApp 
                    }
                }
            }
            route53 -> appLoadBalancer
            route53 -> cloudFront
            cloudFront -> frontStoreAppInstance "Forwards requests to" "[HTTPS]"
            appLoadBalancer -> backOfficeAppInstance "Forwards requests to" "[HTTPS]"
            appLoadBalancer -> publicWebApiInstance "Forwards requests to" "[HTTPS]"
            appLoadBalancer -> searchWebApiInstance "Forwards requests to" "[HTTPS]"
            appLoadBalancer -> adminWebApiInstance "Forwards requests to" "[HTTPS]"
        }

        developer = person "Developer" "Internal bookstore platform developer" "User"
        deployWorkflow = softwareSystem "CI/CD Workflow" "Workflow CI/CD for deploying system using AWS Services" "Target System" {
            repository = container "Code Repository" "GitHub"
            pipeline = container "Code PipeLine" {
                tags "Amazon Web Services - CodePipeline" "Dynamic Element"
            }
            codeBuilder = container "Code Build" {
                tags "Amazon Web Services - EC2 Container Registry" "Dynamic Element"
            }
            containerRegistry = container "Amazon ECR" {
                tags "Amazon Web Services - EC2 Container Registry" "Dynamic Element"
            }
            cluster = container "Amazon EKS" {
                tags "Amazon Web Services - Elastic Kubernetes Service" "Dynamic Element"
            }
        }

        developer -> repository
        repository -> pipeline
        pipeline -> codeBuilder
        codeBuilder -> containerRegistry
        codeBuilder -> pipeline
        pipeline -> cluster
    }

    views {
        # deployment <software-system> <environment> <key> <description>
        deployment bookstoreSystem prodEnvironment "Deploy-PROD"  "Cloud Architecture for Bookstore Platform using AWS Services" {
            include *
            autoLayout lr
        }

        dynamic deployWorkflow "Dynamic-WF" "Bookstore platform deployment workflow" {
            developer -> repository "Commit, and push change"
            repository -> pipeline "Trigger pipeline job"
            pipeline -> codeBuilder "Download source code and start build process"
            codeBuilder -> containerRegistry "Upload Docker image with unique tag"
            codeBuilder -> pipeline "Return the build result"
            pipeline -> cluster "Deploy container"
            autoLayout lr
        }
        # dynamic <container> <name> <description>

        theme "https://static.structurizr.com/themes/amazon-web-services-2020.04.30/theme.json"

        styles {
            element "Dynamic Element" {
                background #ffffff
            }
        }
    }
}