% Anim2 window parameters
global xmin
global xmax
global ymin
global ymax
xmin=0;xmax=40;ymin=0;ymax=3;

% Just in case
warning('off','all')
set_param('Redo7Long','MaxConsecutiveZCsMsg','none');   

% Computation
timeStep=.01;
rel=10^(-11);
abs=10^(-11);
MaxTime=60;

% Parameters for legs
m = 80; g = 9.81; kR =12000; kL =12000; l0 = 1;

% Parameters for energy sweep
%Vx0=3.58; y0=0.96;
Vx0=3.28980242567848; y0=0.96; % Set 1
Vx0=3.40699280891522; y0=0.92; % Set 2
Vx0=3.28980242567848; y0=0.96; % Set 3
Vx0=2.11; y0=0.98; % Set 4

% Reference ground level
yG=0;

% Initialize phi0
phi0=31/360*2*pi;% Set 1
phi0=44/360*2*pi;% Set 2
phi0=28.25/360*2*pi;% Set 3
phi0=31/360*2*pi;% Set 3

% For column reference
disp(["count i"   "noise level"]);
NoiseLevel=.00000001;time=now;

% Initial Conditions for CoM
x0 = 3; Vy0 = 0;

% This index is used for the Excel row selection (to make sure that each measurement goes in a different row)
i=0;
memI=i;
File=0;
FileLim=1000;
%FileLim=20;  %Test Only

% Store Data
Store_vect=NaN(FileLim,12);

% Noise parameters
minNoise=0;
maxNoise=10;

% Initial conditions on angles
a0L =asin(min(1,(y0-yG)/l0));a0R =a0L-phi0;

% Initial FlipFlop states
if y0-l0*sin(a0L)<=0 SRleft0=0; else SRleft0=1; end; % 1 is flight phase
if y0-l0*sin(a0R)<=0 SRright0=0; else SRright0=1; end; % 1 is flight phase

% Initial foot positions
xL0=x0+l0*cos(a0L);yL0=y0-l0*sin(a0L);
xR0=x0+l0*cos(a0R);yR0=y0-l0*sin(a0R);

% run simulink model (make sure it stops at the next apex) 
sim('Redo7Long');
