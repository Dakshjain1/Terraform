# open on chrome
resource "null_resource" "openwebsite"  {
depends_on = [
    kubernetes_service.wp_service
  ]
	provisioner "local-exec" {
	    command = "minikube service ${kubernetes_service.wp_service.metadata[0].name}"
  	}
}