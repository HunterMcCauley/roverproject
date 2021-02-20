clear all % <—–– Watch out if you need workspace vars

%{  
    Every time you run this program, it will add a circular wall/line 
    segment to the indicated map.txt file based on the user input to dlgbox

%}

%% THIS SECTION CAN BE IGNORED, GO TO THE NEXT FOR CHANGING FILE

% approximate each circle with 32 line segments
segments = 32; 
% dialogue box creation
prompt = {'Radius','\theta_{initial}','\theta_{final}'};
opts.Interpreter = 'tex';
x = inputdlg(prompt,'Add Circle',1,{'','',''},opts);
% dialogue info converted to doubles
r = str2double(x{1});
t_i = str2double(x{2});
t_f = str2double(x{3});
% degrees of each arc segment
delta_t = abs((t_i - t_f))/segments;
% first points of complete wall
points = [r*cosd(t_i), r*sind(t_i)];
% current angle being plotted
t = t_i+delta_t;
% loop through remaining angles and get plot data
for i = 2:2:segments*2
    points(i,:) = [r*cosd(t), r*sind(t)];
    points(i+1,:) = [r*cosd(t), r*sind(t)];
    t = t+delta_t;
end


%% PRINTING TO A TEXT FILE %% PLEASE READ %%
for i = 1:2:segments*2
    
    fid = fopen('BeaconTestMap.txt', 'a+'); % Change'BeaconTestMap.txt' to your map file
    
    % Make sure the file is in the MATLAB path or it wont print
    % Change 'wall' to 'line' below in order to switch between solid walls and
    % painted lines
    fprintf(fid, '\nwall %.4f %.4f %.4f %.4f', [points(i,1),points(i,2),points(i+1,1),points(i+1,2)]);
end
fprintf(fid,'\n');
fclose(fid);
