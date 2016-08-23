shinyUI(pageWithSidebar(
  headerPanel("Q and A"),
  sidebarPanel(
    #p("Click the button to update the value displayed in the main panel.")
  ),
  mainPanel(
    tags$head(tags$script(src = "enter_button.js")), 
    htmlOutput("answerTitle"),
    verbatimTextOutput("oText"),
    textInput("text", "Answer:", "[Answer]"),
    actionButton("goButton", "Go!"),
    br(),
    br(),
    verbatimTextOutput("outText")
  )
))