library(plumber)
model <- readRDS("model.Rds")

MODEL_VERSION <- "0.0.1"
VARIABLES <- list(
  Age = "Age = # in Years",
  EstimatedSalary = "EstimatedSalary = # in money",
  Purchased = "Successful submission will results in a calculated purchased Probability from 0 to 1 (Unlikely to More Likely)"
)


# test API working --------------------------------------------------------

#* @get /healthcheck
health_check <- function() {
  result <- data.frame(
    "input" = "",
    "status" = 200,
    "model_version" = MODEL_VERSION
  )
  
  return(result)
}


# API landing page --------------------------------------------------------

#* @get /
#* @html
home <- function() {
  title <- "Customer Purchases Predictions API"
  body_intro <-  "Welcome to the Customer Purchases Predictions API!"
  body_model <- paste("We are currently serving model version:", MODEL_VERSION)
  body_msg <- paste("To received a prediction on Customer Purchases ,", 
                    "submit the following variables to the <b>/Purchased</b> endpoint:",
                    sep = "\n")
  body_reqs <- paste(VARIABLES, collapse = "<br>")
  
  result <- paste(
    "<html>",
    "<h1>", title, "</h1>", "<br>",
    "<body>", 
    "<p>", body_intro, "</p>",
    "<p>", body_model, "</p>",
    "<p>", body_msg, "</p>",
    "<p>", body_reqs, "</p>",
    "</body>",
    "</html>",
    collapse = "\n"
  )
  
  return(result)
}


# helper functions for predict --------------------------------------------

transform_purchased_data <- function(input_purchased_data) {
  ouput_purchased_data <- data.frame(
    Age = input_purchased_data$Age,
    EstimatedSalary = input_purchased_data$EstimatedSalary
    
  )
}

validate_feature_inputs <- function(Age, EstimatedSalary) {
  Age_valid <- (Age >= 0 & Age < 200 | is.na(Age))
  EstimatedSalary_valid <- (EstimatedSalary >= 0 & EstimatedSalary < 200000000000 | is.na(EstimatedSalary))
  tests <- c("Age must be between 0 and 200 or NA", 
             "EstimatedSalary must not be over 200 million euros")
  test_results <- c(Age_valid, EstimatedSalary_valid)
  if(!all(test_results)) {
    failed <- which(!test_results)
    return(tests[failed])
  } else {
    return("OK")
  }
}


# predict endpoint --------------------------------------------------------

#* @post /purchased
#* @get /purchased
predict_purchased <- function(Age=NA, EstimatedSalary=NA) {
  #Age=readline(prompt="Enter Age: ")
  #EstimatedSalary =readline(prompt="Enter EstimatedSalary : ")
  Age = as.integer(Age)
  EstimatedSalary = as.integer(EstimatedSalary)
  data <- data.frame(Age=Age, EstimatedSalary=EstimatedSalary)
  valid_input <- validate_feature_inputs(Age, EstimatedSalary)
  if (valid_input[1] == "OK") {
    payload <- data.frame(Age=Age, EstimatedSalary=EstimatedSalary)
    clean_data <- transform_purchased_data(payload)
    prediction <- predict(model, clean_data, type = "response")
    result <- list(
      input = list(payload),
      reposnse = list("Purchased_probability" = prediction,
                      "Purchased_prediction" = (prediction >= 0.5)
      ),
      status = 200,
      model_version = MODEL_VERSION)
  } else {
    result <- list(
      input = list(Age = Age_valid, EstimatedSalary_valid = EstimatedSalary_valid),
      response = list(input_error = valid_input),
      status = 400,
      model_version = MODEL_VERSION)
  }
  
  return(result)
  print(result)
}