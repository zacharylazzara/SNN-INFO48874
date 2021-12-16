% Written by Zachary Lazzara

classdef LIFLayer < handle
    properties
        SIZE{}              % Number of neurons in the layer
        V_RESET{}           % Resting potential
        V_INFINITY{}        % Voltage approaches this value but never reaches it
        V_THRESHOLD{}       % Voltage reset threshold
        REFRACTORY_PERIOD{} % How long the neuron's refractory period in ms is
        Neurons{}           % Neuron cell array
        Outputs{}           % Output vector
    end
    methods
        % Initialization
        function layer = LIFLayer(neuron_count, v_threshold, v_reset, v_infinity, refractory)
            if ~exist('neuron_count', 'var')
                neuron_count = 1;
            end
            layer.SIZE = neuron_count;
            layer.Outputs = [layer.SIZE];
            layer.Neurons{layer.SIZE} = [];
            
            % Create neurons
            if ~exist('refractory', 'var')
                refractory = 10;            %ms
            end
            if ~exist('v_reset', 'var')
                v_reset = 0;                %mV
            end
            if ~exist('v_threshold', 'var')
                v_threshold = 50;           %mV
            end
            if ~exist('v_infinity', 'var')
                v_infinity = v_threshold+1; %mV
            end
            for i=1:layer.SIZE
                layer.Neurons{i} = LIFNeuron(v_threshold, v_reset, v_infinity, refractory);
            end
            
            % Define offsets since V_RESET isn't used for calculations (it
            % complicates things). Easier to have the neuron be zero based
            % then offset based on the reset value.
            layer.V_RESET = v_reset;
            layer.V_INFINITY = v_infinity+v_reset;
            layer.V_THRESHOLD = v_threshold+v_reset;
            layer.REFRACTORY_PERIOD = refractory;
        end
        
        function outputs = integrate(layer, inputs)
            % TODO: integrate inputs, and divide them amongst the neurons?
            % Neurons should be integrating, but we need to know which
            % inputs go to what neurons. Maybe we can make a subset of
            % inputs to divide among all neurons in the event there's more
            % inputs than neurons? We should also be strengthening and
            % weakening connections here (probably anyway).
            
            
            for i=1:layer.SIZE
                layer.Outputs(i) = layer.Neurons{i}.v_data(1, inputs(mod(i, length(inputs))+1));
            end
            outputs = layer.Outputs;
        end
    end
end