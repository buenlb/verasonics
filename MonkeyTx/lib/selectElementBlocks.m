% selectElementBlocks selects blocks of elements that are nxn in size where
% n is given by n. The code currently assumes the 8x32 element 
% macaque array
% 
% @INPUTS
%   n: specifies the length in elements of one side of the block
%       of elements to be selected
% 
% @OUTPUTS
%   elements: a cell structure with each element representing the list of
%       elements from each block. The blocks are numbered in order by the
%       center element (rounded down if no Elements is even)
% 
% Taylor Webb
% University of UTah
% January 2020

function elements = selectElementBlocks(n,txSn)
if ~exist('txSn','var')
	warning('Serial number not passed to griddedElementBModeImage, assuming JAB800');
	txSn = 'JAB800';
end
switch txSn
	case 'JAB800'
		elements = cell((32-(n-1))*(8-(n-1)),1);
		centerEl = zeros(size(elements));
		blockIdx = 1;
		if mod(n,2)
			for ii = 1:32-(n-1)
				for jj = 1:8-(n-1)
					xEl = ii+floor(n/2);
					yEl = jj+floor(n/2);
					centerEl(blockIdx) = yEl+8*(xEl-1);
					curBlock = zeros(n^2,1);
					curY = (yEl-floor(n/2)):(yEl+floor(n/2));
					for kk = 1:n
						curX = xEl-floor(n/2)+kk-1;
						curBlock(((kk-1)*n+1):(kk*n)) = (curX-1)*8+curY;
					end
					elements{blockIdx} = curBlock;
					blockIdx = blockIdx+1;
				end
			end
		else
			error('Haven''t yet implemented the even case!')
		end
	case 'IHG989'
		nx = 32;
		ny = 8;
		elements = cell((nx-(n-1))*(ny-(n-1)),1);
		centerEl = zeros(size(elements));
		blockIdx = 1;
		if mod(n,2)
			for ii = 1:nx-(n-1)
				for jj = 1:ny-(n-1)
					xEl = ii+floor(n/2);
					yEl = jj+floor(n/2);
					centerEl(blockIdx) = yEl+ny*(xEl-1);
					curBlock = zeros(n^2,1);
					curY = (yEl-floor(n/2)):(yEl+floor(n/2));
					for kk = 1:n
						curX = xEl-floor(n/2)+kk-1;
						curBlock(((kk-1)*n+1):(kk*n)) = (curX-1)*ny+curY;
					end
					elements{blockIdx} = curBlock;
					blockIdx = blockIdx+1;
				end
			end
		else
			error('Haven''t yet implemented the even case!')
		end
	case 'JEC482'
		nx = 43;
		ny = 6;
		elements = cell((nx-(n-1))*(ny-(n-1))-2,1);
		centerEl = zeros(size(elements));
		blockIdx = 1;
		if mod(n,2)
			for ii = 1:nx-(n-1)
				for jj = 1:ny-(n-1)
					xEl = ii+floor(n/2);
					yEl = jj+floor(n/2);
					centerEl(blockIdx) = yEl+ny*(xEl-1);
					curBlock = zeros(n^2,1);
					curY = (yEl-floor(n/2)):(yEl+floor(n/2));
					for kk = 1:n
						curX = xEl-floor(n/2)+kk-1;
						curBlock(((kk-1)*n+1):(kk*n)) = (curX-1)*ny+curY;
                    end
                    if ismember(257,curBlock) || ismember(258,curBlock)
                        continue
                    end
					elements{blockIdx} = curBlock;
					blockIdx = blockIdx+1;
				end
			end
		else
			error('Haven''t yet implemented the even case!')
		end
	otherwise
		error(['Unrecognized Serial Number: ', txSn])
end