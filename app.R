library(shiny)
options(shiny.maxRequestSize = 12 * 1024^2)

#User Interface
ui <- fluidPage(
  titlePanel("Principal Component Analysis - Gene Expression Data"),
  h4("Please choose the CSV files with the (1) input expression values (TPM/RPM/FPKM as rows, sample IDs as columns) and (2) metadata. Move the slider to adjust the lower percentage of variables based on variance to be removed."),
  sidebarLayout (
    sidebarPanel(
      h3("Input Parameters"),
      checkboxInput("Bioconductor_install", "This app requires Bioconductor. Check this box to install Bioconductor", FALSE),
      fileInput("input_matrix", label="Input CSV file with expression values"),
      checkboxInput("col1_genename", "The first column in the CSV file is gene/transcript names", FALSE),
      fileInput("input_metadata", label="Input CSV file with metadata"),
      textInput("group_name", "Enter the name of the column in the Metadata table that you wish to group the samples by"),
      sliderInput("slider1", label = "Percentage of variables to be removed", min =0, max = 50, value = 10)
    ),
    
    mainPanel(
    h1("PCA - Metadata, biplot and scree plot"),
    tabsetPanel(type = "tabs",
                tabPanel("Metadata Table", tableOutput("meta_table")),
                tabPanel("Biplot", plotOutput("biplot")),
                tabPanel("Scree Plot", plotOutput("screeplot")))
    
  )
  )
)

#Principal Component Analysis
server <- function(input, output) {

#Display metadata table 
  data <- reactive ({
    req(input$input_metadata)
    tbl <- read.csv(input$input_metadata$datapath, header=TRUE)
    return(tbl)
  })
  output$meta_table<-renderTable({data()})
    
#PCA biplot
  output$biplot<-renderPlot({
  req(input$input_matrix)
  req(input$input_metadata)
  if (input$Bioconductor_install) {
    if (!require("BiocManager", quietly = TRUE))
    {install.packages("BiocManager")}
      BiocManager::install("PCAtools")
  }
  
  library(PCAtools)
  mat<-read.csv(input$input_matrix$datapath, header=TRUE) #Read matrix of TPM/RPM/FPKM values
  if (input$col1_genename) { mat[1]<-NULL}
  metamyel<-read.csv(input$input_metadata$datapath, header=TRUE, row.names=1)
  colnames(mat)<-rownames(metamyel)
  p <- pca(mat, metadata = metamyel, removeVar = ((input$slider1)/100))
  req(input$group_name)
  biplot(p, colby = input$group_name, legendPosition = 'right')})
  
  #PCA scree plot
  output$screeplot<-renderPlot({
    req(input$input_matrix)
    req(input$input_metadata)
    screeplot(p)
  })
}

shinyApp(ui = ui, server = server)
