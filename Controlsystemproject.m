%% Mech 481/Control system project/Fall 2019
% PID Ball levitation
clear all; close all; clc;

vrep=remApi('remoteApi');               %using the prototype file (remoteApiProto.m)
vrep.simxFinish(-1);                    %just in case, close all opened connections
    clientID=vrep.simxStart('127.0.0.1',19999,true,true,5000,5);

if (clientID>-1)
    disp('Connected to remote API server');
    
%Initialize variables for simulink model
M = 0.0027;                             %Mass of ball [Kg]
B = 0.001;                              %Damp Value of walls
g = 9.81;                               %Gravity [m/s^2]
Kb = 2.868;                             
La = 220;                               %Inductance of Motor [mH]
Ra = 176;                               %Resistance of Motor [ohms]
Bm = 0.001;                             %Damp Value of Motor
Jm = .05;                               %Moment of inertia of motor

Target = 10;                            %Define target height

    %Assign variables to joint handles
	[returnCode,Fan]=vrep.simxGetCollectionHandle(clientID,'Fan',vrep.simx_opmode_blocking);
    [returnCode,Ball]=vrep.simxGetCollectionHandle(clientID,'Ball',vrep.simx_opmode_blocking);
    
    %Get Ball position: Specify -1 to retrieve the absolute position
    [returnCode,InitialPos]=vrep.simxGetObjectPosition(clientID,'Ball',-1,vrep.simx_opmode_streaming);
    InitialPos = BallOrigin;            %Set Initial Position of Ball in Vrep to new Matlab variable

    open('ControlSystemProject.slx')    %Open the Simulink File
while true
    
    sim('ControlSystemProject.slx')     %Run the Block diagram
    
    z = yout + BallOrigin;              %Get Z coordinate for new ball location
    NewPosition = 0,0,z ;
    
    %Set the ball to its new height in Vrep
    [returnCode]=simxSetObjectPosition(clientID,'Ball',-1,NewPosition,vrep.simx_opmode_streaming)
    
    %***Within Command Window press 'ctrl+c' to end the loop***
end

else
    disp('Failed connecting to remote API server');
end

    vrep.delete();                      % call the destructor!
    
    disp('Program ended');
    