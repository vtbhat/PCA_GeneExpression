# PCA_GeneExpression
R/Shiny app to perform principal component analysis of a matrix of gene expression values

Input: Two CSV files
1. Matrix of TPM/RPM/FPKM values for each gene as rows, and the sample IDs as column labels
2. Metadata with the first column containing sample IDs

Output: PCA biplot and scree plot


To run the application on R:

library(shiny)
runGitHub( "PCA_GeneExpression", "vtbhat")
