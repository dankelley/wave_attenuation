This app computes the wave-attenuation factor for observations that are at
specified fraction with a water column of specified height. The results are
displayed as a graph of attenuation factor versus wave period.

The plot shows (in a solid line) the dependence of pressure-reduction factor,
which is the ratio of pressure signal measured at a specified depth, divided by
the pressure signal what would be felt just below the wave troughs and (in a
dashed line) the length of the wave. Both are plotted as a function of wave
period. Clicking in the plot will display values above the plot, which can be
handy for extracting values for use in other analyses.

The calculation is based on several assumptions. First, the bottom is assumed
to be flat, which means that the tool is of limited use for shoaling waves,
e.g. if the water depth changes significantly over the wave length.  Second,
the theory of linear waves is employed, meaning that it is assumed that wave
height is very small compared with water depth. Third, the effects of both
friction and the rotation of the earth are ignored.  With these assumptions,
pressure-reduction factor may be computed as $cosh(k*(z+H))/cosh(k*H)$ where
$k$ is the wave number (i.e. $2\pi$ divided by wave length), $z$ is the height
of the observation above the surface of the water (this is a negative thus,
computed from the right-hand slider in the app), $H$ is the total water depth
(provided by the left-hand slider), and $cosh$ is the hyperbolic cosine
function. The value of $k$ is calculated from the wave period by using a
root-finding method on the dispersion equation for infinitesimal waves
$\omega^2 = g*k*tanh(k*H)$ where $\omega$ is the frequency ($2\pi$ divided by
the period), $g$ is the acceleration due to gravity and $tanh$ is the
hyperbolic tangent function.

There are many sources for the equations above, and users who want to learn
more ought to start by consulting a textbook with which they are already
familiar.
* A good introduction to the infererence of waves from pressure signals is
  Gibbons, D. T., G. Jones, E. Siegel, A. Hay, and F. Johnson. “Performance of
a New Submersible Tide-Wave Recorder.” In Proceedings of OCEANS 2005 MTS/IEEE,
1057-1060 Vol. 2, 2005. https://doi.org/10.1109/OCEANS.2005.1639895.
* A paper dealing with nonlinear waves, which is *not* the topic
here, is https://arxiv.org/ftp/arxiv/papers/1703/1703.04654.pdf.
