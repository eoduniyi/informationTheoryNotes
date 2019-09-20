%% Setup
close all; clear all; clc;
%% 1. Timing
file = 'thomas_cover_excerpt.txt';
f = fopen(file); % sn: Assumes file is in the same directory as this function atm.
% Collect ASCII codes
c = fread(f,inf,'uchar');
% Read message
message = char(c');
message = strtrim(message); % sn: not sure if I'm always going to need this...

% Get ASCII code counts
charcount = zeros(128,1);
for i = 1:128
    charcount(i) = sum(c==i);
end

% Get all the unique characters
alphabet = {};
for i = 1:length(message)
    alphabet{i} = message(i);
end
alphabet = unique(alphabet);

ta = @() LZ78_2018(charcount,alphabet,message);
LZ78_comptime1 = timeit(ta);

% Alternative
tb = @() sourceCodingAlgo(file,'LZ78');
SCA_comptime1 = timeit(tb);

hook1 = [LZ78_comptime1, SCA_comptime1];
%% 2. Timing
file = 'thomas_cover_excerpt.txt';
f = fopen(file); % sn: Assumes file is in the same directory as this function atm.
% Collect ASCII codes
c = fread(f,inf,'uchar');
% Read message
message = char(c');
message = strtrim(message); % sn: not sure if I'm always going to need this...

% Get ASCII code counts
charcount = zeros(128,1);
for i = 1:128
    charcount(i) = sum(c==i);
end

% Get all the unique characters
alphabet = {};
for i = 1:length(message)
    alphabet{i} = message(i);
end
alphabet = unique(alphabet);
ta = @() LZ78_2018(charcount,alphabet,message);
LZ78_comptime2 = timeit(ta);

% Alternative
tb = @() sourceCodingAlgo(file,'LZ78');
SCA_comptime2 = timeit(tb);

hook2 = [LZ78_comptime2, SCA_comptime2];
%% 3. Timing
file = 'childes1.txt';
f = fopen(file); % sn: Assumes file is in the same directory as this function atm.
% Collect ASCII codes
c = fread(f,inf,'uchar');
% Read message
message = char(c');
message = strtrim(message); % sn: not sure if I'm always going to need this...

% Get ASCII code counts
charcount = zeros(128,1);
for i = 1:128
    charcount(i) = sum(c==i);
end

% Get all the unique characters
alphabet = cell(1,length(message));
for i = 1:length(message)
    alphabet{i} = message(i);
end
alphabet = unique(alphabet); 
ta = @() LZ78_2018(charcount,alphabet,message);
LZ78_comptime3 = timeit(ta);

% Alternative
tb = @() sourceCodingAlgo(file,'LZ78');
SCA_comptime3 = timeit(tb);

hook3 = [LZ78_comptime3, SCA_comptime3];
%% 4. Timing
file = 'childes2.txt';
f = fopen(file); % sn: Assumes file is in the same directory as this function atm.
% Collect ASCII codes
c = fread(f,inf,'uchar');
% Read message
message = char(c');
message = strtrim(message); % sn: not sure if I'm always going to need this...

% Get ASCII code counts
charcount = zeros(128,1);
for i = 1:128
    charcount(i) = sum(c==i);
end

% Get all the unique characters
alphabet = {};
for i = 1:length(message)
    alphabet{i} = message(i);
end
alphabet = unique(alphabet);
ta = @() LZ78_2018(charcount,alphabet,message);
LZ78_comptime4 = timeit(ta);

% Alternative
tb = @() sourceCodingAlgo(file,'LZ78_2018');
SCA_comptime4 = timeit(tb);

hook4 = [LZ78_comptime4, SCA_comptime4];
%% 5. Timing
file = 'childes3.txt';
f = fopen(file); % sn: Assumes file is in the same directory as this function atm.
% Collect ASCII codes
c = fread(f,inf,'uchar');
% Read message
message = char(c');
message = strtrim(message); % sn: not sure if I'm always going to need this...

% Get ASCII code counts
charcount = zeros(128,1);
for i = 1:128
    charcount(i) = sum(c==i);
end

% Get all the unique characters
alphabet = {};
for i = 1:length(message)
    alphabet{i} = message(i);
end
alphabet = unique(alphabet);

ta = @() LZ78_2018(charcount,alphabet,message);
LZ78_comptime5 = timeit(ta);

% Alternative
tb = @() sourceCodingAlgo(file,'LZ78_2018');
SCA_comptime5 = timeit(tb);

hook5 = [LZ78_comptime5, SCA_comptime5];


