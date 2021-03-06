shinyUI(pageWithSidebar(
  headerPanel("Q and A"),
  sidebarPanel(
    # To be populated with select course
    uiOutput("boxSelectCourse"),
    # To be populated with radio buttons
    uiOutput("boxSelectLecture"),
    actionButton("loadButton", "Load Data"),
    verbatimTextOutput("outTextLoad")
    #selectInput("selectCourse", label = h3("Select box"), 
    #            choices = list("Choice 1" = 1, "Choice 2" = 2, "Choice 3" = 3), 
    #            selected = 1),
    #checkboxGroupInput("checkGroup", label = h3("Checkbox group"), 
    #                   choices = list("Choice 1" = 1, "Choice 2" = 2, "Choice 3" = 3),
    #                   selected = 1)
    #p("Click the button to update the value displayed in the main panel.")
  ),
  mainPanel(
    tags$head(tags$script(src = "enter_button.js")), 
    htmlOutput("questionTitle"),
    htmlOutput("questionText"),
    textInput("text", "Answer:", ""),
    actionButton("goButton", "Go!"),
    br(),
    br(),
    verbatimTextOutput("outText")
  )
))