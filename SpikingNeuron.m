% Written by Zachary Lazzara

% This is an approximation of a Leaky Integrate and Fire neuron. It was
% made mostly by trial and error and referring to graphs of neural spikes.

classdef SpikingNeuron < handle
    properties
        % Constants %%%%%%%%%%%%%%%%%
        FILL_RATE{}         % Rate the neuron fills at
        LEAK_RATE{}         % Rate the neuron leaks at
        THRESHOLD{}         % Threshold the neuron empties at
        MOMENTUM{}          % The neuron will dip below its resting fill due to momentum
        EQUILIBRIUM{}       % Resting potential (cannot be 0)
        REFRACTORY_PERIOD{} % How long the refractory period lasts
        
        % Variables %%%%%%%%%%%%%%%%%
        Refractory{}        % Time neuron went refractory
        Voltage{}           % Current fill of the neuron
    end
    methods
        % Initialization
        function neuron = SpikingNeuron(threshold, equilibrium)
            % Constants
            neuron.REFRACTORY_PERIOD    = 10;
            
            
            % These should be between 0 and 1
            neuron.FILL_RATE            = 0.5;
            neuron.LEAK_RATE            = 0.03;
            neuron.MOMENTUM             = 0.03;
            
            if exist('threshold', 'var')
                neuron.THRESHOLD        = threshold;    %mV
            else
                neuron.THRESHOLD        = -50;
            end
            
            if exist('equilibrium', 'var')
                neuron.EQUILIBRIUM        = equilibrium;    %mV
            else
                neuron.EQUILIBRIUM        = -70;
            end
            
            % Variables
            neuron.Voltage              = neuron.EQUILIBRIUM;
            neuron.Refractory           = 0;
        end
        
        function output = integrate(neuron, inputs) % Note that inputs are in amps
            if ~exist('inputs', 'var')
                inputs = 0;
            end
            
            if neuron.Refractory == 0
                if sum(inputs) == 0
                    neuron.Voltage = neuron.EQUILIBRIUM;
                else
                    % The following equation was made with trial and error. I
                    % tried to approximate the Hodgkin-Huxley model in a
                    % leaky-integrate-and-fire style. To do so I just tried to
                    % make the output of this fit what the output looks like in
                    % a Hodgkin-Huxley neuron.
                    %
                    % While it's certainly not perfect, it does seem to get
                    % some things semi-right, such as the frequency of spikes
                    % seeming to increase when more input is given.
                    neuron.Voltage = neuron.Voltage + sum(inputs)+log(exp(pi)+tan(cos(neuron.Voltage)))^log(1+sin(neuron.Voltage));  
                end
            end
            output = 1-neuron.EQUILIBRIUM/neuron.Voltage; % Normalize the output
            if neuron.Refractory > 0
                neuron.Refractory = neuron.Refractory - 1;
            elseif neuron.Voltage > neuron.THRESHOLD
                neuron.Voltage = neuron.EQUILIBRIUM * (1+neuron.MOMENTUM);
                neuron.Refractory = neuron.REFRACTORY_PERIOD + 1;
            end
        end
    end
end