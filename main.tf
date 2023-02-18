provider "heroku" {}

resource "heroku_app" "succeed" {
  name   = "succeed"
  region = "us"
}

resource "heroku_addon" "postgres" {
  app  = heroku_app.succeed.id
  plan = "heroku-postgresql:mini"
}

resource "heroku_build" "succeed" {
  app = heroku_app.succeed.id

  source {
    path = "./app"
  }

  lifecycle {
    create_before_destroy = true
  }
}

variable "app_quantity" {
  default     = 1
  description = "Number of dynos in your Heroku formation"
}

# Launch the app's web process by scaling-up
resource "heroku_formation" "succeed" {
  app        = heroku_app.succeed.id
  type       = "web"
  quantity   = var.app_quantity
  size       = "Eco"
  depends_on = [heroku_build.succeed]
}

resource "heroku_addon" "logging" {
  app = heroku_app.succeed.id
  plan = "papertrail:choklad"
}
