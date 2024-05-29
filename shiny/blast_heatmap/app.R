
library('shiny')
library('shinyWidgets')
library('pheatmap')
library('tidyr')


# Define UI for data upload app ----
ui <- fluidPage(

  # App title ----
  titlePanel("Uploading Files"),

  # Sidebar layout with input and output definitions ----
  sidebarLayout(

    # Sidebar panel for inputs ----
    sidebarPanel(

      # Input: Select a file ----
      fileInput("file1", "Choose CSV File",
                multiple = FALSE,
                accept = c("text/csv",
                         "text/comma-separated-values,text/plain",
                         ".csv")),

      # Horizontal line ----
      tags$hr(),

      # Input: Checkbox if file has header ----
      checkboxInput("header", "Header", TRUE),

      # Horizontal line ----
      tags$hr(),

			sliderInput(inputId = "minpident", 
					label = "Minimum Percent Ident",
					value = 25, min = 0, max = 100, step = 1),

			#	need better slider

			shinyWidgets::sliderTextInput("maxevalue","Maximum e-Value:",
				choices=c(0, 0.000001, 0.000005, 0.00001, 0.00005, 0.0001, 0.0005, 0.001, 0.005, 0.01, 0.05, 0.1, 0.5, 1, 5, 10),
				selected=0.5, grid = T ),

			sliderInput(inputId = "minbitscore", 
					label = "Minimum bit score",
					value = 20, min = 0, max = 500, step = 1)
		),

		#qaccver	saccver	pident	length	mismatch	gapopen	qstart	qend	sstart	send	evalue	bitscore


    # Main panel for displaying outputs ----
    mainPanel(

      # Output: Data file ----
      #tableOutput("contents")
			plotOutput(outputId = "plot",height="800px")

    )
  )
)

# Define server logic to read selected file ----
server <- function(input, output) {

	output$plot <- renderPlot({

    # input$file1 will be NULL initially. After the user selects
    # and uploads a file, head of that data file by default,
    # or all rows if selected, will be shown.

    req(input$file1)

    # when reading semicolon separated files,
    # having a comma separator causes `read.csv` to error
    tryCatch(
      {
        blast <- read.csv(input$file1$datapath,
                 header = input$header, 
                 sep = "\t")

print("input$header")
print(input$header)

				if( input$header == FALSE ){
					colnames(blast)=c(
						"qaccver","saccver","pident","length","mismatch","gapopen","qstart","qend","sstart","send","evalue","bitscore")
				}

				#	column types can be a problem if has a header and box is unchecked

				blast = blast[ which( blast['evalue'] <= input$maxevalue ), ]

				blast = blast[ which( blast['bitscore'] >= input$minbitscore ), ]

				blast = blast[ which( blast['pident'] >= input$minpident ), ]

				blast = blast[c('qaccver','saccver','bitscore')]

				#print(head(blast))

				df = blast %>% 
					pivot_wider( names_from = qaccver, values_from = bitscore, values_fn = max, values_fill = 0)

				df = as.data.frame(df)

				row.names(df)=df[[colnames(df)[1]]]

				df[[colnames(df)[1]]]=NULL

				#log_fun=function(x){ -log(x+1,base=10) }

				df1=data.frame(lapply(df,sqrt)) 

				row.names(df1)=row.names(df)

				#colnames(r1)=colnames(r)
	
				pheatmap(df1)
      },
      error = function(e) {
        # return a safeError if a parsing error occurs
        stop(safeError(e))
      }
    )
  })
}

# Create Shiny app ----
shinyApp(ui, server)


#	Setup
#install.packages('rsconnect')
#rsconnect::setAccountInfo(name='jakewendt',
#	token='<TOKEN>',
#	secret='<SECRET>')

#	Publish
#library(rsconnect)
#rsconnect::deployApp(".",account="jakewendt",appName="blast_heatmap")

#	Run locally
#	R -e "library(shiny);runApp(launch.browser = TRUE)"

