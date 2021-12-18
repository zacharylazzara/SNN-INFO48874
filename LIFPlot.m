% Written by Zachary Lazzara and Dennis Suarez

clc;
clear;

% Figure Settings
figure;
WIDTH = 1000;
HEIGHT = 700;
SCREEN = get(0,'ScreenSize');
set(gcf, 'Position', [floor(SCREEN(3)/4), floor(SCREEN(4)/3), WIDTH, HEIGHT], 'Name', 'INFO48874 - Spiking Neuron Simulation');

% Constants %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot Settings
PADDING = 2;
COLOURS =  {[0      0.4470 0.7410];
            [0.8500 0.3250 0.0980];
            [0.9290 0.6940 0.1250];
            [0.4940 0.1840 0.5560];
            [0.4660 0.6740 0.1880];
            [0.3010 0.7450 0.9330];
            [0.6350 0.0780 0.1840]}';

TMAX                = 120;
TIMESTEP            = 0.1;
MARKER              = 'o';

% Neuron Properties (to use defaults, define the layers without these settings).
REFRACTORY_PERIOD   =  5;  % Period the neuron cannot fire another spike.
V_THRESHOLD         =  20;  % Spiking threshold.
V_INFINITY          =  25;  % Upper bound on neuron voltage.
V_RESET             = -70;  % Offset. Unused in calculations (to simplify things), but included because neurons normally operate around -70mV.

% Layer Properties (set to 0 to disable)
INPUT_NEURONS       = 1;
OUTPUT_NEURONS      = 1;
HIDDEN_NEURONS      = 9;
HIDDEN_LAYERS       = 3;

% Detail Plot Grid
LAYER_ROWS          = 4;
ROWS                = (HIDDEN_LAYERS+2)*LAYER_ROWS;
COLUMNS             = 2;

% Input Signals %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
REPEATING_SIGNAL    = false;    % Determines if the signal should be repeated after ending or not.
TIME_RANGE          = [5, 40];  % Should always be two values

% Alternatively, we can define the TIMEKEY as TIMEKEY = [0, 1, 2, 3, etc].
% It doesn't need to be in order of time either.

TIMEKEY = zeros(max(TIME_RANGE)-min(TIME_RANGE),1);
for t=min(TIME_RANGE):max(TIME_RANGE)
    TIMEKEY(t-min(TIME_RANGE)+1) = t;
end

% Signal generators
SIG1_GEN = @(t) 1+sin(pi*t)/5; 
% SIG2_GEN = @(t) 2+sin(pi*t);

SIGNAL{length(TIMEKEY),1} = [];
for i=1:length(SIGNAL) % Define when a given signal generator will be used.
    SIGNAL{i} = SIG1_GEN;
%     if i < 10 || i > 20
%         SIGNAL{i} = SIG1_GEN;
%     else
%         SIGNAL{i} = SIG2_GEN;
%     end
end
SIGNAL_MAP = containers.Map(TIMEKEY, SIGNAL);
MAIN_AXIS_RANGE = [0 TMAX (V_RESET-PADDING) (V_INFINITY+PADDING)];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
plotIndex = COLUMNS;


% Signal Plot
signalRows = (plotIndex-1):(COLUMNS-1):(plotIndex+LAYER_ROWS);
signalPlot = subplot(ROWS,COLUMNS,signalRows);
plotIndex = max(signalRows)+COLUMNS;
% cla(signalPlot);

title(signalPlot, 'Signal In');
xlabel(signalPlot, 'Time (ms)');
ylabel(signalPlot, 'Signal Voltage (mV)');
xline(signalPlot, 0, '-');
xline(signalPlot, TMAX, '-');
axis(signalPlot, [0 TMAX (min(SIG1_GEN(0:TMAX))-PADDING+V_RESET) (max(SIG1_GEN(0:TMAX))+PADDING+V_RESET)]);

signalArrow = animatedline(signalPlot, 'Color', 'r', 'Marker', '<', 'MarkerFaceColor', 'r', MaximumNumPoints=1);
signalPoint = animatedline(signalPlot, 'Color', 'r', 'Marker', MARKER, 'MarkerFaceColor', 'r', MaximumNumPoints=1);
signalLine = animatedline(signalPlot, 'Color', 'r');





