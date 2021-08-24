
server = function(session, input, output) {
  
  
  # active ingredients picker -----------------------------------------------
  
  observeEvent(input$shortages_report_ai_picker, priority = 1000, {
    
    req(isolate(input$shortages_report_ai_picker))
    
    # force the picker to update here even if the supplied choices have not changed
    # dosage choices may be the same for example choosing Aciclovir (which only has Tablet as dosage and then Amisulpride), which would cause no reactivity
    shinyWidgets::updatePickerInput(
      session = session, 
      inputId = 'shortages_report_dosage_picker', 
      choices = '', 
      selected = ''
    )
    
    dosage_choices <- shortages_dt[active_ingredients %in% input$shortages_report_ai_picker, sort(unique(dosage))]
    
    shinyWidgets::updatePickerInput(
      session = session, 
      inputId = 'shortages_report_dosage_picker', 
      choices = dosage_choices, 
      selected = dosage_choices
    )
  })
  
  
  # dosage picker -----------------------------------------------------------
  
  observeEvent(input$shortages_report_dosage_picker, {
    
    req(isolate(input$shortages_report_ai_picker))
    req(isolate(input$shortages_report_dosage_picker))
    
    product_pack$choices <- shortages_dt[active_ingredients %in% input$shortages_report_ai_picker & dosage %in% input$shortages_report_dosage_picker, sort(unique(product_pack))]
    shinyWidgets::updatePickerInput(
      session = session, 
      inputId = 'shortages_report_product_pack', 
      choices = product_pack$choices, 
      selected = product_pack$choices,
      choicesOpt = list(
        content = stringr::str_trunc(product_pack$choices, width = 80, side = "right")
      ))
  })
  
  
  # pagination buttons ------------------------------------------------------
  
  # next
  observeEvent(input$next_button, ignoreInit = TRUE, {
    shinyjs::disable('next_button')
    shinyjs::delay(500, shinyjs::enable('next_button'))
    
    current_position <- match(isolate(input$shortages_report_product_pack), isolate(product_pack$choices))
    
    if (current_position < length(isolate(product_pack$choices))) {
      updateSelectInput(
        session = session, 
        inputId = 'shortages_report_product_pack', 
        selected = isolate(product_pack$choices)[current_position + 1]
      )
      
      if (current_position >= (length(isolate(product_pack$choices))-1)) {shinyjs::disable('next_button')}
      
    }
    shinyjs::enable('back_button')
  })
  
  # back
  observeEvent(input$back_button, ignoreInit = TRUE, {
    
    shinyjs::disable('back_button')
    shinyjs::delay(500, shinyjs::enable('back_button'))
    
    current_position <- match(isolate(input$shortages_report_product_pack), isolate(product_pack$choices))
    
    if (current_position > 1) {
      updateSelectizeInput(
        session = session, 
        inputId = 'shortages_report_product_pack', 
        selected = isolate(product_pack$choices)[current_position - 1])
      
      if (current_position == 2) {shinyjs::disable('back_button')} # i.e position now is actually 1
      
    }
    shinyjs::enable('next_button')
  })
  
  
  # product pack picker -----------------------------------------------------
  
  observeEvent(input$shortages_report_product_pack, {
    
    req(isolate(input$shortages_report_ai_picker))     
    req(isolate(input$shortages_report_dosage_picker)) 
    req(isolate(input$shortages_report_product_pack))
    
    if(length(input$shortages_report_product_pack) > 1){
      shinyjs::disable('next_button')
      shinyjs::disable('back_button')
      shinyjs::show(id = 'product_note_id', anim = TRUE, animType = 'fade')
    } else {
      shinyjs::enable('next_button')
      shinyjs::enable('back_button')
      shinyjs::hide(id = 'product_note_id', anim = TRUE, animType = 'fade')
    }
    
    output_dt_base <- shortages_dt[product_pack %in% isolate(input$shortages_report_product_pack) & month_full >= as.Date('2015-01-01'), .(base_no_shortage_estimate = round(sum(base_no_shortage_estimate)), value = round(sum(value)), quantity = round(sum(quantity)), shortage = as.logical(sum(shortage, na.rm = T))), by = .(month_full, xaxis_months)][order(month_full), ]
    
    output_dt_base[, additional_spending:= value - base_no_shortage_estimate]
    
    if (length(isolate(input$shortages_report_product_pack)) == 1) {
      
      # define plotlines
      output_dt_base[, shortage_lag:= dplyr::lag(shortage)]
      output_dt_base[, shortage_start:= 0]
      output_dt_base[shortage & !shortage_lag, shortage_start:= 1][, shortage_lag:= NULL]
      output_dt_base[, shortage_lead:= dplyr::lead(shortage)]
      output_dt_base[, shortage_end:= 0]
      output_dt_base[shortage & !shortage_lead, shortage_end:= 1][, shortage_lead:= NULL]
      output_dt_base[, plot_line_action:= NA_character_]
      output_dt_base[shortage_start == 1, plot_line_action:= 'start shortage']
      output_dt_base[shortage_end == 1, plot_line_action:= 'end shortage']
      output_dt_base[, rowN:= 1:.N]
      
      output_dt_base_plotlines <- output_dt_base[!is.na(plot_line_action), .(plot_line_action, rowN, xaxis_months)]
      
      plot_lines_list <- list()
      for (i in 1:nrow(output_dt_base_plotlines)) {
        plot_lines_list[[i]] <- list(
          label = list(
            text = htmltools::HTML(
              paste0('<a title = "', output_dt_base_plotlines[i, plot_line_action], ': ', output_dt_base_plotlines[i, xaxis_months], '"',
                     'style="font-size:10px;color:lightgrey;">', output_dt_base_plotlines[i, plot_line_action], '</a>'))),
          color = 'grey',
          width = 1,
          value = output_dt_base_plotlines[i, rowN] - 1, # minus 1 as the highcharter function is javascript based which starts on zero
          dashStyle = 'Dash'
        )
      }
      
      output_dt$title <- paste0('UK National Health Service (NHS) spending on ', isolate(input$shortages_report_product_pack))
      output_dt$plot_lines_list <- copy(plot_lines_list)
      
      output_dt$data <- copy(output_dt_base)
      
    } else {
      
      output_dt$title <- 'UK National Health Service (NHS) spending on shortage affected pharmaceuticals'
      output_dt$data <- copy(output_dt_base)
      
    }
    
  })
  
  
  # value boxes -------------------------------------------------------------
  
  observeEvent(output_dt$data, {
    
    req(output_dt$data)
    
    output$actual_cost <- renderbs4ValueBox({
      bs4ValueBox(
        value = h4(formattable::currency(x = output_dt$data[, sum(value)], symbol = '£', digits = 0, big.mark = ',')),
        gradient = FALSE,
        subtitle = 'Actual NHS spending',
        elevation = 2,
        color = ifelse(input$customSwitch1, 'secondary', 'white')
      )
    })
    
    output$no_shoratage_est <- renderbs4ValueBox({
      bs4ValueBox(
        value = h4(formattable::currency(x = output_dt$data[, sum(base_no_shortage_estimate)], symbol = '£', digits = 0, big.mark = ',')),
        gradient = FALSE,
        subtitle = 'No-shortage estimated NHS spending',
        elevation = 2,
        color = ifelse(input$customSwitch1, 'secondary', 'white')
      )
    })
    
    output$additional_spending_ui <- renderbs4ValueBox({
      bs4ValueBox(
        value = h4(formattable::currency(x = output_dt$data[, sum(additional_spending)], symbol = '£', digits = 0, big.mark = ',')),
        gradient = FALSE,
        subtitle = 'Additional NHS spending',
        elevation = 2,
        color = ifelse(input$customSwitch1, 'secondary', 'white')
      )
    })
    
  })  
  
  
  # graph -------------------------------------------------------------------
  
  output$shortages_graph <- highcharter::renderHighchart({
    
    req(output_dt$data)
    
    hc <- highcharter::highchart() %>% 
      
      highcharter::hc_yAxis_multiples(
        # value (primary y axis)	
        list(
          title = list(text = "Value £",
                       style = list(color = ifelse(input$customSwitch1, '#FFF', '#666666'))),
          labels = list(format = "{value:,.0f}",
                        style = list(color = ifelse(input$customSwitch1, '#FFF', '#666666'))),
          opposite = FALSE,
          min = 0,
          visible = TRUE
        ),
        # quantity (secondary y axis)
        list(
          title = list(text = "Quantity",
                       style = list(color = ifelse(input$customSwitch1, '#FFF', '#666666'))),
          labels = list(format = "{value:,.0f}",
                        style = list(color = ifelse(input$customSwitch1, '#FFF', '#666666'))),
          opposite = TRUE,
          min = 0,
          visible = TRUE
        )
      ) %>%  
      
      highcharter::hc_title(text = output_dt$title,
                            style = list(color = ifelse(input$customSwitch1, '#FFF', 'grey'))) %>%
      
      highcharter::hc_add_series(
        name = "Quantity", 
        data = output_dt$data[, quantity], 
        type = 'spline', marker = list(enabled = FALSE), lineWidth = 3, color = 'lightgrey', dashStyle = "shortdash", yAxis = 1) %>%
      highcharter::hc_add_series(
        name = "Additional NHS spending",
        data = output_dt$data, hcaes(x = xaxis_months, low = base_no_shortage_estimate, high = value),
        type = "arearange", marker = list(enabled = FALSE), lineWidth = 4, color = 'orange') %>%
      highcharter::hc_add_series(
        name = "No-shortage estimated NHS spending", 
        data = output_dt$data[, base_no_shortage_estimate], 
        type = 'spline', marker = list(symbol = 'circle'), lineWidth = 4, color = 'lightgreen')  %>%
      highcharter::hc_add_series(
        name = "Actual NHS spending", 
        data = output_dt$data[, value], 
        type = 'spline', marker = list(symbol = 'circle'), lineWidth = 4, color = 'red') %>%      
      highcharter::hc_legend(itemStyle = list(
        color = ifelse(input$customSwitch1, '#FFF', '#333333')))
    
    if (length(isolate(input$shortages_report_product_pack)) == 1) {
      
      hc <- hc %>%  
        
        highcharter::hc_xAxis(
          categories = xaxis_months, 
          plotLines = 
            isolate(output_dt$plot_lines_list),
          labels = list(style = list(color = ifelse(input$customSwitch1, '#FFF', '#666666')))
        )
    } else {
      
      hc <- hc %>%
        
        highcharter::hc_xAxis(
          categories = xaxis_months,
          labels = list(style = list(color = ifelse(input$customSwitch1, '#FFF', '#666666')))
        )
    }
    
    hc
  })
  
  
  # info button -------------------------------------------------------------
  
  observeEvent(input$info_id, ignoreInit = T, {
    
    showModal(
      modalDialog(
        title = 'Pharmaceutical Shortages', 
        easyClose = TRUE, 
        size = 'l', 
        fade = FALSE, 
        footer = modalButton(label = 'Close'), 
        
        HTML(
          'This R-Shiny application was developed to quantify the financial impact of generic pharmaceutical shortages in the United Kingdom. 
       Each month, an average of 24 active ingredients experience a supply shortage, putting patient\'s health at risk and also adding to the financial burden of the National Health Service (NHS). <br><br>
       
       During a supply shortage event, the NHS reimburse pharmacies at a higher rate for the drug, aiming to compensate the pharmacies for their additional spending on the higher-priced branded pharmaceutical alternatives. <br><br>
       
       We built a model in R which generates an estimation of the NHS spending had there not been a supply shortage at all and compared this against the actual spending amount. 
       The results are staggering, since 2015 the top 100 active ingredients alone have contributed to £1.7 billion (USD2.4 billion) additional spending. 
       The full amount including all active ingredients is over £2.5 billion (USD3.5 billion). 
       This amount continues to compound over time because the drug prices remain elevated for months and often years after the shortage event. <br><br>
       
       We wrote a blog about it 
       <a href="https://analytichealth.co.uk/quantifying-the-financial-impact-of-uk-generic-pharmaceutical-shortages/" target="_blank">here</a>, where you can read more about the issue or contact us to discuss it further.
       '
        )
       
      )
    ) 
    
  }) 
  
}
