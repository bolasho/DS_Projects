library(plumber)
serve_model <- plumb("deploy_api.R")
serve_model$run(port = 8000)