colourOffset = 1;
neuronColours = @(neuronOffset, layerOffset) COLOURS{mod(neuronOffset, length(COLOURS))+1}/layerOffset;

% Input layers
if INPUT_NEURONS > 0
    inputLayer = LIFLayer(TIMESTEP, INPUT_NEURONS, V_THRESHOLD, V_RESET, V_INFINITY, REFRACTORY_PERIOD);
    inputPoints{INPUT_NEURONS,1} = [];
    inputLines{INPUT_NEURONS,1} = [];
    inputRows = plotIndex:COLUMNS:(plotIndex+LAYER_ROWS);
    inputPlot = subplot(ROWS,COLUMNS,inputRows);
    plotIndex = max(inputRows)+COLUMNS;
%     cla(inputPlot);
    
    
    title(inputPlot, 'Input Layer Neuron(s)');
    xlabel(inputPlot, 'Time (ms)');
    ylabel(inputPlot, 'mV');
    yline(inputPlot, inputLayer.V_THRESHOLD, '--', 'V_{th}');
    yline(inputPlot, inputLayer.V_INFINITY, '--', 'V_\infty');
    yline(inputPlot, inputLayer.V_RESET, '--', 'V_{reset}');
    xline(inputPlot, 0, '-');
    xline(inputPlot, TMAX, '-');
    axis(inputPlot, [0 TMAX (inputLayer.V_RESET-PADDING) (inputLayer.V_INFINITY+PADDING)]);
    
    
    
    for n=1:INPUT_NEURONS
        colours = neuronColours(n, colourOffset);
        inputPoints{n} = animatedline(inputPlot, 'Color', colours, 'Marker', MARKER, 'MarkerFaceColor', colours, MaximumNumPoints=1);
        inputLines{n} = animatedline(inputPlot, 'DisplayName', sprintf('N%d_{input}',n), 'Color', colours);
    end
end

% Hidden layers
if HIDDEN_LAYERS > 0 && HIDDEN_NEURONS > 0
    hiddenPlots{HIDDEN_LAYERS,1} = [];
    hiddenLayers{HIDDEN_LAYERS,1} = [];
    hiddenPoints{HIDDEN_LAYERS,HIDDEN_NEURONS} = [];
    hiddenLines{HIDDEN_LAYERS,HIDDEN_NEURONS} = [];
    for i=1:HIDDEN_LAYERS
%         colourOffset = colourOffset + 0.1; % No longer need to offset the colour since we've put the layers on separate subplots
        hiddenLayers{i} = LIFLayer(TIMESTEP, HIDDEN_NEURONS, V_THRESHOLD, V_RESET, V_INFINITY, REFRACTORY_PERIOD);
        hiddenRows = plotIndex:COLUMNS:(plotIndex+LAYER_ROWS);
        hiddenPlots{i} = subplot(ROWS,COLUMNS,hiddenRows);
        plotIndex = max(hiddenRows)+COLUMNS;
%         cla(hiddenPlots{i});
        
        
        title(hiddenPlots{i}, sprintf('Hidden Layer %d Neuron(s)', i));
        xlabel(hiddenPlots{i}, 'Time (ms)');
        ylabel(hiddenPlots{i}, 'mV');
        yline(hiddenPlots{i}, hiddenLayers{i}.V_THRESHOLD, '--', 'V_{th}');
        yline(hiddenPlots{i}, hiddenLayers{i}.V_INFINITY, '--', 'V_\infty');
        yline(hiddenPlots{i}, hiddenLayers{i}.V_RESET, '--', 'V_{reset}');
        xline(hiddenPlots{i}, 0, '-');
        xline(hiddenPlots{i}, TMAX, '-');
        axis(hiddenPlots{i}, [0 TMAX (hiddenLayers{i}.V_RESET-PADDING) (hiddenLayers{i}.V_INFINITY+PADDING)]);
        for n=1:HIDDEN_NEURONS
            colours = neuronColours(n, colourOffset);
            hiddenPoints{i,n} = animatedline(hiddenPlots{i}, 'Color', colours, 'Marker', MARKER, 'MarkerFaceColor', colours, MaximumNumPoints=1);
            hiddenLines{i,n} = animatedline(hiddenPlots{i}, 'DisplayName', sprintf('N%d_{layer %d}', n, i), 'Color', colours);
        end
    end
