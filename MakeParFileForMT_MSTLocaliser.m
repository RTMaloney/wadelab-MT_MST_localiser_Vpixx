function MakeParFileForMT_MSTLocaliser

% Generate a .par file describing the timing in the block design for the MT/MST localiser.
% This is in tab-delimited text format, as expected by mrVista when setting up GLM parameters.
% This includes the labelling of all fixation/baseline blocks as 'Fix'
% This file removes the first fixation block (treats it as dummy TRs): they *must* be removed manually in the mrInit process.
% Only 1 file should be needed, since the localiser (should) be the same for all subjects.
%   R Maloney 23 May 2016, following MakeParFileForEoOLocaliser.m. 
%   Timing information for the localiser can be found in MT_MST_Localiser_Vpixx.m

%The file name to be saved:
parFileName = 'MT_MST_localiser_design_vista.par';

%Most of below comes directly from MT_MST_Localiser_Vpixx where the timing is determined.
%Set a bunch of variables important in determining the timing of stimuli:
numBlocks = 31; %31 blocks all up
BlockLengthTRs = 4; %number of TRs in an block
TR = 3; %length of volume (TR), in sec
BlockLengthSec = BlockLengthTRs * TR;

ScanLengthSec = BlockLengthSec*numBlocks; %should be 372

%Set up the block conditions:
%These provide the given condition for each block of the scan
motionBlockL = 1;
motionBlockR = 2;
staticBlock = 3;
motionBlockFF = 4; %full-field, coherent motion.
Fix = 0; %NOTE: In MrVista conventions, 'fixation' periods are always labelled as 'Fix' and given code 0

% fix | {motionL motionR static}! | fix  %% the 24 permutations of the 4 conditions are displayed, separated by fixation blocks
blockOrder = perms([motionBlockL motionBlockR staticBlock motionBlockFF])'; %the 24 possible permutations of the 4 conditions
blockOrder = blockOrder(:,1:6); % just take the first 6 of these permutations, whatever they are.
blockOrder = [blockOrder; zeros(1,6)]; %separate each of the perms with a fixation block
blockOrder = reshape(blockOrder,30,1);
%NOTE: in the stimulus presentation, we add a fixation block at the start. 
% We don't that that here, because we are treating the 1st fixation block as dummy scans.
%blockOrder = [Fix; blockOrder]; % add in a fixation at the start

%Determine the onset times for each BLOCK. 
% These onset times ignore the very first fixation block at the beginning, which we will effectively treat as 'dummy' scans.
%Ie the first is set as time 0, but really it is 4 TRs after the start of the scan, similar to the dummy TRs in EoO and MID designs.
%The first fixation block MUST be manually removed in mrVista at the start of the analysis.
%We want the onset times for each block only, so subtract the length of the first fixation block, and another block, so the final value is the ONSET time of the FINAL block
BlockOnsets = 0:BlockLengthSec:ScanLengthSec-BlockLengthSec-BlockLengthSec; %(ScanLengthSec = 372 is total length, in sec of scan, including the first fixation block).


%Now make a cell array containing the condition names as strings.
%This seems optional, but we will include it because the mrVista files seem to have it.
for ii = 1: length(blockOrder)
    
    switch blockOrder(ii)
        case Fix
            BlockName{ii} = 'Fix'
        case motionBlockL
            BlockName{ii} = 'motionBlockL'
        case motionBlockR
            BlockName{ii} = 'motionBlockR'
        case staticBlock
            BlockName{ii} = 'staticBlock'
        case motionBlockFF
            BlockName{ii} = 'motionBlockFF'
    end
end

%Now open and save the appropriate text file:
fileID = fopen(parFileName,'wt'); %open the file to be saved, 'w' for writing, 't' for text

%Set up the formatting for the file, this is the order of each item in each row of the file.
% 3.2f means fixed point notation, so up to 3 integer parts and 2 decimal places (for onset time)
% d means a signed integer  (for block code)
% s means a string          (for block/condition name)
% \t means separate by a horizontal tab 
% \n means go to a new line.
formatSpec = '%3.2f\t %d\t %s\t\n'; 

%loop across each line and add it to the file:
for ii = 1:length(blockOrder)
    
    fprintf(fileID, formatSpec, BlockOnsets(ii), blockOrder(ii), BlockName{ii});
    
end

fclose(fileID); %close the file when done. It should be saved in the pwd



