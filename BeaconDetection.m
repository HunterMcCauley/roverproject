% Purpose: Detect beacons at junctions and dead ends. Change the color of
%           the rover based on beacon rank, shifting from blue to red as 
%           the finish line is approached. User interrupt button allows 
%           for a movement to be cancled and changed.

% Inputs: Rover ID, Simulation GUI handles (requires modified
%           SimulationGUI.m and SimulationGUI.fig files)

% Outputs: No output, callback to image recognition function and update
%           rover display

% Usage: Place BeaconDetection(rover) in a continuous loop in the main
%           function to constantly scan for beacons. When the rover is within
%           distance to a beacon it will stop on the beacon, change the rover 
%           color according to beacon ranking, and call the image recognition 
%           function.

% Notes: The function must be called continuously to always update beacon 
%           locations relative to the rover.
%        The SimulatorGUI.m program must be modified to pass the handles
%           variable in the function push_auto_start_Callback to the user
%           defined function as an input, and to have a callback for the
%           user interrupt button
%        The SimulationGUI.fig must be modified to have the user interupt
%           button.

%% THIS IS A PSEUDO MAIN FUNCTION %%

function P__main__(rover,handlesGUI)
    
    % start tic-tac timer 
    tstart = tic;
    
    % plot beacons for demonstration because im too lazy to load maps
    setMap(rover,[],[],...
        {1,0, 1,1,1, "right";...
        -1,0, 1,1,1, "right";...
         1,1, 1,1,1, "right";...
        -1,1, 1,1,1, "wrong";...
         0,2, 1,1,1, "finished"}...
        ,[]);
    plot(1,0,'Color',[.5 .5 .5],'Marker','o')
    plot(-1,0,'Color',[.5 .5 .5],'Marker','o')
    plot(1,1,'Color',[.5 .5 .5],'Marker','o')
    plot(-1,1,'Color',[.5 .5 .5],'Marker','o') 
    plot(0,2,'Color',[.5 .5 .5],'Marker','o') 
    text(1,0,['  ' 'right']);
    text(-1,0,['  ' 'right']);
    text(1,1,['  ' 'right']);
    text(-1,1,['  ' 'wrong']); 
    text(0,2,['  ' 'FINISH LINE']);
    
    % vroom vroom rover
    LineFollower(rover,tstart)

    
    %% THIS WILL NEED TO BE IN THE REAL MAIN FUNCTION TO WORK %% 
    
    % Number of correct beacons correspond to the number of colors to cycle
    N = 5; % Must be odd
    
    % Add one color to include the initial color in the cycle
    N = N+1; 
    
    % Split choices between red to green, and green to blue gradients
    length = N/2;
    red2green = [linspace(1,0,length)',linspace(0,1,length)',zeros(length,1)];
    green2blue = [zeros(length,1),linspace(1,0,length)',linspace(0,1,length)'];
    
    % Remove green repeat, reduces color list by 1 choice so make last
    % beacon a 'finish line' beacon that congratulates
    red2green = red2green(1:end-1,:);
    
    % Join gradients into one color matrix, red to blue
    colors = [red2green;green2blue];
    
    % Interrupt button's UserData as cell, {0 for no interrupt, color matrix}
    handles = {0, colors};
    set(handlesGUI.pushbutton17,'UserData',handles);

    % Loop beacon detection to always scan for beacons
    while true
        BaconDetection(rover,tstart,handlesGUI)
    end
end
    
%% Beginning of actual BeaconDetection function, bacon for now because names
function BaconDetection(rover,tstart,handlesGUI,th)

    % Scan for beacons 
    [X, ~, Z, ~, ID] = ReadBeacon(rover);
    
    % Record data from closest beacon only
    [dist, id] = min(sqrt(X.^2+Z.^2));
    ID = ID(id,:);
    
    % Retrieve data stored in user interrupt button 'UserData'
    handles = get(handlesGUI.pushbutton17,'UserData');
    
    % If beacon is within range
    if dist <= 0.2
        
        % Center rover on beacon
        travelDist(rover,0.5,dist+0.103);
        
        % Stop rover from moving
        SetDriveWheelsCreate(rover,0,0);
        
        % Retrieve color list to cycle through
        colors = handles{2};

        % Get robot information 
        handles_robot= get(handlesGUI.figure_simulator,'UserData');
        
        % Find index corresponding to current robot color
        color_c = handles_robot.Color;
        index = find(ismember(colors,color_c,'rows'));
        
        % Wrong choice beacon encountered
        if strcmpi(ID, 'wrong')
            
            % color from red to blue
            color = colors(index+1,:);
            fprintf('\nYoure getting colder (farther)\n');
            
        % Right choice beacon encountered
        elseif strcmpi(ID, 'right')
            
            % color from blue to red
            color = colors(index-1,:);
            fprintf('\nYoure getting hotter (closer)\n');
            
        % Final beacon encountered
        elseif strcmpi(ID,'finished')
            % Finish message
            f = msgbox('You Finished, Yay!','Finish Line');
            uiwait(f);
            % Quit program
            error('done');
        end
        
        % Set rover color
        set(handles_robot(1),'Color',color);
        set(handles_robot(2),'Color',color);
        
        % Call image recognition function for next step
        ImageRecognition(rover,tstart,handlesGUI);
    end
    
    % If user interrupt button is pressed 
    if  handles{1} == 1
        
        % Reset interrupt indicator
        handles{1} = 0;
        set(handlesGUI.pushbutton17,'UserData',handles);
        
        % Call image recognition function for next step
        ImageRecognition(rover,tstart,handlesGUI);
    end
end

%% This is a Pseudo line follower func to verify compatibility and req
function LineFollower(rover,tstart)
    % Go Dog Go
    SetDriveWheelsCreate(rover,0.5,0.5)
    if toc(tstart) > 2400
        % No Dog No
        SetDriveWheelsCreate(rover,0,0);
    end
end

%% This is a Pseudo image recognition func to verify compatibility and req
function ImageRecognition(rover, tstart, handlesGUI)
    % Wheeeeeee
    obj= get(handlesGUI.text_title,'UserData');
    cord = rover.posAbs;
    th = rover.thAbs;
    th = th+pi/2;                     % Direction is set by second mouse click
    origin= [cord(1) cord(2) th];         % Start point is set by first mouse click
    setMapStart(obj,origin)
    % Good job encouragement
    fprintf('\nYaY! You hit a beacon and made a decision. \n Returning to line follower function...\n');
    % Pass on responsibility 
    pause(1);
    LineFollower(rover,tstart);
end