end

% Output layers
if OUTPUT_NEURONS > 0
    outputLayer = LIFLayer(TIMESTEP, OUTPUT_NEURONS, V_THRESHOLD, V_RESET, V_INFINITY, REFRACTORY_PERIOD);
    outputPoints{OUTPUT_NEURONS,1} = [];
    outputLines{OUTPUT_NEURONS,1} = [];
    outputRows = plotIndex:COLUMNS:(plotIndex+LAYER_ROWS);
    outputPlot = subplot(ROWS,COLUMNS,outputRows);
    plotIndex = max(outputRows)+COLUMNS;
%     cla(outputPlot);
    
    
    title(outputPlot, 'Output Layer Neuron(s)');
    xlabel(outputPlot, 'Time (ms)');
    ylabel(outputPlot, 'mV');
    yline(outputPlot, outputLayer.V_THRESHOLD, '--', 'V_{th}');
    yline(outputPlot, outputLayer.V_INFINITY, '--', 'V_\infty');
    yline(outputPlot, outputLayer.V_RESET, '--', 'V_{reset}');
    xline(outputPlot, 0, '-');
    xline(outputPlot, TMAX, '-');
    axis(outputPlot, [0 TMAX (outputLayer.V_RESET-PADDING) (outputLayer.V_INFINITY+PADDING)]);
    for n=1:OUTPUT_NEURONS
        colours = neuronColours(n, colourOffset);
        outputPoints{n} = animatedline(outputPlot, 'Color', colours, 'Marker', MARKER, 'MarkerFaceColor', colours, MaximumNumPoints=1);
        outputLines{n} = animatedline(outputPlot, 'DisplayName', sprintf('N%d_{output}',n), 'Color', colours);
    end
end

% Plot

% figure;


% title('LIF Neuron(s)');
% xlabel('Time (ms)');
% ylabel('Neuron Voltage (mV)');
% axis([0 TMAX (inputLayer.V_RESET-PADDING) (inputLayer.V_INFINITY+PADDING)]);
% yline(inputLayer.V_THRESHOLD, '--', 'V_{th}');
% yline(inputLayer.V_INFINITY, '--', 'V_\infty');
% yline(inputLayer.V_RESET, '--', 'V_{reset}');
% xline(0, '-');
% xline(TMAX, '-');
% Legend %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if OUTPUT_NEURONS > 0 && HIDDEN_LAYERS > 0 && HIDDEN_NEURONS > 0
%     lgd = legend([inputLines{:}, hiddenLines{:}, outputLines{:}]);
% elseif HIDDEN_LAYERS > 0 && HIDDEN_NEURONS > 0
%     lgd = legend([inputLines{:}, hiddenLines{:}]);
% else
%     lgd = legend([inputLines{:}]);
% end
% 
% lgd.Location = 'northeastoutside';
% title(lgd, 'Neurons');





% Simulation Loop %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
signal_generator = SIGNAL_MAP(TIMEKEY(n));
previousText = text(0, signal_generator(0), '\t V_{signal-in}');
delete(previousText);

overviewRows = (COLUMNS+max(signalRows)-1):COLUMNS:(COLUMNS*ROWS);
overviewPlot = subplot(ROWS,COLUMNS,overviewRows); %subplot('Position', [0.5 0.15 0.4 0.7]);
% cla(overviewPlot);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DRAW NEURONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

neu = drawNeurons();
connectHiddenLayers();
connectInputOutputLayes();

%Set the dormant color for the neurons
for i= 1:29
    set(neu(i), 'FaceColor', [0 0.5 0.5]);
    axis equal;
end

