library(stringr)
library(RCurl)
library(googlesheets)

biochemUrl <- "https://docs.google.com/spreadsheets/d/1vSe9pLzvAre6geRtqKbJLDmh5oJqIXyOz1_KSmhKOcY/edit?usp=sharing"
biochemKey <- extract_key_from_url(biochemUrl)
biochemGS <- gs_key(biochemKey)

my.data <- gs_read(biochemGS, ws = 2, col_names=FALSE)

my.data <- as.data.frame(my.data)

quiz.data <- list(
  questions=my.data[,1],
  answers=as.vector(sapply(1:nrow(my.data), function(rowindex) {
    # Get all non-NA columns in this row, exclude the question
    my.data[rowindex, !is.na(my.data[rowindex,])][-1]
  }))
  )

counter <- 0
currentQuestionText <- ""
currentAnswers <- ""
animatingText <- FALSE
animationCounter <- 0
maxAnimationCounter <- 10

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
  
  output$questionTitle <- renderText("<b>Question:</b>")
  output$oText <- renderText("Once you have loaded questions, hit <Enter>")
  
  outText <- eventReactive(input$goButton, {
    textToWrite <- ""
    if(counter > 0) {
      oldQuestionText <- currentQuestionText
      oldAnswerText <- currentAnswers[1]
      givenAnswer <- input$text
      correct <- any(sapply(oldAnswerText, function(answer) string_equals(answer, givenAnswer)))
      if(correct) {
        textToWrite <- paste0("Correct! The correct answer was ", oldAnswerText[1])
      } else {
        textToWrite <- paste0("Nice try. The correct answer is ", oldAnswerText[1])
      }
    }
    
    counter <<- counter + 1
    currentQuestionText <<- quiz.data$questions[counter]
    currentAnswers <<- quiz.data$answers[[counter]]
    
    #output$questionText <- renderText(currentQuestionText)
    animationCounter <<- maxAnimationCounter
    animatingText <<- TRUE
    
    return(textToWrite)
  })
  
  output$outText <- renderText({
    outText()
  })
  
  autoInvalidate <- reactiveTimer(1)
  observe({
    autoInvalidate()
    if(animatingText) {
      if(animationCounter <= 0) {
        animatingText <- FALSE
      } else {
        output$questionText <- renderText(paste0(paste0(rep(" ", animationCounter), collapse = ""), currentQuestionText))
        animationCounter <<- animationCounter - 1;
      }
    }
    
  })
 
})