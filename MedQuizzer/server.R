library(stringr)
library(googlesheets)

courses <- c("Embryology", "Biochemistry", "Cell and Tissue Biology", "Genetics")
course.abbreviations <- c("Biochem", "CTB", "Embryo", "Genetics")
course.urls <- c("https://docs.google.com/spreadsheets/d/1IjT1NnIGwrYYIepIbF1Wg9WzDNNBKETyJeVufCtx3SI",
                 "https://docs.google.com/spreadsheets/d/1vSe9pLzvAre6geRtqKbJLDmh5oJqIXyOz1_KSmhKOcY",
                 "https://docs.google.com/spreadsheets/d/13JzVU2X-Jp8-meMB23srn2q82FCprouTQxVDumBfIXg",
                 "https://docs.google.com/spreadsheets/d/1xQ3gjE9tUce2t4_zVQfdydOlGjnOdr00PxXhKJaJSbg/edit?usp=sharing")

googlesheets_keys <- lapply(course.urls, extract_key_from_url)
googlesheets_GS <- lapply(googlesheets_keys, gs_key)

biochemGS <- googlesheets_GS[[1]]

my.data <- gs_read(biochemGS, ws = 2, col_names=FALSE)

my.data <- as.data.frame(my.data)

quiz.data <- list(
  questions=vector(),
  answers=list()
  )

counter <- 1
currentQuestionText <- ""
currentAnswers <- ""
animatingText <- FALSE
animationCounter <- 0
maxAnimationCounter <- 30
firstQuestion <- TRUE

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
  
  output$boxSelectCourse = renderUI(selectInput("selectCourse", label="Select a Course", choices=courses,selected=1))
  #output$boxSelectLecture = checkboxGroupInput("selectLecture", label = "Lecture Title", 
  #                                      choices = list("Choice 1" = 1, "Choice 2" = 2, "Choice 3" = 3))
  
  output$boxSelectLecture = renderUI(
    if (is.null(input$selectCourse)) {
      return()
    } else
      checkboxGroupInput("selectLecture", 
        label="Select a Lecture", 
        choices=googlesheets_GS[[which(courses == input$selectCourse)]]$ws$ws_title,
        selected=googlesheets_GS[[which(courses == input$selectCourse)]]$ws$ws_title
        )
  )
  
  output$questionTitle <- renderText("<b>Question:</b>")
  output$questionText <- renderText("Once you have loaded questions, hit ENTER")
  
  outTextFromGoButton <- eventReactive(input$goButton, {
    if(length(quiz.data$questions) == 0) {
      return("Load data to begin.")
    }
    if(counter > length(quiz.data$questions)) {
      counter <- 1
      }
    textToWrite <- ""
    if(firstQuestion) {
      firstQuestion <<- FALSE
    } else {
      oldQuestionText <- currentQuestionText
      oldAnswerText <- currentAnswers[1]
      givenAnswer <- input$text
      correct <- any(sapply(oldAnswerText, function(answer) string_equals(answer, givenAnswer)))
      if(correct) {
        textToWrite <- paste0("Correct! The correct answer was: ", oldAnswerText[1])
        # Trigger yepbutton
        session$sendCustomMessage(type='myCallbackHandler', 1) 
      } else {
        textToWrite <- paste0("Nice try. The correct answer is: ", oldAnswerText[1])
        # Trigger nopebutton
        session$sendCustomMessage(type='myCallbackHandler', 0) 
      }
    }
    
    currentQuestionText <<- paste0("[", counter, "/", length(quiz.data$questions), "] ", quiz.data$questions[counter])
    
    currentAnswers <<- quiz.data$answers[[counter]]
    counter <<- counter + 1
    
    output$questionText <- renderText(currentQuestionText)
    
    # The animations aren't working right now.
    #animationCounter <<- maxAnimationCounter
    #animatingText <<- TRUE
    
    return(textToWrite)
  })
  output$outText <- renderText({
    outTextFromGoButton()
  })
  
  outTextFromLoadButton <- eventReactive(input$loadButton, {
    # Get the index of the selected course
    courseIndex <- which(courses == input$selectCourse)
    
    course_GS <- googlesheets_GS[[courseIndex]]
    
    # get the index of selected lectures
    lectureIndex <- which(input$selectLecture == course_GS$ws$ws_title)
    questions <- c()
    answers <- list()
    for(currentLectureIndex in lectureIndex) {
      my.data <- gs_read(course_GS, ws = currentLectureIndex, col_names=FALSE)
      my.data <- as.data.frame(my.data)
      if(nrow(my.data) == 0) {
        next
      }
      
      current.questions=my.data[,1]
      current.answers=as.vector(sapply(1:nrow(my.data), function(rowindex) {
          # Get all non-NA columns in this row, exclude the question
        my.data[rowindex, !is.na(my.data[rowindex,])][-1]
        }))
      questions <- c(questions, current.questions)
      answers <- c(answers, current.answers)
    }
    
    #Randomize the order of questions.
    permutation <- sample(1:length(questions))
    questions <- questions[permutation]
    answers <- answers[permutation]
    
    quiz.data <<- list(questions=questions, answers=answers)
    
    counter <<- 1
    firstQuestion <<- TRUE
    
    return(paste0("Loaded ", length(quiz.data$questions), " questions from ", input$selectCourse, "."))
  })
  
  output$outTextLoad <- renderText({
    outTextFromLoadButton()
  })
  
  # Text Animations
  #autoInvalidate <- reactiveTimer(1)
  #observe({
  #  autoInvalidate()
  #  if(animatingText) {
  #    if(animationCounter <= 0) {
  #      animationCounter <-- 0
  #      animatingText <- FALSE
  #    } else {
  #      output$questionText <- renderText(paste0(paste0(rep(" ", animationCounter), collapse = ""), currentQuestionText))
  #      animationCounter <<- animationCounter - 1;
  #    }
  #  }
  #})
 
})