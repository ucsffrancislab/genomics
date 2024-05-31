
library('shiny')
library('shinyWidgets')
library('pheatmap')
library('tidyr')
#library('dplyr')


# Define UI for data upload app ----
#	fluidPage is apparently 12 unit wide.
#	by default the sidebarPanel is then 4 units wide and the mainPanel is 8
ui <- fluidPage(

  # App title ----
  titlePanel("TSV Heatmap"),

  # Sidebar layout with input and output definitions ----
  sidebarLayout(

    # Sidebar panel for inputs ----
    sidebarPanel( width = 2,

      # Input: Select a file ----
      fileInput("file1", "Choose TSV File",
                multiple = FALSE,
                accept = c("text/tsv", "text/tab-separated-values,text/plain", ".tsv")),

                #accept = c("text/csv", "text/comma-separated-values,text/plain", ".csv", ".tsv")),

      # Horizontal line ----
      tags$hr(),

      # Input: Checkbox if file has header ----
      checkboxInput("header", "Header", TRUE),

#      # Horizontal line ----
#      tags$hr(),
#
#			sliderInput(inputId = "minpident", 
#					label = "Minimum Percent Ident",
#					value = 25, min = 0, max = 100, step = 1),
#
#			sliderInput(inputId = "max_evalue_exponent", 
#					label = "Maximum e-value EXPONENT",
#					value = -1, min = -30, max = 1, step = 1),


			sliderInput(inputId = "maximum", 
					label = "Maximum",
					value = 100000, min = 0, max = 1000000, step = 10),

			sliderInput(inputId = "minimum", 
					label = "Minimum",
					value = 0, min = 0, max = 1000000, step = 10),

			uiOutput("slider_maximum"),
			uiOutput("slider_minimum"),
			#verbatimTextOutput("breaks")

		),


    # Main panel for displaying outputs ----
    mainPanel(

      # Output: Data file ----
      #tableOutput("contents")
			plotOutput(outputId = "plot",height="1000px")

    )
  )
)

#previous_filename=""

#	https://stackoverflow.com/questions/34323896/resetting-data-in-r-shiny-app-when-file-upload-fields-change


# Define server logic to read selected file ----
server <- function(input, output, session) {

  #myReactives <- reactiveValues()  
#	print( session$previous_filename )

	output$plot <- renderPlot({

		# input$file1 will be NULL initially. After the user selects
    # and uploads a file, 

		req(input$file1)

		# when reading semicolon separated files,
		# having a comma separator causes `read.csv` to error


#  observeEvent(input$file1, {

#print( session$previous_filename )
#print( input$file1$name )

#		if ( session$previous_filename != input$file1$name ){
#			session$previous_filename = input$file1$name
#		}

		tryCatch(
			{
				df <- read.csv(input$file1$datapath,
					header = input$header, 
					sep = "\t")
			},
			error = function(e) {
				# return a safeError if a parsing error occurs
				stop(safeError(e))
			}
		)

#observeEvent( input$file1, {
#print("Now I know that an attempt was made to upload a file and it was unsuccessful")
#})


#  observeEvent(input$file1,{
#    if (nrow(myfile()) > 100){
#    shinyalert("error","file too long",type = "error")
#      }
#  },ignoreNULL = FALSE)


		row.names(df)=df[[colnames(df)[1]]]

		df[[colnames(df)[1]]]=NULL

		#if( previous_filename != input$file1$name ){

#    	output$slider_maximum <- renderUI({
#      	sliderInput(
#        	inputId = "maximum",
#        	label = "Maximum:",
#        	min   = min(df),
#        	max   = max(df),
#					value = max(df)
##					value = input$maximum$value || max(df)
#      	)
#    	})
#
#    	output$slider_minimum <- renderUI({
#      	sliderInput(
#        	inputId = "minimum",
#        	label = "Minimum:",
#        	min   = min(df),
#        	max   = max(df),
#					value = min(df)
##					value = input$minimum$value || min(df)
#      	)
#    	})

#  })	#	observeEvent(input$file1, {


#		df = df[ 
#			apply(df, 1, function(x) ( max(x) > input$minimum ) && ( min(x) < input$maximum ) ),
#			apply(df, 2, function(x) ( max(x) > input$minimum ) && ( min(x) < input$maximum ) ) ]

#		pheatmap(df,

		pheatmap( df[ 
			apply(df, 1, function(x) ( max(x) > input$minimum ) && ( min(x) < input$maximum ) ),
			apply(df, 2, function(x) ( max(x) > input$minimum ) && ( min(x) < input$maximum ) ) ],

			main=input$file1$name,
			fontsize=16,
			fontsize_row=10,
			fontsize_col=10,
		)

	})	#	output$plot <- renderPlot({
}	#	server <- function(input, output) {

# Create Shiny app ----
shinyApp(ui, server)


#	Setup
#install.packages('rsconnect')
#rsconnect::setAccountInfo(name='jakewendt',
#	token='<TOKEN>',
#	secret='<SECRET>')

#	Publish
#library(rsconnect)
#rsconnect::deployApp(".",account="jakewendt",appName="tsv_heatmap")

#	Run locally
#	R -e "library(shiny);runApp(launch.browser = TRUE)"

