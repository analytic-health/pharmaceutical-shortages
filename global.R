
# libraries --------------------------------------------------------------------

library(data.table)
library(formattable)
library(highcharter)
library(shinyWidgets)
library(shiny)
library(shinyjs)
library(bs4Dash)


# initialise reactive values and read in global variables ----------------------

shortages_dt <- fread('shortages_data.csv')
xaxis_months <- shortages_dt[month_full >= as.Date('2015-01-01'), unique(xaxis_months)]
ai_choices <- sort(unique(shortages_dt$active_ingredients))
output_dt <- reactiveValues(data = NULL, 
                            plot_lines_list = NULL, 
                            title = 'UK National Health Service (NHS) spending on shortage affected pharmaceuticals')
product_pack <- reactiveValues(choices = NULL)


# Highcharter language options -------------------------------------------------

hcopts <- getOption("highcharter.lang")
hcopts$thousandsSep <- ","
hcopts$decimalPoint <- '.'
hcopts$loading  <- "Loading..."
hcopts$noData <- "No data to display"
options(highcharter.lang = hcopts)
