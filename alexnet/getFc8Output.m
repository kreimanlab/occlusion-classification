function[fc8] = getFc8Output(netParams, preparedImage)
    if nargin < 2
        error('not enough parameters provided');
    end

    %% Preparation
    fc8Weights=netParams.weights(8).weights{1};
    fc8Bias=netParams.weights(8).weights{2};

    %% pass image through network
    fc7=getFc7Output(netParams, preparedImage);
    
    relu7=relu(fc7);
    dropout7=dropout(relu7);
    fc8=fc(dropout7,fc8Weights,fc8Bias);