%Pause to see the neurons off
pause(1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for time = 1:TIMESTEP:TMAX
    % Input Signals
    timekey = time;
    if ~isKey(SIGNAL_MAP, timekey)
        timekey = floor(time);
    end
    if REPEATING_SIGNAL % If false the following line will give a warning in MATLAB, but you can ignore it.
        timekey = TIMEKEY(mod(timekey, length(SIGNAL_MAP))+1);
    end
    if isKey(SIGNAL_MAP, timekey)
        signal_generator = SIGNAL_MAP(timekey);
        inputSignal = signal_generator(time);
    else
        inputSignal = 0;
    end
    
    % Plot Sensor Inputs
    offsetSignal = inputSignal+V_RESET;
    
    

    addpoints(signalArrow, TMAX, offsetSignal);
    addpoints(signalPoint, time, offsetSignal);
    addpoints(signalLine, time, offsetSignal);
    previousText = text(signalPlot, TMAX, offsetSignal, sprintf('\t V_{signal-in} = %.2f',offsetSignal));

    % Main Simulation %%%%%%%%%%%%%%%%%%%%%%%%%
    % Input Layer
    if INPUT_NEURONS > 0
        inputLayer.integrate(inputSignal);
%%%%%%%%%%%%%%%%%%%%%%%%%  Updating input layer  %%%%%%%%%%%%%%%%%%%%%%%%%%%
        set(neu(1), 'FaceColor', [inputLayer.normalized() 0.5 0.5]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        for n=1:inputLayer.SIZE
            addpoints(inputPoints{n}, time, inputLayer.Outputs(n));
            addpoints(inputLines{n}, time, inputLayer.Outputs(n));
        end
    end
    
    % Hidden Layers
    if HIDDEN_LAYERS > 0 && HIDDEN_NEURONS > 0
        hiddenLayers{1}.integrate(inputLayer.Outputs-V_RESET); % Subtract V_RESET here because it messes up calculations otherwise
 
%%%%%%%%%%%%%%%%%%%%%%%  Updating hidden layers  %%%%%%%%%%%%%%%%%%%%%%%%%%%
% %Updating layer 1
%         neu_col = hiddenLayers{1}.normalized();
%         set(neu(2), 'FaceColor', [neu_col(1) 0.5 0.5]);
%         set(neu(5), 'FaceColor', [neu_col(2) 0.5 0.5]);
%         set(neu(8), 'FaceColor', [neu_col(3) 0.5 0.5]);
%         set(neu(11), 'FaceColor', [neu_col(1) 0.5 0.5]);
%         set(neu(14), 'FaceColor', [neu_col(2) 0.5 0.5]);
%         set(neu(17), 'FaceColor', [neu_col(3) 0.5 0.5]);
%         set(neu(20), 'FaceColor', [neu_col(1) 0.5 0.5]);
%         set(neu(23), 'FaceColor', [neu_col(2) 0.5 0.5]);
%         set(neu(26), 'FaceColor', [neu_col(3) 0.5 0.5]);
% %Updating layer 2
% %         hiddenLayers{2}.integrate(inputLayer.Outputs-V_RESET);
%          neu_col2 = hiddenLayers{2}.normalized();
%          set(neu(3), 'FaceColor', [neu_col2(1) 0.5 0.5]);
%          set(neu(6), 'FaceColor', [neu_col2(2) 0.5 0.5]);
%          set(neu(9), 'FaceColor', [neu_col2(3) 0.5 0.5]);
%          set(neu(12), 'FaceColor', [neu_col2(1) 0.5 0.5]);
%          set(neu(15), 'FaceColor', [neu_col2(2) 0.5 0.5]);
%          set(neu(18), 'FaceColor', [neu_col2(3) 0.5 0.5]);
%          set(neu(21), 'FaceColor', [neu_col2(1) 0.5 0.5]);
%          set(neu(24), 'FaceColor', [neu_col2(2) 0.5 0.5]);
%          set(neu(27), 'FaceColor', [neu_col2(3) 0.5 0.5]);
% %Updating layer 3
% %           hiddenLayers{3}.integrate(inputLayer.Outputs-V_RESET);
%          neu_col3 = hiddenLayers{3}.normalized();
%          set(neu(4), 'FaceColor', [neu_col3(1) 0.5 0.5]);
%          set(neu(7), 'FaceColor', [neu_col3(2) 0.5 0.5]);
%          set(neu(10), 'FaceColor', [neu_col3(3) 0.5 0.5]);
%          set(neu(13), 'FaceColor', [neu_col3(1) 0.5 0.5]);
%          set(neu(16), 'FaceColor', [neu_col3(2) 0.5 0.5]);
%          set(neu(19), 'FaceColor', [neu_col3(3) 0.5 0.5]);
%          set(neu(22), 'FaceColor', [neu_col3(1) 0.5 0.5]);
%          set(neu(25), 'FaceColor', [neu_col3(2) 0.5 0.5]);
%          set(neu(28), 'FaceColor', [neu_col3(3) 0.5 0.5]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        
        for n=1:hiddenLayers{1}.SIZE
            addpoints(hiddenPoints{1,n}, time, hiddenLayers{1}.Outputs(n));
            addpoints(hiddenLines{1,n}, time, hiddenLayers{1}.Outputs(n));
        end
        
        nIndex = [2, 5, 8, 11, 14, 17, 20, 23, 26];
        neu_col = hiddenLayers{1}.normalized();
        for colIndex=1:3
            set(neu(nIndex), 'FaceColor', [neu_col(colIndex) 0.5 0.5]);
        end
        
        for i=2:HIDDEN_LAYERS
            hiddenLayers{i}.integrate(hiddenLayers{i-1}.Outputs-V_RESET);
            
            neu_col = hiddenLayers{i}.normalized();
            for colIndex=1:3
                set(neu(nIndex+1), 'FaceColor', [neu_col(colIndex) 0.5 0.5]);
            end
            
            nIndex = nIndex + 1;
            
            for n=1:hiddenLayers{i}.SIZE
                addpoints(hiddenPoints{i,n}, time, hiddenLayers{i}.Outputs(n));
                addpoints(hiddenLines{i,n}, time, hiddenLayers{i}.Outputs(n));
            end
        end
    end
    
    % Output Layer
    if OUTPUT_NEURONS > 0 && HIDDEN_LAYERS > 0 && HIDDEN_NEURONS > 0
        outputLayer.integrate(hiddenLayers{end}.Outputs-V_RESET); % Subtract V_RESET here because it messes up calculations otherwise
%%%%%%%%%%%%%%%%%%%%%%%%%  Updating output layer  %%%%%%%%%%%%%%%%%%%%%%%%%%
        set(neu(29), 'FaceColor', [outputLayer.normalized() 0.5 0.5]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for n=1:outputLayer.SIZE
            addpoints(outputPoints{n}, time, outputLayer.Outputs(n));
            addpoints(outputLines{n}, time, outputLayer.Outputs(n));
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
%     pause(.01);
    drawnow limitrate;
    
    % Signal Plot Cleanup
    for n=1:length(offsetSignal)
        delete(previousText);
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% Written by Dennis Suarez
%%%%%%%%%%%%%%%%%%%%%%%%%%%   VISUALIZATION   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Draw a 3x3x3 Neuron Grid with 27 neurons
function array = drawNeurons()
    %Give x,y,z sphere values [0,0,1]
    [x,y,z] = sphere;
    %Space between neurons is 4 units * 2
    position = [0, 2, 4];
    %Neurons array
    array = zeros(29,1);
    %Counter for neuron array index
    i = 1;
        
    for x_l = 1:3
        for y_l = 1:3
            for z_l = 1:3
                i = i + 1;
                array(i) = surf(x + (position(x_l) * 2),y + (position(y_l) * 2),z + (position(z_l) * 2));
                hold on;
            end
        end
    end
    
    %Input and output layer
    array(1) = surf(x + 4,y + 4,z -4);
    array(29) = surf(x + 4,y + 4,z + 12);
end

%Connect the hidden layers fully
function connectHiddenLayers()
    position = [0, 2, 4];
    layer2 = [3 7];
    layer1 = [1 4];
    %Once for each layer
    for lay_z = 1:2
        %For all three coordinated from position. The layer x and y creates
        %the connection for each neuron
        for lay_x = 1:3
            for lay_y = 1:3
                for n_x = 1:3
                    for n_y = 1:3
                        line([(position(lay_x) * 2) (position(n_x) * 2)],[(position(lay_y) * 2) (position(n_y) * 2)],[layer2(lay_z) layer1(lay_z)]);
                    end
                end
            end
        end
    end
end

%Connect inpu and ouput neuron to the 1st and last hidden layer
function connectInputOutputLayes()
    %Constant definitions
    lay1_z = [11 -3];
    lay2_z = [9 -1];
    position = [0, 2, 4];
    %Draw the line connections between neurons
    for layer = 1:2
        for n_y = 1:3
            for n_x = 1:3
                line([4 (position(n_x) * 2)],[4 (position(n_y) * 2)],[lay1_z(layer) lay2_z(layer)]);
            end
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
