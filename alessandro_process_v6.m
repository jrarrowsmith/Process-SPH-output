%script for Alessandro to visualize data from the Lahar program
%Arrowsmith 2017 updates July 2020
close all
clear all

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%set the variables; this is all you should have to change
mesh_file_name = 'vu6.post.msh';
res_file_name = 'vu6.post.res';
soilcolorbarmax = 1; %maximum value for the matlab soil thickness color bars
x_vel_colorbarmax = 2; %maximum value for the matlab x velocity color bars
y_vel_colorbarmax = 8; %maximum value for the matlab y velocity color bars
minimum_thickness = 0; %this is a minimum lahar thickness in meters
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

%set a few more variables
mesh_header_length = 2;
output_elements = 4; %this was 5 in the original model
FormatString = repmat('%f',1,output_elements); %'%f%f%f%f'

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%first load the nodes file (.msh)
meshfileID = fopen(mesh_file_name);

%assumes that the beginning of the file looks like this
% # encoding utf-8
% MESH "SPH points" dimension 3 ElemType Point Nnode 1
% Coordinates
% 1 495454.7 4250480 84.99999
for i=1:mesh_header_length
    t=fgetl(meshfileID);
end
formatSpec = '%d %f %f %f';
sizeA = [4 Inf];
A = fscanf(meshfileID,formatSpec,sizeA);
node_number=A(1,:);
x_pos=A(2,:); x_max = max(x_pos); x_min = min(x_pos); dx = x_pos(2)-x_pos(1);
y_pos=A(3,:); y_max = max(y_pos); y_min = min(y_pos); dy = y_pos(2)-y_pos(1);
z_pos=A(4,:);
fclose(meshfileID);

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%These plots are about the mesh points
%plot the mesh nodes
figure
clf
plot(x_pos,y_pos, 'k.') %2D
figure
clf
plot3(x_pos,y_pos,z_pos, 'k.') %3D

%this is not really necessary but just grids the mesh points into a dem
[xq,yq] = meshgrid(x_min:dx:x_max, y_min:dx:y_max); %assuming dx and dy are the same; we do need this to grid the results
[nrows, ncols]=size(xq);
topo = griddata(x_pos,y_pos,z_pos,xq,yq);
figure
clf
imagesc(x_min:dx:x_max,y_min:dx:y_max,flipud(topo))
colormap bone
axis equal
title('DEM of Mesh Points')


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%read the lahar depths and velocities
%much of this comes from openExample('matlab_featured/textscanDemo')
resfileID = fopen(res_file_name);
intro = textscan(resfileID,'%s',1,'Delimiter','\n'); %Read one line at the top
model = 1;
heightresults = [];
velocityresults = [];
while (~feof(resfileID))
    fprintf('Model: %s \n', num2str(model))
    
    %Read soil height
    SoilResultValue = cell2mat(textscan(resfileID,' Result "height soil" "Height soil" %f'));
    fprintf('Soil Height Result Value: %f\n', SoilResultValue);
    heightresults=[heightresults SoilResultValue];
    HeightInputText = textscan(resfileID,'%s',2,'delimiter','\n');
    HeightInputText = textscan(resfileID,FormatString, 'delimiter','\n');
    HeightData{model,1} = cell2mat(HeightInputText);
    EOM = textscan(resfileID,'%s',1,'delimiter','\n');  % Read and discard end-of-model marker
    
    %Read velocity
    VelResultValue = cell2mat(textscan(resfileID,'  Result "vel" "veloc" %f'));
    fprintf('Velocity Result Value: %f\n', VelResultValue);
    velocityresults=[velocityresults VelResultValue];
    VelInputText = textscan(resfileID,'%s',2,'delimiter','\n');
    VelInputText = textscan(resfileID,FormatString, 'delimiter','\n');
    VelData{model,1} = cell2mat(VelInputText);
    EOM = textscan(resfileID,'%s',1,'delimiter','\n');  % Read and discard end-of-model marker
    
    
    model = model+1;
end
fclose(resfileID);

