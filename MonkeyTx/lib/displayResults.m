% displayResults is an external function called to give a live update of
% the current measured grid. It shows three perpindicular plains
% representing the 3-D volume.
% 
% Taylor Webb
% Fall 2019

function displayResults(RData)

persistent figHandle;
persistent data;

if ~exist('isSoniqConnected.m','file')
    addpath('C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\Aims\lib\soniq');
    addpath('C:\Users\Verasonics\Desktop\Taylor\Code\verasonics\Aims\lib')
end

Receive = evalin('base','Receive');
Resource = evalin('base','Resource');
% 

try
    figure(figHandle);
catch
    figHandle = figure;
    data = [];
end
clf;
grid = load(Resource.Parameters.gridInfoFile);
if isempty(data)
    data = zeros(size(grid.X));
end
if Resource.Parameters.saveDir(end) ~= '\' && Resource.Parameters.saveDir(end) ~= '/'
    Resource.Parameters.saveDir(end+1) = '\';
end
files = dir([Resource.Parameters.saveDir,Resource.Parameters.saveName,'*.snq']);
[~,idx] = sort([files.datenum]);
files = files(idx);
[~,wv] = readWaveform([Resource.Parameters.saveDir,files(end).name]);
data(length(files)) = max(wv);


subplot(221)
imagesc(grid.z,grid.x,squeeze(data(ceil(size(data,1)/2),:,:))');
xlabel('Y-Axis')
ylabel('X-Axis')
axis('equal')
axis('tight')

subplot(222)
imagesc(grid.y,grid.x,squeeze(data(:,ceil(size(data,2)/2),:)));
xlabel('X-Axis')
ylabel('Z-Axis')
axis('equal')
axis('tight')

subplot(223)
imagesc(grid.z,grid.y,squeeze(data(:,:,ceil(size(data,3)/2))));
xlabel('Y-Axis')
ylabel('Z-Axis')
axis('equal')
axis('tight')

if length(idx) == length(grid.X(:))
    disp('Attempting to close VSX')
    VSXquit;
    VsClose;
    return
end