%script for Alessandro Gattuso to visualize data from the GeoSPH program
%JR Arrowsmith 2017 updates July 2020
% Professor of Geology at Arizona State University
% Associate Director for Operations
% School of Earth and Space Exploration
% Arizona State University
% Tempe, AZ 85287-6004, U.S.A.
% (480) 965-5081 MAIN OFFICE (480) 965-8102 FAX
% ramon.arrowsmith@asu.edu

%file was renamed from alessandro_process_v7.m

close all
clear all
clc

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%set the variables; this is all you should have to change
mesh_file_name = 'vul.post.msh';
res_file_name = 'vul.post.res';
mesh_header_length = 2;
output_elements = 4; %this was 5 in the original model
FormatString = repmat('%f',1,output_elements); %'%f%f%f%f'
dotsize = 2; %size of points in the plots
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


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%read the lahar depths and velocities
%much of this comes from openExample('matlab_featured/textscanDemo')
resfileID = fopen(res_file_name);
intro = textscan(resfileID,'%s',1,'Delimiter','\n'); %Read one line at the top
model = 1;
heightresults = [];
velocityresults = [];
while (~feof(resfileID))
        
    %Read soil height
    SoilResultValue = cell2mat(textscan(resfileID,' Result "height soil" "Height soil" %f'));
    heightresults=[heightresults SoilResultValue];
    HeightInputText = textscan(resfileID,'%s',2,'delimiter','\n');
    HeightInputText = textscan(resfileID,FormatString, 'delimiter','\n');
    HeightData{model,1} = cell2mat(HeightInputText);
    EOM = textscan(resfileID,'%s',1,'delimiter','\n');  % Read and discard end-of-model marker
    
    %Read velocity
    VelResultValue = cell2mat(textscan(resfileID,'  Result "vel" "veloc" %f'));
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
    HeightData{i,1}(:,output_elements+3)=z_pos(HeightData{i,1}(:,1)); %z
end

%explain the columns:
fprintf('Height data columns:\n')
fprintf('1=node #, 2 and 3=unknown height, 4=height to plot\n')
fprintf('node locations 5=UTM easting, 6=UTM northing, 7=elevation\n')

figure
clf
title('Successive points of results soil height')
for i=1:t(1)
%for i=1:2
    scatter(HeightData{i,1}(:,output_elements+1), HeightData{i,1}(:,output_elements+2),[dotsize],HeightData{i,1}(:,output_elements), 'filled')
    axis([x_min x_max y_min y_max])
    drawnow
    %write out each into a new spreadsheet
    s=sprintf('_heights_model_%i.csv', i);
    filename=strcat(res_file_name,s);
    writematrix(HeightData{i,1},filename); %Needs R2019a https://www.mathworks.com/help/matlab/ref/writematrix.html
end


%Second, let's do the velocities
t=size(VelData);
for i=1:t(1)
    VelData{i,1}(:,output_elements+1)=sqrt((VelData{i,1}(:,output_elements).^2)+(VelData{i,1}(:,output_elements-1).^2)+(VelData{i,1}(:,output_elements-2).^2)); %3D vector length for the velocity
    VelData{i,1}(:,output_elements+2)=x_pos(VelData{i,1}(:,1)); %x 
    VelData{i,1}(:,output_elements+3)=y_pos(VelData{i,1}(:,1)); %y
    VelData{i,1}(:,output_elements+4)=z_pos(VelData{i,1}(:,1)); %z
    
end

%explain the columns:
fprintf('Velocity data columns:\n')
fprintf('1=node #, 2=x vel, 3=y vel, 4=z vel, 5=3D velocity\n')
fprintf('node locations 6=UTM easting, 7=UTM northing, 8=elevation\n') 

figure
clf
title('Successive points of results velocity')
for i=1:t(1)
    scatter(VelData{i,1}(:,output_elements+2), VelData{i,1}(:,output_elements+3),[dotsize],VelData{i,1}(:,output_elements+1), 'filled')
    axis([x_min x_max y_min y_max])
    drawnow
    %write out each into a new spreadsheet
    s=sprintf('_velocity_model_%i.csv', i);
    filename=strcat(res_file_name,s);
    writematrix(VelData{i,1},filename);
end


%Now we can do some additional mapping
%Start with soil thickness
t=size(HeightData);
figure
title('Model results--Soil Height')
for i=1:t(1)
subplot(3,floor(t(1)/3),i)
scatter(HeightData{i,1}(:,output_elements+1), HeightData{i,1}(:,output_elements+2),[dotsize],HeightData{i,1}(:,output_elements), 'filled')
colormap gray
axis off

end
colorbar


%Now we can do some additional mapping
%Velocity
t=size(VelData);
figure
title('Model results--Velocity 3D length')
for i=1:t(1)
subplot(3,floor(t(1)/3),i)
scatter(VelData{i,1}(:,output_elements+2), VelData{i,1}(:,output_elements+3),[dotsize],VelData{i,1}(:,output_elements+1), 'filled')
colormap summer
axis off
end
colorbar



