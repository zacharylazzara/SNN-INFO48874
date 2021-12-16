% Written by Zachary Lazzara

classdef LIFNeuron < handle
    properties
        % Constants %%%%%%%%%%%%%%%%%
        V_RESET{}           % Resting potential; note that this acts only as an offset
        V_INFINITY{}        % Voltage approaches this value but never reaches it
        V_THRESHOLD{}       % Voltage reset threshold
        REFRACTORY_PERIOD{} % How long the neuron's refractory period in ms is
        
        % Variables %%%%%%%%%%%%%%%%%
        Voltage{}
        Refractory{}    % Time neuron went refractory
        InputStrengths{}
    end
    methods
        % Initialization
        function neuron = LIFNeuron(v_threshold, v_reset, v_infinity, refractory)
            % Constants
            if ~exist('refractory', 'var')
                refractory = 10;                    % ms
            end
            neuron.REFRACTORY_PERIOD = refractory;  % ms
            
            if ~exist('v_reset', 'var')
                v_reset = 0;                        % mV
            end
            neuron.V_RESET  = v_reset;              % mV
            
            if ~exist('v_infinity', 'var')
                v_infinity = v_threshold+1;         % mV
            end
            neuron.V_INFINITY = v_infinity;         % mV
            
            if ~exist('v_threshold', 'var')
                v_threshold = 50;                   % mV
            end
            neuron.V_THRESHOLD    = v_threshold;    % mV
            
            % Variables
            neuron.Voltage          = 0;            % mV
            neuron.Refractory       = 0;            % ms
            neuron.InputStrengths   = [1];          % Vector with range [0,1]
        end
        
        function output = integrate(neuron, inputs)
            if ~exist('inputs', 'var')
                inputs = 0;
            end
            
            if length(neuron.InputStrengths) ~= length(inputs)
                neuron.InputStrengths = ones(1, length(inputs))
            end
            
            
            
            if neuron.Refractory > 0
                neuron.Refractory = neuron.Refractory - 1;
            else
                neuron.Voltage = neuron.Voltage + sum(inputs);
            end
            
            neuron.Voltage = neuron.Voltage - (neuron.Voltage/neuron.V_INFINITY);
            
            if neuron.Voltage >= neuron.V_INFINITY
               neuron.Voltage = neuron.V_INFINITY-eps; % Since voltage should never reach V_INFINITY we subtract epsilon
            end
            if neuron.Voltage >= neuron.V_THRESHOLD
                neuron.Refractory = neuron.REFRACTORY_PERIOD + 1;
            end
            
            output = neuron.Voltage;
        end
        
        function d = v_data(neuron, index, inputs) % y-axis translated by V_RESET
            if exist('inputs', 'var')
                neuron.integrate(inputs);
            end
            d=[ neuron.Voltage+neuron.V_RESET;
                neuron.V_RESET;
                neuron.V_INFINITY+neuron.V_RESET;
                neuron.V_THRESHOLD+neuron.V_RESET];
            if exist('index', 'var')
                d=d(index);
            end
        end
    end
end