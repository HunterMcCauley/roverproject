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
    setMap(rover,[],[],{[1],[0],[1],[1],[1],'right'; [-1],[0],[1],[1],[1],'right'; [1],[1],[1],[1],[1],'right';[-1],[1],[1],[1],[1],'wrong'},[]);
    plot(1,0,'Color',[.5 .5 .5],'Marker','o')
    plot(-1,0,'Color',[.5 .5 .5],'Marker','o')
    plot(1,1,'Color',[.5 .5 .5],'Marker','o')
    plot(-1,1,'Color',[.5 .5 .5],'Marker','o')    
    text(1,0,['  ' 'right']);
    text(-1,0,['  ' 'right']);
    text(1,1,['  ' 'right']);
    text(-1,1,['  ' 'wrong']);    
    % vroom vroom rover
    LineFollower(rover,tstart)

    
    %% THIS WILL NEED TO BE IN THE REAL MAIN FUNCTION TO WORK %% 
    while true
        BaconDetection(rover,tstart,handlesGUI)
    end
end
    
%% Beginning of actual BeaconDetection function, bacon for now because names
function BaconDetection(rover,tstart,handlesGUI,th)
    % Scan for beacons and record data from closest
    [X, Y, Z, Rot, ID] = ReadBeacon(rover);
    [dist id] = min(sqrt(X.^2+Z.^2));
    ID = ID(id,:);
    
    % If beacon is within range
    if dist <= 0.2
        
        % Center rover on beacon
        travelDist(rover,0.5,dist+0.103);
        % Stop rover from moving
        SetDriveWheelsCreate(rover,0,0);
        
        % Check beacon ID for position ranking 
        % NEED TO MAKE A VAR TO HOLD COLOR DATA, EACH WRONG DECISION BRINGS
        % BLUE SHADE UP AND EACH RIGHT DECISION BRINGS RED SHADE UP (OR
        % BRING OPPOSITE COLOR DOWN) (OR A MIX OR BOTH)
        
        % Get robot information
        handles_robot= get(handlesGUI.figure_simulator,'UserData');
        % Set var to rover's current color value
        color = handles_robot.Color;
        
        % Wrong choice beacon encountered
        k = 0.5;
        if strcmpi(ID, 'wrong')
            if color(1) == 1 && color(2) < 1
                color(2) = color(2)+k;
                
            elseif color(1) > 0 && color(2) == 1
                color(1) = color(1)-k;
                
            elseif color(2) == 1 && color(3) < 1
                color(3) = color(3)+k;
                
            elseif color(2) > 0 && color(3) == 1 
                color(2) = color(2)-k;
                
            else

            end
            fprintf('\nYoure getting colder (farther)\n');
            
        elseif strcmpi(ID, 'right')
             if color(3) == 1 && color(2) < 1
                color(2) = color(2)+k;
                
            elseif color(3) > 0 && color(2) == 1
                color(3) = color(3)-k;
                
            elseif color(2) == 1 && color(1) < 1
                color(1) = color(1)+k;
                
            elseif color(2) > 0 && color(1) == 1 
                color(2) = color(2)-k;
             else
                
            end

            fprintf('\nYoure getting hotter (closer)\n');
        end
        
        for i = 1:3
            fprintf('\t\tThis is color %.0f: %0.3f\n',[i,color(i)]);
            if color(i) < 0
                color(i) = 0;
            elseif color(i) > 1
                color(i) = 1;
            end
        end
        set(handles_robot(1),'Color',color);
        set(handles_robot(2),'Color',color);
        
        % Call image recognition function for next step
        ImageRecognition(rover,tstart,handlesGUI);
    end    
end

%% This is a Pseudo line follower func to verify compatibility and req
function LineFollower(rover,tstart)
    % Go Dog Go!
    SetDriveWheelsCreate(rover,0.5,0.5)
    if toc(tstart) > 2400
        % No Dog No!
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
