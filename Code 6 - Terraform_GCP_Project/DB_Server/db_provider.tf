provider "google" {
 credentials = file("./DB_Server/db_key.json")
 project     = "dev-12-proj-34"
 region      = "asia-southeast1"
}