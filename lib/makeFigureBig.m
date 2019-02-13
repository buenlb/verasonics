% makeFigureBig(h,fontSize,axisFontSize) sets the background of the figure
% h to white and updates the text to size fontSize and the axis text to 
% size axisFontSize. If fontSize is not specified then it defaults to 18,
% if axisFontSize is not specified then it defaults to fontSize.

function makeFigureBig(h,fontSize,axisFontSize,bgColor)
if nargin < 2
    fontSize = 18;
end
if nargin < 3
    axisFontSize = fontSize;
end
if nargin < 4
    bgColor = 'w';
end
set(findall(h,'type','text'),'fontSize',fontSize)
% set(findall(h,'type','text'),'color','k')
set(gcf,'color',bgColor)
set(gca,'fontsize',axisFontSize)