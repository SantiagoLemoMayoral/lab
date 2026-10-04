resource "kubernetes_service_v1" "api" {
  metadata {
    name = "lab-api"
  }

  spec {
    selector = {
      app = "lab-api"
    }

    type = "NodePort"

    port {
      port        = 80
      target_port = 8000
      node_port   = 30080
    }
  }

}