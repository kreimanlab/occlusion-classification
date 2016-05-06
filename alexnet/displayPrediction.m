%Display the predicted image category.
%prob is a 1d vector (numOfPredictions x 1) with the probabilities for each
%image category.
function [ ] = displayPrediction( prob )
	one_top_prediction=find(prob==max(prob));
    fid=fopen('ressources/synset_words.txt');
    C = textscan(fid, '%s','delimiter', '\n');
    textLine=C{1}{one_top_prediction};
    whiteSpace=find(textLine==' ');
    textPrediction=textLine(whiteSpace(1)+1:end);
    msg=sprintf('PREDICTION: %s\n', textPrediction);
    disp(msg);
end
