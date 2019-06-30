library(shiny)

debug <- FALSE
version <- "1.0"
date <- "2019 June 29"

#' Wavenumber from wave period
#' @param tau wave period [s]
#' @param H water depth [m]
#' @param g acceleration due to gravity [m/s^2]
#' @return wavenumber [1/m]
tau2k <- function(tau, H, g=9.8)
{
    omega <- function(k, H, g=9.8)
        sqrt(g * k * tanh(k * H))
    o <- 2 * pi / tau # omega [rad/s]
    n <- length(o)
    k <- rep(NA, n)
    for (i in seq_len(n)) {
        k[i] <- uniroot(function(K) o[i] - omega(K, H), 2*pi/c(1e3,1e-3))$root
    }
    k
}

#' Ratio of wave pressure signal at depth z to that just below the wave
#' @param k wavenumber [1/m]
#' @param z observation coordinate (converted to a negative number) [m]
#' @param H water depth [m]
#' @return Pressure-reduction factor.
reductionFactor <- function(k, z, H)
{
    H <- abs(H)
    z <- -abs(z)
    cosh(k*(z+H))/ cosh(k*H)
}

ui <- fluidPage(h4(paste("Wave pressure reduction through the water column (version ", version, ", ", date, ")", sep="")),
                fluidRow(column(2, radioButtons("instructions",
                                                "Instructions",
                                                choices=c("Hide", "Show"),
                                                selected="Hide",
                                                inline=TRUE))),
                fluidRow(conditionalPanel(condition="input.instructions=='Show'",
                                          withMathJax(includeMarkdown("wave_attenuation_help.md")))),
                fluidRow(column(6, sliderInput(inputId="H",
                                               label="Water depth [m]",
                                               min=1, max=100, value=20, step=1)),
                         column(6, sliderInput(inputId="habOverH",
                                               label="Ratio of sensor height above bottom to water depth",
                                               min=0, max=1, value=0.05, step=0.01))),
                fluidRow(plotOutput("plot")))

server <- function(input, output) {
    output$plot <- renderPlot({
        tau <- seq(1, 12, length.out=500)
        H <- abs(input$H)
        z <- - H * (1 - input$habOverH)
        par(mar=c(3.3, 3.3, 1, 3.3), mgp=c(2, 0.7, 0))
        k <- tau2k(tau, H)
        rf <- reductionFactor(k=k, z=z, H=H)
        if (debug) {
            cat(file=stderr(), "z=", z, "H=", H, "\n")
            cat(file=stderr(), "    head(k)=", paste(head(k), collapse=" "), "\n")
            cat(file=stderr(), "    head(tau)=", paste(head(tau), collapse=" "), "\n")
            cat(file=stderr(), "    head(reductionFactor)=", paste(head(rf), collapse=" "), "\n")
        }
        plot(tau, rf, type="l", lwd=2,
             xlab="Period [s]", ylab="Solid: pressure reduction factor",
             xaxs="i", ylim=c(0, 1), yaxs="i")
        mtext(sprintf("Solid: pressure factor; dashed: wave length", z+H), side=3, line=0.25, adj=0)
        mtext(sprintf("Sensor %.2fm above bottom", z+H), side=3, line=0.25, adj=1)
        par(new=TRUE)
        plot(tau, 2*pi/k, axes=FALSE, xlab="", ylab="", type="l", lwd=2, xaxs="i", yaxs="i", lty="dashed",
             ylim=c(0, max(2*pi/k)))
        axis(4)
        mtext("Wave Length [m]", side=4, line=2)
        grid()
        #legend("topleft", lwd=2, col=c("black", "red"), legend=c("Pressure factor", "Wave length"), bg="white")
    }, pointsize=16)
}

shinyApp(ui, server)
