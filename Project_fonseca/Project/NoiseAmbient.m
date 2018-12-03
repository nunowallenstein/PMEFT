% Anim2 window parameters
global xmin
global xmax
global ymin
global ymax
xmin=0;xmax=220;ymin=0;ymax=3;

% Just in case
warning('off','all')
set_param('Redo7LongNoise','MaxConsecutiveZCsMsg','none');   

% Computation
timeStep=.01;
rel=10^(-11);
abs=10^(-11);
MaxTime=60;

% Parameters for legs
m = 80; g = 9.81; kR =12000; kL =12000; l0 = 1;

% Parameters for energy sweep
Vx0=3.58; y0=0.96;
Vx0=2.11; y0=0.98; % Set 4

% Reference ground level
yG=0;

% Initialize phi0
phi0=28/360*2*pi;
phi0=31/360*2*pi;% Set 3

% For column reference
disp(["count i"   "noise level"]);

% Initial Conditions for CoM
x0 = 3; Vy0 = 0;


% This index is used for the Excel row selection (to make sure that each measurement goes in a different row)
i=0;
memI=i;
File=0;
FileLim=1000;
%FileLim=20;  %Test Only

% Store Data
Store_vect=NaN(FileLim,15);

% Noise parameters
minNoise=0;
maxNoise=.1;
nRuns=0;       % How many runs per noise level 200
nNoiseRuns=1000; % How many noise levels 200

% Start cycle here
for nNoise=0:nNoiseRuns
    
% Set noise Level
NoiseLevel=minNoise+(maxNoise-minNoise)*nNoise/nNoiseRuns+.00000001;

    for NCycle=0:nRuns

    % Initial conditions on angles
    a0L =asin(min(1,(y0-yG)/l0));a0R =a0L-phi0;

    % Initial FlipFlop states
    if y0-l0*sin(a0L)<=0 SRleft0=0; else SRleft0=1; end; % 1 is flight phase
    if y0-l0*sin(a0R)<=0 SRright0=0; else SRright0=1; end; % 1 is flight phase

    % Initial foot positions
    xL0=x0+l0*cos(a0L);yL0=y0-l0*sin(a0L);
    xR0=x0+l0*cos(a0R);yR0=y0-l0*sin(a0R);

    % run simulink model (make sure it stops at the next apex) 
    time=now;
    %disp(i);
    %disp(noise);
        
    sim('Redo7LongNoise');i=i+1;File=File+1;
    rng('shuffle');

    % Store locally
    Store_vect(File,1)=i;
    Store_vect(File,2)=x0;
    Store_vect(File,3)=y0;
    Store_vect(File,4)=Vx0;
    Store_vect(File,5)=Vy0;
    Store_vect(File,6)=a0L*360/2/pi;
    Store_vect(File,7)=phi0*360/2/pi;
    Store_vect(File,8)=x_1;
    Store_vect(File,9)=y_1;
    Store_vect(File,10)=vx_1;
    Store_vect(File,11)=vy_1;
    Store_vect(File,12)=t_1;
    Store_vect(File,13)=NoiseLevel;
    Store_vect(File,14)=Lcount;
    Store_vect(File,15)=Rcount;
    
    % Periodic output to file
    if(i/FileLim == int16(i/FileLim)||i==(nRuns+1)*(nNoiseRuns+1)) 
        % Warn user
        disp([i/FileLim NoiseLevel]);
        % Output to file
        Range="A"+(memI+1)+":O"+(i+1);
        xlswrite("Output5",Store_vect,"sheet2",Range);
        % Clear stuff
        Store_vect=NaN(FileLim,15);
        clear Excel;
        % Inform user get ready for another round
        disp("========== Saved to Excel =====");
        memI=i;
        File=0;
    end; % End if

    end;
end;