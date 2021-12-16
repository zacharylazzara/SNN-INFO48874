% Written by Zachary Lazzara

clc;
clear;

% Constants %%%%%%%%%%%%%%%%%%%%%%%%%
% Plot Settings
TMAX = 120;
TIMESTEP = 0.1;
COLOURS = {'#0072BD', '#D95319', '#EDB120', '#7E2F8E', '#77AC30', '#4DBEEE', '#A2142F'};

% Neuron Properties (comment out to use defaults)
THRESHOLD = 20;
RESET = 0;

% Layer Properties
INPUT_NEURONS = 1;
OUTPUT_NEURONS = 1;
HIDDEN_LAYERS = 3;
HIDDEN_LAYER_NEURONS = 3;
% Variables %%%%%%%%%%%%%%%%%%%%%%%%%
amps = 0;%[[0.01, 0.3, 0.02], [0.1, 0.8]];% TODO: I think it's amperage we should be inputting, not voltage?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Input layers
inputLayer = LIFLayer(INPUT_NEURONS, THRESHOLD, RESET);
inputLines{INPUT_NEURONS,1} = [];
for n=1:INPUT_NEURONS
    inputLines{n} = animatedline('Color', COLOURS{mod(n, length(COLOURS))+1});
end

% Hidden layers
layers{HIDDEN_LAYERS,1} = [];
lines{HIDDEN_LAYER_NEURONS*HIDDEN_LAYERS,1} = [];
for i=1:HIDDEN_LAYERS
    layers{i} = LIFLayer(HIDDEN_LAYER_NEURONS, THRESHOLD, RESET);
    for n=1:HIDDEN_LAYER_NEURONS
        lines{n} = animatedline('Color', COLOURS{mod(n, length(COLOURS))+1});
    end
end

% Output layers
outputLayer = LIFLayer(OUTPUT_NEURONS, THRESHOLD, RESET);
outputLines{OUTPUT_NEURONS,1} = [];
for n=1:OUTPUT_NEURONS
    outputLines{n} = animatedline('Color', COLOURS{mod(n, length(COLOURS))+1});
end

% Plot
padding = 1;
title('LIF Neuron');
xlabel('Time');
ylabel('Neuron Voltage');
axis([0 TMAX (inputLayer.V_RESET-padding) (inputLayer.V_INFINITY+padding)]);
yline(inputLayer.V_THRESHOLD, '--', 'V_{th}');
yline(inputLayer.V_INFINITY, '--', 'V_\infty');
yline(inputLayer.V_RESET, '--', 'V_{reset}');

% Simulation Loop
for time = 1:TIMESTEP:TMAX
    % TODO: use a poisson process for the inputs
    if time > 5
        amps = 1+sin(pi*time)/5;
    end
    if time > 50
        amps = 0;
    end
    
    % Input Layer
    inputLayer.integrate(amps);
    for n=1:inputLayer.SIZE
        addpoints(inputLines{n}, time, inputLayer.Outputs(n));
    end
    
    % Hidden Layers
    layers{1}.integrate(inputLayer.Outputs);
    for n=1:layers{1}.SIZE
        addpoints(lines{n}, time, layers{1}.Outputs(n));
    end
    for i=2:HIDDEN_LAYERS
        layers{i}.integrate(layers{i-1}.Outputs);
        for n=1:layers{i}.SIZE
            addpoints(lines{n}, time, layers{i}.Outputs(n));
        end
    end
    
    % Output Layer
    outputLayer.integrate(layers{end}.Outputs);
    for n=1:outputLayer.SIZE
        addpoints(outputLines{n}, time, outputLayer.Outputs(n));
    end
    
    pause(.01);
    drawnow limitrate;
end