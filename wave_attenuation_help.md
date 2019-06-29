This app computes the wave-attenuation factor for observations that are at
specified fraction with a water column of specified height. The results are
displayed as a graph of attenuation factor versus wave period.

The attenuation factor can be regarded as the ratio of pressure signal measured
at the specified depth, divided by the pressure signal what would be obtained
at a depth that is below the wave troughs.

Linear (also called infinitesimal) wave dynamics are assumed here, so the wave
attenuation factor is given by $cosh(k*(z+H))/cosh(k*H)$ where $k$ is the wave
number ($2*\pi/wavelength$), z$ is the vertical coordinate of the observation
(a negative number). The value of $k$ is calculated from the wave period by
using a root-finding method on the dispersion equation for infinitesimal waves
$\omega^2 = g*k*tanh(k*H)$ where $g$ is the acceleration due to gravity.

There are many sources for the equations above, and users who want to learn
more ought to start by consulting a textbook with which they are already
familiar.  (A paper dealing with nonlinear waves, which is *not* the topic
here, is https://arxiv.org/ftp/arxiv/papers/1703/1703.04654.pdf, and the
present app uses its equation 13 for the wave-attenuation factor.)
