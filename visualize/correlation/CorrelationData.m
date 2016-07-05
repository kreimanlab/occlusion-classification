classdef CorrelationData
    
    properties
        presIds
        
        humanResults
        humanCorrect
        humanCorrectHalfs
        
        modelNames
        modelTimestepNames
        timesteps
        modelCorrect
        
        humanHumanCorrelation
        modelHumanCorrelations
    end
    
    methods
        function obj = CorrelationData(presIds, ...
                humanResults, humanCorrect, humanCorrectHalfs, ...
                modelNames, modelTimestepNames, timesteps, ...
                modelCorrect, ...
                humanHumanCorrelation, modelHumanCorrelations)
            obj.presIds = presIds;
            
            obj.humanResults = humanResults;
            obj.humanCorrect = humanCorrect;
            obj.humanCorrectHalfs = humanCorrectHalfs;
            
            obj.modelNames = modelNames;
            obj.modelTimestepNames = modelTimestepNames;
            obj.timesteps = timesteps;
            obj.modelCorrect = modelCorrect;
            
            obj.humanHumanCorrelation = humanHumanCorrelation;
            obj.modelHumanCorrelations = modelHumanCorrelations;
        end
        
    end
end    
