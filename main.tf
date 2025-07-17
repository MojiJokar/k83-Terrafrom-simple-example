locals {
 datascientest-wordpress = {
   App = "datascientest-wordpress"
   Tier = "frontend"
 }
 datascientest-mysql = {
   App = "datascientest-wordpress"
   Tier = "mysql"
 }
}

# hard code just for  sake of practise ! in real we hide them in different ways
resource "kubernetes_secret" "datascientest-mysql-password" {
 metadata {
   name = "datascientest-mysql-password"
 }
 data = {
   password = "Datascientest123@" # password value will be Datascientest123@
 }
}

resource "kubernetes_secret" "datascientest-mysql-user" {
 metadata {
   name = "datascientest-mysql-user"
 }
 data = {
   user = "root" # le user aura pour valeur root
 }
}

# wordpress deployement
resource "kubernetes_deployment" "datascientest-wordpress" {
 metadata {
   name = "datascientest-wordpress"
   labels = local.datascientest-wordpress # retrieves the values declared in the datascientest-wordpress variable
 }
 spec {
   replicas = 1 # number of replicas
   selector {
     match_labels = local.datascientest-wordpress
   }
   template {
     metadata {
       labels = local.datascientest-wordpress
     }
     spec {
       container {
         image = "wordpress:4.8-apache" # image to use for wordpress deployment
         name = "datascientest-wordpress"
         port {
           container_port = 80
         }
         env { # declaration of environment variables
           name = "WORDPRESS_DB_HOST"
           value = "mysql-service"
         }
         env {
           name = "WORDPRESS_DB_PASSWORD"
           value_from {
             secret_key_ref {
               name = "datascientest-mysql-password"
               key = "password"
             }
           }
         }
         env { # déclaration des variables d'environnement
           name = "WORDPRESS_DB_USER"
           value_from {
             secret_key_ref {
               name = "datascientest-mysql-user"
               key = "user"
             }
           }
         }
       }
     }
   }
 }
}

resource "kubernetes_service" "wordpress-service" {
 metadata {
   name = "wordpress-service"
 }
 spec {
   selector = local.datascientest-wordpress # retrieves the values declared in the datascientest-wordpress variable in order to return requests on the correct pods
   port {
     port = 85 # open port, here we're talking about a web service listening on port 80
     target_port = 85 # Target port
     node_port = 32000 # open port on each node
   }
   type = "NodePort" # type of NodePort service that will allow access from every node in the cluster on port 32000
 }
}

# mysql deployment
resource "kubernetes_deployment" "mysql" {
 metadata {
   name = "mysql"
   labels = local.datascientest-mysql # retrieves the values declared in the datascientest-mysql variable
 }
 spec {
   replicas = 1
   selector {
     match_labels = local.datascientest-mysql
   }
   template {
     metadata {
       labels = local.datascientest-mysql
     }
     spec {
       container {
         image = "mysql:5.6" # image to use for mysql deployment
         name = "mysql"
         port {
           container_port = 3306
         }
         env {
           name = "MYSQL_ROOT_PASSWORD" # declaration of the MYSQL_ROOT_PASSWORD value to be retrieved from the mysql-pass secret
           value_from {
             secret_key_ref {
               name = "datascientest-mysql-password"
               key = "password
             }
           }
         }
       }
     }
   }
 }
}

resource "kubernetes_service" "mysql-service" {
 metadata {
   name = "mysql-service"
 }
 spec {
   selector = local.datascientest-mysql
   port {
     port = 3306
     target_port = 3306
   }
   type = "NodePort
 }
}













