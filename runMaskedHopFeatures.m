function runMaskedHopFeatures(tExp, objectForRow, varargin)

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
maskedProvider = BipolarFeatures(0,featureProviderFactory.get(NamedFeatures('alexnet-fc7-masked')));
maskSavesteps = [1, 2, 4, 8, 16, 32, 64, 128, 256]; % = 2.^(0:8)

%% Run
%for tExp = -1:8
    if tExp == -1
        t = 0;
        normalProvider = BipolarFeatures(0, featureProviderFactory.get(AlexnetFc7Features()));
    else
        t = 2 ^ tExp;
        normalProvider = featureProviderFactory.get(NamedFeatures(sprintf('caffenet_relu7-bipolar0-hop_t%d', t)));
    end
    maxStep = 256 - t;
    savesteps = union(maskSavesteps(maskSavesteps < maxStep), [maxStep, 256]);
    
    summedFeatures = CombineFeatures(@sumFeatures, ...
        normalProvider, maskedProvider);
    hopExtractor = HopFeatures(max(maskSavesteps), summedFeatures, net);
    computeHopTimeFeatures(...
        'objectForRow', objectForRow, ...
        'trainDirectory', trainDir, 'testDirectory', testDir, ...
        'weightsDirectory', '.', ... % won't be used anyway
        'featureExtractor', hopExtractor, ...
        'savesteps', savesteps, ...
        'omitTrain', true, ...
        varargin{:});
%end
end

function f = sumFeatures(f1, f2)
f = sum(cat(3, f1, f2), 3);
end
