# Process-SPH-output
This MATLAB script (and sample files once ready) were developed to read and analyze output from the SPH code. The main use was to support the mapping needed for the Gattuso, et al., Lahar risk assessment from source identification to potential impact analysis: the case of Vulcano Island, Italy, Journal of Applied Volcanology, 2021, DOI 10.1186/s13617-021-00107-6. 

The Smoothed Particle Hydrodynamics (SPH) code was used to compute flow velocities and deposit thicknesses. For intepretation, the model results need to be placed in context. In this case, the outputs are transformed into a series of cvs files which can be imported into GIS software such as ArcGIS or QGIS.  

The SPH outputs were two files: the first is a mesh file which specifies the mesh node positions while the second is the parameters of interest (height and velocity components) at each node location for each output time of the model.

It uses the https://www.mathworks.com/help/matlab/ref/writematrix.html MATLAB function which was introduced in R2019a. It is convenient but could be worked around with https://www.mathworks.com/help/matlab/ref/dlmwrite.html but that has been deprecated.




