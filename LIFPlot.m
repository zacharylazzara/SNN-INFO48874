clc;
clear;

TMAX = 120;
NEURON_COUNT = 5;
THRESHOLD = 20;
RESET = -70;
LAYER_COUNT = 2;

time = 0;
timestep = 0.1;

INPUTS = 1;
OUTPUTS = 1;

layers{LAYER_COUNT,1} = [];
lines{NEURON_COUNT*LAYER_COUNT,1} = [];
colors = {'#0072BD', '#D95319', '#EDB120', '#7E2F8E', '#77AC30', '#4DBEEE', '#A2142F'};
for i=1:LAYER_COUNT
    layers{i} = LIFLayer(NEURON_COUNT, THRESHOLD, RESET);
    for n=1:NEURON_COUNT
        lines{n} = animatedline('Color', colors{mod(n, length(colors))+1});
    end
end

inputLayer = LIFLayer(INPUTS, THRESHOLD, RESET);
inputLines{INPUTS,1} = [];
for n=1:INPUTS
    inputLines{n} = animatedline('Color', colors{mod(n, length(colors))+1});
end


outputLayer = LIFLayer(OUTPUTS, THRESHOLD, RESET);
outputLines{INPUTS,1} = [];
for n=1:INPUTS
    inputLines{n} = animatedline('Color', colors{mod(n, length(colors))+1});
end

% neurons{NEURON_COUNT,1} = [];
% lines{NEURON_COUNT,1} = [];
% colors = ['r', 'g', 'b', 'c' 'm'];
% for i=1:NEURON_COUNT
%     neurons{i} = LIFSpikingNeuron(THRESHOLD);
%     lines{i} = animatedline('Color', colors(mod(i, length(colors))+1));
% end




% Plot
padding = 1;
title('LIF Neuron');
xlabel('Time');
ylabel('Neuron Voltage');
axis([0 TMAX (inputLayer.V_RESET-padding) (inputLayer.V_INFINITY+padding)]);
% ax = gca;
% ax.XAxisLocation = "origin";
% ax.YAxisLocation = "origin";

yline(inputLayer.V_THRESHOLD, '--', 'V_{th}');
yline(inputLayer.V_INFINITY, '--', 'V_\infty');
yline(inputLayer.V_RESET, '--', 'V_{reset}');


set(inputLines{1}, 'LineWidth', 1.5);

amps = 0;%[[0.01, 0.3, 0.02], [0.1, 0.8]];
aLine = animatedline;



% TODO: I think it's amperage we should be inputting, not voltage?
while time < TMAX
    time = time + timestep;
    if time > 5
%         amps = 2;
        amps = 1+sin(pi*time)/5;
    end
    if time > 50
        amps = 0;
    end
    
    
    
    
    addpoints(aLine, time, amps);
    
%     inputLayer.integrate(time, amps);
    for n=1:inputLayer.SIZE
        addpoints(inputLines{n}, time, inputLayer.integrate(amps));
    end
    
%     for i=2:LAYER_COUNT
%         layers{i}.integrate(time, layers{i-1}.Outputs);
%         for n=1:layers{i}.SIZE
%             addpoints(lines{n}, time, layers{i}.Neurons{n}.Voltage);
%             
%             
%             layers{i}.Neurons{n}
%         end
%     end
%     
% %     outputLayer.integrate(time, voltage); % should use layers not voltage
% %     for n=1:outputLayer.SIZE
% %         addpoints(outputLines{n}, time, outputLayer.Neurons{n}.Voltage);
% %     end
    
    
%     amps = 0;
    
    
    pause(.01);
    drawnow limitrate;
end