function [sys,x0]=AnimWalkerGRF(t,x,u, flag, ts); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AnimWalkerGRF.m: S-function that animates the spring mass walking model %
%                  in the sagittal plane. Besides a two-leg stick figure, %
%                  the legs' ground reaction forces are shown.            %
% 																							                          %
%														 		                                          % 
% Last modified:   June, 2005										                          %
%            by:   H. Geyer  				       	                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





% ---------------- %
% DECLARATION PART %
% ---------------- %


% global variables and constants
global   FigureHndl      ...    % animation figure handle
  			 Spring          ...    % spring object
         hLeg hCOM       ...    % leg and com 
         hCOMTrace       ...    % COM trace
         hGndTrace              % Ground trace
         
        
         
         
  
% horizontal view window of walking model in meter
viewrange = 6; %[m]  
rerange   = 0.0; %relative to viewrange        
  
% colors
COMColor = 0.0*[0 0 0];
LegColor = [0.7 0 0];



% Traces Properties
% -----------------

% trace length in stored points
TraceLength = 4000; 






% ------------ %
% PROGRAM PART %
% ------------ %

% see Matlab S-Function Manual for the structuring of S-functions.

switch flag,
  

  
  % --------------
  % Initialization
  % --------------

  case 0,
     
    % create animation figure
    AnimSMR_Init('Spring Mass Running Model');
    
    % assign figure handle for later access (e.g. in 'case 2') 
    FigureHndl = findobj('Type', 'figure',  'Name', 'Spring Mass Running Model');
  
    
    % set axis range in meters
    axis([0-viewrange*rerange 0+viewrange*(1-rerange) -0.1 1.5]);

    set(gca, 'Visible', 'off')
        
    % create xy-vectors for COM and spring objects (in meters)
    SpringX = [0    0  -1/6  1/6  -1/6  1/6 -1/6  1/6 -1/6     0 0] *0.6;
    SpringY = [0 2/12  3/12 4/12  5/12 6/12 7/12 8/12 9/12 10/12 1];
    Spring  = [SpringX; SpringY]';    

    % initialize plot handles (note zero multiplication to avoid graphic output)
    hCOM = plot(0, 1, 'o', 'MarkerSize', 15, 'MarkerEdgeColor', COMColor, ...
                          'EraseMode', 'xor',  'LineWidth', 8);
    hLeg = plot(0*Spring(:,1), 0*Spring(:,2), 'Color',  LegColor,  'EraseMode', 'xor',  'LineWidth', 3);
    
    
    % create general trace line vector
    TraceVector = ones( TraceLength,1);

    % create hip trace 
    hCOMTrace = plot( 0*TraceVector, 0*TraceVector, 'k', 'LineWidth', 1);
      
    % create ground trace
    hGndTrace = plot( 0*TraceVector, 0*TraceVector, 'k', 'LineWidth', 1);
     
   

    % Simulink interaction
    % --------------------
    
    % set io-data: .  .  .  number of Simulink u(i)-inputs  .  .
    sys = [0 0 0 6 0 0];
    
    % initial conditions
    x0 = [];
  

  % end of initialization



  % -------------
  % Modifizierung
  % -------------

  case 2, 

    
    % find object 'FigureHndl' in matlab root
    if any( get(0,'Children') == FigureHndl ),
      
      % verify figure handle 
      if strcmp( get(FigureHndl,'Name'), 'Spring Mass Running Model'),
        

        % set actual figure to FigureHndl
        set(0, 'currentfigure', FigureHndl);
        
        % if COM leaves view range, adjust axes range  
        limit = get(gca,'XLim');
        if limit(2)<(u(1) + viewrange*rerange),
          set(gca,'XLim',[u(1)-viewrange*rerange  u(1)+viewrange*(1-rerange)])
        end
        
 
        
        % Ground
        % ------
        
        % get GRF trace points
        XData = get(hGndTrace, 'XData');
        YData = get(hGndTrace, 'YData');

        % shift trace points by one
        XData = [XData(2:end) u(3)];
        YData = [YData(2:end) u(5)];

        % set new trace points
        set(hGndTrace, 'XData', XData, 'YData', YData);

        
        
        % Ground
        % ------
        
        set(hCOM,  'XData', u(1),  'YData', u(2));
        
        
        % get GRF trace points
        XData = get(hCOMTrace, 'XData');
        YData = get(hCOMTrace, 'YData');

        % shift trace points by one
        XData = [XData(2:end) u(3)];
        YData = [YData(2:end) u(5)];

        % set new trace points
        set(hCOMTrace, 'XData', XData, 'YData', YData);

       
        

        % Leg Spring
        % ----------

        % calculate spring lengths (L) and angle of attack (alpha)
        L       =  sqrt( (u(3)-u(1))^2 + (u(4)-u(2))^2 );
        Alpha   = atan2( u(3)-u(1), u(2)-u(4) );
        
        % scale spring height and rotate spring to actual angle of attack
        SpringX = cos(Alpha)*Spring(:,1) - sin(Alpha)*Spring(:,2) *L;
        SpringY = sin(Alpha)*Spring(:,1) + cos(Alpha)*Spring(:,2) *L;
        
        % translate spring foot points to actual footpoints
        SpringX = SpringX + u(3);
        SpringY = SpringY + u(4);
        
        % reset xy-vector data for spring plot handles
        Style =  char(58-13*u(6));
        
        set(hLeg,  'XData', SpringX,  'YData', SpringY, ...
          'LineWidth', 2, 'LineStyle', Style);
        
        drawnow
      end 
    end


    
    sys = []; %no simulink interaction


  % end of modifications







  %%%%%%%%%%%%%%%%%%%%%%%
  % Ausgabe an Simulink %
  %%%%%%%%%%%%%%%%%%%%%%%
  case 3,                                                
    sys = []; %keine Ausgabe, nur Grafikroutine

   
    


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Zeitpunkt des nächsten Aufrufes der Funktion %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  case 4,

    % berechnen des nächsten Aufrufzeitpunkt
  	sys = t + ts;




  %%%%%%%%%%%
  % Abbruch %
  %%%%%%%%%%%
  case 9,
    sys=[]; %Aufräumen
    
    


  %%%%%%%%%%%%%%%%%%%%%
  % Unerwartetes flag %
  %%%%%%%%%%%%%%%%%%%%%
  otherwise
    error(['Unhandled flag = ',num2str(flag)]); %Fehlerausgabe




end %switch




% ------------- %
% FUNCTION PART %
% ------------- %

% Initialize Animation Window
function AnimSMR_Init(NameStr)


% check whether animation figure exists already
[ExistFlag, FigNumber] = figflag(NameStr);

% if not, initialize figure and axes objects
if ~ExistFlag,
   
  % define figure object 
  h0 = figure( ...
       'Tag',          NameStr, ...
       'Name',         NameStr, ...
       'NumberTitle',    'off', ...
       'BackingStore',   'off', ...
       'MenuBar',       'none', ...
			 'Color',        [1 1 1], ...
       'Position',     [100   300   900   450]);
     
  % define axes object
  h1 = axes( ...
       'Parent',              h0, ...
       'Tag',             'axes', ...    
       'Units',     'normalized', ...
       'Position',  [0.01 0.01 0.98 0.98], ...
       'FontSize',            8);

  
end %if ~existflag

cla reset;
set(gca, 'DrawMode', 'fast', ...
         'Visible',    'on', ...
         'Color',   [1 1 1], ...
         'XColor',  [0 0 0], ...
				 'YColor',  [0 0 0]);

axis on;
axis image;
hold on;



% end of function 


