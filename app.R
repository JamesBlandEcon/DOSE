
library(shiny)
library(tidyverse)
library(googledrive)
# If there is an error with googlesheets4, you will need to:
# remotes::install_github("tidyverse/googlesheets4")
library(googlesheets4)


gs4_auth(path = "dose-489213-d24119a31279.json")


set.seed(42)


battery<-read.csv("data/questionTreeNewDOSEmoduleNoNAs16-Oct-2019.csv",
                  header=FALSE,
                  col.names = c("rownum", "risky.high","risky.low","safe","next.risky","next.safe")
                  )




pick.lottery<-function(lot,action) {
  
  
  if (action=="start") {
    
    returnThis<-battery |>
      filter(rownum==1)
    
  } else if (action=="risky") {
    
    returnThis<-battery |>
      filter(rownum==lot$next.risky)
    
  } else {
    
    returnThis<-battery |>
      filter(rownum==lot$next.safe)
    
  }
  
  return(returnThis)
  
}





ui <- fluidPage(

    # Application title
    titlePanel("Dynamically optimized sequential experimentation (DOSE)"),
    uiOutput("page"),
    br(),
    br(),
    p('Chapman, Jonathan, Erik Snowberg, Stephanie Wang, and Colin Camerer. "Dynamically optimized sequential experimentation (DOSE) for estimating economic preference parameters." (2024).')

    
)

server <- function(input, output, session) { ############################################

  
  page <- reactiveVal("start")
  
  lottery <- reactiveVal(c())
  
  data <- reactiveVal(c())
  
  # These next two reactives retrive the id from the URL
  query <- reactive({
    parseQueryString(session$clientData$url_search)
  })
  id <- reactive({
    query()[["id"]]  %||% paste("id is empty",Sys.time())
  })
  
  output$page <- renderUI({
    
    if (page()=="start"){
      tagList(
        h1("START"),
        p("A placeholder for whatever you want to tell people at the start"),
        actionButton("start", "Start")
      )
      
    } else if (page()=="elicitation") {
      
      lot<-lottery()
      
      if (lot$next.risky==0 & lot$next.safe==0) {
        page("end")
        print("Initiating data dump")
        sheet_append(
          ss   = as_id("1pqQauMQX5Vrr_utC-jXo8J5YAlYLJArDiNK_oLOi6WU"),
          data = data()|> mutate(id=id())
        )
        
        
        
        
        
        
        
      }
      
      
      tagList(
        h1("ELICITATION"),
        p("A placeholder for whatever you want to tell people"),
        p("Please indicate which option you would prefer"),
        fluidRow(
          column(5,
                 p(paste0(" A lottery where you either ",ifelse(lot$risky.high<0,"lose ","receive "),abs(lot$risky.high), " or ",ifelse(lot$risky.low<0,"lose ","receive "),abs(lot$risky.low), ", each with probability 50%")),
                 actionButton("select_risky", "Select")
                 ),
          
          column(2),
          column(5,
                 p(paste0(ifelse(lot$safe<0,"Losing ", "Receiving "),abs(lot$safe)," for certain")),
                 actionButton("select_safe", "Select")
          )
        )
        
      )
    } else if (page()=="end") {
      tagList(
        h1("RESULTS"),
        br(),
        p("Click on the following link to download your data"),
        downloadButton("download_data", "Download choice data")
        
      )
    }
    
    
    
  })
  
  
  
  
  # START page things ----------------------------------------------------------
  
    # start button moves you to the elicitation page
    observeEvent(
      input$start, {
        page("elicitation")
       lottery(pick.lottery(c(),"start")) 
      }
        
    )
  
  # ELICITATION page things ----------------------------------------------------
  
  observeEvent(
    input$select_risky, {
      page("elicitation")
      
      data(
        data() |>
          rbind(
            lottery() |>
              mutate(
                choice = "risky"
              )
          )
      )
      
      lottery(pick.lottery(lottery(),"risky")) 
      
      
    }
  )
  
  observeEvent(
    input$select_safe, {
      page("elicitation")
      
      data(
        data() |>
          rbind(
            lottery() |>
              mutate(
                choice = "safe"
              )
          )
      )
      
      lottery(pick.lottery(lottery(),"safe")) 
      
      
    }
  )
  
  # END page things ------------------------------------------------------------
  
  output$download_data <- downloadHandler(
    
    
    
    filename = function() {
      paste0("choice_data_", Sys.time(),"_",id(),".csv")
    },
    content = function(file) {
      data() |>
        mutate(
          id = id()
        ) |>
        write.csv(file, row.names = FALSE)
    }
  )
}

# Run the application 
shinyApp(ui = ui, server = server)
