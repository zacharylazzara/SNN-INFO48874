% Written by Zachary Lazzara

% This is used to create layers of spiking neurons.

classdef SpikingLayer < handle
    properties
        SIZE{}
        EQUILIBRIUM{}
        THRESHOLD{}
        Neurons{}
        Outputs{}
    end
    methods
        % Initialization
        function layer = SpikingLayer(neuronCount, threshold, equilibrium)
            layer.SIZE = neuronCount;
            layer.Outputs = [layer.SIZE];
            layer.Neurons{layer.SIZE} = [];
            
            if exist('threshold', 'var')
                layer.THRESHOLD        = threshold;    %mV
            else
                layer.THRESHOLD        = -50;
            end
            
            if exist('equilibrium', 'var')
                layer.EQUILIBRIUM        = equilibrium;    %mV
            else
                layer.EQUILIBRIUM        = -70;
            end
            
            for i=1:layer.SIZE
                layer.Neurons{i} = SpikingNeuron(layer.THRESHOLD, layer.EQUILIBRIUM);
            end
        end
        
        function outputs = integrate(layer, inputs)
            % TODO: integrate inputs, and divide them amongst the neurons?
            % Neurons should be integrating, but we need to know which
            % inputs go to what neurons. Maybe we can make a subset of
            % inputs to divide among all neurons in the event there's more
            % inputs than neurons? We should also be strengthening and
            % weakening connections here (probably anyway).
            
            
            for i=1:layer.SIZE
                layer.Outputs(i) = layer.Neurons{i}.integrate(inputs(mod(i, length(inputs))+1));
            end
            
            outputs = layer.Outputs;
        end
    end
end