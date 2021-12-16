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
REFRACTORY_PERIOD   =  50;   % Period the neuron cannot fire another spike.
V_THRESHOLD         =  20;   % Spiking threshold.
V_INFINITY          =  25;   % Upper bound on neuron voltage.
V_RESET             = -70;  % Offset. Unused in calculations (to simplify things), but included because neurons normally operate around -70mV.

% Layer Properties
INPUT_NEURONS       = 1;
OUTPUT_NEURONS      = 1;
HIDDEN_NEURONS      = 3;
HIDDEN_LAYERS       = 3;

% Variables %%%%%%%%%%%%%%%%%%%%%%%%%
% This is the value given to the input neurons. It can be a vector, in
% which case it is divided among the input neurons. If it's a scalar then
% all neurons will recieve the same value.
inputSignal             = 0; % 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

signalArrow = animatedline('Color', 'r', 'Marker', '<', 'MarkerFaceColor', 'r', MaximumNumPoints=1);
signalPoint = animatedline('Color', 'r', 'Marker', MARKER, 'MarkerFaceColor', 'r', MaximumNumPoints=1);
signalLine = animatedline('Color', 'r');

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
previousText = text(0, inputSignal+V_RESET, 'Point');
for time = 1:TIMESTEP:TMAX
    % TODO: use a poisson process for the inputs
    if time > 5
        inputSignal = 1+sin(pi*time)/5;
    end
    if time > 50
        inputSignal = 0;
    end
    
    % Sensor Input
    offsetSignal = inputSignal+V_RESET;
    addpoints(signalArrow, TMAX, offsetSignal);
    addpoints(signalPoint, time, offsetSignal);
    addpoints(signalLine, time, offsetSignal);
    delete(previousText);
    previousText = text(TMAX, offsetSignal, sprintf('\t V_{input} = %.2f',offsetSignal));
    
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
    
    pause(.01);
    drawnow limitrate;
end