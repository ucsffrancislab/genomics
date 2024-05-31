
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
				accept = c(".gz", 
                   "text/tsv", "text/tab-separated-values,text/plain", ".tsv",
                   "text/csv", "text/comma-separated-values,text/plain", ".csv")),

			# Input: Checkbox if file has header ----
			checkboxInput("header", "Header", TRUE),

			# Input: Select separator ----
			radioButtons("sep", "Separator",
				choices = c(Comma = ",",
				Semicolon = ";",
				Tab = "\t"),
				selected = "\t"),

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



# Define server logic to read selected file ----
server <- function(input, output, session) {

	output$plot <- renderPlot({

		# input$file1 will be NULL initially. After the user selects
		# and uploads a file, 

		req(input$file1)

		tryCatch(
			{
				df <- read.csv( input$file1$datapath,
					header = input$header, 
					sep = input$sep
				)
			},
			error = function(e) {
				# return a safeError if a parsing error occurs
				stop(safeError(e))
			}
		)


		row.names(df)=df[[colnames(df)[1]]]

		df[[colnames(df)[1]]]=NULL


		#	The following is to detect when the file changes

		if(is.null(session$userData$filedatapath)){
			filedatapath=""
		}else{
			filedatapath=session$userData$filedatapath
		}

		if( input$file1$datapath != filedatapath ){
			session$userData$filedatapath=input$file1$datapath
			output$slider_maximum <- renderUI({
				sliderInput(
					inputId = "maximum",
					label = "Maximum:",
					min   = floor(min(df)),
					max   = ceiling(max(df)),
					value = max(df)
				)
			})
			output$slider_minimum <- renderUI({
				sliderInput(
					inputId = "minimum",
					label = "Minimum:",
					min   = floor(min(df)),
					max   = ceiling(max(df)),
					value = min(df)
				)
			})
		}

		maximum <- if(is.null(input$maximum))  1e10 else input$maximum
		minimum <- if(is.null(input$minimum)) 1e-10 else input$minimum

		pheatmap( df[ 
			apply(df, 1, function(x) ( max(x) > minimum ) && ( min(x) < maximum ) ),
			apply(df, 2, function(x) ( max(x) > minimum ) && ( min(x) < maximum ) ) ],

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

