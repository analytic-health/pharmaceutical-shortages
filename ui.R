
bs4DashPage(
  header = dashboardHeader(disable = TRUE),
  sidebar = dashboardSidebar(disable = TRUE),
  preloader = list(waiter = list(html = tagList( waiter::spin_6())),
                   duration = 2),
  body = dashboardBody(
    tagList(
      
      shinyjs::useShinyjs(),
      
      # include stylesheet
      tags$head(includeCSS("www/stylesheet.css")),
      
      # include favicon
      tags$head(
        tags$link(rel = "shortcut icon", href = "favicon.ico"),
        tags$link(rel = "icon", href = "favicon.ico"),
        tags$link(rel = "apple-touch-icon", sizes = "180x180", href = "apple-touch-icon.png")
      ),
      
      # include tracking code
      tags$head(includeHTML(("google-analytics.html"))),
      
      absolutePanel(
        top = 50, 
        left = 20, 
        shinyWidgets::circleButton('info_id', icon = icon('info'), status = "default", size = "default")
      ),
      
      div(style = 'max-width:1200px; margin:0 auto;',
          fluidRow(
            column(12,
                   align = 'center',
                   HTML("
                       <center>
                        <br>
                          <a href='https://analytichealth.co.uk/' target='_blank'><img src='https://analytichealth.co.uk/wp-content/uploads/2021/03/Analytic-Health_Horizontal_XS.png' align='center' width='200' alt='Analytic Health Logo'></a>
                        <br>
                       </center>
                      "),
                   br()
            )
          ),
          fluidRow(
            column(4,
                   align = 'center',
                   bs4ValueBoxOutput('actual_cost',
                                     width = 12)
            ),
            column(4,
                   align = 'center',
                   bs4ValueBoxOutput('no_shoratage_est',
                                     width = 12)
            ),
            column(4,
                   align = 'center',
                   bs4ValueBoxOutput('additional_spending_ui',
                                     width = 12)
            )
          ),
          
          br(),
          
          fluidRow(
            highchartOutput('shortages_graph',
                            height = '400px')
          ),
          
          br(),
          br(),
          
          fluidRow(
            column(12,
                   align = 'center',
                   column(4,
                          shinyWidgets::pickerInput(
                            inputId = "shortages_report_ai_picker",
                            label = "Select Active Ingredients:",
                            choices = ai_choices,
                            selected = ai_choices,
                            width = '100%',
                            multiple = TRUE,
                            options = list(title = "Please select Active Ingredients",
                                           `actions-box` = TRUE,
                                           `live-search` = TRUE,
                                           `selected-text-format` = "count > 0",
                                           `count-selected-text` = "{0} selected (out of {1})",
                                           size = 5
                            )
                          )),
                   
                   column(4,
                          shinyWidgets::pickerInput(
                            inputId = "shortages_report_dosage_picker",
                            label = "Select Dosage Forms:",
                            choices = '',
                            width = '100%',
                            multiple = TRUE,
                            options = list(title = "Please select Dosage Forms",
                                           `actions-box` = TRUE,
                                           `live-search` = TRUE,
                                           `selected-text-format` = "count > 0",
                                           `count-selected-text` = "{0} selected (out of {1})",
                                           size = 5
                            )
                          )),
                   
                   column(4,
                          shinyWidgets::pickerInput(
                            inputId = "shortages_report_product_pack",
                            label = "Select Product:",
                            choices = '',
                            width = '100%',
                            multiple = TRUE,
                            options = list(title = "Please select Products",
                                           `actions-box` = TRUE,
                                           `live-search` = TRUE,
                                           `selected-text-format` = "count > 0",
                                           `count-selected-text` = "{0} selected (out of {1})",
                                           size = 5
                            )
                          ))
                   
            )
          ),
          
          fluidRow(
            column(12,
                   align = 'right',
                   shiny::actionButton(inputId = 'back_button', label = NULL, icon = icon("chevron-left"), width = '75px'),
                   shiny::actionButton(inputId = 'next_button', label = NULL, icon = icon("chevron-right"), width = '75px')
            )
          ),
          fluidRow(
            column(12,
                   align = 'right',
                   p(id = 'product_note_id', style="font-size:14px; color: grey;", '* please select just 1 product to use these buttons')
            )
          ),
          br(),
          br()
      )
    )
  ),
  footer = bs4DashFooter(
    left = HTML('
              <center><span style="color:grey">Data made available as part of the <a href="http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/" style="color:grey" target="_blank"><strong>Open Government Licence</strong></a> and report produced by <a href="https://analytichealth.co.uk/" style ="color:grey" target="_blank"><strong>Analytic Health Ltd.</strong></a></span></center>
              <br>
              <center>
                <span style="font-size: 1.5rem;">
                  <span style="color: grey;">
                    <a href="https://www.linkedin.com/company/analytic-health/" target="_blank">
                      <i style="color: grey;" class="fab fa-linkedin-in"></i>
                    </a>
                  </span>
                  <br><br>
               <span style="color: grey;font-size: 1rem;">
                    Whilst we make every effort to ensure that the information appearing in this report is accurate and up to date, we cannot be held liable for any use or reliance you may make of or put on it.
                  </span>   
              </center>
              </span>  
              ')
  )
)
