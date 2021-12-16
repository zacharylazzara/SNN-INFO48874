% Written by Zachary Lazzara

clc;
clear;

% Constants %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot Settings
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
HIDDEN_NEURONS      = 3;
HIDDEN_LAYERS       = 3;

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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

signalArrow = animatedline('Color', 'r', 'Marker', '<', 'MarkerFaceColor', 'r', MaximumNumPoints=1);
signalPoint = animatedline('Color', 'r', 'Marker', MARKER, 'MarkerFaceColor', 'r', MaximumNumPoints=1);
signalLine = animatedline('Color', 'r');

% signalArrows{MAX_INPUTS,1} = [];
% signalPoints{MAX_INPUTS,1} = [];
% signalLines{MAX_INPUTS,1} = [];
% for n=1:MAX_INPUTS
%     signalLines{n} = animatedline('Color', 'r');
% end

colourOffset = 1;
neuronColours = @(neuronOffset, layerOffset) COLOURS{mod(neuronOffset, length(COLOURS))+1}/layerOffset;

% Input layers
if INPUT_NEURONS > 0
    inputLayer = LIFLayer(TIMESTEP, INPUT_NEURONS, V_THRESHOLD, V_RESET, V_INFINITY, REFRACTORY_PERIOD);
    inputPoints{INPUT_NEURONS,1} = [];
    inputLines{INPUT_NEURONS,1} = [];
    for n=1:INPUT_NEURONS
        colours = neuronColours(n, colourOffset);
        inputPoints{n} = animatedline('Color', colours, 'Marker', MARKER, 'MarkerFaceColor', colours, MaximumNumPoints=1);
        inputLines{n} = animatedline('DisplayName', sprintf('N%d_{input}',n), 'Color', colours);
    end
end

% Hidden layers
if HIDDEN_LAYERS > 0 && HIDDEN_NEURONS > 0
    hiddenLayers{HIDDEN_LAYERS,1} = [];
    hiddenPoints{HIDDEN_NEURONS*HIDDEN_LAYERS,1} = [];
    hiddenLines{HIDDEN_NEURONS*HIDDEN_LAYERS,1} = [];
    for i=1:HIDDEN_LAYERS
        colourOffset = colourOffset + 0.1;
        hiddenLayers{i} = LIFLayer(TIMESTEP, HIDDEN_NEURONS, V_THRESHOLD, V_RESET, V_INFINITY, REFRACTORY_PERIOD);
        for n=1:HIDDEN_NEURONS
            colours = neuronColours(n, colourOffset);
            hiddenPoints{n} = animatedline('Color', colours, 'Marker', MARKER, 'MarkerFaceColor', colours, MaximumNumPoints=1);
            hiddenLines{n} = animatedline('DisplayName', sprintf('N%d_{layer %d}', n, i), 'Color', colours);
        end
    end
end

% Output layers
if OUTPUT_NEURONS > 0
    outputLayer = LIFLayer(TIMESTEP, OUTPUT_NEURONS, V_THRESHOLD, V_RESET, V_INFINITY, REFRACTORY_PERIOD);
    outputPoints{OUTPUT_NEURONS,1} = [];
    outputLines{OUTPUT_NEURONS,1} = [];
    for n=1:OUTPUT_NEURONS
        colours = neuronColours(n, colourOffset);
        outputPoints{n} = animatedline('Color', colours, 'Marker', MARKER, 'MarkerFaceColor', colours, MaximumNumPoints=1);
        outputLines{n} = animatedline('DisplayName', sprintf('N%d_{output}',n), 'Color', colours);
    end
end

% Plot
padding = 2;
title('LIF Neuron(s)');
xlabel('Time (ms)');
ylabel('Neuron Voltage (mV)');
axis([0 TMAX (inputLayer.V_RESET-padding) (inputLayer.V_INFINITY+padding)]);
yline(inputLayer.V_THRESHOLD, '--', 'V_{th}');
yline(inputLayer.V_INFINITY, '--', 'V_\infty');
yline(inputLayer.V_RESET, '--', 'V_{reset}');
xline(0, '-');
xline(TMAX, '-');
screen = get(0,'ScreenSize');
set(gcf, 'Position', [floor(screen(3)/4), floor(screen(4)/3), 900, 500], 'Name', 'INFO48874 - Spiking Neuron Simulation');

% Legend %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if OUTPUT_NEURONS > 0 && HIDDEN_LAYERS > 0 && HIDDEN_NEURONS > 0
    lgd = legend([inputLines{:}, hiddenLines{:}, outputLines{:}]);
elseif HIDDEN_LAYERS > 0 && HIDDEN_NEURONS > 0
    lgd = legend([inputLines{:}, hiddenLines{:}]);
else
    lgd = legend([inputLines{:}]);
end

lgd.Location = 'northeastoutside';
title(lgd, 'Neurons');

% Simulation Loop %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
signal_generator = SIGNAL_MAP(TIMEKEY(n));
previousText = text(0, signal_generator(0), '\t V_{signal-in}');
delete(previousText);
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
    previousText = text(TMAX, offsetSignal, sprintf('\t V_{signal-in} = %.2f',offsetSignal));
    
    % Main Simulation %%%%%%%%%%%%%%%%%%%%%%%%%
    % Input Layer
    if INPUT_NEURONS > 0
        inputLayer.integrate(inputSignal);
        for n=1:inputLayer.SIZE
            addpoints(inputPoints{n}, time, inputLayer.Outputs(n));
            addpoints(inputLines{n}, time, inputLayer.Outputs(n));
        end
    end
    
    % Hidden Layers
    if HIDDEN_LAYERS > 0 && HIDDEN_NEURONS > 0
        hiddenLayers{1}.integrate(inputLayer.Outputs-V_RESET); % Subtract V_RESET here because it messes up calculations otherwise
        for n=1:hiddenLayers{1}.SIZE
            addpoints(hiddenPoints{n}, time, hiddenLayers{1}.Outputs(n));
            addpoints(hiddenLines{n}, time, hiddenLayers{1}.Outputs(n));
        end
        for i=2:HIDDEN_LAYERS
            hiddenLayers{i}.integrate(hiddenLayers{i-1}.Outputs-V_RESET);
            for n=1:hiddenLayers{i}.SIZE
                addpoints(hiddenPoints{n}, time, hiddenLayers{i}.Outputs(n));
                addpoints(hiddenLines{n}, time, hiddenLayers{i}.Outputs(n));
            end
        end
    end
    
    % Output Layer
    if OUTPUT_NEURONS > 0 && HIDDEN_LAYERS > 0 && HIDDEN_NEURONS > 0
        outputLayer.integrate(hiddenLayers{end}.Outputs-V_RESET); % Subtract V_RESET here because it messes up calculations otherwise
        for n=1:outputLayer.SIZE
            addpoints(outputPoints{n}, time, outputLayer.Outputs(n));
            addpoints(outputLines{n}, time, outputLayer.Outputs(n));
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    pause(.01);
    drawnow limitrate;
    
    % Signal Plot Cleanup
    for n=1:length(offsetSignal)
        delete(previousText);
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%