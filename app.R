library(shiny)
# Configure the log object
log <- log4r::logger()

api_url <- "http://127.0.0.1:8000/predict"

ui <- fluidPage(
  titlePanel("Penguin Mass Predictor"),

  # Model input values
  sidebarLayout(
    sidebarPanel(
      sliderInput(
        "bill_length",
        "Bill Length (mm)",
        min = 30,
        max = 60,
        value = 45,
        step = 0.1
      ),
      selectInput(
        "sex",
        "Sex",
        c("Male", "Female")
      ),
      selectInput(
        "species",
        "Species",
        c("Adelie", "Chinstrap", "Gentoo")
      ),
      # Get model predictions
      actionButton(
        "predict",
        "Predict"
      )
    ),

    mainPanel(
      h2("Penguin Parameters"),
      verbatimTextOutput("vals"),
      h2("Predicted Penguin Mass (g)"),
      textOutput("pred")
    )
  )
)

server <- function(input, output) {

  # Log app start
  log4r::info(log, "App Started")

  # Input params
  vals <- reactive(
    list(
      bill_length_mm = input$bill_length,
      species_Chinstrap = input$species == "Chinstrap",
      species_Gentoo = input$species == "Gentoo",
      sex_male = input$sex == "Male"
    )
  )

  # Fetch prediction from API
  pred <- eventReactive(
    input$predict,
    {
      input_json_array <- jsonlite::toJSON(
        list( # <- creates an array of objects
          isolate(vals())
        ),
        auto_unbox=TRUE,
        pretty = FALSE
      )
      ## log4r::info breaks when called from within eventReactive code block...
      # log4r::info(paste0("Send prediction inputs (", input_json_array, ") to api (", api_url, ")"))
      ## Warning: Error in $: $ operator is invalid for atomic vectors
      ##   145: log4r::info
      ## ... have to use message() instead:
      message(paste0("Send prediction inputs (", input_json_array, ") to api (", api_url, ")"))
      tryCatch({
        res <- httr2::request(api_url) |>
          # httr2::req_body_json(val()) |>          # <- json auto serialization was not working...
          httr2::req_body_raw(input_json_array) |>  # <- ... so we manualy serialized to json string
          httr2::req_perform()

        message("Return response")

        # Log error returned from server
        if (httr2::resp_is_error(res)) {
          log4r::error(log, paste("HTTP Error"))
        }

      }, error = function(err) {
        # Log error if no response from server
        log4r::error(log, paste(err))
      })

      httr2::resp_body_json(res)
    },
    ignoreInit = TRUE
  )

  # Render to UI
  output$pred <- renderText(pred()$predict[[1]])
  output$vals <- renderPrint(vals())
}

# Run the application
shinyApp(ui = ui, server = server)
