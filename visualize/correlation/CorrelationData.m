classdef CorrelationData
    
    properties
        presIds
        categoriesPres
        
        humanResults
        humanCorrect
        humanCorrectHalfs
        humanCorrectPerCategory
        humanCorrectHalfsPerCategory
        
        modelNames
        modelTimestepNames
        timesteps
        modelCorrect
        modelCorrectPerCategory
        
        humanHumanCorrelations
        modelHumanCorrelations
        humanHumanCorrelationsPerCategory
        modelHumanCorrelationsPerCategory
    end
    
    methods
        function obj = CorrelationData(presIds, categoriesPres, ...
                humanResults, humanCorrect, humanCorrectHalfs, ...
                humanCorrectPerCategory, humanCorrectHalfsPerCategory, ...
                modelNames, modelTimestepNames, timesteps, ...
                modelCorrect, modelCorrectPerCategory, ...
                humanHumanCorrelations, modelHumanCorrelations, ...
                humanHumanCorrelationsPerCategory, ...
                modelHumanCorrelationsPerCategory)
            obj.presIds = presIds;
            obj.categoriesPres = categoriesPres;
            
            obj.humanResults = humanResults;
            obj.humanCorrect = humanCorrect;
            obj.humanCorrectHalfs = humanCorrectHalfs;
            obj.humanCorrectPerCategory = humanCorrectPerCategory;
            obj.humanCorrectHalfsPerCategory = humanCorrectHalfsPerCategory;
            
            obj.modelNames = modelNames;
            obj.modelTimestepNames = modelTimestepNames;
            obj.timesteps = timesteps;
            obj.modelCorrect = modelCorrect;
            obj.modelCorrectPerCategory = modelCorrectPerCategory;
            
            obj.humanHumanCorrelations = humanHumanCorrelations;
            obj.modelHumanCorrelations = modelHumanCorrelations;
            obj.humanHumanCorrelationsPerCategory = ...
                humanHumanCorrelationsPerCategory;
            obj.modelHumanCorrelationsPerCategory = ...
                modelHumanCorrelationsPerCategory;
        end
        
    end
end    
