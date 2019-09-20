clear all;
clc;
%% Setup
f = fopen('text.txt');
% Collect ASCII codes
c = fread(f,inf,'uchar');
% Look at message
message = char(c');

% Create Look ahead buffer
lookAheadBuffer = transpose(message);

% Initialize Dictionary
dict = [];

% Clean up input string
for i = 1:length(lookAheadBuffer)
    if(strcmpi(char(32), lookAheadBuffer(i)) || strcmpi(char(10),lookAheadBuffer(i)))
        lookAheadBuffer(i) = regexprep(lookAheadBuffer(i), {char(32) char(10)}, '_');
    end
end

%% Encoding
disp('*** Encoding... ***');
timeElapsed = tic;
% Stream all characters
i = 1;
index = 1;
while(i <= length(lookAheadBuffer))
    compareString = lookAheadBuffer(i);
    searhBuffer = find(ismember(dict, compareString));
    if(~isempty(searhBuffer))     
        % Check for consecutive characters
        consecChars = 1;
        j = 1;
        while(consecChars && ((i+j-1) < length(lookAheadBuffer)))
            compareString = strcat(compareString, lookAheadBuffer(i+j));
            searhBuffer = find(ismember(dict, compareString),1);
            if(~isempty(searhBuffer))
                consecChars = 1;
                j = j+1;
            else
                consecChars = 0;
            end
        end             
        % Process the matched string
        streamInit = compareString(1:end-1);
        streamTail = compareString(end:end);
        streamTail = strcat('''', streamTail, '''');
        if((i+j-1) >= length(lookAheadBuffer))
            streamInit = compareString;
            % End of file
            streamTail = 'END';
        end        
        searhBuffer = find(ismember(dict, streamInit));
        code = ['(' num2str(searhBuffer) ', ' streamTail ')'];
    else
        code = ['(0, ' '''' compareString '''' ')'];     
    end   
    % Generate codebook
    if(~cellfun('isempty', {code}))
        codeBook{i} = code;
        dict{index} = compareString;
    end

    i = i + length(compareString);
    index = index + 1;
end
timeElapsed = toc;
disp('*** Encoding Finished! ***');
%% Generate codebook
% Not sure why I keep getting this error in my code...
% But w/e nerf all the empty cells
codeBook(:, any(cellfun(@isempty, codeBook), 1)) = [];
%% Space Saved & Compression Ratio
% Calculate Compression Ratio (Uncompressed/Compressed)
% bits = sum(cellfun('length',codeBook(index,2)));
% compressionRatio = length(c)*8/bits
% 
% % Calculate amount of space saved
% spaceSavin = 1 - compressionRatio^-1