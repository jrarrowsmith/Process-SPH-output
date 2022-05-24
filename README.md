# Process-SPH-output
This MATLAB script were developed to read and analyze output from the SPH code. The main use was to support the mapping needed for
Gattuso, A., Bonadonna, C., Frischknecht, C., Cuomo, C., Baumann, V., Pistolesi, M., Biass, S., Arrowsmith, J R., Moscariello, M., Rosi, M., Lahar
Risk Assessment: the case study of Vulcano Island, Italy, Journal of Applied Volcanology, 10, 9, https://doi.org/10.1186/s13617-021-00107-6, 2021. 

The Smoothed Particle Hydrodynamics (SPH) code was used to compute flow velocities and deposit thicknesses. For intepretation, the model results need to be placed in context. In this case, the outputs are transformed into a series of cvs files which can be imported into GIS software such as ArcGIS or QGIS.  

The SPH outputs were two files: the first is a mesh file which specifies the mesh node positions while the second is the parameters of interest (height and velocity components) at each node location for each output time of the model.

It uses the https://www.mathworks.com/help/matlab/ref/writematrix.html MATLAB function which was introduced in R2019a. It is convenient but could be worked around with https://www.mathworks.com/help/matlab/ref/dlmwrite.html but that has been deprecated.




