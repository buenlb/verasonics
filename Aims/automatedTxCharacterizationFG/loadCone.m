function Tx = loadCone(Tx,coneName)

FileLocation = 'C:\Users\Verasonics\Box Sync\TransducerCharacterizations\Cone Files';


coneName = strrep(coneName,'-','_');
coneName = strrep(coneName,' ','_');

if coneName(1) == '_' ||  coneName(end) == '_'
    error('Invalid cone name.')
end


try load([FileLocation,'/',coneName]);
    Tx.cone     = name;
    Tx.coneEdge = edgeCone;
catch
    what(FileLocation)
    disp(' ');
    error(['Could not find file. Attempted to search for: ',coneName]);
end
