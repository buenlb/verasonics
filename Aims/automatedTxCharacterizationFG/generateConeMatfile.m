%generateConeMatfile

% Cone Properties
name = 'none';
edgeCone = 0;





% Error checks and saving information
FileLocation = 'C:\Users\Verasonics\Box Sync\TransducerCharacterizations\Cone Files';
cd(FileLocation);

coneName = strrep(name,'-','_');
coneName = strrep(coneName,' ','_');

if coneName(1) == '_' || coneName(end) == '_'
    error('Cone name invalid for saving.')
else
    save(coneName,'name','edgeCone');
end