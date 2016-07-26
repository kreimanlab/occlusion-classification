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
        
        humanHumanCorrelations
        modelHumanCorrelations
    end
    
    methods
        function obj = CorrelationData(presIds, ...
                humanResults, humanCorrect, humanCorrectHalfs, ...
                modelNames, modelTimestepNames, timesteps, ...
                modelCorrect, ...
                humanHumanCorrelations, modelHumanCorrelations)
            obj.presIds = presIds;
            
            obj.humanResults = humanResults;
            obj.humanCorrect = humanCorrect;
            obj.humanCorrectHalfs = humanCorrectHalfs;
            
            obj.modelNames = modelNames;
            obj.modelTimestepNames = modelTimestepNames;
            obj.timesteps = timesteps;
            obj.modelCorrect = modelCorrect;
            
            obj.humanHumanCorrelations = humanHumanCorrelations;
            obj.modelHumanCorrelations = modelHumanCorrelations;
        end
        
    end
end    
