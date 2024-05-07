library(shiny)

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
      message(paste0("Send prediction inputs (", input_json_array, ") to api (", api_url, ")"))
      res <- httr2::request(api_url) |>
        # httr2::req_body_json(val()) |>          # <- json auto serialization was not working...
        httr2::req_body_raw(input_json_array) |>  # <- ... so we manualy serialized to json string
        httr2::req_perform()

      message("Return response")
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