%This step assigns the positions from the .msh file to the relevant .res
%nodes with the data
%First, let's do the soil heights
t=size(HeightData);
for i=1:t(1)
    HeightData{i,1}(:,output_elements+1)=x_pos(HeightData{i,1}(:,1)); %x 
    HeightData{i,1}(:,output_elements+2)=y_pos(HeightData{i,1}(:,1)); %y
    HeightData{i,1}(:,output_elements+3)=z_pos(HeightData{i,1}(:,1)); %y
end

figure
clf
title('Successive points of results soil height')
for i=1:t(1)
    plot(HeightData{i,1}(:,output_elements+1), HeightData{i,1}(:,output_elements+2), 'r.')
    axis([x_min x_max y_min y_max])
    drawnow
end

%Second, let's do the velocities
t=size(VelData);
for i=1:t(1)
    VelData{i,1}(:,output_elements+1)=x_pos(VelData{i,1}(:,1)); %x 
    VelData{i,1}(:,output_elements+2)=y_pos(VelData{i,1}(:,1)); %y
    VelData{i,1}(:,output_elements+3)=z_pos(VelData{i,1}(:,1)); %y
end

figure
clf
title('Successive points of results velocity')
for i=1:t(1)
    plot(VelData{i,1}(:,output_elements+1), VelData{i,1}(:,output_elements+2), 'b.')
    axis([x_min x_max y_min y_max])
    drawnow
end


%Now we can do some additional mapping
%Start with soil thickness
t=size(HeightData);
figure
title('Model results--Soil Height')
for i=1:t(1)
subplot(3,floor(t(1)/3),i)
height_soil_grid = griddata(HeightData{i,1}(:,output_elements+1), HeightData{i,1}(:,output_elements+2),HeightData{i,1}(:,output_elements),xq,yq);
locs=isnan(height_soil_grid);
height_soil_grid(locs)=-9999;
    %New addition May 2019 to put a floor on the lahar thickness for better
    %display
locs = height_soil_grid<=minimum_thickness;
height_soil_grid(locs)=-9999;
imagesc(flipud(height_soil_grid), [0 soilcolorbarmax])
colormap gray
axis off

    %write out ascii grids for each model
    filenametext=sprintf('_SoilHeight_%07.3f.asc',heightresults(i));
    filenametext=strcat(res_file_name, filenametext)
    fileID = fopen(filenametext,'w');
    fprintf(fileID,'ncols %d\n',ncols);
    fprintf(fileID,'nrows %d\n',nrows);
    fprintf(fileID,'xllcorner %f\n',x_min);
    fprintf(fileID,'yllcorner %f\n',y_min);
    fprintf(fileID,'cellsize %f\n',dx);
    fprintf(fileID,'NODATA_value %f\n',-9999);
    fclose(fileID);
    dlmwrite(filenametext,flipud(height_soil_grid),'-append', 'delimiter',' ')
end
colorbar

%Now we can do some additional mapping
%Velocity
t=size(VelData);
figure
title('Model results--Velocity x?')
for i=1:t(1)
subplot(3,floor(t(1)/3),i)
%here we are taking the second column which I am assuming is the x-component
x_vel_grid = griddata(VelData{i,1}(:,output_elements+1), VelData{i,1}(:,output_elements+2),VelData{i,1}(:,output_elements-2),xq,yq);
locs=isnan(x_vel_grid);
x_vel_grid(locs)=-9999;
imagesc(flipud(x_vel_grid), [0 x_vel_colorbarmax])
colormap summer
axis off

    %write out ascii grids for each model
    filenametext=sprintf('_x_velocity_grid_%07.3f.asc',velocityresults(i));
    filenametext=strcat(res_file_name, filenametext)
    fileID = fopen(filenametext,'w');
    fprintf(fileID,'ncols %d\n',ncols);
    fprintf(fileID,'nrows %d\n',nrows);
    fprintf(fileID,'xllcorner %f\n',x_min);
    fprintf(fileID,'yllcorner %f\n',y_min);
    fprintf(fileID,'cellsize %f\n',dx);
    fprintf(fileID,'NODATA_value %f\n',-9999);
    fclose(fileID);
    dlmwrite(filenametext,flipud(x_vel_grid),'-append', 'delimiter',' ')
