% Purpose: Detect beacons at junctions and dead ends. Call color function
%           when a beacon is encountered.
% Inputs: Rover ID, Simulation GUI handles (requires modified
%           SimulationGUI.m file)
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
%           defined function as an input.

%% THIS IS A PSEUDO MAIN FUNCTION %%
function P__main__(rover,handlesGUI)
    
    % start tic-tac timer 
    tstart = tic;
    
    % plot beacons for demonstration because im too lazy to load maps
    setMap(rover,[],[],{[1],[0],[1],[1],[1],'b1'; [-1],[0],[1],[1],[1],'b2'},[]);
    plot(1,0,'Color',[.5 .5 .5],'Marker','o')
    plot(-1,0,'Color',[.5 .5 .5],'Marker','o')
    text(1,0,['  ' 'b1']);
    text(-1,0,['  ' 'b2']);
    
    % vroom vroom rover
    LineFollower(rover,tstart)
    
    %% THIS WILL NEED TO BE IN THE REAL MAIN FUNCTION TO WORK %%
    while true
        BaconDetection(rover,tstart,handlesGUI)
    end
end
    
%% Beginning of actual BeaconDetection function, bacon for now because names
function BaconDetection(rover,tstart,handlesGUI)
    % Scan for beacons and record data from closest
    [X, Y, Z, Rot, ID] = ReadBeacon(rover);
    
    % If beacon is within range
    if sqrt(X^2+Z^2)<=0.4
        
        % Center rover on beacon
        travelDist(rover,0.5,sqrt(X^2+Z^2)+0.103);
        % Stop rover from moving
        SetDriveWheelsCreate(rover,0,0);
        
        % Check beacon ID for position ranking 
        % NEED TO MAKE A VAR TO HOLD COLOR DATA, EACH WRONG DECISION BRINGS
        % BLUE SHADE UP AND EACH RIGHT DECISION BRINGS RED SHADE UP (OR
        % BRING OPPOSITE COLOR DOWN) (OR A MIX OR BOTH)
        if ID == 'b1'
            handles_robot= get(handlesGUI.figure_simulator,'UserData');
            set(handles_robot(1),'Color',[1 0 0]);
            set(handles_robot(2),'Color',[1 0 0]);
            fprintf('\nYoure getting hotter (closer)\n');
        elseif ID == 'b2'
            handles_robot= get(handlesGUI.figure_simulator,'UserData');
            set(handles_robot(1),'Color',[0 0 1]);
            set(handles_robot(2),'Color',[0 0 1]);
            fprintf('\nYoure getting colder (farther)\n');
        end
        
        % Call image recognition function for next step
        ImageRecognition(rover,tstart);
    end    
end

%% This is a Pseudo line follower func to verify compatibility and req
function LineFollower(rover,tstart)
    % Go Dog Go!
    SetDriveWheelsCreate(rover,0.5,0.5)
    if toc(tstart) > 1200
        % No Dog No!
        SetDriveWheelsCreate(rover,0,0);
    end
end

%% This is a Pseudo image recognition func to verify compatibility and req
function ImageRecognition(rover, tstart)
    % Wheeeeeee
    turnAngle(rover,0.5,180);
    % Good job encouragement
    fprintf('\nYaY! You hit a beacon and made a decision. \n Returning to line follower function...\n');
    % Pass on responsibility 
    LineFollower(rover,tstart);
end
