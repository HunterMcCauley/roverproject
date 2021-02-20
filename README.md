# roverproject
UTK – EF 230 rover robot project

This is a supporting file for notes and instructions
It will be updated accordingly 

——————— INSTRUCTIONS FOR MODDING THE SimulatorGUI.m FUNCTION ———————
This is a simple change that is necessary to update the color of the rover

1.) Open SimulatorGUI.m script
2.) Open the find dialogue and search for  “Run autonomous controller function”
3.) Change…
                % Run autonomous controller function
                feval(fileName,obj);
    Into...
                % Run autonomous controller function
                feval(fileName,obj,handles);

4.) Don’t forget to add ‘handlesGUI’ as an input to the main function 
	ie. function MAIN(rover,handlesGUI) if making a new program
