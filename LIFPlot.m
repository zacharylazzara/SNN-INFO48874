% Written by Zachary Lazzara

clc;
clear;

% Constants %%%%%%%%%%%%%%%%%%%%%%%%%
% Plot Settings
TMAX                = 120;
TIMESTEP            = 0.1;
COLOURS             = {'#0072BD', '#D95319', '#EDB120', '#7E2F8E', '#77AC30', '#4DBEEE', '#A2142F'};
MARKER              = 'o';

% Neuron Properties (to use defaults, define the layers without these settings).
REFRACTORY_PERIOD   =  50;  % Period the neuron cannot fire another spike.
V_THRESHOLD         =  20;  % Spiking threshold.
V_INFINITY          =  25;  % Upper bound on neuron voltage.
V_RESET             = -70;  % Offset. Unused in calculations (to simplify things), but included because neurons normally operate around -70mV.

% Layer Properties
INPUT_NEURONS       = 2;
OUTPUT_NEURONS      = 1;
HIDDEN_NEURONS      = 1;
HIDDEN_LAYERS       = 1;

% Input Signals %%%%%%%%%%%%%%%%%%%%%%%%%
REPEATING_SIGNAL    = false;    % Determines if the signal should be repeated after ending or not.
MAX_INPUTS          = 1;        % We could theoretically have more than one signal source. For now we'll just use one.
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

signalArrows{MAX_INPUTS,1} = [];
signalPoints{MAX_INPUTS,1} = [];
signalLines{MAX_INPUTS,1} = [];
for n=1:MAX_INPUTS
    signalLines{n} = animatedline('Color', 'k');
end

% Input layers
inputLayer = LIFLayer(INPUT_NEURONS, V_THRESHOLD, V_RESET, V_INFINITY, REFRACTORY_PERIOD);
inputPoints{INPUT_NEURONS,1} = [];
inputLines{INPUT_NEURONS,1} = [];
for n=1:INPUT_NEURONS
    inputPoints{n} = animatedline('Color', COLOURS{mod(n, length(COLOURS))+1}, 'Marker', MARKER, 'MarkerFaceColor', COLOURS{mod(n, length(COLOURS))+1}, MaximumNumPoints=1);
    inputLines{n} = animatedline('Color', COLOURS{mod(n, length(COLOURS))+1});
end

% Hidden layers
hiddenLayers{HIDDEN_LAYERS,1} = [];
hiddenPoints{HIDDEN_NEURONS*HIDDEN_LAYERS,1} = [];
hiddenLines{HIDDEN_NEURONS*HIDDEN_LAYERS,1} = [];
for i=1:HIDDEN_LAYERS
    hiddenLayers{i} = LIFLayer(HIDDEN_NEURONS, V_THRESHOLD, V_RESET, V_INFINITY, REFRACTORY_PERIOD);
    for n=1:HIDDEN_NEURONS
        hiddenPoints{n} = animatedline('Color', COLOURS{mod(n, length(COLOURS))+1}, 'Marker', MARKER, 'MarkerFaceColor', COLOURS{mod(n, length(COLOURS))+1}, MaximumNumPoints=1);
        hiddenLines{n} = animatedline('Color', COLOURS{mod(n, length(COLOURS))+1});
    end
end

% Output layers
outputLayer = LIFLayer(OUTPUT_NEURONS, V_THRESHOLD, V_RESET, V_INFINITY, REFRACTORY_PERIOD);
outputPoints{OUTPUT_NEURONS,1} = [];
outputLines{OUTPUT_NEURONS,1} = [];
for n=1:OUTPUT_NEURONS
    outputPoints{n} = animatedline('Color', COLOURS{mod(n, length(COLOURS))+1}, 'Marker', MARKER, 'MarkerFaceColor', COLOURS{mod(n, length(COLOURS))+1}, MaximumNumPoints=1);
    outputLines{n} = animatedline('Color', COLOURS{mod(n, length(COLOURS))+1});
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

% Simulation Loop
previousTexts{MAX_INPUTS,1} = [];
for n=1:MAX_INPUTS
    signal_generator = SIGNAL_MAP(TIMEKEY(n));
    previousTexts{n} = text(0, signal_generator(0), '\t V_{signal-in}');
    delete(previousTexts{n});
end
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
    for n=1:length(offsetSignal)
        signalArrows{n} = animatedline('Color', 'r', 'Marker', '<', 'MarkerFaceColor', 'r', MaximumNumPoints=1);
        signalPoints{n} = animatedline('Color', 'r', 'Marker', MARKER, 'MarkerFaceColor', 'r', MaximumNumPoints=1);
        addpoints(signalArrows{n}, TMAX, offsetSignal(n));
        addpoints(signalPoints{n}, time, offsetSignal(n));
        addpoints(signalLines{n}, time, offsetSignal(n));
        previousTexts{n} = text(TMAX, offsetSignal(n), sprintf('\t V_{signal-in} = %.2f',offsetSignal(n)));
    end
    
    % Main Simulation %%%%%%%%%%%%%%%%%%%%%%%%%
    % Input Layer
    inputLayer.integrate(inputSignal);
    for n=1:inputLayer.SIZE
        addpoints(inputPoints{n}, time, inputLayer.Outputs(n));
        addpoints(inputLines{n}, time, inputLayer.Outputs(n));
    end
    
    % Hidden Layers
    hiddenLayers{1}.integrate(inputLayer.Outputs-V_RESET); % Subtract V_RESET here because it messes up calculations otherwise
    for n=1:hiddenLayers{1}.SIZE
        addpoints(hiddenLines{n}, time, hiddenLayers{1}.Outputs(n));
    end
    for i=2:HIDDEN_LAYERS
        hiddenLayers{i}.integrate(hiddenLayers{i-1}.Outputs-V_RESET);
        for n=1:hiddenLayers{i}.SIZE
            addpoints(hiddenPoints{n}, time, hiddenLayers{i}.Outputs(n));
            addpoints(hiddenLines{n}, time, hiddenLayers{i}.Outputs(n));
        end
    end
    
    % Output Layer
    outputLayer.integrate(hiddenLayers{end}.Outputs-V_RESET); % Subtract V_RESET here because it messes up calculations otherwise
    for n=1:outputLayer.SIZE
        addpoints(outputPoints{n}, time, outputLayer.Outputs(n));
        addpoints(outputLines{n}, time, outputLayer.Outputs(n));
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    pause(.01);
    drawnow limitrate;
    
    % Signal Plot Cleanup
    for n=1:length(offsetSignal)
        delete(signalArrows{n});
        delete(signalPoints{n});
        delete(previousTexts{n});
        signalPoints{n} = animatedline('Color', 'r', 'Marker', 'x', 'MarkerFaceColor', 'r', MaximumNumPoints=1);
    end
end