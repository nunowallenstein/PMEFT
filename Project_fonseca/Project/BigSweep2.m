% Anim2 window parameters
global xmin
global xmax
global ymin
global ymax
xmin=0;xmax=25;ymin=0;ymax=3;

% Just in case
warning('off','all')
set_param('Redo7','MaxConsecutiveZCsMsg','none');   

% Parameters for legs
m = 80; g = 9.81; kR =12000; kL =12000; l0 = 1;

% Parameters for energy sweep
V0maxEver=6;% [m/s]% 6 12;
V0minEver=2;% [m/s]
Y0maxEver=1.2;% [m]
Y0minEver=.8;% [m]

% Reference ground level
yG=0;

% Min and Max Energy to Search
EmaxEver=1/2*m*(V0maxEver*V0maxEver+0)+m*g*(Y0maxEver-yG);
EminEver=1/2*m*(V0minEver*V0minEver+0)+m*g*(Y0minEver-yG);

% Define apex map parameters
%NEn = 40;Ny = 40;Nphi0=90;
NEn = 20;Ny = 20;Nphi0=90; %%% 34
%NEn = 4;Ny = 4;Nphi0=4;  %Test Only

% Initialize phi0
minPhi0=0/360*2*pi;
maxPhi0=90/360*2*pi;

% For column reference
disp(["count i"    "x0  " "y0  " "Vx0  " "Vy0  " "aL0  " "phi0  " "x_1  " "y_1  " "vx_1  " "vy_1  " "t_1  "]);

% This index is used for the Excel row selection (to make sure that each measurement goes in a different row)
i=0;
memI=i;
File=0;
FileLim=1000;
%FileLim=20;  %Test Only

% Computation
timeStep=.01;
rel=10^(-11);
abs=10^(-11);
MaxTime=60;

% Store Data
Store_vect=NaN(FileLim,12);

% phi0 Cycle

for Nphi0Cycle=0:Nphi0

    phi0=minPhi0+(maxPhi0-minPhi0)/Nphi0*Nphi0Cycle;
    
    % Energy Cycle
    for NEnCycle = 0:NEn

        Esys=EminEver+(EmaxEver-EminEver)/NEn*NEnCycle;
        yMax=Esys/(m*g);
        yMaxRel=min(yMax,Y0maxEver);

        % Height cycle inside Energy Cycle
        for NyCycle = 0:Ny

                % Initial Conditions for CoM
                x0 = 3; Vy0 = 0;

                % set the rest of the initial conditions ensuring constant energy
                y0  = Y0minEver+(yMaxRel-Y0minEver)*NyCycle/Ny; Vx0=real((2/m*(Esys-m*g*(y0-yG)))^.5);

                % Initial conditions on angles
                a0L =asin(min(1,(y0-yG)/l0));a0R =a0L-phi0;

                % Initial FlipFlop states
                if y0-l0*sin(a0L)<=0 SRleft0=0; else SRleft0=1; end; % 1 is flight phase
                if y0-l0*sin(a0R)<=0 SRright0=0; else SRright0=1; end; % 1 is flight phase

                % Initial foot positions
                xL0=x0+l0*cos(a0L);yL0=y0-l0*sin(a0L);
                xR0=x0+l0*cos(a0R);yR0=y0-l0*sin(a0R);

                 % run simulink model (make sure it stops at the next apex)
                sim('Redo7');i=i+1; File=File+1;
                drawnow; pause(0.1);
               
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

                % Periodic output
                if(i/FileLim == int16(i/FileLim)||i==(NEn+1)*(Ny+1)*(Nphi0+1)) 
                    % Warn user
                    disp([i/FileLim x0 y0 Vx0 Vy0 a0L*360/2/pi phi0*360/2/pi x_1 y_1 vx_1 vy_1 t_1]);
                    % Output to file
                    Range="A"+(memI+1)+":L"+(i+1);
                    xlswrite("Output5",Store_vect,"sheet1",Range);
                    % Clear stuff
                    Store_vect=NaN(FileLim,12);
                    clear Excel;
                    % Inform user get ready for another round
                    disp("========== Saved to Excel =====");
                    memI=i;
                    File=0;
                end
        end
    end
end

disp("end BigSweep2");