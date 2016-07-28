classdef AlexnetPool5Features < AlexnetFeatures
    % Extract Alexnet pool5 features
    
    methods
        function obj = AlexnetPool5Features(netParams)
            pool5OutputLength = 9216;
            if ~exist('netParams', 'var')
                netParams = [];
            end
            obj = obj@AlexnetFeatures(pool5OutputLength, netParams);
        end
        
        function name = getName(~)
            name = 'alexnet-pool5';
        end
        
        function features = getImageFeatures(self, image)
            % Preparation
            conv1Kernels = self.netParams.weights(1).weights{1};
            conv1Bias = self.netParams.weights(1).weights{2};
            conv2Kernels = self.netParams.weights(2).weights{1};
            conv2Bias = self.netParams.weights(2).weights{2};
            conv3Kernels = self.netParams.weights(3).weights{1};
            conv3Bias = self.netParams.weights(3).weights{2};
            conv4Kernels = self.netParams.weights(4).weights{1};
            conv4Bias = self.netParams.weights(4).weights{2};
            conv5Kernels = self.netParams.weights(5).weights{1};
            conv5Bias = self.netParams.weights(5).weights{2};
            % pass image through network
            conv1 = conv(image, conv1Kernels, conv1Bias, 11, 4, 0, 1);
            relu1 = relu(conv1);
            pool1 = maxpool(relu1, 3, 2);
            lrn1 = lrn(pool1, 5, .0001, 0.75, 1);
            conv2 = conv(lrn1, conv2Kernels, conv2Bias, 5, 1, 2, 2);
            relu2 = relu(conv2);
            pool2 = maxpool(relu2, 3, 2);
            norm2 = lrn(pool2, 5, .0001, 0.75, 1);
            conv3 = conv(norm2, conv3Kernels, conv3Bias, 3, 1, 1, 1);
            relu3 = relu(conv3);
            conv4 = conv(relu3, conv4Kernels, conv4Bias, 3, 1, 1, 2);
            relu4 = relu(conv4);
            conv5 = conv(relu4, conv5Kernels, conv5Bias, 3, 1, 1, 2);
            relu5 = relu(conv5);
            pool5 = maxpool(relu5, 3, 2);
            pool5_2d = reshape(pool5, [9216, 1]); % flatten data
            
            features = pool5_2d;
        end
    end
end

