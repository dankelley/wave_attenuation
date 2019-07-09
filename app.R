library(shiny)

debug <- FALSE
version <- "1.3"
date <- "2019 July 9"

k2omega <- function(k, H, g=9.8)
{
    sqrt(g * k * tanh(k * H))
}

#' Wavenumber from wave period
#' @param tau wave period [s]
#' @param H water depth [m]
#' @param g acceleration due to gravity [m/s^2]
#' @return wavenumber [1/m]
tau2k <- function(tau, H, g=9.8)
{
    omega <- 2 * pi / tau # omega [rad/s]
    n <- length(omega)
    k <- rep(NA, n)
    for (i in seq_len(n)) {
        k[i] <- uniroot(function(K) omega[i] - k2omega(K, H), 2*pi/c(1e3,1e-3))$root
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

ui <- fluidPage(h5(paste("Wave pressure reduction through the water column (version ", version, ", ", date, ")", sep="")),
                fluidRow(column(12, checkboxInput("instructions", "Show instructions", value=FALSE))),
                fluidRow(conditionalPanel(condition="input.instructions",
                                          withMathJax(includeMarkdown("wave_attenuation_help.md")))),
                fluidRow(column(12, radioButtons("x", label=h5("Display results in terms of"),
                                                 choices=list("Wave period"=1, "Wave length"=2), selected=1, inline=TRUE))),
                fluidRow(column(6, sliderInput(inputId="H",
                                               label="Water depth [m]",
                                               min=1, max=100, value=20)),
                         column(6, sliderInput(inputId="hab",
                                               label="Sensor height above bottom",
                                               min=0, max=100, value=0))),
                fluidRow(uiOutput(outputId="showSample")),
                fluidRow(plotOutput("plot", click="click")))

server <- function(input, output, session) {

    state <- reactiveValues(msg=NULL)

    observeEvent(input$H, {
                 updateSliderInput(session=session, inputId="hab", value=0, max=input$H)
                })

    output$showSample <- renderText({
        if (!is.null(state$msg)) state$msg else "Click in the plot to show values here."
    })

    observeEvent(input$click, {
                 H <- abs(input$H)
                 z <- -H + input$hab
                 if (input$x == 1) {
                     ## x is wave period
                     tau <- input$click$x
                     k <- tau2k(tau, H)
                 } else {
                     ## x is wave length
                     k <- 2 * pi / input$click$x
                     tau <- 2 * pi / k2omega(k, H)
                 }
                 rf <- reductionFactor(k=k, z=z, H=H)
                 state$msg <<- paste(sprintf(" Period: %.1fs, Pressure Factor: %.2g, Wave Length: %.1fm",
                                             tau, rf, 2 * pi / k))
    })

    output$plot <- renderPlot({
        tau <- seq(1, 12, length.out=500)
        H <- abs(input$H)
        z <- -H + input$hab
        par(mar=c(3.3, 3.3, 1, 3.3), mgp=c(2, 0.7, 0))
        k <- tau2k(tau, H)
        rf <- reductionFactor(k=k, z=z, H=H)
        if (debug) {
            cat(file=stderr(), "hab=", input$hab, ", H=", H, "; therefore z=", z, "\n")
            cat(file=stderr(), "    head(k)=", paste(head(k), collapse=" "), "\n")
            cat(file=stderr(), "    head(tau)=", paste(head(tau), collapse=" "), "\n")
            cat(file=stderr(), "    head(reductionFactor)=", paste(head(rf), collapse=" "), "\n")
        }
        wavelength <- 2 * pi / k
        if (input$x == 1) {
            plot(tau, rf, type="l", lwd=2,
                 xlab="Period [s]", ylab="Pressure Factor",
                 xaxs="i", ylim=c(0, 1), yaxs="i")
            legend("topleft", horiz=TRUE, lty=c("solid", "dashed"), lwd=2,
                   legend=c("Pressure Factor", "Wave Length"), bg="white")
            par(new=TRUE)
            plot(tau, wavelength, axes=FALSE, xlab="", ylab="", type="l", lwd=2, xaxs="i", yaxs="i", lty="dashed",
                 ylim=c(0, max(wavelength)))
            axis(4)
            mtext("Wave Length [m]", side=4, line=2)
        } else if (input$x == 2) {
            plot(2*pi/k, rf, type="l", lwd=2,
                 xlab="Wavelength [m]", ylab="Pressure Factor",
                 xaxs="i", ylim=c(0, 1), yaxs="i")
            legend("topleft", horiz=TRUE, lty=c("solid", "dashed"), lwd=2,
                   legend=c("Pressure Factor", "Period"), bg="white")
            par(new=TRUE)
            plot(wavelength, tau, axes=FALSE, xlab="", ylab="", type="l", lwd=2, xaxs="i", yaxs="i", lty="dashed",
                 xlim=c(0, max(wavelength)))
            axis(4)
            mtext("Period [s]", side=4, line=2)
        } else {
            stop("programming error: how can input$x not be 1 or 2?")
        }
    }, pointsize=16)
}

shinyApp(ui, server)

