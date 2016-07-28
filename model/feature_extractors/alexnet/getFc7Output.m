function[fc7] = getFc7Output(netParams, preparedImage)
    if nargin < 2
        error('not enough parameters provided');
    end

    %% Preparation
    fc6Weights=netParams.weights(6).weights{1};
    fc6Bias=netParams.weights(6).weights{2};
    fc7Weights=netParams.weights(7).weights{1};
    fc7Bias=netParams.weights(7).weights{2};

    %% pass image through network
    pool5_2d=getPool5Output(netParams, preparedImage);
    
    fc6=fc(pool5_2d,fc6Weights,fc6Bias);
    relu6=relu(fc6);
    dropout6=dropout(relu6);
    fc7=fc(dropout6,fc7Weights,fc7Bias);
