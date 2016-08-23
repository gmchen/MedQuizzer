library(stringr)
library(RCurl)
library(googlesheets)

biochemUrl <- "https://docs.google.com/spreadsheets/d/1vSe9pLzvAre6geRtqKbJLDmh5oJqIXyOz1_KSmhKOcY/edit?usp=sharing"
biochemKey <- extract_key_from_url(biochemUrl)
biochemGS <- gs_key(biochemKey)

my.data <- gs_read(biochemGS, ws = 1, col_names=FALSE)

quiz.data <- list(
  questions=my.data[,1],
  answers=sapply(1:ncol(my.data), function(rowindex) {
    # Get all non-NA columns in this row, exclude the question
    my.data[rowindex, !is.na(my.data[rowindex,])][-1]
  })
  )

order <- c(2,1,3)
counter <- 1

string_equals <- function(str1, str2) {
  str1 <- toupper(str_replace_all(str1, "[^[:alnum:]]", ""))
  str2 <- toupper(str_replace_all(str2, "[^[:alnum:]]", ""))
  # make str2 the longer string
  if(nchar(str1) > nchar(str2)) {
    temp <- str1
    str1 <- str2
    str2 <- temp
  }
  # Remove a trailing s if str2 is longer
  if(nchar(str2) > nchar(str1) && substr(str2,nchar(str2),nchar(str2)) == "s") {
    str2 <- substr(str2, 1, nchar(str2)-1)
  }
  return(str1 == str2)
}

shinyServer(function(input, output, session) {
  
  output$answerTitle <- renderText("<b>Question:</b>")
  output$oText <- renderText("Once you have loaded questions, hit <Enter>")
  
  outText <- eventReactive(input$goButton, {
    questionText <- as.character(my.data$question[counter])
    counter <<- counter + 1
    output$oText <- renderText(questionText)
   # updateTextInput(session, "text", value = "")
    paste(input$text)
  })
  
  output$outText <- renderText({
    outText()
  })
})