end
colorbar

t=size(VelData);
figure
title('Model results--Velocity y?')
for i=1:t(1)
subplot(3,floor(t(1)/3),i)
%here we are taking the third column which I am assuming is the y-component
y_vel_grid = griddata(VelData{i,1}(:,output_elements+1), VelData{i,1}(:,output_elements+2),VelData{i,1}(:,output_elements-1),xq,yq);
locs=isnan(y_vel_grid);
y_vel_grid(locs)=-9999;
imagesc(flipud(y_vel_grid), [0 y_vel_colorbarmax])
colormap autumn
axis off

%     %write out ascii grids for each model
    filenametext=sprintf('_y_velocity_grid_%07.3f.asc',velocityresults(i));
    filenametext=strcat(res_file_name, filenametext)
    fileID = fopen(filenametext,'w');
    fprintf(fileID,'ncols %d\n',ncols);
    fprintf(fileID,'nrows %d\n',nrows);
    fprintf(fileID,'xllcorner %f\n',x_min);
    fprintf(fileID,'yllcorner %f\n',y_min);
    fprintf(fileID,'cellsize %f\n',dx);
    fprintf(fileID,'NODATA_value %f\n',-9999);
    fclose(fileID);
    dlmwrite(filenametext,flipud(x_vel_grid),'-append', 'delimiter',' ')
end
colorbar

%make a movie of the lahar propagating
t=size(HeightData);
figure
title('Model results--Soil Height')
F(t(1))=struct('cdata',[],'colormap',[]);
colorbar
for i=1:t(1)
    height_soil_grid = griddata(HeightData{i,1}(:,output_elements+1), HeightData{i,1}(:,output_elements+2),HeightData{i,1}(:,output_elements),xq,yq);
    imagesc(x_min:dx:x_max,y_min:dx:y_max,flipud(height_soil_grid), [0 soilcolorbarmax])
    colormap gray
    axis equal
    drawnow
    F(i) = getframe(gcf);
end
fig = figure;
movie(fig,F,5)
filenametext=sprintf('_SoilHeight')
filenametext=strcat(res_file_name, filenametext)
v = VideoWriter(res_file_name);
open(v)
writeVideo(v,F) %writes the video as an avi file
close(v)

%make a movie of the lahar propagating
t=size(VelData);
figure
title('Model results--Velocity x?')
F(t(1))=struct('cdata',[],'colormap',[]);
colorbar
for i=1:t(1)
    x_vel_grid = griddata(VelData{i,1}(:,output_elements+1), VelData{i,1}(:,output_elements+2),VelData{i,1}(:,output_elements-2),xq,yq);
    imagesc(x_min:dx:x_max,y_min:dx:y_max,flipud(x_vel_grid), [0 x_vel_colorbarmax])
    colormap summer
    axis equal
    drawnow
    F(i) = getframe(gcf);
end
fig = figure;
movie(fig,F,5)
filenametext=sprintf('_x_velocity');
filenametext=strcat(res_file_name, filenametext);
v = VideoWriter(res_file_name);
open(v)
writeVideo(v,F) %writes the video as an avi file
close(v)

t=size(VelData);
figure
title('Model results--Velocity y?')
F(t(1))=struct('cdata',[],'colormap',[]);
colorbar
for i=1:t(1)
    y_vel_grid = griddata(VelData{i,1}(:,output_elements+1), VelData{i,1}(:,output_elements+2),VelData{i,1}(:,output_elements-1),xq,yq);
    imagesc(x_min:dx:x_max,y_min:dx:y_max,flipud(y_vel_grid), [0 y_vel_colorbarmax])
    colormap autumn
    axis equal
    drawnow
    F(i) = getframe(gcf);
end
fig = figure;
movie(fig,F,5)
filenametext=sprintf('_y_velocity');
filenametext=strcat(res_file_name, filenametext);
v = VideoWriter(res_file_name);
open(v)
writeVideo(v,F) %writes the video as an avi file
close(v)

