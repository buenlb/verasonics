function [xAx,yAx,zAx,xDir,yDir,zDir,res] =  assignTxAxes(hdr)

imgOrientation = hdr.ImageOrientationPatient;

if sum(abs(imgOrientation(1:3)) ~= 1)
    warning('Oblique Image!')
    [~,mrRow] = max(abs(imgOrientation(1:3)));
    [~,mrCol] = max(abs(imgOrientation(4:6)));
    
    tmp = zeros(size(imgOrientation));
    tmp(mrRow) = sign(imgOrientation(mrRow))*1;
    tmp(mrCol+3) = sign(imgOrientation(mrCol+3))*1;
    imgOrientation = tmp;
end

position = hdr.PatientPosition;

xAx = 0;
yAx = 0;
zAx = 0;

switch position
    case 'HFP'
        [~,mrRow] = max(abs(imgOrientation(1:3)));
        [~,mrCol] = max(abs(imgOrientation(4:6)));
        
        % Identify which axis is the row axis
        if mrRow == 1
            xAx = 2;
            if imgOrientation(mrRow) < 0
                xDir = -1;
            else
                xDir = 1;
            end
        elseif mrRow == 2
            zAx = 2;
            if imgOrientation(mrRow) < 0
                zDir = 1;
            else
                zDir = -1;
            end
        else
            yAx = 2;
            if imgOrientation(mrRow) < 0
                yDir = 1;
            else
                yDir = -1;
            end
        end
        
        % Identify which axis is the column axis
        if mrCol == 1
            xAx = 1;
            if imgOrientation(mrCol+3) < 0
                xDir = -1;
            else
                xDir = 1;
            end
        elseif mrCol == 2
            zAx = 1;
            if imgOrientation(mrCol+3) < 0
                zDir = 1;
            else
                zDir = -1;
            end
        else
            yAx = 1;
            if imgOrientation(mrCol+3) < 0
                zDir = 1;
            else
                zDir = -1;
            end
        end
        if xAx == 0
            for ii = 1:3
                if ~ismember(ii,[yAx,zAx])
                    xAx = ii;
                    break
                end
            end
            xDir = -sign(imgOrientation(yAx))*sign(imgOrientation(zAx));
        elseif yAx == 0
            for ii = 1:3
                if ~ismember(ii,[xAx,zAx])
                    yAx = ii;
                    break
                end
            end
            yDir = -sign(imgOrientation(xAx))*sign(imgOrientation(zAx));
        else
            for ii = 1:3
                if ~ismember(ii,[yAx,xAx])
                    zAx = ii;
                    break
                end
            end
            zDir = -sign(imgOrientation(yAx))*sign(imgOrientation(xAx));
        end
        
        res(1) = hdr.PixelSpacing(1);
        if isfield(hdr,'SpacingBetweenSlices')
            res(2) = hdr.SpacingBetweenSlices;
        else
            res(2) = hdr.SliceThickness;
        end
        res(3) = hdr.PixelSpacing(2);
    otherwise
        error(['Patient Position ', position, ' not recognized/implemented'])
end

    