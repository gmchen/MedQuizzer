shinyUI(pageWithSidebar(
  headerPanel("Q and A"),
  sidebarPanel(
    #p("Click the button to update the value displayed in the main panel.")
  ),
  mainPanel(
    tags$head(tags$script(src = "enter_button.js")), 
    htmlOutput("questionTitle"),
    verbatimTextOutput("questionText"),
    textInput("text", "Answer:", "[Answer]"),
    actionButton("goButton", "Go!"),
    br(),
    br(),
    verbatimTextOutput("outText")
  )
))