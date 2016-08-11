function runMaskedHopFeatures(objectForRow, varargin)

%% Args
argParser = inputParser();
argParser.KeepUnmatched = true;
argParser.addParameter('dataSelection', 1:numel(objectForRow), @isnumeric);
argParser.addParameter('netFile', [], @(f) exist(f, 'file'));
argParser.addParameter('trainDirectory', [], @(p) exist(p, 'dir'));
argParser.addParameter('testDirectory', [], @(p) exist(p, 'dir'));

argParser.parse(varargin{:});
fprintf('Running masked-hop-features in %s with args:\n', pwd);
disp(argParser.Results);
dataSelection = argParser.Results.dataSelection;
netFile = argParser.Results.netFile;
trainDir = argParser.Results.trainDirectory;
testDir = argParser.Results.testDirectory;

%% Prepare
net = load(netFile);
net = net.net;
featureProviderFactory = FeatureProviderFactory(...
    trainDir, testDir, objectForRow, dataSelection);
maskedProvider = BipolarFeatures(0,featureProviderFactory.get(NamedFeatures('alexnet-relu7-masked')));
maskSavesteps = [1:16, 32, 64, 128, 256];
normalProviders = {...
    BipolarFeatures(0, featureProviderFactory.get(AlexnetRelu7Features()))};
for t = 2 .^ (1:6)
    normalProviders{end + 1} = featureProviderFactory.get(NamedFeatures(sprintf('alexnet-relu7-bipolar0-hop_t%d', t)));
end

%% Run
for i = 1:numel(normalProviders)
    summedFeatures = CombineFeatures(@(x, y) sum(cat(3, x, y), 3), ...
        normalProviders{i}, maskedProvider);
    hopExtractor = HopFeatures(max(maskSavesteps), summedFeatures, net);
    computeHopTimeFeatures(...
            'objectForRow', objectForRow, ...
            'trainDirectory', trainDir, 'testDirectory', testDir, ...
            'weightsDirectory', '.', ... % won't be used anyway
            'featureExtractor', hopExtractor, ...
            'savesteps', maskSavesteps, ...
            'omitTrain', true, ...
            varargin{:});
end
end
