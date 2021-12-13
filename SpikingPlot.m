clc;
clear;

TMAX = 150;
NEURON_COUNT = 5;

LAYER_COUNT = 2;


INPUTS = 1;
OUTPUTS = 1;


% TODO: we need neural layers, and then neurons need to communicate with
% neurons in next layer. We need some sort of function to strengthen and
% weaken neural connections.

% Voltage inputs to the input neuron will be a poission process


layers{LAYER_COUNT,1} = [];
lines{NEURON_COUNT*LAYER_COUNT,1} = [];
colors = {'#0072BD', '#D95319', '#EDB120', '#7E2F8E', '#77AC30', '#4DBEEE', '#A2142F'};
for i=1:LAYER_COUNT
    layers{i} = SpikingLayer(NEURON_COUNT);
    for n=1:NEURON_COUNT
        lines{n} = animatedline('Color', colors{mod(n, length(colors))+1});
    end
end

inputLayer = SpikingLayer(INPUTS);
inputLines{INPUTS,1} = [];
for n=1:INPUTS
    inputLines{n} = animatedline('Color', colors{mod(n, length(colors))+1});
end

outputLayer = SpikingLayer(OUTPUTS);
outputLines{INPUTS,1} = [];
for n=1:INPUTS
    inputLines{n} = animatedline('Color', colors{mod(n, length(colors))+1});
end

time = 0;
timestep = 0.1;

xlabel('Time');
ylabel('Neuron Voltage');
axis([0 TMAX inputLayer.Neurons{1}.EQUILIBRIUM*(1+inputLayer.Neurons{1}.MOMENTUM)-1 inputLayer.Neurons{1}.THRESHOLD+1]);

amps = 0;%[[0.01, 0.3, 0.02], [0.1, 0.8]];
aLine = animatedline;

% TODO: I think it's amperage we should be inputting, not voltage?
while time < TMAX
    time = time + timestep;
%     amps = max(sin(time)/1.5, 0);
%     amps = 0.827;%max(0, sin(time));

    if time > 5
        amps = 0.1; % past 21.2 it stops working for some reason
    end
    if time > 100
        amps = 0;
    end



    addpoints(aLine, time, amps);
    
    
    
    

    % TODO: the reason the downstream neurons are doing so much stuff is
    % because we're using voltage as an input, but voltage is -70. We need
    % to normalize this to 0 or convert to amps somehow.
    
    inputLayer.integrate(amps);
    for n=1:inputLayer.SIZE
        addpoints(inputLines{n}, time, inputLayer.Neurons{n}.Voltage);
    end
    
    for i=1:LAYER_COUNT
        if i == 1
            layers{i}.integrate(inputLayer.Outputs);
        else
            layers{i}.integrate(layers{i-1}.Outputs);
        end
        for n=1:layers{i}.SIZE
            addpoints(lines{n}, time, layers{i}.Neurons{n}.Voltage);
        end
    end
    
%     outputLayer.integrate(timestep, voltage); % should use layers not voltage
%     for n=1:outputLayer.SIZE
%         addpoints(outputLines{n}, time, outputLayer.Neurons{n}.Voltage);
%     end
    
    
    
%     if mod(time, 1) >= 0.5
%         amps = 0.5;
%     else
%         amps = 0;
%     end
    
%     pause(.001)
    drawnow limitrate;
end