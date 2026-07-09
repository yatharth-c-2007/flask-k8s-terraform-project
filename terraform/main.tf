terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}
resource "kubernetes_deployment" "flask_app" {
  metadata {
    name = "flask-app-deployment"
    labels = {
      app = "flask-app"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "flask-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "flask-app"
        }
      }

      spec {
        container {
          image             = "flask-k8s-app:v1"
          name              = "flask-app"
          image_pull_policy = "Never"

          port {
            container_port = 5000
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "flask_app" {
  metadata {
    name = "flask-app-service"
  }

  spec {
    selector = {
      app = "flask-app"
    }

    port {
      port        = 80
      target_port = 5000
    }

    type = "NodePort"
  }
}
